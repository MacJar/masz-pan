 # REST API Plan

 ## 1. Resources

 - profiles → table: profiles (RLS enabled)
 - publicProfiles → view: public_profiles (limited public fields)
 - tools → table: tools (RLS enabled)
 - toolImages → table: tool_images (RLS enabled)
 - reservations → table: reservations (RLS enabled)
 - tokenLedger → table: token_ledger (insert-only, RLS enabled)
 - balances → view: balances (aggregated token balances)
 - awardEvents → table: award_events (RLS enabled)
 - rescueClaims → table: rescue_claims (RLS enabled)
 - ratings → table: ratings (RLS enabled)
 - auditLog → table: audit_log (RLS enabled; primarily internal/service reads)
 - rpc/business functions (SECURITY DEFINER):
   - publish_tool(tool_id)
   - get_counterparty_contact(reservation_id)
   - reservation_transition(reservation_id, new_status, price_tokens?)
   - award_signup_bonus(user_id)
   - award_listing_bonus(user_id, tool_id)
   - claim_rescue_token(user_id)

 Notes
 - ENUMs: reservation_status, tool_status, ledger_kind, award_kind
 - Spatial: profiles.location_geog (GIST index) used for 10 km queries
 - Search: tools.search_name_tsv (GIN index); trigger-maintained FTS
 - Unique constraints surfaced as 409 Conflict in API
 - Insert-only tables enforced via DB triggers; API maps prohibited updates to 405/403

 ## 2. Endpoints

 Conventions
 - Base URL: /api
 - Pagination: cursor (opaque) and limit (default 20, max 100)
 - Errors: JSON { error: { code, message, details? } }
 - Idempotency: optional Idempotency-Key header for state transitions and awards
 - All write endpoints require authentication unless explicitly stated

 ### 2.1 Auth & Session (integration with Supabase Auth)

 - GET /api/auth/user
   - Description: Return current user session and own profile (if exists)
   - Query: none
   - Response:
 ```json
 {
   "user": { "id": "uuid", "email": "string" },
   "profile": {
     "id": "uuid",
     "username": "string",
     "location_text": "string|null",
     "rodo_consent": true,
     "created_at": "timestamptz",
     "updated_at": "timestamptz"
   }
 }
 ```
   - 200 OK | 401 Unauthorized

 ### 2.2 Profiles

 - GET /api/profile
   - Description: Get authenticated user's profile
   - Response: profile object as above
   - 200 | 401 | 404 (no profile yet)

 - PUT /api/profile
   - Description: Create/update own profile; triggers geocoding if location_text changed
   - Request:
 ```json
 {
   "username": "string",
   "location_text": "string",
   "rodo_consent": true
 }
 ```
   - Response: profile
   - 200 | 201 | 400 (invalid) | 401 | 409 (username taken)

 - POST /api/profile/geocode
   - Description: Force geocoding and persist location_geog from location_text
   - Response:
 ```json
 { "location_geog": { "type": "Point", "coordinates": [lon, lat] } }
 ```
   - 200 | 400 (bad location) | 401 | 422 (geocoder failure)

 - GET /api/profiles/:id/public
   - Description: Public read-only profile with rating summary
   - Response:
 ```json
 { "id": "uuid", "username": "string", "location_text": "string|null", "avg_rating": 4.5, "ratings_count": 10 }
 ```
   - 200 | 404

 Validation
 - username non-empty, unique (409 on conflict)
 - rodo_consent required for contact reveal logic

 ### 2.3 Tools

 - POST /api/tools
   - Description: Create a tool (draft by default)
   - Request:
 ```json
 { "name": "string", "description": "string|null", "suggested_price_tokens": 1 }
 ```
   - Response:
 ```json
 { "id": "uuid", "owner_id": "uuid", "name": "string", "description": "string|null", "suggested_price_tokens": 1, "status": "draft", "created_at": "timestamptz" }
 ```
   - 201 | 400 | 401 | 422 (price out of range)

 - GET /api/tools/:id
   - Description: Get tool by id; public if active or owner-only otherwise
   - Response: tool with images (ordered by position)
   - 200 | 401 (owner-only draft) | 404

 - PATCH /api/tools/:id
   - Description: Update own tool (not status to active directly)
   - Request: partial fields { name?, description?, suggested_price_tokens? }
   - Response: updated tool
   - 200 | 400 | 401 | 403 (not owner) | 422

 - DELETE /api/tools/:id
   - Description: Soft-archive tool (set status="archived" and archived_at)
   - Response: { archived: true, archived_at: "timestamptz" }
   - 200 | 401 | 403 | 409 (active reservations prevent archive)

 - POST /api/tools/:id/publish
   - Description: Publish tool (enforces at least one image, status transitions)
   - Response: tool with status="active"
   - 200 | 401 | 403 | 409 (no image) | 422 (invalid state)

 - GET /api/tools
   - Description: List tools (owner filter and/or status)
   - Query: owner_id?, status? (draft|inactive|active|archived), cursor?, limit?
   - Response:
 ```json
 { "items": [ { "id": "uuid", "name": "string", "status": "active" } ], "next_cursor": "opaque|null" }
 ```
   - 200

 - GET /api/tools/search
   - Description: Search active tools by text within 10 km of caller's profile location; sorted by distance
   - Query: q (text, required), cursor?, limit?
   - Response:
 ```json
 { "items": [ { "id": "uuid", "name": "string", "distance_m": 1234 } ], "next_cursor": "opaque|null" }
 ```
   - 200 | 401 (if profile required) | 400 (missing location)

 Validation
 - suggested_price_tokens ∈ [1,5]
 - status changes to active only via publish endpoint

 ### 2.4 Tool Images & Storage

 - POST /api/tools/:id/images/upload-url
   - Description: Issue a signed upload URL for client to PUT the image to Storage
   - Request:
 ```json
 { "content_type": "image/jpeg", "size_bytes": 123456 }
 ```
   - Response:
 ```json
 { "upload_url": "https://...", "headers": {"x-upsert": "true"}, "storage_key": "tools/<tool_id>/<uuid>.jpg" }
 ```
   - 200 | 401 | 403 | 413 (too large) | 415 (unsupported type)

 - POST /api/tools/:id/images
   - Description: Create image record after successful upload
   - Request:
 ```json
 { "storage_key": "tools/<tool_id>/<uuid>.jpg", "position": 0 }
 ```
   - Response: { "id": "uuid", "tool_id": "uuid", "storage_key": "string", "position": 0 }
   - 201 | 401 | 403 | 409 (unique position conflict)

 - GET /api/tools/:id/images
   - Description: List images for a tool; public if tool active or owner otherwise
   - Response: [image]
   - 200 | 401 | 403

 - DELETE /api/tools/:id/images/:imageId
   - Description: Delete image record (and optionally Storage object)
   - Response: { "deleted": true }
   - 200 | 401 | 403 | 404

 ### 2.5 Reservations

 - POST /api/reservations
   - Description: Create reservation request by borrower
   - Request:
 ```json
 { "tool_id": "uuid", "owner_id": "uuid" }
 ```
   - Response:
 ```json
 { "id": "uuid", "status": "requested", "tool_id": "uuid", "owner_id": "uuid", "borrower_id": "uuid", "created_at": "timestamptz" }
 ```
   - 201 | 400 | 401 | 403 | 409 (active reservation exists for tool)

 - GET /api/reservations/:id
   - Description: Get reservation (owner or borrower only)
   - Response: reservation with minimal joined tool info
   - 200 | 401 | 403 | 404

 - GET /api/reservations
   - Description: List own reservations
   - Query: role=borrow|owner (required), status? (multi allowed), cursor?, limit?
   - Response:
 ```json
 { "items": [ { "id": "uuid", "status": "requested" } ], "next_cursor": "opaque|null" }
 ```
   - 200 | 401

 - POST /api/reservations/:id/transition
   - Description: State transition via DB function (accept with price, confirm, picked_up, returned, cancel/reject)
   - Headers: Idempotency-Key? (recommended)
   - Request:
 ```json
 { "new_status": "owner_accepted", "price_tokens": 5 }
 ```
   - Response: updated reservation and ledger effects summary
 ```json
 { "reservation": { "id": "uuid", "status": "owner_accepted", "agreed_price_tokens": 5 }, "ledger": { "hold": null, "transfer": null } }
 ```
   - 200 | 401 | 403 | 409 (invalid transition) | 422 (insufficient tokens or validation)

 - POST /api/reservations/:id/cancel
   - Description: Convenience wrapper to transition to cancelled and release holds
   - Response: reservation
   - 200 | 401 | 403 | 409 | 422

 - GET /api/reservations/:id/contacts
   - Description: Reveal counterpart emails after mutual confirmation
   - Response:
 ```json
 { "owner_email": "string", "borrower_email": "string" }
 ```
   - 200 | 401 | 403 | 409 (not yet confirmed)

 Validation
 - owner_id must equal tool.owner_id (enforced by trigger)
 - borrower_id ≠ owner_id
 - Unique active reservation per tool enforced (partial unique index)

 ### 2.6 Tokens: Balances & Ledger

 - GET /api/tokens/balance
   - Description: Get own token balances (total, held, available)
   - Response:
 ```json
 { "user_id": "uuid", "total": 10, "held": 0, "available": 10 }
 ```
   - 200 | 401

 - GET /api/tokens/ledger
   - Description: List own ledger entries
   - Query: kind? (debit|credit|hold|release|transfer|award), cursor?, limit?
   - Response:
 ```json
 { "items": [ { "id": "uuid", "kind": "award", "amount": 2, "details": {} } ], "next_cursor": "opaque|null" }
 ```
   - 200 | 401

 - POST /api/tokens/award/signup
   - Description: Grant one-time signup bonus
   - Response: { "awarded": true, "amount": 10 }
   - 200 | 401 | 409 (already awarded)

 - POST /api/tokens/award/listing
   - Description: Grant listing bonus for a tool (max first 3)
   - Request: { "tool_id": "uuid" }
   - Response: { "awarded": true, "amount": 2, "count_used": 1 }
   - 200 | 401 | 409 (limit reached or already awarded for tool)

 - POST /api/tokens/rescue
   - Description: Claim +1 daily when available==0 (CET day uniqueness)
   - Response: { "awarded": true, "amount": 1, "claim_date_cet": "YYYY-MM-DD" }
   - 200 | 401 | 409 (already claimed today) | 422 (available > 0)

 Notes
 - token_ledger is insert-only; API never updates/deletes entries

 ### 2.7 Ratings

 - POST /api/ratings
   - Description: Create rating (1–5) after reservation returned
   - Request:
 ```json
 { "reservation_id": "uuid", "stars": 5 }
 ```
   - Response:
 ```json
 { "id": "uuid", "reservation_id": "uuid", "rater_id": "uuid", "rated_user_id": "uuid", "stars": 5, "created_at": "timestamptz" }
 ```
   - 201 | 401 | 403 | 409 (duplicate) | 422 (stars out of range or reservation not eligible)

 - GET /api/users/:id/ratings/summary
   - Description: Get aggregate rating for a user (from materialized view if available)
   - Response: { "rated_user_id": "uuid", "avg_stars": 4.5, "ratings_count": 12 }
   - 200 | 404

 ### 2.8 Audit Log (limited)

 - GET /api/audit
   - Description: List own audit events (actor_id==auth.uid())
   - Query: event_type?, since?, cursor?, limit?
   - Response:
 ```json
 { "items": [ { "id": "uuid", "event_type": "contact_reveal", "details": {}, "created_at": "timestamptz" } ], "next_cursor": "opaque|null" }
 ```
   - 200 | 401

 ### 2.9 AI Helper (OpenRouter)

 - POST /api/ai/describe-tool
   - Description: Generate suggested description from name (non-blocking for create)
   - Request: { "name": "string" }
   - Response: { "suggestion": "string" }
   - 200 | 422 (timeout or model error) — UI must not block tool creation

 ## 3. Authentication and Authorization

 Mechanism
 - Supabase Auth (JWT) with cookies for browser; API reads Authorization: Bearer <token> or server-side cookies via Supabase client
 - RLS as primary enforcement at DB layer across all tables
 - Public reads limited to active tools and public profile view

 Authorization Rules (API layer mirrors/enhances RLS)
 - Profiles: user can read/write only own profile; public read via view
 - Tools: anyone can read active tools; only owner may create/update/archive/publish
 - Tool images: only owner can manage; public read for active tools’ images
 - Reservations: only owner or borrower can read; borrower creates; transitions enforced via function
 - Token ledger/balances: only owner reads own; writes only through DB functions
 - Awards/rescue: only self; server calls SECURITY DEFINER functions
 - Ratings: rater creates exactly one per reservation; reads limited by RLS
 - Audit log: self reads own events; writes via functions

 Rate Limiting & Abuse Protection
 - Global: 60 requests/min per IP, 30 state-changing requests/min per user id
 - Sensitive endpoints stricter: transitions/awards/rescue 10/min per user (Idempotency-Key honored)
 - Upload URLs: 10/min per tool, enforce content-type and size limits

 ## 4. Validation and Business Logic

 Validation by Resource (API-level, mapped to DB constraints)
 - profiles
   - username: non-empty; unique (409 on conflict)
   - location_text: optional but required for search; geocode must succeed (422) to enable proximity features
   - rodo_consent: boolean required when creating profile
 - tools
   - name: required; non-empty
   - suggested_price_tokens: integer 1–5 (422)
   - publish requires ≥1 image; status transitions outside publish forbidden (409)
 - tool_images
   - storage_key: required; must belong to tool owner (403)
   - position: non-negative; unique per tool (409)
 - reservations
   - borrower_id is caller; borrower_id ≠ owner_id (422)
   - owner_id must match tool.owner_id (409)
   - one active reservation per tool (409)
   - direct status updates forbidden; use transition endpoint only
 - tokens / ledger
   - no direct writes; only via reservation_transition / award_* / claim_rescue_token
 - awards
   - signup: once per user (409)
   - listing: +2 for first 3 tools; one per tool (409)
 - rescue
   - only when available == 0; once per CET day (409/422)
 - ratings
   - stars: integer 1–5 (422)
   - one per (reservation_id, rater_id) (409)
   - allowed only if reservation.status == returned (409/422)

 Business Logic Mapping (DB-driven)
 - publish_tool(tool_id): invoked by POST /api/tools/:id/publish
 - reservation_transition(...): invoked by POST /api/reservations/:id/transition
   - handles: owner_accepted (sets agreed_price_tokens), borrower_confirmed, picked_up (creates hold), returned (transfers), cancelled/rejected (releases holds)
   - serializable transaction + advisory locks on reservation_id
 - get_counterparty_contact(reservation_id): invoked by GET /api/reservations/:id/contacts; writes audit_log
 - award_signup_bonus(user_id), award_listing_bonus(user_id, tool_id): invoked by award endpoints
 - claim_rescue_token(user_id): invoked by POST /api/tokens/rescue; uses CET date uniqueness

 Pagination, Filtering, Sorting
 - cursor: opaque base64 token containing last (created_at, id) tuple; stable sort primarily by created_at desc (except /tools/search sorted by ST_Distance asc then created_at desc)
 - limit: default 20, max 100; reject >100 with 400
 - filtering: status enums, role, kind, event_type, tool owner_id; multi-status allowed via repeated query params (status=...)

 Error Model
 - 400 Bad Request: malformed input, unsupported params, limit too large
 - 401 Unauthorized: missing/invalid auth
 - 403 Forbidden: RLS denied or not owner/party
 - 404 Not Found: resource absent or not visible due to RLS
 - 405 Method Not Allowed: attempted disallowed method (e.g., ledger update)
 - 409 Conflict: unique/constraint violation, invalid state transition, already awarded/claimed
 - 413 Payload Too Large: upload size exceeded
 - 415 Unsupported Media Type: image content-type invalid
 - 422 Unprocessable Entity: validation failed (price range, stars range, geocode failure, insufficient balance)
 - 429 Too Many Requests: rate limits

 Security Considerations
 - Enforce content-type and size checks for upload URLs; randomized storage keys per tool
 - Never expose emails except via contacts endpoint after confirmation
 - All state changes are DB-transactional via SECURITY DEFINER functions
 - Log contact reveals and failed transition attempts into audit_log (via DB)

 Implementation Notes (Astro 5 + Supabase)
 - Endpoints under src/pages/api/
 - Use Supabase server client bound to request cookies for RLS-context queries
 - For public reads: call with anon key and no auth; DB RLS restricts rows
 - Geocoding: server-side function with timeout, rate limit, and caching; persist location_geog
 - Search: use to_tsvector('polish'|'simple') with tools.search_name_tsv and ST_DWithin(profile.location_geog, tool.owner.location, 10000); order by ST_Distance

 Sample Responses (abbreviated)
 - Error
 ```json
 { "error": { "code": "validation_error", "message": "suggested_price_tokens must be between 1 and 5" } }
 ```
 - Cursor pagination
 ```json
 { "items": [/* ... */], "next_cursor": "eyJsYXN0Q3JlYXRlZEF0IjoiMjAyNS0xMS0wN1QwOTowMDowMFoiLCJsYXN0SWQiOiIuLi4ifQ==" }
 ```

 Non-Goals / Out of Scope (MVP)
 - Admin endpoints (use direct DB for ops)
 - Monetary payments (tokens only)
 - Chat/comments


