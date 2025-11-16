SET session_replication_role = replica;

--
-- PostgreSQL database dump
--

-- \restrict Lb0YZ537vydZno93t9kmOAkVRezr9fVBtm6szpa49o55VltUHWdEgfQeonXTvhA

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Data for Name: audit_log_entries; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES
	('00000000-0000-0000-0000-000000000000', '763d8e81-2222-4679-8846-5bf350eb9202', '{"action":"user_signedup","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"provider":"email","user_email":"maciej@yarla.com","user_id":"3973b11e-118a-4933-b752-f78cc7469daf","user_phone":""}}', '2025-11-07 14:26:36.770021+00', ''),
	('00000000-0000-0000-0000-000000000000', '57afec7e-4732-485a-93fe-6337d43408ee', '{"action":"user_recovery_requested","actor_id":"3973b11e-118a-4933-b752-f78cc7469daf","actor_username":"maciej@yarla.com","actor_via_sso":false,"log_type":"user"}', '2025-11-07 14:26:43.971363+00', ''),
	('00000000-0000-0000-0000-000000000000', '4d320450-d935-4859-8c6a-fbb3d3ee4fe0', '{"action":"login","actor_id":"3973b11e-118a-4933-b752-f78cc7469daf","actor_username":"maciej@yarla.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-11-07 14:27:15.400816+00', ''),
	('00000000-0000-0000-0000-000000000000', 'f7f0d78c-1719-4d6d-b82f-5ccad6e58f99', '{"action":"login","actor_id":"3973b11e-118a-4933-b752-f78cc7469daf","actor_username":"maciej@yarla.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-11-07 14:28:15.917561+00', ''),
	('00000000-0000-0000-0000-000000000000', '3f544dd4-81d8-4c8b-a00b-5f988d362980', '{"action":"login","actor_id":"3973b11e-118a-4933-b752-f78cc7469daf","actor_username":"maciej@yarla.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-11-07 14:28:17.700784+00', ''),
	('00000000-0000-0000-0000-000000000000', '540fe2ae-e9a0-4386-b462-b77ffe224e8c', '{"action":"login","actor_id":"3973b11e-118a-4933-b752-f78cc7469daf","actor_username":"maciej@yarla.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-11-07 14:28:19.418697+00', ''),
	('00000000-0000-0000-0000-000000000000', '0f17c48f-5e0e-4d58-b4c7-a062e2eb16c1', '{"action":"login","actor_id":"3973b11e-118a-4933-b752-f78cc7469daf","actor_username":"maciej@yarla.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-11-07 14:29:33.159968+00', ''),
	('00000000-0000-0000-0000-000000000000', 'c48d13f0-af27-409e-8342-859466e6ddc9', '{"action":"login","actor_id":"3973b11e-118a-4933-b752-f78cc7469daf","actor_username":"maciej@yarla.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-11-07 14:30:33.131749+00', ''),
	('00000000-0000-0000-0000-000000000000', '1c9a1417-b1f3-46d6-98c5-6f60e6517150', '{"action":"login","actor_id":"3973b11e-118a-4933-b752-f78cc7469daf","actor_username":"maciej@yarla.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-11-07 14:33:42.716737+00', ''),
	('00000000-0000-0000-0000-000000000000', '98738bf5-d095-4db3-a498-7e76712f7a97', '{"action":"token_refreshed","actor_id":"3973b11e-118a-4933-b752-f78cc7469daf","actor_username":"maciej@yarla.com","actor_via_sso":false,"log_type":"token"}', '2025-11-07 14:33:57.276459+00', ''),
	('00000000-0000-0000-0000-000000000000', '34dbdc1b-141d-4815-9dbd-32a4996ccd6a', '{"action":"token_revoked","actor_id":"3973b11e-118a-4933-b752-f78cc7469daf","actor_username":"maciej@yarla.com","actor_via_sso":false,"log_type":"token"}', '2025-11-07 14:33:57.276845+00', ''),
	('00000000-0000-0000-0000-000000000000', '8713288e-d9fb-40ad-bfb2-1e47680f4db5', '{"action":"token_refreshed","actor_id":"3973b11e-118a-4933-b752-f78cc7469daf","actor_username":"maciej@yarla.com","actor_via_sso":false,"log_type":"token"}', '2025-11-07 14:33:59.927544+00', ''),
	('00000000-0000-0000-0000-000000000000', '9fae2851-6de7-4f32-bc09-6a5b272413df', '{"action":"token_refreshed","actor_id":"3973b11e-118a-4933-b752-f78cc7469daf","actor_username":"maciej@yarla.com","actor_via_sso":false,"log_type":"token"}', '2025-11-07 14:34:01.498917+00', ''),
	('00000000-0000-0000-0000-000000000000', '3faf0b10-ddb2-405a-90f8-1b073e66e7db', '{"action":"token_refreshed","actor_id":"3973b11e-118a-4933-b752-f78cc7469daf","actor_username":"maciej@yarla.com","actor_via_sso":false,"log_type":"token"}', '2025-11-07 14:34:39.327562+00', ''),
	('00000000-0000-0000-0000-000000000000', '6a835002-5ba0-4e53-9b9f-881e26257b05', '{"action":"token_refreshed","actor_id":"3973b11e-118a-4933-b752-f78cc7469daf","actor_username":"maciej@yarla.com","actor_via_sso":false,"log_type":"token"}', '2025-11-07 14:35:20.060206+00', ''),
	('00000000-0000-0000-0000-000000000000', 'c5af2e18-a868-4986-af99-2264d4421b8f', '{"action":"token_refreshed","actor_id":"3973b11e-118a-4933-b752-f78cc7469daf","actor_username":"maciej@yarla.com","actor_via_sso":false,"log_type":"token"}', '2025-11-07 14:36:08.900148+00', ''),
	('00000000-0000-0000-0000-000000000000', 'b65b4514-5df7-4f21-8b7e-26f84be54e29', '{"action":"token_refreshed","actor_id":"3973b11e-118a-4933-b752-f78cc7469daf","actor_username":"maciej@yarla.com","actor_via_sso":false,"log_type":"token"}', '2025-11-07 14:36:10.626592+00', ''),
	('00000000-0000-0000-0000-000000000000', '002a7e50-3f65-410b-b683-2f9a2c3dfda6', '{"action":"token_refreshed","actor_id":"3973b11e-118a-4933-b752-f78cc7469daf","actor_username":"maciej@yarla.com","actor_via_sso":false,"log_type":"token"}', '2025-11-07 14:41:32.375048+00', ''),
	('00000000-0000-0000-0000-000000000000', '2ae32349-2054-461e-9d92-530a94f1c24f', '{"action":"user_signedup","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"provider":"email","user_email":"romek@maszpan.pl","user_id":"1f587053-c01e-4aa6-8931-33567ca6a080","user_phone":""}}', '2025-11-07 15:21:06.557244+00', ''),
	('00000000-0000-0000-0000-000000000000', '10057203-3630-4346-8ae7-1bd26f76a6f4', '{"action":"user_signedup","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"provider":"email","user_email":"atomek@maszpan.pl","user_id":"0fc43071-195f-445a-ac6c-80319d362d66","user_phone":""}}', '2025-11-07 15:21:21.927935+00', ''),
	('00000000-0000-0000-0000-000000000000', 'c9703a00-e5c8-4556-8660-876a5dfcb52d', '{"action":"user_signedup","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"provider":"email","user_email":"tytus@maszpan.pl","user_id":"b79685eb-78d6-46de-96d5-a8325b4ca05d","user_phone":""}}', '2025-11-07 15:21:36.58127+00', ''),
	('00000000-0000-0000-0000-000000000000', '653f09d8-005f-4dd1-a2e8-1dec3aedc2b2', '{"action":"user_repeated_signup","actor_id":"3973b11e-118a-4933-b752-f78cc7469daf","actor_username":"maciej@yarla.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}', '2025-11-15 21:39:27.292869+00', ''),
	('00000000-0000-0000-0000-000000000000', 'b4c7d4a1-15f4-460b-a595-360aaa3033b3', '{"action":"user_signedup","actor_id":"c75465ea-25bc-4991-a4da-b309601005bf","actor_username":"wwwwwwww@yarla.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}', '2025-11-15 21:39:34.45006+00', ''),
	('00000000-0000-0000-0000-000000000000', '4ab9bcf6-7192-4f17-905f-bb960c035d16', '{"action":"login","actor_id":"c75465ea-25bc-4991-a4da-b309601005bf","actor_username":"wwwwwwww@yarla.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-11-15 21:39:34.45389+00', ''),
	('00000000-0000-0000-0000-000000000000', '00e264d3-42bc-4c2b-9e24-2a8cedfdaf75', '{"action":"logout","actor_id":"c75465ea-25bc-4991-a4da-b309601005bf","actor_username":"wwwwwwww@yarla.com","actor_via_sso":false,"log_type":"account"}', '2025-11-15 21:39:49.520283+00', ''),
	('00000000-0000-0000-0000-000000000000', '71abcd42-ecd6-4197-bae1-503073924837', '{"action":"user_signedup","actor_id":"78c9fdb7-7e0c-404e-abe9-14533b7737f7","actor_username":"maciej.jarlaczynski@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}', '2025-11-15 21:40:21.351996+00', ''),
	('00000000-0000-0000-0000-000000000000', '1ee6153b-698f-4a0f-95ee-196718b120ba', '{"action":"login","actor_id":"78c9fdb7-7e0c-404e-abe9-14533b7737f7","actor_username":"maciej.jarlaczynski@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-11-15 21:40:21.354143+00', ''),
	('00000000-0000-0000-0000-000000000000', '837b4020-6555-477b-94ec-337468f6a6f0', '{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"wwwwwwww@yarla.com","user_id":"c75465ea-25bc-4991-a4da-b309601005bf","user_phone":""}}', '2025-11-15 21:43:12.469979+00', ''),
	('00000000-0000-0000-0000-000000000000', 'bf32b41f-4302-4504-b0f9-7dd6279c04ca', '{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"maciej.jarlaczynski@gmail.com","user_id":"78c9fdb7-7e0c-404e-abe9-14533b7737f7","user_phone":""}}', '2025-11-15 21:43:12.487053+00', ''),
	('00000000-0000-0000-0000-000000000000', 'bf2c75f6-0f6a-4b10-af48-555747f503be', '{"action":"login","actor_id":"70b079c7-e216-4084-b96a-7f4de3ea23cc","actor_username":"yyyy@yyyy.yyy","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-11-15 23:31:28.469188+00', ''),
	('00000000-0000-0000-0000-000000000000', '777c983c-deb0-49cf-914f-7a3ba05ef1af', '{"action":"user_signedup","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"provider":"email","user_email":"maciej2@yarla.com","user_id":"b6f1d8cf-91ed-49d6-8d18-c016fc4e6931","user_phone":""}}', '2025-11-15 21:44:03.851311+00', ''),
	('00000000-0000-0000-0000-000000000000', '0ff07ca9-ed5c-44f2-aafe-932edb0b1b00', '{"action":"login","actor_id":"b6f1d8cf-91ed-49d6-8d18-c016fc4e6931","actor_username":"maciej2@yarla.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-11-15 21:44:16.954204+00', ''),
	('00000000-0000-0000-0000-000000000000', 'ed7ac565-1e3b-435b-9c09-c9c21d35cf00', '{"action":"logout","actor_id":"b6f1d8cf-91ed-49d6-8d18-c016fc4e6931","actor_username":"maciej2@yarla.com","actor_via_sso":false,"log_type":"account"}', '2025-11-15 21:44:33.125679+00', ''),
	('00000000-0000-0000-0000-000000000000', '874944a9-c5d0-4e2b-a072-ccfb527eb739', '{"action":"user_signedup","actor_id":"347ef2e1-28e0-4d3e-8287-3c3d60a58a2b","actor_username":"wwwwwwww@yarla.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}', '2025-11-15 22:17:36.640948+00', ''),
	('00000000-0000-0000-0000-000000000000', 'addfb992-4fe2-4dff-8353-2592b4abd0bf', '{"action":"login","actor_id":"347ef2e1-28e0-4d3e-8287-3c3d60a58a2b","actor_username":"wwwwwwww@yarla.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-11-15 22:17:36.644093+00', ''),
	('00000000-0000-0000-0000-000000000000', 'e33bd680-9450-4682-b349-562964c8625f', '{"action":"user_signedup","actor_id":"cb26ad8a-9ae5-4634-9c1b-7fafb7ecfdd5","actor_username":"qqq@qqq.qqq","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}', '2025-11-15 22:18:19.243559+00', ''),
	('00000000-0000-0000-0000-000000000000', 'f18076c3-fb07-4de1-aa76-092e46cc8f43', '{"action":"login","actor_id":"cb26ad8a-9ae5-4634-9c1b-7fafb7ecfdd5","actor_username":"qqq@qqq.qqq","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-11-15 22:18:19.247325+00', ''),
	('00000000-0000-0000-0000-000000000000', 'fd636326-d980-40a8-abfa-ff8e87c91850', '{"action":"user_repeated_signup","actor_id":"cb26ad8a-9ae5-4634-9c1b-7fafb7ecfdd5","actor_username":"qqq@qqq.qqq","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}', '2025-11-15 22:19:25.925659+00', ''),
	('00000000-0000-0000-0000-000000000000', 'b268c137-a466-461e-a58c-aec941b6c79b', '{"action":"user_signedup","actor_id":"56794987-8cd6-4c57-a376-9ebb831d7247","actor_username":"qqq@qqq.qqqq","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}', '2025-11-15 22:19:33.762703+00', ''),
	('00000000-0000-0000-0000-000000000000', '7ae50fcc-fe7a-450b-87c1-4143b7fff8ee', '{"action":"login","actor_id":"56794987-8cd6-4c57-a376-9ebb831d7247","actor_username":"qqq@qqq.qqqq","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-11-15 22:19:33.765224+00', ''),
	('00000000-0000-0000-0000-000000000000', 'bb5a64c3-0fa4-4ddf-aa04-346f7796d189', '{"action":"user_signedup","actor_id":"1dd44748-ddc6-4a89-b9f3-7a43a41d205a","actor_username":"rrr@rrr.rrr","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}', '2025-11-15 22:24:25.359767+00', ''),
	('00000000-0000-0000-0000-000000000000', 'c49331e3-34b3-47e1-a84f-73f4f1739362', '{"action":"login","actor_id":"1dd44748-ddc6-4a89-b9f3-7a43a41d205a","actor_username":"rrr@rrr.rrr","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-11-15 22:24:25.363376+00', ''),
	('00000000-0000-0000-0000-000000000000', 'e1e1f93a-61e3-4944-9c3a-904048105b20', '{"action":"logout","actor_id":"1dd44748-ddc6-4a89-b9f3-7a43a41d205a","actor_username":"rrr@rrr.rrr","actor_via_sso":false,"log_type":"account"}', '2025-11-15 22:35:25.429538+00', ''),
	('00000000-0000-0000-0000-000000000000', 'eced898f-a30f-44d7-9493-1410fa933f3b', '{"action":"user_signedup","actor_id":"1de0172a-7664-4e07-80a0-4010e41d0509","actor_username":"qqq@qqqq.q","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}', '2025-11-15 22:35:34.987536+00', ''),
	('00000000-0000-0000-0000-000000000000', '18a5a864-452b-412f-b344-d89cb4c11a4c', '{"action":"login","actor_id":"1de0172a-7664-4e07-80a0-4010e41d0509","actor_username":"qqq@qqqq.q","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-11-15 22:35:34.990944+00', ''),
	('00000000-0000-0000-0000-000000000000', '5d64fae3-25db-4c0e-9cea-143b72971f70', '{"action":"user_confirmation_requested","actor_id":"4447805b-5a21-4446-8e76-cfcc95555b4e","actor_username":"aaa@aaaa.pl","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}', '2025-11-15 22:46:27.671999+00', ''),
	('00000000-0000-0000-0000-000000000000', '2983283d-9986-4487-98bf-a8213449f1ad', '{"action":"user_signedup","actor_id":"4447805b-5a21-4446-8e76-cfcc95555b4e","actor_username":"aaa@aaaa.pl","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}', '2025-11-15 22:46:33.781349+00', ''),
	('00000000-0000-0000-0000-000000000000', 'caf12f56-b5a1-46cf-be24-639ac8fcc78c', '{"action":"login","actor_id":"4447805b-5a21-4446-8e76-cfcc95555b4e","actor_username":"aaa@aaaa.pl","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-11-15 22:46:48.074247+00', ''),
	('00000000-0000-0000-0000-000000000000', 'b84486d2-24aa-47a6-a617-60fd9f979c05', '{"action":"logout","actor_id":"4447805b-5a21-4446-8e76-cfcc95555b4e","actor_username":"aaa@aaaa.pl","actor_via_sso":false,"log_type":"account"}', '2025-11-15 22:51:13.270582+00', ''),
	('00000000-0000-0000-0000-000000000000', 'cb31533a-a7a6-4bfb-92c6-3cf3dfefe86b', '{"action":"user_confirmation_requested","actor_id":"09021b77-3bfb-4c88-82d9-a723f3499892","actor_username":"rrr@www.ooo2","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}', '2025-11-15 22:55:51.971566+00', ''),
	('00000000-0000-0000-0000-000000000000', 'aee51833-0ffa-4ba2-a8e7-244a69ac290f', '{"action":"user_signedup","actor_id":"09021b77-3bfb-4c88-82d9-a723f3499892","actor_username":"rrr@www.ooo2","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}', '2025-11-15 22:56:12.555132+00', ''),
	('00000000-0000-0000-0000-000000000000', 'd3c74424-40f0-4cf3-8cc6-8402b2d98016', '{"action":"login","actor_id":"09021b77-3bfb-4c88-82d9-a723f3499892","actor_username":"rrr@www.ooo2","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-11-15 22:56:18.448865+00', ''),
	('00000000-0000-0000-0000-000000000000', '59c3eac8-533b-4b72-bb8b-28e7c054590f', '{"action":"logout","actor_id":"09021b77-3bfb-4c88-82d9-a723f3499892","actor_username":"rrr@www.ooo2","actor_via_sso":false,"log_type":"account"}', '2025-11-15 22:58:54.857366+00', ''),
	('00000000-0000-0000-0000-000000000000', '4dec8821-a384-470a-bb62-762ac008f036', '{"action":"user_recovery_requested","actor_id":"3973b11e-118a-4933-b752-f78cc7469daf","actor_username":"maciej@yarla.com","actor_via_sso":false,"log_type":"user"}', '2025-11-15 23:13:35.239275+00', ''),
	('00000000-0000-0000-0000-000000000000', '67192b9a-792f-45aa-b3ca-b8f2a25b355f', '{"action":"login","actor_id":"3973b11e-118a-4933-b752-f78cc7469daf","actor_username":"maciej@yarla.com","actor_via_sso":false,"log_type":"account"}', '2025-11-15 23:13:40.940809+00', ''),
	('00000000-0000-0000-0000-000000000000', '30717e6a-3349-41bb-b86b-5ccb4bce44cb', '{"action":"user_recovery_requested","actor_id":"3973b11e-118a-4933-b752-f78cc7469daf","actor_username":"maciej@yarla.com","actor_via_sso":false,"log_type":"user"}', '2025-11-15 23:18:41.451994+00', ''),
	('00000000-0000-0000-0000-000000000000', '05b8a55f-7004-4c1f-b556-d0b1bc87bbab', '{"action":"login","actor_id":"3973b11e-118a-4933-b752-f78cc7469daf","actor_username":"maciej@yarla.com","actor_via_sso":false,"log_type":"account"}', '2025-11-15 23:18:45.391695+00', ''),
	('00000000-0000-0000-0000-000000000000', 'f0db96f7-a9b7-4848-a39c-e2ca60507a00', '{"action":"user_confirmation_requested","actor_id":"d89d9d8c-ca55-491e-848e-2ea511d40294","actor_username":"qqqqqqq@aaaaaa.llll","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}', '2025-11-15 23:22:56.853191+00', ''),
	('00000000-0000-0000-0000-000000000000', '7c24db44-5648-4e1b-89da-7bf1718e5d61', '{"action":"user_signedup","actor_id":"d89d9d8c-ca55-491e-848e-2ea511d40294","actor_username":"qqqqqqq@aaaaaa.llll","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}', '2025-11-15 23:23:43.108279+00', ''),
	('00000000-0000-0000-0000-000000000000', '2e543bb0-a113-4b41-8eb6-ba48d95fb292', '{"action":"user_signedup","actor_id":"70b079c7-e216-4084-b96a-7f4de3ea23cc","actor_username":"yyyy@yyyy.yyy","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}', '2025-11-15 23:30:28.094098+00', ''),
	('00000000-0000-0000-0000-000000000000', 'cdcc08d9-f540-4c15-86a4-47b48ec4ad88', '{"action":"login","actor_id":"70b079c7-e216-4084-b96a-7f4de3ea23cc","actor_username":"yyyy@yyyy.yyy","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-11-15 23:30:28.099861+00', ''),
	('00000000-0000-0000-0000-000000000000', 'bc56156b-da7d-4c21-9966-638bcd801bb5', '{"action":"logout","actor_id":"70b079c7-e216-4084-b96a-7f4de3ea23cc","actor_username":"yyyy@yyyy.yyy","actor_via_sso":false,"log_type":"account"}', '2025-11-15 23:34:33.175334+00', ''),
	('00000000-0000-0000-0000-000000000000', '23c638ed-e7dd-40c2-a425-c814adf6edf4', '{"action":"user_recovery_requested","actor_id":"3973b11e-118a-4933-b752-f78cc7469daf","actor_username":"maciej@yarla.com","actor_via_sso":false,"log_type":"user"}', '2025-11-15 23:34:41.173042+00', ''),
	('00000000-0000-0000-0000-000000000000', '660d0249-82d6-4a38-8cb9-00b209843df2', '{"action":"login","actor_id":"3973b11e-118a-4933-b752-f78cc7469daf","actor_username":"maciej@yarla.com","actor_via_sso":false,"log_type":"account"}', '2025-11-15 23:34:45.109818+00', ''),
	('00000000-0000-0000-0000-000000000000', '694fbe62-c550-48ac-9b8e-c2e8ee0e83db', '{"action":"user_recovery_requested","actor_id":"3973b11e-118a-4933-b752-f78cc7469daf","actor_username":"maciej@yarla.com","actor_via_sso":false,"log_type":"user"}', '2025-11-15 23:35:47.715896+00', ''),
	('00000000-0000-0000-0000-000000000000', '55e86e83-0d96-45bc-b7b4-d8fa992aa521', '{"action":"login","actor_id":"3973b11e-118a-4933-b752-f78cc7469daf","actor_username":"maciej@yarla.com","actor_via_sso":false,"log_type":"account"}', '2025-11-15 23:35:51.895747+00', ''),
	('00000000-0000-0000-0000-000000000000', '7cda6c58-696c-4498-9f93-047b6acef8e7', '{"action":"user_signedup","actor_id":"87330a64-e6b2-496b-b8d9-8bbbf5c138ec","actor_username":"zzz@zzz.pl","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}', '2025-11-15 23:40:58.83181+00', ''),
	('00000000-0000-0000-0000-000000000000', 'ad3e81ad-4cb0-41de-8712-0dfc32f31c68', '{"action":"login","actor_id":"87330a64-e6b2-496b-b8d9-8bbbf5c138ec","actor_username":"zzz@zzz.pl","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-11-15 23:40:58.835888+00', ''),
	('00000000-0000-0000-0000-000000000000', '8ea67c6a-d2c8-4d8d-95fb-68f10cb70cff', '{"action":"user_recovery_requested","actor_id":"87330a64-e6b2-496b-b8d9-8bbbf5c138ec","actor_username":"zzz@zzz.pl","actor_via_sso":false,"log_type":"user"}', '2025-11-15 23:41:12.684585+00', ''),
	('00000000-0000-0000-0000-000000000000', '116e2f7f-1995-408a-b4f3-9e485f7cc71d', '{"action":"login","actor_id":"87330a64-e6b2-496b-b8d9-8bbbf5c138ec","actor_username":"zzz@zzz.pl","actor_via_sso":false,"log_type":"account"}', '2025-11-15 23:41:16.690842+00', ''),
	('00000000-0000-0000-0000-000000000000', '6916b897-4ed4-45de-bcf5-2316f7dc3933', '{"action":"logout","actor_id":"87330a64-e6b2-496b-b8d9-8bbbf5c138ec","actor_username":"zzz@zzz.pl","actor_via_sso":false,"log_type":"account"}', '2025-11-15 23:48:11.441791+00', ''),
	('00000000-0000-0000-0000-000000000000', '60c09666-bcbf-4b23-bef5-0e4323c92afa', '{"action":"user_recovery_requested","actor_id":"3973b11e-118a-4933-b752-f78cc7469daf","actor_username":"maciej@yarla.com","actor_via_sso":false,"log_type":"user"}', '2025-11-15 23:48:45.230988+00', ''),
	('00000000-0000-0000-0000-000000000000', 'ca87ae6a-c1fd-4b42-b90a-02cdb927514c', '{"action":"login","actor_id":"3973b11e-118a-4933-b752-f78cc7469daf","actor_username":"maciej@yarla.com","actor_via_sso":false,"log_type":"account"}', '2025-11-15 23:48:48.613319+00', ''),
	('00000000-0000-0000-0000-000000000000', '5d0e1187-e8a5-4137-92d0-3e8c8adedea4', '{"action":"user_recovery_requested","actor_id":"3973b11e-118a-4933-b752-f78cc7469daf","actor_username":"maciej@yarla.com","actor_via_sso":false,"log_type":"user"}', '2025-11-15 23:53:18.045381+00', ''),
	('00000000-0000-0000-0000-000000000000', 'ac438df6-d189-40f9-85fe-17ce17a979bd', '{"action":"login","actor_id":"3973b11e-118a-4933-b752-f78cc7469daf","actor_username":"maciej@yarla.com","actor_via_sso":false,"log_type":"account"}', '2025-11-15 23:53:22.070839+00', ''),
	('00000000-0000-0000-0000-000000000000', 'e9db915f-0a02-4b46-9ac2-1fc5efeb3725', '{"action":"user_recovery_requested","actor_id":"3973b11e-118a-4933-b752-f78cc7469daf","actor_username":"maciej@yarla.com","actor_via_sso":false,"log_type":"user"}', '2025-11-15 23:55:06.895703+00', ''),
	('00000000-0000-0000-0000-000000000000', 'e73285e7-1f9c-4577-a4ce-4b5ffbbb3ef1', '{"action":"login","actor_id":"3973b11e-118a-4933-b752-f78cc7469daf","actor_username":"maciej@yarla.com","actor_via_sso":false,"log_type":"account"}', '2025-11-15 23:55:23.754447+00', ''),
	('00000000-0000-0000-0000-000000000000', 'f248efb4-2c8b-4a49-af7d-297a82a2e6e7', '{"action":"user_recovery_requested","actor_id":"3973b11e-118a-4933-b752-f78cc7469daf","actor_username":"maciej@yarla.com","actor_via_sso":false,"log_type":"user"}', '2025-11-15 23:56:57.42414+00', ''),
	('00000000-0000-0000-0000-000000000000', 'c0a1434b-85ce-46d7-84fa-5ed7304ffd27', '{"action":"login","actor_id":"3973b11e-118a-4933-b752-f78cc7469daf","actor_username":"maciej@yarla.com","actor_via_sso":false,"log_type":"account"}', '2025-11-15 23:57:00.790852+00', ''),
	('00000000-0000-0000-0000-000000000000', 'ebbb5e64-e845-4324-af43-7bac46ab57e3', '{"action":"user_recovery_requested","actor_id":"3973b11e-118a-4933-b752-f78cc7469daf","actor_username":"maciej@yarla.com","actor_via_sso":false,"log_type":"user"}', '2025-11-16 00:02:01.413745+00', ''),
	('00000000-0000-0000-0000-000000000000', '0595a23a-dad8-42fd-bc0a-da342ea66c8b', '{"action":"login","actor_id":"3973b11e-118a-4933-b752-f78cc7469daf","actor_username":"maciej@yarla.com","actor_via_sso":false,"log_type":"account"}', '2025-11-16 00:02:05.566554+00', ''),
	('00000000-0000-0000-0000-000000000000', '053d0fbc-4296-4175-af83-1d39bb487491', '{"action":"login","actor_id":"3973b11e-118a-4933-b752-f78cc7469daf","actor_username":"maciej@yarla.com","actor_via_sso":false,"log_type":"account","traits":{"provider_type":"recovery"}}', '2025-11-16 00:02:05.585819+00', ''),
	('00000000-0000-0000-0000-000000000000', 'c2f28ec6-2211-4854-b206-2ab0ed86d262', '{"action":"user_updated_password","actor_id":"3973b11e-118a-4933-b752-f78cc7469daf","actor_username":"maciej@yarla.com","actor_via_sso":false,"log_type":"user"}', '2025-11-16 00:02:15.733989+00', ''),
	('00000000-0000-0000-0000-000000000000', '9489de80-d9ae-4c1c-b12f-8691a5210875', '{"action":"user_modified","actor_id":"3973b11e-118a-4933-b752-f78cc7469daf","actor_username":"maciej@yarla.com","actor_via_sso":false,"log_type":"user"}', '2025-11-16 00:02:15.734489+00', ''),
	('00000000-0000-0000-0000-000000000000', '2ce54b8d-68ca-49b7-af8b-b761cf6e6a57', '{"action":"logout","actor_id":"3973b11e-118a-4933-b752-f78cc7469daf","actor_username":"maciej@yarla.com","actor_via_sso":false,"log_type":"account"}', '2025-11-16 00:02:21.949383+00', ''),
	('00000000-0000-0000-0000-000000000000', 'c3ecd605-cd0a-4d10-8825-b5ca9bad3190', '{"action":"login","actor_id":"3973b11e-118a-4933-b752-f78cc7469daf","actor_username":"maciej@yarla.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-11-16 00:02:31.07293+00', ''),
	('00000000-0000-0000-0000-000000000000', '9c3e6d18-18a8-4d35-bea4-10a3d9bf754e', '{"action":"token_refreshed","actor_id":"3973b11e-118a-4933-b752-f78cc7469daf","actor_username":"maciej@yarla.com","actor_via_sso":false,"log_type":"token"}', '2025-11-16 07:12:00.389113+00', ''),
	('00000000-0000-0000-0000-000000000000', '65a8e90d-d538-4cb4-987f-1e1a9b3eaa45', '{"action":"token_revoked","actor_id":"3973b11e-118a-4933-b752-f78cc7469daf","actor_username":"maciej@yarla.com","actor_via_sso":false,"log_type":"token"}', '2025-11-16 07:12:00.389944+00', ''),
	('00000000-0000-0000-0000-000000000000', '7d2ede92-e2c0-4a3d-a800-6aad997c66b0', '{"action":"token_refreshed","actor_id":"3973b11e-118a-4933-b752-f78cc7469daf","actor_username":"maciej@yarla.com","actor_via_sso":false,"log_type":"token"}', '2025-11-16 07:12:00.427224+00', ''),
	('00000000-0000-0000-0000-000000000000', '6cea00ad-8c40-4675-8326-41a859a7041f', '{"action":"logout","actor_id":"3973b11e-118a-4933-b752-f78cc7469daf","actor_username":"maciej@yarla.com","actor_via_sso":false,"log_type":"account"}', '2025-11-16 07:12:22.316051+00', ''),
	('00000000-0000-0000-0000-000000000000', 'fac53a17-4347-41c3-b502-ad522f90847e', '{"action":"login","actor_id":"3973b11e-118a-4933-b752-f78cc7469daf","actor_username":"maciej@yarla.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-11-16 07:12:32.010524+00', ''),
	('00000000-0000-0000-0000-000000000000', '28d2e4d7-f96c-4a86-8586-c61d015fac4a', '{"action":"logout","actor_id":"3973b11e-118a-4933-b752-f78cc7469daf","actor_username":"maciej@yarla.com","actor_via_sso":false,"log_type":"account"}', '2025-11-16 07:15:44.736223+00', ''),
	('00000000-0000-0000-0000-000000000000', '8d6c7a18-c813-493c-b192-bc1a5a7029d3', '{"action":"login","actor_id":"3973b11e-118a-4933-b752-f78cc7469daf","actor_username":"maciej@yarla.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-11-16 07:15:54.671953+00', ''),
	('00000000-0000-0000-0000-000000000000', '3eda79ea-0fa1-45e9-bbeb-44d49fabe886', '{"action":"user_updated_password","actor_id":"3973b11e-118a-4933-b752-f78cc7469daf","actor_username":"maciej@yarla.com","actor_via_sso":false,"log_type":"user"}', '2025-11-16 07:19:59.269854+00', ''),
	('00000000-0000-0000-0000-000000000000', '49c0845c-b501-4c41-ad7b-c2edf99abe7e', '{"action":"user_modified","actor_id":"3973b11e-118a-4933-b752-f78cc7469daf","actor_username":"maciej@yarla.com","actor_via_sso":false,"log_type":"user"}', '2025-11-16 07:19:59.27047+00', ''),
	('00000000-0000-0000-0000-000000000000', 'c93c2ccc-a086-47af-bf8f-c70c588531de', '{"action":"logout","actor_id":"3973b11e-118a-4933-b752-f78cc7469daf","actor_username":"maciej@yarla.com","actor_via_sso":false,"log_type":"account"}', '2025-11-16 07:20:07.76215+00', ''),
	('00000000-0000-0000-0000-000000000000', '7edcb6a1-52f7-45cc-ab29-e1a4a0170788', '{"action":"login","actor_id":"3973b11e-118a-4933-b752-f78cc7469daf","actor_username":"maciej@yarla.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-11-16 07:20:17.713304+00', '');


--
-- Data for Name: flow_state; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

INSERT INTO "auth"."flow_state" ("id", "user_id", "auth_code", "code_challenge_method", "code_challenge", "provider_type", "provider_access_token", "provider_refresh_token", "created_at", "updated_at", "authentication_method", "auth_code_issued_at") VALUES
	('de19033e-20b0-41bc-aafd-160facd55865', '4447805b-5a21-4446-8e76-cfcc95555b4e', '11ba8ec3-baac-4523-a0fe-93c3208b4210', 's256', 'cgZJk4ZHvOar-1VOVbOMlbNS8daAyf-xhIThn0eaMWQ', 'email', '', '', '2025-11-15 22:46:27.67258+00', '2025-11-15 22:46:33.785432+00', 'email/signup', '2025-11-15 22:46:33.785415+00'),
	('0f089e77-ad55-4583-96ea-0fa747d3cd7d', '09021b77-3bfb-4c88-82d9-a723f3499892', '73044747-10a2-4d01-bf52-760b5cd751c0', 's256', '1AQ42b-57aIQWbCy553LC5iHDZa5ZnVdHBdTTbtBYU8', 'email', '', '', '2025-11-15 22:55:51.971933+00', '2025-11-15 22:56:12.558118+00', 'email/signup', '2025-11-15 22:56:12.558101+00'),
	('3461e231-b528-4b26-aa98-d4881ad4773a', '3973b11e-118a-4933-b752-f78cc7469daf', '365be3f0-c432-46f2-9d80-ab91d81656a1', 's256', 'h5N3egZwZaM7xaBjLBAksLBYOCE4ApFUAlDBOy23bTo', 'recovery', '', '', '2025-11-15 23:13:35.237737+00', '2025-11-15 23:13:40.942467+00', 'recovery', '2025-11-15 23:13:40.942447+00'),
	('718ac1c6-c70f-4f2d-b9ca-1811a0b1ee5e', '3973b11e-118a-4933-b752-f78cc7469daf', 'cff273fd-7016-4df8-83c8-575a60bada60', 's256', 'y716kN2zFl9KJYcVC5kxL4Uo8hKskhpl3PyGPhahOdc', 'recovery', '', '', '2025-11-15 23:18:41.450428+00', '2025-11-15 23:18:45.393285+00', 'recovery', '2025-11-15 23:18:45.393257+00'),
	('8d01b238-9643-40f5-a15e-7ae48371cee2', 'd89d9d8c-ca55-491e-848e-2ea511d40294', 'f300ebc5-73ef-4ad0-ac1f-8b9f4c87989e', 's256', 'WzCphr4vfqJSX7LaS2t-I_kCK0XxNSSv6daJppRCnCs', 'email', '', '', '2025-11-15 23:22:56.853624+00', '2025-11-15 23:23:43.111948+00', 'email/signup', '2025-11-15 23:23:43.111932+00'),
	('44aaa486-6afe-4123-8d07-cb3af7cd8be3', '3973b11e-118a-4933-b752-f78cc7469daf', 'b8370cab-497d-497d-8d9b-967fdc213de6', 's256', 'l2cpGp6srVwdoxtKpysv35iilOBAuFwY6TUZuRUI884', 'recovery', '', '', '2025-11-15 23:34:41.170748+00', '2025-11-15 23:34:45.111692+00', 'recovery', '2025-11-15 23:34:45.111676+00'),
	('785076b6-d239-4177-af1c-98958de61f53', '87330a64-e6b2-496b-b8d9-8bbbf5c138ec', '5230f08f-39c2-49aa-b450-46062356f542', 's256', 'CtUZUNSnE4_zrr1dGXttNdb61PBE884qdLzRDzHidSU', 'recovery', '', '', '2025-11-15 23:41:12.68218+00', '2025-11-15 23:41:16.69424+00', 'recovery', '2025-11-15 23:41:16.694218+00'),
	('f9dc9b9a-cd6f-4b65-a2fb-ce82e9ed4f99', '3973b11e-118a-4933-b752-f78cc7469daf', 'c6de6349-9eb3-46ed-bf33-627abe69befb', 's256', 'Yce56ipYtbykxn19GOW4nyYR1s9H0BaySIyTkZM3_QU', 'recovery', '', '', '2025-11-15 23:48:45.22842+00', '2025-11-15 23:48:48.616013+00', 'recovery', '2025-11-15 23:48:48.615997+00'),
	('6c323893-3563-4774-9139-b0cea457fcd5', '3973b11e-118a-4933-b752-f78cc7469daf', '664a3986-3d45-4dfc-a225-c02b00091775', 's256', 'px7NEdlBiMU11JQzV0y39PXQmIkOCjIMJAXuWnFk5aM', 'recovery', '', '', '2025-11-15 23:53:18.043655+00', '2025-11-15 23:53:22.073211+00', 'recovery', '2025-11-15 23:53:22.073196+00'),
	('ded0284c-c301-4b03-89c0-0cf3b7e32923', '3973b11e-118a-4933-b752-f78cc7469daf', '83853e01-601e-449b-bf25-ac410524f87d', 's256', '1HUR1rgskVMgBVhzIFsUsOuf5YKDKhDGHV9DS1lURjE', 'recovery', '', '', '2025-11-15 23:55:06.894352+00', '2025-11-15 23:55:23.756534+00', 'recovery', '2025-11-15 23:55:23.756518+00'),
	('e33513ef-087a-4d3e-90ff-6e00c02e00fb', '3973b11e-118a-4933-b752-f78cc7469daf', '5d17d14d-281b-4fad-bb37-b973b735a9a6', 's256', '3W7RoczqIYIwHlc-ZcsHD3r8u9AyDJon8lL0NsSPvuI', 'recovery', '', '', '2025-11-15 23:56:57.422724+00', '2025-11-15 23:57:00.792142+00', 'recovery', '2025-11-15 23:57:00.792122+00');


--
-- Data for Name: users; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

INSERT INTO "auth"."users" ("instance_id", "id", "aud", "role", "email", "encrypted_password", "email_confirmed_at", "invited_at", "confirmation_token", "confirmation_sent_at", "recovery_token", "recovery_sent_at", "email_change_token_new", "email_change", "email_change_sent_at", "last_sign_in_at", "raw_app_meta_data", "raw_user_meta_data", "is_super_admin", "created_at", "updated_at", "phone", "phone_confirmed_at", "phone_change", "phone_change_token", "phone_change_sent_at", "email_change_token_current", "email_change_confirm_status", "banned_until", "reauthentication_token", "reauthentication_sent_at", "is_sso_user", "deleted_at", "is_anonymous") VALUES
	('00000000-0000-0000-0000-000000000000', '1de0172a-7664-4e07-80a0-4010e41d0509', 'authenticated', 'authenticated', 'qqq@qqqq.q', '$2a$10$wRxyEoIF1qK3Fpzan6F1nOzRPrl0iOVlTwCsXLfh20avblAjmO6k6', '2025-11-15 22:35:34.987884+00', NULL, '', NULL, '', NULL, '', '', NULL, '2025-11-15 22:35:34.991246+00', '{"provider": "email", "providers": ["email"]}', '{"sub": "1de0172a-7664-4e07-80a0-4010e41d0509", "email": "qqq@qqqq.q", "email_verified": true, "phone_verified": false}', NULL, '2025-11-15 22:35:34.983292+00', '2025-11-15 22:35:34.992616+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', 'b79685eb-78d6-46de-96d5-a8325b4ca05d', 'authenticated', 'authenticated', 'tytus@maszpan.pl', '$2a$10$OAv2sf8zJsbsiKrtG7j7uezv.WM7aTlJy5AgVgv0Y4M.4oHB/l7Xe', '2025-11-07 15:21:36.582483+00', NULL, '', NULL, '', NULL, '', '', NULL, NULL, '{"provider": "email", "providers": ["email"]}', '{"email_verified": true}', NULL, '2025-11-07 15:21:36.578321+00', '2025-11-07 15:21:36.583068+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', 'cb26ad8a-9ae5-4634-9c1b-7fafb7ecfdd5', 'authenticated', 'authenticated', 'qqq@qqq.qqq', '$2a$10$vUOwutS2E5qKVlTTvWt3zOV5eJpW1E8.I7Tt2hm7.ZVjiAPq4F5vq', '2025-11-15 22:18:19.244121+00', NULL, '', NULL, '', NULL, '', '', NULL, '2025-11-15 22:18:19.247768+00', '{"provider": "email", "providers": ["email"]}', '{"sub": "cb26ad8a-9ae5-4634-9c1b-7fafb7ecfdd5", "email": "qqq@qqq.qqq", "email_verified": true, "phone_verified": false}', NULL, '2025-11-15 22:18:19.240013+00', '2025-11-15 22:18:19.248961+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', 'b6f1d8cf-91ed-49d6-8d18-c016fc4e6931', 'authenticated', 'authenticated', 'maciej2@yarla.com', '$2a$10$cbh2.qWkNfUPlQ4W1GDk.OyV5tMzL6idEPqCDKD91hcDis0OES8aq', '2025-11-15 21:44:03.853836+00', NULL, '', NULL, '', NULL, '', '', NULL, '2025-11-15 21:44:16.954669+00', '{"provider": "email", "providers": ["email"]}', '{"email_verified": true}', NULL, '2025-11-15 21:44:03.848317+00', '2025-11-15 21:44:16.956331+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', '1f587053-c01e-4aa6-8931-33567ca6a080', 'authenticated', 'authenticated', 'romek@maszpan.pl', '$2a$10$QL1ZRVc3KIYVY3ash4JO1uByGR5tx4XS4LFg26dpktTPQ3MeuNU.O', '2025-11-07 15:21:06.559753+00', NULL, '', NULL, '', NULL, '', '', NULL, NULL, '{"provider": "email", "providers": ["email"]}', '{"email_verified": true}', NULL, '2025-11-07 15:21:06.553244+00', '2025-11-07 15:21:06.560846+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', '1dd44748-ddc6-4a89-b9f3-7a43a41d205a', 'authenticated', 'authenticated', 'rrr@rrr.rrr', '$2a$10$0cuNb0c9JKvnQkSUjfsBi.8Ji76/0cTzXhL6k3BY2ZzKq7dNQAuqm', '2025-11-15 22:24:25.360877+00', NULL, '', NULL, '', NULL, '', '', NULL, '2025-11-15 22:24:25.36395+00', '{"provider": "email", "providers": ["email"]}', '{"sub": "1dd44748-ddc6-4a89-b9f3-7a43a41d205a", "email": "rrr@rrr.rrr", "email_verified": true, "phone_verified": false}', NULL, '2025-11-15 22:24:25.354639+00', '2025-11-15 22:24:25.367482+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', '0fc43071-195f-445a-ac6c-80319d362d66', 'authenticated', 'authenticated', 'atomek@maszpan.pl', '$2a$10$2G/TziuWIrRPHcq2zkQ7WO2gvhXE96fmSZNSwxfcX9MZ9BnFKI4d.', '2025-11-07 15:21:21.929387+00', NULL, '', NULL, '', NULL, '', '', NULL, NULL, '{"provider": "email", "providers": ["email"]}', '{"email_verified": true}', NULL, '2025-11-07 15:21:21.925284+00', '2025-11-07 15:21:21.93016+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', '347ef2e1-28e0-4d3e-8287-3c3d60a58a2b', 'authenticated', 'authenticated', 'wwwwwwww@yarla.com', '$2a$10$3/bdR017EtdkHOKDgjJdU.ybAcASyvcwyUCOz6jKXi81IdJLXeBFy', '2025-11-15 22:17:36.641572+00', NULL, '', NULL, '', NULL, '', '', NULL, '2025-11-15 22:17:36.644604+00', '{"provider": "email", "providers": ["email"]}', '{"sub": "347ef2e1-28e0-4d3e-8287-3c3d60a58a2b", "email": "wwwwwwww@yarla.com", "email_verified": true, "phone_verified": false}', NULL, '2025-11-15 22:17:36.633933+00', '2025-11-15 22:17:36.647587+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', '56794987-8cd6-4c57-a376-9ebb831d7247', 'authenticated', 'authenticated', 'qqq@qqq.qqqq', '$2a$10$nz3Pcicc3uwLl1XWYwY7lORHJK/9nrSXStfLKAShtP1prHcyhfo2e', '2025-11-15 22:19:33.763315+00', NULL, '', NULL, '', NULL, '', '', NULL, '2025-11-15 22:19:33.765548+00', '{"provider": "email", "providers": ["email"]}', '{"sub": "56794987-8cd6-4c57-a376-9ebb831d7247", "email": "qqq@qqq.qqqq", "email_verified": true, "phone_verified": false}', NULL, '2025-11-15 22:19:33.759223+00', '2025-11-15 22:19:33.766507+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', '4447805b-5a21-4446-8e76-cfcc95555b4e', 'authenticated', 'authenticated', 'aaa@aaaa.pl', '$2a$10$UE9/rapsmbqcEilsOyMOWuzvuDxOri273mt6bB.bocUcRswk4UY6i', '2025-11-15 22:46:33.781878+00', NULL, '', '2025-11-15 22:46:27.673911+00', '', NULL, '', '', NULL, '2025-11-15 22:46:48.074822+00', '{"provider": "email", "providers": ["email"]}', '{"sub": "4447805b-5a21-4446-8e76-cfcc95555b4e", "email": "aaa@aaaa.pl", "email_verified": true, "phone_verified": false}', NULL, '2025-11-15 22:46:27.667884+00', '2025-11-15 22:46:48.076738+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', '09021b77-3bfb-4c88-82d9-a723f3499892', 'authenticated', 'authenticated', 'rrr@www.ooo2', '$2a$10$BvCIWalfOoWfSTwGjO7LnOVm/GcqT6do/SgeAbZevmtVOBT3t1IUi', '2025-11-15 22:56:12.555725+00', NULL, '', '2025-11-15 22:55:51.97236+00', '', NULL, '', '', NULL, '2025-11-15 22:56:18.449386+00', '{"provider": "email", "providers": ["email"]}', '{"sub": "09021b77-3bfb-4c88-82d9-a723f3499892", "email": "rrr@www.ooo2", "email_verified": true, "phone_verified": false}', NULL, '2025-11-15 22:55:51.954481+00', '2025-11-15 22:56:18.450595+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', 'd89d9d8c-ca55-491e-848e-2ea511d40294', 'authenticated', 'authenticated', 'qqqqqqq@aaaaaa.llll', '$2a$10$vsP3m3lCp3zx.almqpsj9O8n9CW2pp0C0hlSHXC8emjDtQj5VeseO', '2025-11-15 23:23:43.108934+00', NULL, '', '2025-11-15 23:22:56.854288+00', '', NULL, '', '', NULL, NULL, '{"provider": "email", "providers": ["email"]}', '{"sub": "d89d9d8c-ca55-491e-848e-2ea511d40294", "email": "qqqqqqq@aaaaaa.llll", "email_verified": true, "phone_verified": false}', NULL, '2025-11-15 23:22:56.850042+00', '2025-11-15 23:23:43.110929+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', '70b079c7-e216-4084-b96a-7f4de3ea23cc', 'authenticated', 'authenticated', 'yyyy@yyyy.yyy', '$2a$10$voH5B55MlsPWh4mGgyK9VewqgHtY6Yh7pnjNnxQrLaUrPTcj08ocS', '2025-11-15 23:30:28.095731+00', NULL, '', NULL, '', NULL, '', '', NULL, '2025-11-15 23:31:28.472003+00', '{"provider": "email", "providers": ["email"]}', '{"sub": "70b079c7-e216-4084-b96a-7f4de3ea23cc", "email": "yyyy@yyyy.yyy", "email_verified": true, "phone_verified": false}', NULL, '2025-11-15 23:30:28.071661+00', '2025-11-15 23:31:28.473924+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', '87330a64-e6b2-496b-b8d9-8bbbf5c138ec', 'authenticated', 'authenticated', 'zzz@zzz.pl', '$2a$10$dmGux3.pWpw7f6H7iCbVWuJJOTTJzECPM3ytO3ySXofV5sVvbE76.', '2025-11-15 23:40:58.833126+00', NULL, '', NULL, '', '2025-11-15 23:41:12.685044+00', '', '', NULL, '2025-11-15 23:40:58.836256+00', '{"provider": "email", "providers": ["email"]}', '{"sub": "87330a64-e6b2-496b-b8d9-8bbbf5c138ec", "email": "zzz@zzz.pl", "email_verified": true, "phone_verified": false}', NULL, '2025-11-15 23:40:58.808922+00', '2025-11-15 23:41:16.691859+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', '3973b11e-118a-4933-b752-f78cc7469daf', 'authenticated', 'authenticated', 'maciej@yarla.com', '$2a$10$dX35/qHAQciLECx.pJY5rOHOUW6esFi/YTSPtx05rfFKQzceuByou', '2025-11-07 14:26:36.775282+00', NULL, '', NULL, '', NULL, '', '', NULL, '2025-11-16 07:20:17.713973+00', '{"provider": "email", "providers": ["email"]}', '{"email_verified": true}', NULL, '2025-11-07 14:26:36.759019+00', '2025-11-16 07:20:17.715221+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false);


--
-- Data for Name: identities; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

INSERT INTO "auth"."identities" ("provider_id", "user_id", "identity_data", "provider", "last_sign_in_at", "created_at", "updated_at", "id") VALUES
	('3973b11e-118a-4933-b752-f78cc7469daf', '3973b11e-118a-4933-b752-f78cc7469daf', '{"sub": "3973b11e-118a-4933-b752-f78cc7469daf", "email": "maciej@yarla.com", "email_verified": false, "phone_verified": false}', 'email', '2025-11-07 14:26:36.767204+00', '2025-11-07 14:26:36.767308+00', '2025-11-07 14:26:36.767308+00', 'd39e0b52-1585-4a93-ba31-2c466f81ef9b'),
	('1f587053-c01e-4aa6-8931-33567ca6a080', '1f587053-c01e-4aa6-8931-33567ca6a080', '{"sub": "1f587053-c01e-4aa6-8931-33567ca6a080", "email": "romek@maszpan.pl", "email_verified": false, "phone_verified": false}', 'email', '2025-11-07 15:21:06.55549+00', '2025-11-07 15:21:06.555525+00', '2025-11-07 15:21:06.555525+00', '4fb72134-b661-4464-9548-3dfa68a98a0c'),
	('0fc43071-195f-445a-ac6c-80319d362d66', '0fc43071-195f-445a-ac6c-80319d362d66', '{"sub": "0fc43071-195f-445a-ac6c-80319d362d66", "email": "atomek@maszpan.pl", "email_verified": false, "phone_verified": false}', 'email', '2025-11-07 15:21:21.926983+00', '2025-11-07 15:21:21.927015+00', '2025-11-07 15:21:21.927015+00', '84fd3fac-d05c-4da0-ac04-d100918d581f'),
	('b79685eb-78d6-46de-96d5-a8325b4ca05d', 'b79685eb-78d6-46de-96d5-a8325b4ca05d', '{"sub": "b79685eb-78d6-46de-96d5-a8325b4ca05d", "email": "tytus@maszpan.pl", "email_verified": false, "phone_verified": false}', 'email', '2025-11-07 15:21:36.579617+00', '2025-11-07 15:21:36.579679+00', '2025-11-07 15:21:36.579679+00', 'e0473459-12ba-4328-9a57-7abd1b187c47'),
	('b6f1d8cf-91ed-49d6-8d18-c016fc4e6931', 'b6f1d8cf-91ed-49d6-8d18-c016fc4e6931', '{"sub": "b6f1d8cf-91ed-49d6-8d18-c016fc4e6931", "email": "maciej2@yarla.com", "email_verified": false, "phone_verified": false}', 'email', '2025-11-15 21:44:03.849767+00', '2025-11-15 21:44:03.849826+00', '2025-11-15 21:44:03.849826+00', '378d6344-ad1c-4eb9-b1ce-92f3e89044ed'),
	('347ef2e1-28e0-4d3e-8287-3c3d60a58a2b', '347ef2e1-28e0-4d3e-8287-3c3d60a58a2b', '{"sub": "347ef2e1-28e0-4d3e-8287-3c3d60a58a2b", "email": "wwwwwwww@yarla.com", "email_verified": false, "phone_verified": false}', 'email', '2025-11-15 22:17:36.638071+00', '2025-11-15 22:17:36.638112+00', '2025-11-15 22:17:36.638112+00', '7c40b9bd-7154-4d8f-a756-7f73e80291b7'),
	('cb26ad8a-9ae5-4634-9c1b-7fafb7ecfdd5', 'cb26ad8a-9ae5-4634-9c1b-7fafb7ecfdd5', '{"sub": "cb26ad8a-9ae5-4634-9c1b-7fafb7ecfdd5", "email": "qqq@qqq.qqq", "email_verified": false, "phone_verified": false}', 'email', '2025-11-15 22:18:19.242072+00', '2025-11-15 22:18:19.2421+00', '2025-11-15 22:18:19.2421+00', 'a6fcb5f8-d444-4efc-94b2-9e1164cfdb4c'),
	('56794987-8cd6-4c57-a376-9ebb831d7247', '56794987-8cd6-4c57-a376-9ebb831d7247', '{"sub": "56794987-8cd6-4c57-a376-9ebb831d7247", "email": "qqq@qqq.qqqq", "email_verified": false, "phone_verified": false}', 'email', '2025-11-15 22:19:33.760944+00', '2025-11-15 22:19:33.760962+00', '2025-11-15 22:19:33.760962+00', 'fe0f3a94-f6a5-4cb9-b894-c5e0b4f66b3d'),
	('1dd44748-ddc6-4a89-b9f3-7a43a41d205a', '1dd44748-ddc6-4a89-b9f3-7a43a41d205a', '{"sub": "1dd44748-ddc6-4a89-b9f3-7a43a41d205a", "email": "rrr@rrr.rrr", "email_verified": false, "phone_verified": false}', 'email', '2025-11-15 22:24:25.357887+00', '2025-11-15 22:24:25.357913+00', '2025-11-15 22:24:25.357913+00', 'ccae54f6-2203-4736-8d08-93200b9aa240'),
	('1de0172a-7664-4e07-80a0-4010e41d0509', '1de0172a-7664-4e07-80a0-4010e41d0509', '{"sub": "1de0172a-7664-4e07-80a0-4010e41d0509", "email": "qqq@qqqq.q", "email_verified": false, "phone_verified": false}', 'email', '2025-11-15 22:35:34.985617+00', '2025-11-15 22:35:34.985638+00', '2025-11-15 22:35:34.985638+00', '9568f5af-449e-4532-b249-a8de79b2671e'),
	('4447805b-5a21-4446-8e76-cfcc95555b4e', '4447805b-5a21-4446-8e76-cfcc95555b4e', '{"sub": "4447805b-5a21-4446-8e76-cfcc95555b4e", "email": "aaa@aaaa.pl", "email_verified": true, "phone_verified": false}', 'email', '2025-11-15 22:46:27.670378+00', '2025-11-15 22:46:27.670398+00', '2025-11-15 22:46:27.670398+00', '0d97ad1f-85c2-4ae6-9c71-ffd1dec8003f'),
	('09021b77-3bfb-4c88-82d9-a723f3499892', '09021b77-3bfb-4c88-82d9-a723f3499892', '{"sub": "09021b77-3bfb-4c88-82d9-a723f3499892", "email": "rrr@www.ooo2", "email_verified": true, "phone_verified": false}', 'email', '2025-11-15 22:55:51.970028+00', '2025-11-15 22:55:51.970047+00', '2025-11-15 22:55:51.970047+00', '4184bc2c-c5b8-495f-bb50-00990e0315c1'),
	('d89d9d8c-ca55-491e-848e-2ea511d40294', 'd89d9d8c-ca55-491e-848e-2ea511d40294', '{"sub": "d89d9d8c-ca55-491e-848e-2ea511d40294", "email": "qqqqqqq@aaaaaa.llll", "email_verified": true, "phone_verified": false}', 'email', '2025-11-15 23:22:56.851994+00', '2025-11-15 23:22:56.852013+00', '2025-11-15 23:22:56.852013+00', '56a6cec7-884a-4b26-b9f9-b7dbe8c9c6d7'),
	('70b079c7-e216-4084-b96a-7f4de3ea23cc', '70b079c7-e216-4084-b96a-7f4de3ea23cc', '{"sub": "70b079c7-e216-4084-b96a-7f4de3ea23cc", "email": "yyyy@yyyy.yyy", "email_verified": false, "phone_verified": false}', 'email', '2025-11-15 23:30:28.091572+00', '2025-11-15 23:30:28.091594+00', '2025-11-15 23:30:28.091594+00', '436560b7-d003-4ede-9e6d-c54c7b9d3081'),
	('87330a64-e6b2-496b-b8d9-8bbbf5c138ec', '87330a64-e6b2-496b-b8d9-8bbbf5c138ec', '{"sub": "87330a64-e6b2-496b-b8d9-8bbbf5c138ec", "email": "zzz@zzz.pl", "email_verified": false, "phone_verified": false}', 'email', '2025-11-15 23:40:58.829117+00', '2025-11-15 23:40:58.829137+00', '2025-11-15 23:40:58.829137+00', '120ebfc6-f204-41bf-96dd-3297fed12db4');


--
-- Data for Name: instances; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: oauth_clients; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: sessions; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

INSERT INTO "auth"."sessions" ("id", "user_id", "created_at", "updated_at", "factor_id", "aal", "not_after", "refreshed_at", "user_agent", "ip", "tag", "oauth_client_id") VALUES
	('7842fe5a-8484-447f-a5cc-4a7e7c7fd2a7', '347ef2e1-28e0-4d3e-8287-3c3d60a58a2b', '2025-11-15 22:17:36.644857+00', '2025-11-15 22:17:36.644857+00', NULL, 'aal1', NULL, NULL, 'node', '172.18.0.1', NULL, NULL),
	('bc54565f-1e8d-40a8-a88a-77252f6d78c8', 'cb26ad8a-9ae5-4634-9c1b-7fafb7ecfdd5', '2025-11-15 22:18:19.247837+00', '2025-11-15 22:18:19.247837+00', NULL, 'aal1', NULL, NULL, 'node', '172.18.0.1', NULL, NULL),
	('a85a65b3-7b61-40c1-8624-a2803c86e93c', '56794987-8cd6-4c57-a376-9ebb831d7247', '2025-11-15 22:19:33.765605+00', '2025-11-15 22:19:33.765605+00', NULL, 'aal1', NULL, NULL, 'node', '172.18.0.1', NULL, NULL),
	('16494cb6-f346-4d0d-b2b1-174250c54103', '1de0172a-7664-4e07-80a0-4010e41d0509', '2025-11-15 22:35:34.991279+00', '2025-11-15 22:35:34.991279+00', NULL, 'aal1', NULL, NULL, 'node', '172.18.0.1', NULL, NULL),
	('b9d75a5a-7652-4b77-8789-1e5f337670e5', '3973b11e-118a-4933-b752-f78cc7469daf', '2025-11-16 07:20:17.714011+00', '2025-11-16 07:20:17.714011+00', NULL, 'aal1', NULL, NULL, 'node', '172.18.0.1', NULL, NULL);


--
-- Data for Name: mfa_amr_claims; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

INSERT INTO "auth"."mfa_amr_claims" ("session_id", "created_at", "updated_at", "authentication_method", "id") VALUES
	('7842fe5a-8484-447f-a5cc-4a7e7c7fd2a7', '2025-11-15 22:17:36.647859+00', '2025-11-15 22:17:36.647859+00', 'password', 'dc2c6bb6-7403-4057-a935-93f84e0d3cf0'),
	('bc54565f-1e8d-40a8-a88a-77252f6d78c8', '2025-11-15 22:18:19.249169+00', '2025-11-15 22:18:19.249169+00', 'password', '36bdc6ff-fdeb-4875-b757-2601d8e89f6e'),
	('a85a65b3-7b61-40c1-8624-a2803c86e93c', '2025-11-15 22:19:33.766722+00', '2025-11-15 22:19:33.766722+00', 'password', '4ec123ea-fba2-450b-b7bb-0c433d9e4502'),
	('16494cb6-f346-4d0d-b2b1-174250c54103', '2025-11-15 22:35:34.992873+00', '2025-11-15 22:35:34.992873+00', 'password', '70771706-7d54-4587-a18a-6487c9a50c8f'),
	('b9d75a5a-7652-4b77-8789-1e5f337670e5', '2025-11-16 07:20:17.715419+00', '2025-11-16 07:20:17.715419+00', 'password', 'f6377816-d517-48ce-aa14-a8da99ceb8ab');


--
-- Data for Name: mfa_factors; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: mfa_challenges; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: oauth_authorizations; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: oauth_consents; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: one_time_tokens; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

INSERT INTO "auth"."refresh_tokens" ("instance_id", "id", "token", "user_id", "revoked", "created_at", "updated_at", "parent", "session_id") VALUES
	('00000000-0000-0000-0000-000000000000', 12, '6jrwwse7og7p', '347ef2e1-28e0-4d3e-8287-3c3d60a58a2b', false, '2025-11-15 22:17:36.645889+00', '2025-11-15 22:17:36.645889+00', NULL, '7842fe5a-8484-447f-a5cc-4a7e7c7fd2a7'),
	('00000000-0000-0000-0000-000000000000', 13, 'rmrqe2aja7g7', 'cb26ad8a-9ae5-4634-9c1b-7fafb7ecfdd5', false, '2025-11-15 22:18:19.248389+00', '2025-11-15 22:18:19.248389+00', NULL, 'bc54565f-1e8d-40a8-a88a-77252f6d78c8'),
	('00000000-0000-0000-0000-000000000000', 14, 'q65a5vgsqhan', '56794987-8cd6-4c57-a376-9ebb831d7247', false, '2025-11-15 22:19:33.766013+00', '2025-11-15 22:19:33.766013+00', NULL, 'a85a65b3-7b61-40c1-8624-a2803c86e93c'),
	('00000000-0000-0000-0000-000000000000', 16, 'ku7z56hvilbi', '1de0172a-7664-4e07-80a0-4010e41d0509', false, '2025-11-15 22:35:34.991881+00', '2025-11-15 22:35:34.991881+00', NULL, '16494cb6-f346-4d0d-b2b1-174250c54103'),
	('00000000-0000-0000-0000-000000000000', 60, 'r5c5vxxastiv', '3973b11e-118a-4933-b752-f78cc7469daf', false, '2025-11-16 07:20:17.714647+00', '2025-11-16 07:20:17.714647+00', NULL, 'b9d75a5a-7652-4b77-8789-1e5f337670e5');


--
-- Data for Name: sso_providers; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: saml_providers; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: saml_relay_states; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: sso_domains; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: profiles; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."profiles" ("id", "username", "location_text", "location_geog", "rodo_consent", "created_at", "updated_at", "is_complete") VALUES
	('0fc43071-195f-445a-ac6c-80319d362d66', 'atomek', 'Warszawa - Śródmieście', '0101000020E6100000DE02098A1F03354013F241CF661D4A40', true, '2025-11-07 15:30:57.476+00', '2025-11-15 11:05:35.307069+00', true),
	('1f587053-c01e-4aa6-8931-33567ca6a080', 'romek', '72-123', '0101000020E6100000865AD3BCE3F4344075931804561E4A40', true, '2025-11-07 15:30:57.476+00', '2025-11-15 19:34:15.447504+00', true),
	('3973b11e-118a-4933-b752-f78cc7469daf', 'maciej', 'Warszawa - Wola', '0101000020E6100000865AD3BCE3F4344075931804561E4A40', true, '2025-11-07 15:30:57.476+00', '2025-11-15 19:34:25.135645+00', true),
	('b79685eb-78d6-46de-96d5-a8325b4ca05d', 'tytus', 'Warszawa - Praga-Południe', '0101000020E6100000C1CAA145B6133540AC1C5A643B1F4A40', true, '2025-11-07 15:30:57.476+00', '2025-11-15 19:34:28.351549+00', true),
	('09021b77-3bfb-4c88-82d9-a723f3499892', 'rrr@www.ooo2', '72-123', NULL, true, '2025-11-15 22:55:51.954268+00', '2025-11-15 22:58:46.253987+00', false),
	('d89d9d8c-ca55-491e-848e-2ea511d40294', 'qqqqqqq@aaaaaa.llll', NULL, NULL, false, '2025-11-15 23:22:56.84974+00', '2025-11-15 23:22:56.84974+00', false),
	('70b079c7-e216-4084-b96a-7f4de3ea23cc', 'yyyy@yyyy.yyy', NULL, NULL, false, '2025-11-15 23:30:28.071122+00', '2025-11-15 23:30:28.071122+00', false),
	('87330a64-e6b2-496b-b8d9-8bbbf5c138ec', 'zzz@zzz.pl', NULL, NULL, false, '2025-11-15 23:40:58.808573+00', '2025-11-15 23:40:58.808573+00', false);


--
-- Data for Name: tools; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."tools" ("id", "owner_id", "name", "description", "suggested_price_tokens", "status", "search_name_tsv", "created_at", "updated_at", "archived_at") VALUES
	('4a57b044-c675-4418-ae8d-00cbc6d4ac7f', '0fc43071-195f-445a-ac6c-80319d362d66', 'Wkrętarka - atomek #1 [seed-05c97a]', 'Egzemplarz w dobrym stanie, gotowy do pracy. Akcesoria na zapytanie.', 2, 'active', '''05c97a'':6 ''1'':3 ''atomek'':2 ''seed'':5 ''seed-05c97a'':4 ''wkrętarka'':1', '2025-11-07 15:30:57.476+00', '2025-11-07 15:30:57.476+00', NULL),
	('3195257d-f050-4fdd-b73f-2c7691ea1c5b', '0fc43071-195f-445a-ac6c-80319d362d66', 'Szlifierka kątowa - atomek #2 [seed-05c97a]', 'Egzemplarz w dobrym stanie, gotowy do pracy. Akcesoria na zapytanie.', 3, 'active', '''05c97a'':7 ''2'':4 ''atomek'':3 ''kątowa'':2 ''seed'':6 ''seed-05c97a'':5 ''szlifierka'':1', '2025-11-07 15:30:57.476+00', '2025-11-07 15:30:57.476+00', NULL),
	('395101c6-e505-4b99-877b-d21ef1fbe4e0', '0fc43071-195f-445a-ac6c-80319d362d66', 'Piła ręczna - atomek #3 [seed-05c97a]', 'Egzemplarz w dobrym stanie, gotowy do pracy. Akcesoria na zapytanie.', 4, 'active', '''05c97a'':7 ''3'':4 ''atomek'':3 ''piła'':1 ''ręczna'':2 ''seed'':6 ''seed-05c97a'':5', '2025-11-07 15:30:57.476+00', '2025-11-07 15:30:57.476+00', NULL),
	('d6877d21-70dd-4cb1-900e-ac43e881dd28', '0fc43071-195f-445a-ac6c-80319d362d66', 'Młotek stolarski - atomek #4 [seed-05c97a]', 'Egzemplarz w dobrym stanie, gotowy do pracy. Akcesoria na zapytanie.', 5, 'active', '''05c97a'':7 ''4'':4 ''atomek'':3 ''młotek'':1 ''seed'':6 ''seed-05c97a'':5 ''stolarski'':2', '2025-11-07 15:30:57.476+00', '2025-11-07 15:30:57.476+00', NULL),
	('942bbe95-2f85-4943-93f3-179485f824a6', '0fc43071-195f-445a-ac6c-80319d362d66', 'Klucz nasadowy - atomek #5 [seed-05c97a]', 'Egzemplarz w dobrym stanie, gotowy do pracy. Akcesoria na zapytanie.', 1, 'active', '''05c97a'':7 ''5'':4 ''atomek'':3 ''klucz'':1 ''nasadowy'':2 ''seed'':6 ''seed-05c97a'':5', '2025-11-07 15:30:57.476+00', '2025-11-07 15:30:57.476+00', NULL),
	('83fdef2a-cff6-4bc1-a029-d84c9d7d3a54', '0fc43071-195f-445a-ac6c-80319d362d66', 'Kosiarka elektryczna - atomek #6 [seed-05c97a]', 'Egzemplarz w dobrym stanie, gotowy do pracy. Akcesoria na zapytanie.', 2, 'active', '''05c97a'':7 ''6'':4 ''atomek'':3 ''elektryczna'':2 ''kosiarka'':1 ''seed'':6 ''seed-05c97a'':5', '2025-11-07 15:30:57.476+00', '2025-11-07 15:30:57.476+00', NULL),
	('54b4d70f-3f01-4cb6-a94d-61bed16ab11a', '1f587053-c01e-4aa6-8931-33567ca6a080', 'Piła ręczna - romek #1 [seed-05c97a]', 'Egzemplarz w dobrym stanie, gotowy do pracy. Akcesoria na zapytanie.', 3, 'active', '''05c97a'':7 ''1'':4 ''piła'':1 ''romek'':3 ''ręczna'':2 ''seed'':6 ''seed-05c97a'':5', '2025-11-07 15:30:57.476+00', '2025-11-07 15:30:57.476+00', NULL),
	('e4f2b658-373c-4656-bcee-472cfb84ea74', '1f587053-c01e-4aa6-8931-33567ca6a080', 'Młotek stolarski - romek #2 [seed-05c97a]', 'Egzemplarz w dobrym stanie, gotowy do pracy. Akcesoria na zapytanie.', 4, 'active', '''05c97a'':7 ''2'':4 ''młotek'':1 ''romek'':3 ''seed'':6 ''seed-05c97a'':5 ''stolarski'':2', '2025-11-07 15:30:57.476+00', '2025-11-07 15:30:57.476+00', NULL),
	('9b35c494-e01c-4a34-89a2-959efe5ac2c6', '1f587053-c01e-4aa6-8931-33567ca6a080', 'Kosiarka elektryczna - romek #4 [seed-05c97a]', 'Egzemplarz w dobrym stanie, gotowy do pracy. Akcesoria na zapytanie.', 1, 'active', '''05c97a'':7 ''4'':4 ''elektryczna'':2 ''kosiarka'':1 ''romek'':3 ''seed'':6 ''seed-05c97a'':5', '2025-11-07 15:30:57.476+00', '2025-11-07 15:30:57.476+00', NULL),
	('76ea0bbf-a9eb-4144-abeb-f590fb8cde02', '1f587053-c01e-4aa6-8931-33567ca6a080', 'Myjka ciśnieniowa - romek #6 [seed-05c97a]', 'Egzemplarz w dobrym stanie, gotowy do pracy. Akcesoria na zapytanie.', 3, 'active', '''05c97a'':7 ''6'':4 ''ciśnieniowa'':2 ''myjka'':1 ''romek'':3 ''seed'':6 ''seed-05c97a'':5', '2025-11-07 15:30:57.476+00', '2025-11-07 15:30:57.476+00', NULL),
	('71b2d07e-63d4-4f1d-84d7-b0c10e1527d2', '3973b11e-118a-4933-b752-f78cc7469daf', 'Klucz nasadowy - maciej #1 [seed-05c97a]', 'Egzemplarz w dobrym stanie, gotowy do pracy. Akcesoria na zapytanie.', 4, 'active', '''05c97a'':7 ''1'':4 ''klucz'':1 ''maciej'':3 ''nasadowy'':2 ''seed'':6 ''seed-05c97a'':5', '2025-11-07 15:30:57.476+00', '2025-11-07 15:30:57.476+00', NULL),
	('1c975e66-1466-411d-a3a2-eff960eec214', '3973b11e-118a-4933-b752-f78cc7469daf', 'Kosiarka elektryczna - maciej #2 [seed-05c97a]', 'Egzemplarz w dobrym stanie, gotowy do pracy. Akcesoria na zapytanie.', 5, 'active', '''05c97a'':7 ''2'':4 ''elektryczna'':2 ''kosiarka'':1 ''maciej'':3 ''seed'':6 ''seed-05c97a'':5', '2025-11-07 15:30:57.476+00', '2025-11-07 15:30:57.476+00', NULL),
	('87476300-72db-48bc-9184-bb8aacaa4387', '3973b11e-118a-4933-b752-f78cc7469daf', 'Nożyce do żywopłotu - maciej #3 [seed-05c97a]', 'Egzemplarz w dobrym stanie, gotowy do pracy. Akcesoria na zapytanie.', 1, 'active', '''05c97a'':8 ''3'':5 ''do'':2 ''maciej'':4 ''nożyce'':1 ''seed'':7 ''seed-05c97a'':6 ''żywopłotu'':3', '2025-11-07 15:30:57.476+00', '2025-11-07 15:30:57.476+00', NULL),
	('236fb360-277b-43a6-8f00-c3355703926e', '3973b11e-118a-4933-b752-f78cc7469daf', 'Myjka ciśnieniowa - maciej #4 [seed-05c97a]', 'Egzemplarz w dobrym stanie, gotowy do pracy. Akcesoria na zapytanie.', 2, 'active', '''05c97a'':7 ''4'':4 ''ciśnieniowa'':2 ''maciej'':3 ''myjka'':1 ''seed'':6 ''seed-05c97a'':5', '2025-11-07 15:30:57.476+00', '2025-11-07 15:30:57.476+00', NULL),
	('1b422aaf-99cb-43d5-bc9f-e4a852c25039', '3973b11e-118a-4933-b752-f78cc7469daf', 'Drabina aluminiowa - maciej #5 [seed-05c97a]', 'Egzemplarz w dobrym stanie, gotowy do pracy. Akcesoria na zapytanie.', 3, 'active', '''05c97a'':7 ''5'':4 ''aluminiowa'':2 ''drabina'':1 ''maciej'':3 ''seed'':6 ''seed-05c97a'':5', '2025-11-07 15:30:57.476+00', '2025-11-07 15:30:57.476+00', NULL),
	('d374081d-292c-4716-a7c2-cdc72d54aee9', '3973b11e-118a-4933-b752-f78cc7469daf', 'Wiertarka udarowa - maciej #6 [seed-05c97a]', 'Egzemplarz w dobrym stanie, gotowy do pracy. Akcesoria na zapytanie.', 4, 'active', '''05c97a'':7 ''6'':4 ''maciej'':3 ''seed'':6 ''seed-05c97a'':5 ''udarowa'':2 ''wiertarka'':1', '2025-11-07 15:30:57.476+00', '2025-11-07 15:30:57.476+00', NULL),
	('d824714a-3d41-4398-8943-783c03db3395', 'b79685eb-78d6-46de-96d5-a8325b4ca05d', 'Nożyce do żywopłotu - tytus #1 [seed-05c97a]', 'Egzemplarz w dobrym stanie, gotowy do pracy. Akcesoria na zapytanie.', 5, 'active', '''05c97a'':8 ''1'':5 ''do'':2 ''nożyce'':1 ''seed'':7 ''seed-05c97a'':6 ''tytus'':4 ''żywopłotu'':3', '2025-11-07 15:30:57.476+00', '2025-11-07 15:30:57.476+00', NULL),
	('9a0db2e0-de38-4192-8d32-bd9d33c976de', 'b79685eb-78d6-46de-96d5-a8325b4ca05d', 'Myjka ciśnieniowa - tytus #2 [seed-05c97a]', 'Egzemplarz w dobrym stanie, gotowy do pracy. Akcesoria na zapytanie.', 1, 'active', '''05c97a'':7 ''2'':4 ''ciśnieniowa'':2 ''myjka'':1 ''seed'':6 ''seed-05c97a'':5 ''tytus'':3', '2025-11-07 15:30:57.476+00', '2025-11-07 15:30:57.476+00', NULL),
	('6fe0f3d2-4ad5-4f2c-b21d-d4a066e50eb8', 'b79685eb-78d6-46de-96d5-a8325b4ca05d', 'Drabina aluminiowa - tytus #3 [seed-05c97a]', 'Egzemplarz w dobrym stanie, gotowy do pracy. Akcesoria na zapytanie.', 2, 'active', '''05c97a'':7 ''3'':4 ''aluminiowa'':2 ''drabina'':1 ''seed'':6 ''seed-05c97a'':5 ''tytus'':3', '2025-11-07 15:30:57.476+00', '2025-11-07 15:30:57.476+00', NULL),
	('b86baca8-04f7-4df6-94f9-b5c2f67eb1f1', 'b79685eb-78d6-46de-96d5-a8325b4ca05d', 'Wiertarka udarowa - tytus #4 [seed-05c97a]', 'Egzemplarz w dobrym stanie, gotowy do pracy. Akcesoria na zapytanie.', 3, 'active', '''05c97a'':7 ''4'':4 ''seed'':6 ''seed-05c97a'':5 ''tytus'':3 ''udarowa'':2 ''wiertarka'':1', '2025-11-07 15:30:57.476+00', '2025-11-07 15:30:57.476+00', NULL),
	('d213d69e-7975-4c52-bde8-1950c3c38279', 'b79685eb-78d6-46de-96d5-a8325b4ca05d', 'Wkrętarka - tytus #5 [seed-05c97a]', 'Egzemplarz w dobrym stanie, gotowy do pracy. Akcesoria na zapytanie.', 4, 'active', '''05c97a'':6 ''5'':3 ''seed'':5 ''seed-05c97a'':4 ''tytus'':2 ''wkrętarka'':1', '2025-11-07 15:30:57.476+00', '2025-11-07 15:30:57.476+00', NULL),
	('cd727031-ac68-49ee-b262-3a4b4dec2d8f', 'b79685eb-78d6-46de-96d5-a8325b4ca05d', 'Szlifierka kątowa - tytus #6 [seed-05c97a]', 'Egzemplarz w dobrym stanie, gotowy do pracy. Akcesoria na zapytanie.', 5, 'active', '''05c97a'':7 ''6'':4 ''kątowa'':2 ''seed'':6 ''seed-05c97a'':5 ''szlifierka'':1 ''tytus'':3', '2025-11-07 15:30:57.476+00', '2025-11-07 15:30:57.476+00', NULL),
	('35089eb7-36ec-48c3-b779-19105c034e53', '1f587053-c01e-4aa6-8931-33567ca6a080', 'Nożyce do żywopłotu - romek #5 [seed-05c97a]', 'Egzemplarz w dobrym stanie, gotowy do pracy. Akcesoria na zapytanie.', 2, 'draft', '''05c97a'':8 ''5'':5 ''do'':2 ''nożyce'':1 ''romek'':4 ''seed'':7 ''seed-05c97a'':6 ''żywopłotu'':3', '2025-11-07 15:30:57.476+00', '2025-11-12 15:28:40.428105+00', NULL),
	('5405bb7b-fb21-47df-b9b2-e4db81bc9bbd', '1f587053-c01e-4aa6-8931-33567ca6a080', 'YARLA YACHTS', 'Aaaaa', 5, 'active', '''yachts'':2 ''yarla'':1', '2025-11-12 12:39:20.496537+00', '2025-11-12 12:39:41.875103+00', NULL),
	('a75a901c-cfee-421c-b34b-92a3c34fe890', '1f587053-c01e-4aa6-8931-33567ca6a080', 'Glebogryzarka', 'ssssss', 3, 'draft', '''glebogryzarka'':1', '2025-11-12 12:30:24.987789+00', '2025-11-12 12:35:19.402541+00', NULL),
	('ee3a8dbc-ccb6-4f07-b2e7-6f25c7ed33ab', '1f587053-c01e-4aa6-8931-33567ca6a080', 'Glebogryzarka', 'ssssss', 3, 'draft', '''glebogryzarka'':1', '2025-11-12 12:35:19.383533+00', '2025-11-12 12:35:19.422619+00', NULL),
	('0ddcf029-df3c-420a-90d7-afa7f49cfafc', '1f587053-c01e-4aa6-8931-33567ca6a080', 'Klucz nasadowy - romek #3 [seed-05c97a]', 'Egzemplarz w dobrym stanie, gotowy do pracy. Akcesoria na zapytanie.', 5, 'draft', '''05c97a'':7 ''3'':4 ''klucz'':1 ''nasadowy'':2 ''romek'':3 ''seed'':6 ''seed-05c97a'':5', '2025-11-07 15:30:57.476+00', '2025-11-12 13:53:11.730156+00', NULL),
	('70c34f24-3723-48f2-8354-c59880b7144b', '1f587053-c01e-4aa6-8931-33567ca6a080', 'sssss', '', 1, 'draft', '''sssss'':1', '2025-11-12 14:23:27.046096+00', '2025-11-12 14:24:03.06042+00', NULL),
	('47d5ffc8-e25b-4bab-b2de-7558cdd4901e', '1f587053-c01e-4aa6-8931-33567ca6a080', 'Glebogryzarka', 'asssss', 3, 'active', '''glebogryzarka'':1', '2025-11-12 12:36:01.990502+00', '2025-11-12 12:36:12.512125+00', NULL),
	('47dfb404-88ea-4df4-9b60-d4072d3a4c00', '1f587053-c01e-4aa6-8931-33567ca6a080', 'sssss', '', 1, 'draft', '''sssss'':1', '2025-11-12 14:24:03.043919+00', '2025-11-12 14:26:12.191097+00', NULL),
	('3ba54133-fba5-4b73-9ce4-8f3939eccc2a', '1f587053-c01e-4aa6-8931-33567ca6a080', 'YARLA YACHTS 3', '2222', 3, 'archived', '''3'':3 ''yachts'':2 ''yarla'':1', '2025-11-12 14:18:16.985654+00', '2025-11-12 14:26:20.839018+00', NULL),
	('be84b6fa-294f-43f8-bef5-6977906c9e74', '1f587053-c01e-4aa6-8931-33567ca6a080', 'YARLA YACHTS 23332', 'Aaaaaa 3333', 5, 'archived', '''23332'':3 ''yachts'':2 ''yarla'':1', '2025-11-12 13:57:43.059255+00', '2025-11-12 15:27:41.584631+00', NULL),
	('ed5c4251-5b43-49fa-b9fb-0a011868dba7', '1f587053-c01e-4aa6-8931-33567ca6a080', 'wwwww', 'wwwwwwwww', 1, 'archived', '''wwwww'':1', '2025-11-12 15:13:41.108664+00', '2025-11-14 11:00:51.140663+00', NULL),
	('8ffebbb4-4c1c-4a1f-a478-7be74a5b95a0', '1f587053-c01e-4aa6-8931-33567ca6a080', 'wwwww2', 'qqqqqq', 2, 'archived', '''wwwww2'':1', '2025-11-12 15:13:20.147879+00', '2025-11-14 11:13:49.835126+00', NULL),
	('65c7c171-a92e-4bcc-a2ad-1c8d350fd1f6', '1f587053-c01e-4aa6-8931-33567ca6a080', 'qqqqq22211 122', 'wwwww', 3, 'active', '''122'':2 ''qqqqq22211'':1', '2025-11-14 11:37:09.207494+00', '2025-11-14 11:37:24.569519+00', NULL),
	('89d7ee5c-902b-42e3-baba-d1310828888e', '1f587053-c01e-4aa6-8931-33567ca6a080', 'qqqq', 'wwwww', 1, 'draft', '''qqqq'':1', '2025-11-15 09:40:32.222683+00', '2025-11-15 09:40:52.863988+00', NULL),
	('06ff89c9-3fbc-46ef-8f85-3f36adea1f2a', '1f587053-c01e-4aa6-8931-33567ca6a080', 'aaaaaa', '', 1, 'draft', '''aaaaaa'':1', '2025-11-15 09:37:28.643455+00', '2025-11-15 09:37:36.737353+00', NULL),
	('2082c326-6fbe-4bb5-9689-5257bb1ad7c2', '1f587053-c01e-4aa6-8931-33567ca6a080', 'aaaawww', '', 1, 'draft', '''aaaawww'':1', '2025-11-15 09:37:57.982296+00', '2025-11-15 09:38:08.582586+00', NULL),
	('de889366-c54a-4de5-aaf8-308a7e5b6c23', '1f587053-c01e-4aa6-8931-33567ca6a080', 'ccccccc222', 'wwwwwww', 4, 'draft', '''ccccccc222'':1', '2025-11-15 09:42:29.048969+00', '2025-11-15 09:42:39.539951+00', NULL),
	('4eb130a6-855b-4d1d-ab64-2b0b85575101', '1f587053-c01e-4aa6-8931-33567ca6a080', 'wwwwww', 'wwwwww', 5, 'draft', '''wwwwww'':1', '2025-11-15 09:42:56.089192+00', '2025-11-15 09:42:58.410291+00', NULL),
	('614c7653-94f2-48d2-bb65-c443663efb88', '1f587053-c01e-4aa6-8931-33567ca6a080', 'Maciej2', 'wwwwww', 1, 'draft', '''maciej2'':1', '2025-11-15 09:43:34.762526+00', '2025-11-15 09:44:25.772256+00', NULL),
	('7ad85121-c17f-4c91-960f-2c713170a98c', '1f587053-c01e-4aa6-8931-33567ca6a080', 'wwwww2222', 'wwwww', 1, 'draft', '''wwwww2222'':1', '2025-11-15 09:47:04.143578+00', '2025-11-15 09:47:16.303071+00', NULL),
	('01156fb3-785b-4b49-b512-c8966ba50f0c', '1f587053-c01e-4aa6-8931-33567ca6a080', 'aaaa22', 'ssssswwww', 5, 'draft', '''aaaa22'':1', '2025-11-15 09:45:27.153705+00', '2025-11-15 09:45:59.276693+00', NULL),
	('d3e51fbf-9167-4a04-adc4-a85e007937a9', '1f587053-c01e-4aa6-8931-33567ca6a080', 'bbbbbb', 'bbbbbbb', 1, 'draft', '''bbbbbb'':1', '2025-11-15 10:02:15.470874+00', '2025-11-15 19:32:19.12214+00', NULL);


--
-- Data for Name: reservations; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."reservations" ("id", "tool_id", "owner_id", "borrower_id", "status", "agreed_price_tokens", "cancelled_reason", "created_at", "updated_at") VALUES
	('a48494c5-ca6f-4937-ad1f-2ed9d01fecf2', '1b422aaf-99cb-43d5-bc9f-e4a852c25039', '3973b11e-118a-4933-b752-f78cc7469daf', '1f587053-c01e-4aa6-8931-33567ca6a080', 'requested', NULL, NULL, '2025-11-15 20:02:30.465275+00', '2025-11-15 20:02:30.465275+00'),
	('11a3f5e4-6390-43b3-bb23-335376bfecef', '1c975e66-1466-411d-a3a2-eff960eec214', '3973b11e-118a-4933-b752-f78cc7469daf', '1f587053-c01e-4aa6-8931-33567ca6a080', 'borrower_confirmed', 2, NULL, '2025-11-15 20:03:31.962396+00', '2025-11-15 20:45:07.914551+00');


--
-- Data for Name: audit_log; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."audit_log" ("id", "event_type", "actor_id", "reservation_id", "details", "created_at") VALUES
	('5ca698b1-4c55-4cfd-9585-88841faed199', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-10 11:49:58.983329+00'),
	('0f9d504f-ae89-4d5f-baa7-19528e462f4b', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-10 11:49:59.119747+00'),
	('f36b2529-81b7-407c-a0ef-ea4e6f19cc36', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-10 11:50:06.580172+00'),
	('41e7c732-62a5-4a70-94b9-6d3c8e9a33ad', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-10 11:50:27.973457+00'),
	('5bdc4bcf-95a1-44bc-9484-1dd8df304eb1', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 3, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-10 11:50:28.972182+00'),
	('59bc1ab3-4f76-4b11-b527-ed13caf887fe', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-10 11:50:29.000548+00'),
	('b4bdb72d-fa18-48cb-964c-992af7a0dd85', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-10 12:15:18.712195+00'),
	('c9c12eac-c118-4e52-ba7a-a8fa8b9613c2', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-10 12:27:28.502566+00'),
	('b037b627-d3d2-4078-85d0-6b73c26014b2', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-10 12:27:28.583701+00'),
	('00ab87f5-fc75-4113-9600-d30d5560faad', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-10 12:27:30.26715+00'),
	('67846f38-7850-4944-80ef-9e59c7176b24', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-10 12:27:30.73119+00'),
	('faf46885-946b-4ab5-b7e0-ad62e93e2e52', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 3, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-10 12:27:31.841935+00'),
	('4b5b276f-ad65-4792-ae9a-31b25ef66ae6', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-10 12:27:31.867288+00'),
	('0832315a-afc7-43ac-889b-555858b1aab5', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 3, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-10 12:28:17.132614+00'),
	('fa12a1cc-1c82-4deb-9f37-643f67a9745f', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-10 12:28:17.167496+00'),
	('9d1133bd-e4a0-4f0f-879d-60a7b4c8585a', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 3, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-10 12:28:43.803143+00'),
	('85054c74-2f33-46e8-9085-97595090252c', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-10 12:28:43.837432+00'),
	('67bac3ee-3894-48dc-9350-fbd622a7a139', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 3, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-10 12:30:21.563971+00'),
	('83d7e773-93fe-4bae-8003-dbe7aecfce00', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-10 12:30:21.592773+00'),
	('e01676d6-ee6d-4e24-8381-cfa0ae6c3a7d', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 3, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-10 12:31:31.618316+00'),
	('acc28d4f-33e8-47b3-9469-b5590de57175', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-10 12:31:31.675323+00'),
	('cf41c668-657b-4a2c-be3e-3f1e50ce6f77', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 3, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-10 14:09:37.160378+00'),
	('bbf7611c-3fdd-42b6-8c69-c1585297ca97', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-10 14:09:37.207242+00'),
	('4a8a6d4d-aa1e-4617-917b-da3d9a85e6e0', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 3, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-10 14:09:55.816625+00'),
	('c3a27b72-259c-4ff0-96d6-61cb93698ec6', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-10 14:09:55.839927+00'),
	('15512606-3da3-458f-acca-4e4cd31bba97', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 3, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-10 14:10:44.942979+00'),
	('99133a69-a47c-43b9-88a4-9a2154827265', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-10 14:10:44.966983+00'),
	('f9d4bb47-cf55-48da-86f4-6c4d81d5b58a', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 3, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-10 14:10:58.075308+00'),
	('8e2460fe-6fce-4cb2-b78b-8451cb36d3e3', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-10 14:10:58.116884+00'),
	('50ced619-b3e4-47b4-bcff-182b13e8d5f1', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 3, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-10 14:11:02.886824+00'),
	('b9ee0dee-1046-40f1-97c1-ee66e87e9d55', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-10 14:11:02.926141+00'),
	('29995efd-69d3-4b2d-b4bc-02ed74861fb9', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 3, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-10 14:20:50.167779+00'),
	('033ca1c4-ede3-4baf-9fa6-a8840a3564c7', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-10 14:20:50.196007+00'),
	('d4a052b6-9209-4837-a65e-45e6fe828c23', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-11 17:06:42.924402+00'),
	('65e8e84e-139f-44fe-a061-7d42735d7e21', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-11 17:06:43.326396+00'),
	('45ff1959-710e-4169-a2b5-64171afca769', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 3, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-11 17:06:44.419359+00'),
	('2b228fde-113a-4965-bc52-6511dba908e8', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-11 17:06:44.452678+00'),
	('091f2ddc-ebc5-42a4-b57b-4a7918e7817e', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 3, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-11 17:29:10.981773+00'),
	('82c6d9b2-4e44-4bc2-8bf5-e1822531aa8e', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-11 17:29:11.006764+00'),
	('388a2152-02a7-444f-9681-4f0bf674242d', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 3, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-11 17:31:16.820581+00'),
	('c36e3bdd-ac79-40e6-b309-17778f1e8ddf', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-11 17:31:16.849461+00'),
	('20d259b1-7e92-404c-a037-de1950759848', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 3, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-11 17:31:17.06143+00'),
	('b72b7ac8-7579-4c64-98e2-12b2f67d8f19', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-11 17:31:17.090195+00'),
	('0ebeb9b1-a679-4a88-90fc-a3d3f86928bc', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 3, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-11 17:31:25.321176+00'),
	('81b02595-2cc2-46ae-a23d-56ca66e421ef', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-11 17:31:25.35304+00'),
	('5fb50482-68b5-4aa2-8374-88ece5f2b959', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 3, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-11 17:33:19.236456+00'),
	('8786c05e-6cb7-4ba1-882d-0ffa006b6c6f', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-11 17:33:19.270451+00'),
	('d6bd485d-59b2-4d1f-a59e-aef546d3d594', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 3, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-11 17:39:10.072379+00'),
	('01f0bb95-5dc0-49b0-ae8f-3c3c880f59c8', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-11 17:39:10.104773+00'),
	('c992eaa6-6dcd-41c2-a3ff-dbd508de228d', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 3, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-11 17:39:10.246731+00'),
	('d4bd00a4-6c2a-457e-bc02-79a0d3a0a950', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-11 17:39:10.281795+00'),
	('f4978ba5-32a2-4041-a19e-eba91f5ef5de', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 3, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-11 17:51:56.550888+00'),
	('ed0c533d-36a2-4ad1-803b-ceb3a11b8170', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 3, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-11 17:51:56.663728+00'),
	('19842cb6-9d8a-4e58-9786-fe63f849ac91', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-11 17:51:56.868138+00'),
	('e5b81e6d-59e8-4bb3-b2d4-a6d4fbaaedea', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 3, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-12 11:00:48.374738+00'),
	('2d776204-ab1f-40f5-8163-a3e1f7d2c356', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-12 11:00:48.40421+00'),
	('3538be42-349c-4dd0-80a1-dad9b87af93c', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 3, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-12 11:00:48.512196+00'),
	('6813c08f-db5b-439e-b494-5eed2e38b4d0', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-12 11:00:48.543626+00'),
	('75c450cb-b917-4135-8700-d24c5b937610', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 3, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-12 11:12:38.094708+00'),
	('37e14389-330e-4068-81ac-20063cababf0', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-12 11:12:38.125264+00'),
	('5b783ee6-cb82-4dbb-ba40-886667193e76', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 3, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-12 11:12:38.238806+00'),
	('1245a683-148c-41e4-9f9e-a9ca8b966259', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-12 11:12:38.262811+00'),
	('bd2420ea-5fcb-4354-8507-bb3fd8bb9807', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 3, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-12 11:37:47.807635+00'),
	('98322b03-b490-4f05-b748-f0e5d95d9da9', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-12 11:37:47.841273+00'),
	('c791774b-1251-4008-b401-3ba587c5bc6d', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 3, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-12 11:37:47.897567+00'),
	('ecc16c7a-0149-449b-a505-2eee71d30551', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-12 11:37:47.922102+00'),
	('f7738b5b-8031-453a-a666-c58d5ae2643f', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-12 12:36:51.591866+00'),
	('430a5c95-08eb-4c10-b167-27d64eba88c3', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-12 12:36:51.693742+00'),
	('e9c7a3a1-b236-4ffb-ac01-c9cece69a259', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 1, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-12 12:36:55.494865+00'),
	('2bdbc9ca-61d9-444d-bc15-55017a0aa3b7', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-12 12:36:55.530445+00'),
	('3d1ebc0c-6194-40fa-8cea-b48fc38229b1', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 1, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-12 12:36:55.705181+00'),
	('4a884800-6469-4941-a84d-07ba3737e57e', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-12 12:36:55.732191+00'),
	('a7df5b9e-e4a1-40e7-b6c7-8f1c0f3b0551', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 1, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-12 12:48:45.951233+00'),
	('f540ba9c-38ad-4389-943b-194c675efa1d', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-12 12:48:46.028647+00'),
	('8bbae6f3-c7a6-43c5-9545-8bbac7b93e6a', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 1, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-12 12:48:46.140877+00'),
	('e723a29a-0d5f-4f08-879e-9c588fdbbdbb', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-12 12:48:46.18193+00'),
	('5547de29-ec4b-407c-8553-be90c33f25d9', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 3, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-12 12:51:31.120704+00'),
	('61af4c69-90ae-4a67-8604-a3fbe71c50cd', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 3, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-12 12:51:31.205409+00'),
	('0a30c0d5-5734-4e8e-8977-8a4a94e81239', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-12 12:51:31.256536+00'),
	('44242ca1-2e11-46a3-b687-43273fac7e1a', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 3, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-12 13:18:29.060049+00'),
	('a695374a-1d1d-4f18-aede-af5aabf8f946', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 3, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-12 13:18:29.181383+00'),
	('2a8212d3-2d89-4058-b9cf-9a53e9574bb8', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-12 13:18:29.181658+00'),
	('9748e75e-8cba-43ca-a160-5a6da3eaf1f2', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-12 13:18:29.204157+00'),
	('94036ba6-8cdb-4e25-acb0-92cc7b2517ff', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 3, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-12 13:22:11.131334+00'),
	('f36e4e92-429b-4bb3-ae62-e438050c3ee5', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-12 13:22:11.209846+00'),
	('86aaa98e-2947-4b8a-bfca-d9e651839c99', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 3, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-12 13:22:11.235684+00'),
	('5f5b98c8-aa2c-4d41-9a2d-a1ab3b0229d9', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-12 13:22:11.268273+00'),
	('b96c0c8b-e211-4d72-a80b-181835c4a2c9', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-12 13:22:16.932932+00'),
	('971b6372-8dda-4ccb-bb8c-f4c6499fa3ba', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-12 13:22:17.422875+00'),
	('50ae006b-566f-449c-a54e-34a2b06e25d1', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-12 13:22:18.131395+00'),
	('a9469cad-fb8d-4fae-902d-fd35ef1de2bc', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 1, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-12 13:22:18.590827+00'),
	('d7e937bb-a01b-411b-9054-9d9f8efc2795', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-12 13:22:18.62432+00'),
	('af6f9fdb-246b-4ac2-b256-4eba22d5cc1f', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 1, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-12 13:22:18.72292+00'),
	('41d9f302-1ad4-4ce7-98a1-e6a7c7be6f14', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-12 13:22:18.751141+00'),
	('3556074d-8c6a-4c3a-b27f-e95a67753ab4', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 3, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-12 13:26:54.969645+00'),
	('852d42c6-6ce7-46b7-91c5-a35e975bc28a', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 3, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-12 13:26:55.028272+00'),
	('17ff3ce2-73af-4f17-9264-8d80b49e58a6', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-12 13:26:55.035339+00'),
	('b14c0b13-7e17-4069-8b3a-87ba54657528', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-12 13:26:55.05297+00'),
	('caa7fbdd-3023-4566-807e-3b529da9b8a0', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-12 13:27:01.403914+00'),
	('f54a0f87-86b4-4d28-a19e-c9da9b8a0fa4', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 1, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-12 13:27:01.70517+00'),
	('0d9ca991-9409-47cc-857d-88b880b25e76', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-12 13:27:01.806137+00'),
	('a97ad3e8-3524-496a-9965-543fb98f68d4', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 1, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-12 13:27:01.956275+00'),
	('6777e5bb-7f5b-497c-aa27-52454309de02', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-12 13:27:02.044778+00'),
	('458621db-f1fa-4a69-875a-4ec196452a95', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 2, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-12 13:55:18.919194+00'),
	('ac13b4e9-dfb6-4ead-a73a-0b642e73ef7e', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-12 13:55:18.996715+00'),
	('09bdc1b2-4d19-4b56-8b07-124f14dfb4d0', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 2, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-12 13:55:19.088556+00'),
	('f7f69720-8d86-4966-a595-47e61dce3de4', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-12 13:55:19.125694+00'),
	('f47c1186-fc7b-49a7-85aa-d7229d878646', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 2, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-12 13:55:22.043473+00'),
	('e60a4b19-95c3-4b17-b9eb-20140ebede06', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-12 13:55:22.181714+00'),
	('7fa29133-1f62-48c8-af33-363758d49fa5', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 2, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-12 13:55:22.247629+00'),
	('dbb6bce6-5392-4d83-a340-515c81507cef', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-12 13:55:22.291626+00'),
	('5b36fff3-f0f1-4019-93a4-f240f6497711', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 2, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-12 13:58:32.124429+00'),
	('1689b311-5052-4485-878e-8b43a2bcf1b4', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-12 13:58:32.196756+00'),
	('9b92a29a-e229-4ef3-8e78-f6fe373d46b1', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 2, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-12 13:58:32.340953+00'),
	('5d05abc5-710d-4711-a8b7-d42db3d5b5fd', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-12 13:58:32.375608+00'),
	('cadc0784-221e-4a1e-9816-044418b5523b', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 1, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-12 13:58:38.395319+00'),
	('6faa98a8-9a69-4f0b-841a-b497d84ba2ef', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-12 13:58:38.444094+00'),
	('e993b144-f109-4beb-96d4-b6f5cd03fe34', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 1, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-12 13:58:38.607387+00'),
	('bba78659-c96a-4230-8c17-640d4ca465ac', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-12 13:58:38.633266+00'),
	('3d2676a9-d988-439d-bddf-da7778276e8f', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 2, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-12 13:59:07.265884+00'),
	('3f4ad69a-c581-4db8-a5fe-c1570ca05787', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-12 13:59:07.287714+00'),
	('98603fe6-3547-46cf-b0a7-8da592ce135b', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 2, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-12 13:59:07.555047+00'),
	('630e9f15-a93c-40c4-b774-5fa5e7fc57d5', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-12 13:59:07.615592+00'),
	('92d2e312-81e4-4b22-8be5-54b99e3ff552', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-12 14:53:01.801087+00'),
	('b0088f55-5452-4b7b-94de-b64c23598ae7', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-12 14:53:02.211635+00'),
	('5ae83b27-c9f1-4c38-a1d8-e6aa8dff773b', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-12 14:53:02.701704+00'),
	('bac63966-e7f8-4557-a9d0-32223dffcda5', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 2, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-12 14:53:03.175664+00'),
	('65bb763b-b8f3-4a81-ac37-6cb8cf8ee2f1', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 2, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-12 14:53:03.17735+00'),
	('9d301650-70b6-465f-a8ff-26a2a270baaa', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-12 14:53:03.200783+00'),
	('620c1ac3-5af4-4de6-9d00-2cfcd9d012f2', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 2, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-12 14:58:05.180835+00'),
	('fa17d49f-4226-405e-8b4a-728db1173493', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-12 14:58:05.228061+00'),
	('97445d75-22d8-479f-bf22-1eb8233b0880', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 2, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-12 14:58:05.352616+00'),
	('b98beb6b-1635-47d6-aebf-a6f808135ee3', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-12 14:58:05.388271+00'),
	('43a6b957-6657-45e6-b94e-3edd5293cd10', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-12 15:01:30.073418+00'),
	('ff3d7315-85f8-420d-b1b5-7ad7ba647ddd', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 2, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-12 15:01:31.732164+00'),
	('9c35bd02-e003-49c6-b8e1-388d7fa6034a', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-12 15:01:31.783359+00'),
	('1043d85f-592d-426c-8f78-dec9dd87d099', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 2, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-12 15:15:07.520902+00'),
	('f0b2fdfe-3423-42a1-b2a7-5006189b3690', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-12 15:15:07.569247+00'),
	('1b72cc11-2fa1-44a8-9cfa-99869a2f04ab', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 2, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-12 15:15:07.632943+00'),
	('d85ffaee-851a-4de4-ab3c-5cc838bfe6d0', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-12 15:15:07.66945+00'),
	('941af384-589c-4c42-9eac-70b9970b3884', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-14 12:22:03.530609+00'),
	('8aeca420-0632-49bd-a250-05f34052e385', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-14 12:22:06.640879+00'),
	('6e043434-187b-44e1-b540-c799c67e64d5', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 1, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-14 12:22:09.53579+00'),
	('b99fe1ab-e889-4f8d-a5ce-9a2eb400af6b', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-14 12:22:09.572521+00'),
	('17825976-850d-4952-bf2e-4b7abc9d336b', 'profile_read', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080"}', '2025-11-14 12:22:17.680256+00'),
	('10ed752b-24ac-4f40-bd93-4c9e0b697fe5', 'profile_read', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080"}', '2025-11-14 12:27:36.574812+00'),
	('33d08b11-3bf5-4239-9154-806d679c31f7', 'profile_update', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080", "geocode_triggered": false}', '2025-11-14 12:27:42.944254+00'),
	('a7fed9e4-436c-4c1b-a37d-f591079ab945', 'profile_read', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080"}', '2025-11-14 12:27:53.889193+00'),
	('7390c9f4-36cc-4b84-be76-a08816b8a656', 'profile_read', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080"}', '2025-11-14 12:32:32.952484+00'),
	('46750a6c-067e-4bdf-b83c-6caba0578e81', 'profile_read', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080"}', '2025-11-14 13:13:01.969726+00'),
	('d0966053-3875-4698-a982-27bd15123fae', 'profile_read', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080"}', '2025-11-14 13:49:14.72597+00'),
	('2d07657e-1724-42eb-a5bf-63a036181c44', 'profile_read', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080"}', '2025-11-14 14:04:56.840286+00'),
	('14f176fa-6d20-4c37-a075-109c9f72208f', 'profile_read', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080"}', '2025-11-14 14:40:53.724962+00'),
	('48558e57-1312-450f-a2ec-9d3de58bd17c', 'profile_read', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080"}', '2025-11-14 14:40:54.110825+00'),
	('40efc976-610a-4b6f-8448-eeea7d0c6b50', 'profile_read', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080"}', '2025-11-14 14:41:16.840552+00'),
	('923f0154-3659-447e-8821-05fdb7e8b193', 'profile_read', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080"}', '2025-11-14 14:41:17.502061+00'),
	('913fd4e4-7ad7-4675-af32-d9e33b36a7d0', 'profile_read', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080"}', '2025-11-14 14:41:41.1767+00'),
	('67052fe7-52f5-476c-8e03-9807f20c30a3', 'profile_read', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080"}', '2025-11-14 14:43:11.029537+00'),
	('d130df40-2a50-4da7-a6f9-4ad00b5c2411', 'profile_read', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080"}', '2025-11-14 14:43:16.893708+00'),
	('bd846770-c00b-46bc-bd5d-7f81276f7e35', 'profile_update', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080", "geocode_triggered": false}', '2025-11-14 14:43:24.071371+00'),
	('d085be9c-3c38-416f-a65a-a7747dbae9e8', 'profile_read', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080"}', '2025-11-14 14:43:43.382068+00'),
	('ce13e9ec-b7ce-460d-a4f0-c30ceac7f98b', 'profile_read', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080"}', '2025-11-14 15:54:00.873786+00'),
	('6600fdad-ffa2-4245-918d-5d609472b2dc', 'profile_read', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080"}', '2025-11-14 15:54:10.803721+00'),
	('f8195f8d-da5d-49ac-b7d4-54acaf49d6d6', 'profile_read', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080"}', '2025-11-14 15:54:35.623806+00'),
	('2109ea2c-97ea-4c3f-80c2-c45d62e81faf', 'profile_read', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080"}', '2025-11-14 15:56:03.240711+00'),
	('1b35905b-6893-4465-affb-436a28885c5b', 'profile_read', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080"}', '2025-11-14 15:56:15.350133+00'),
	('017a5eb3-f385-42a6-9d69-adcaff1958a1', 'profile_read', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080"}', '2025-11-14 15:56:27.143031+00'),
	('72578258-6723-4b8e-8c57-3e8a11771f75', 'profile_read', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080"}', '2025-11-14 15:57:22.188656+00'),
	('d0c33551-b602-4d45-846b-6c4cb4cacaba', 'profile_read', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080"}', '2025-11-14 15:57:36.585604+00'),
	('51f8e6b5-e02a-447f-81a1-57e8bef57a5a', 'profile_read', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080"}', '2025-11-14 15:57:46.387346+00'),
	('b08b684a-8dc0-4d45-b4f1-a6181eb00727', 'profile_update', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080", "geocode_triggered": false}', '2025-11-14 15:57:52.899417+00'),
	('bd15d28e-0c73-4396-9b44-2f821c2b32b0', 'profile_read', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080"}', '2025-11-14 15:57:56.290408+00'),
	('f9366eae-f43f-4db4-9135-05328710fc06', 'profile_update', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080", "geocode_triggered": false}', '2025-11-14 15:57:59.052239+00'),
	('0f8cb679-bb15-441e-af43-0ea53420659f', 'profile_update', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080", "geocode_triggered": false}', '2025-11-14 15:58:00.242877+00'),
	('979e67fe-15e9-4c11-81bc-32e0ccb48bf9', 'profile_read', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080"}', '2025-11-14 16:02:43.640048+00'),
	('31c01614-cf25-41c3-a090-d33b52d417a2', 'profile_read', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080"}', '2025-11-14 16:02:49.391808+00'),
	('00e04b86-6522-4fe2-956d-707c09e0a84f', 'profile_read', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080"}', '2025-11-14 16:03:04.473909+00'),
	('a67286b7-33c2-4abd-b129-2c341aab2d5a', 'profile_read', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080"}', '2025-11-14 16:03:09.67653+00'),
	('dc2452c3-46f4-4976-9b05-923c9aa72f16', 'profile_read', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080"}', '2025-11-14 16:03:22.310682+00'),
	('d21dbd62-28d9-4f28-a7f5-99c546725375', 'profile_read', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080"}', '2025-11-14 16:03:33.05715+00'),
	('e948c717-4b1b-441e-9bcb-7573699b66cc', 'profile_read', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080"}', '2025-11-14 16:07:06.273389+00'),
	('e83eb7c2-d841-4424-ae57-3f0ade408c8b', 'profile_read', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080"}', '2025-11-14 16:07:40.950185+00'),
	('9a229964-460e-4996-aa9d-a9954a0e91a6', 'profile_read', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080"}', '2025-11-14 16:07:45.192526+00'),
	('11f80fcc-3a61-42d6-947b-aaf3b31cfe33', 'profile_update', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080", "geocode_triggered": false}', '2025-11-14 16:09:39.561794+00'),
	('066973f6-177c-4430-9544-35ed5fb4aff1', 'profile_read', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080"}', '2025-11-14 16:09:40.093533+00'),
	('d1502d1b-c820-4d03-b676-a1dd8f05d587', 'profile_read', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080"}', '2025-11-14 16:09:43.401933+00'),
	('d208d089-a747-4f40-9b27-d9ae88bd500b', 'profile_read', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080"}', '2025-11-14 16:09:58.938764+00'),
	('ba101595-6fbc-478e-b8ee-724ced3569a8', 'profile_read', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080"}', '2025-11-14 16:10:00.002057+00'),
	('810370fe-b9bb-4246-b64b-0f78e861ee7e', 'profile_read', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080"}', '2025-11-14 16:10:01.385644+00'),
	('3a6e8bb4-be47-441b-a9ad-0efd0310c5ea', 'profile_read', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080"}', '2025-11-14 16:10:57.87001+00'),
	('26a886ef-2d27-41af-be1c-7fbdc317bd93', 'profile_read', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080"}', '2025-11-14 16:15:56.225872+00'),
	('cddaddc3-d2cc-4e14-929a-d4a4b4a366b0', 'profile_read', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080"}', '2025-11-14 16:16:17.899148+00'),
	('7b27ff3c-45d0-4560-85c5-0e45b213ade8', 'profile_read', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080"}', '2025-11-14 16:17:05.042639+00'),
	('f53383e5-1ddf-4deb-b660-df370d112db8', 'profile_read', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080"}', '2025-11-14 16:17:07.783907+00'),
	('5a84b028-2a80-477f-b22a-468eacef5f79', 'profile_read', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080"}', '2025-11-14 16:17:11.778162+00'),
	('4a2dc7f6-0b71-4b05-b47b-fdbbb85a6557', 'profile_read', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080"}', '2025-11-14 16:17:17.508166+00'),
	('77078bf7-fd63-4d8a-8ba5-17fdd607e711', 'profile_read', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080"}', '2025-11-14 16:17:27.150193+00'),
	('e25c8b1e-bc90-4644-8659-b0f5f57eaa04', 'profile_read', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080"}', '2025-11-14 16:17:28.163479+00'),
	('5c0fdaa3-70fa-4f47-82a6-c475ef71b0ec', 'profile_read', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080"}', '2025-11-14 16:17:35.860357+00'),
	('f2092dd8-9092-4544-932a-4bc6b3c60634', 'profile_read', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080"}', '2025-11-14 16:17:47.38558+00'),
	('dbae9966-55a6-4fa3-9650-77473d628ada', 'profile_read', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080"}', '2025-11-14 16:17:58.013149+00'),
	('6602e180-4e41-474c-8dc2-c15cd74dd43b', 'profile_read', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080"}', '2025-11-14 16:18:46.771268+00'),
	('96f1e189-670e-4ea3-8325-8fd0ca2c7447', 'profile_read', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080"}', '2025-11-14 16:19:15.455901+00'),
	('c4653fc7-ace0-40cb-8c84-e09268af027e', 'profile_read', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080"}', '2025-11-14 16:19:17.100586+00'),
	('c6085277-1632-475a-b78b-ed721183587e', 'profile_read', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080"}', '2025-11-14 16:19:18.448077+00'),
	('21cfd244-6062-405d-8194-ed7c99d68fa6', 'profile_read', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080"}', '2025-11-14 16:19:33.759803+00'),
	('62fc05e6-9773-4cda-a27a-1fec4082a5f0', 'profile_read', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080"}', '2025-11-14 16:20:03.73692+00'),
	('86d5b852-2818-427a-94a0-d2704e162852', 'profile_read', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080"}', '2025-11-14 16:20:23.613224+00'),
	('a576ccf7-8c06-4ce3-8daa-e59bf512566c', 'profile_read', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080"}', '2025-11-14 16:20:30.362571+00'),
	('83a3e332-b4ec-4d91-974c-c90a730dbaf7', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 1, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-14 18:04:44.776528+00'),
	('2a686d02-efb7-44db-87ff-4c6b0f1e4b99', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-14 18:04:44.81088+00'),
	('13cd9f9d-4bdf-4e1d-af04-8af652aa853e', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 1, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-14 18:04:44.855954+00'),
	('fe8ab43a-01eb-4740-be8b-6be30bfefc13', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-14 18:04:44.879425+00'),
	('9aeac922-4e66-4f4a-b0ee-448f938f9716', 'profile_read', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080"}', '2025-11-14 18:04:48.623125+00'),
	('95b76496-7000-4d7f-8c67-9de8d0e43e20', 'profile_read', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080"}', '2025-11-14 18:04:53.826278+00'),
	('fbfd5551-e0a8-4b5f-bcce-ae6d98861766', 'profile_read', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080"}', '2025-11-14 18:04:57.422461+00'),
	('a24cf9f8-c25d-4a6f-9c62-ea12b20b44f9', 'profile_read', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080"}', '2025-11-14 18:09:31.210127+00'),
	('c69987b6-ba6f-47d3-8969-77ac6f3e8075', 'profile_read', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080"}', '2025-11-14 18:09:40.754292+00'),
	('6c6350fc-ae91-46af-9359-e1cdb9eba66f', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-14 18:10:10.448581+00'),
	('4ebaa799-d460-4051-acf5-003afe8bd0a2', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-14 18:10:10.681811+00'),
	('43a4746b-b839-4175-9a7c-f994d994832d', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-14 18:10:14.768872+00'),
	('74e9c882-14c0-491d-b049-3c17b3336b6d', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-14 18:10:14.901726+00'),
	('7e195cb9-fa8a-4e92-99d7-49cb32f9a7d9', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-14 18:39:09.360405+00'),
	('144d9199-8d33-49b9-bfcb-83d3affc8d4f', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 2, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-14 18:39:10.010955+00'),
	('2bbf9718-3c8c-44da-b130-5d6b8374a140', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-14 18:39:10.039442+00'),
	('00053ec2-da38-4161-9c1b-ed47a9a613a6', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 2, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-14 18:39:10.095985+00'),
	('f639ca39-2315-4fac-9134-1a1c93ea3cd5', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-14 18:39:10.123086+00'),
	('7b896bd6-1947-4c83-a331-ad865a825e74', 'profile_read', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080"}', '2025-11-15 09:20:53.871363+00'),
	('064523d6-64ad-4a15-9a4f-efb4ecb33d15', 'profile_read', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080"}', '2025-11-15 09:20:59.204971+00'),
	('8b353b8c-b642-4344-9a10-e081c80f9a3d', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 1, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-15 09:21:03.717494+00'),
	('c486286f-da3e-4d9f-99b2-eab2f3f6483a', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 1, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-15 09:21:03.720141+00'),
	('23b1af91-9b22-4a15-b69e-058c2636dc56', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-15 09:21:03.740726+00'),
	('08ec41cd-d68c-444d-9288-cfa8fb61dccb', 'profile_read', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080"}', '2025-11-15 09:31:10.008412+00'),
	('4d220920-2f7f-4d09-9aae-89bd6f51810d', 'profile_read', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080"}', '2025-11-15 09:40:56.572742+00'),
	('9948e47d-e21e-47b7-abc0-606e6df88715', 'profile_read', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080"}', '2025-11-15 09:46:47.937908+00'),
	('831ee088-e1df-430d-ba69-3ca7e1a1bb99', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-15 09:50:43.595241+00'),
	('32e8c9e0-bbbd-492d-b2f8-f35f6ef0dd28', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-15 09:50:43.649815+00'),
	('4a7f3c8f-3846-4dc8-9e2e-efd6619b48fb', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-15 09:50:47.022364+00'),
	('5e1c6437-d728-43eb-85d8-742ab695f1a2', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-15 09:50:49.857425+00'),
	('ff1eb04c-3518-4a52-a946-dc5802ffc9cf', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 1, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-15 09:50:54.945751+00'),
	('068cf984-2918-4fd2-8830-110d5ffe18c3', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-15 09:50:54.978222+00'),
	('ab3c748c-d89c-4944-b7f5-6d3065b3b6c7', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-15 09:59:03.832106+00'),
	('ecac67b3-3225-4f40-95a6-07f4dabcdaba', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-15 09:59:06.565544+00'),
	('84133a2c-ef52-4a65-89cd-babba38ce7a5', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-15 09:59:06.783317+00'),
	('a71f9551-7eaa-4860-acde-0556d221f768', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-15 09:59:09.462961+00'),
	('f7177a19-b6f1-479b-8692-489fe69ee5e5', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-15 09:59:09.712454+00'),
	('c82e17ed-a210-4cc6-bbdd-3db126fef927', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 1, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-15 10:01:03.634005+00'),
	('9028c367-4bd8-4960-b68f-7a02189931c6', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-15 10:01:03.665417+00'),
	('f41752e7-2f4d-4856-a347-0c42a475d5cb', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 1, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-15 10:01:03.782938+00'),
	('74d3aeea-528a-4ec7-95d6-a749323d469a', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-15 10:01:03.807193+00'),
	('f0c9932d-2bde-4662-a7bb-2d79c91bcc47', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 1, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-15 10:16:33.499512+00'),
	('f7cb3bc7-00b0-4f90-bfea-de71568cde3b', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-15 10:16:33.537778+00'),
	('d255e88a-d60f-4bc6-a9d4-9c91d083a243', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 1, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-15 10:16:33.703564+00'),
	('fb5b4f38-1f37-4b96-abab-90d9855ae23c', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-15 10:16:33.774553+00'),
	('7b7ea4fc-364d-43bb-9004-c9d62d659904', 'profile_read', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080"}', '2025-11-15 10:19:47.445452+00'),
	('1723140e-7ddf-4741-82e5-04965ec4fbfb', 'profile_read', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080"}', '2025-11-15 10:21:40.391155+00'),
	('225fc4c9-67ed-487c-aded-cf9fe71d5b89', 'profile_read', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080"}', '2025-11-15 10:21:42.820919+00'),
	('ee75af29-f1c5-494a-beda-7690d93071b6', 'tools_nearby', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 18, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 10:43:47.391034+00'),
	('1493f800-2375-4274-aa30-1d59b4f30098', 'tools_nearby', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 0, "endpoint": "/api/tools/nearby", "has_next": false}', '2025-11-15 10:43:48.799363+00'),
	('40dc5890-eaa8-47b4-afdf-b77024397352', 'tools_nearby', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 18, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 10:48:04.740561+00'),
	('bb781e1e-2af4-47cc-a5ba-44d85b347311', 'tools_nearby', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 18, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 10:48:30.446766+00'),
	('369cdc86-2b02-4847-adb9-799d6d6668b6', 'tools_nearby', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 18, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 10:48:36.389427+00'),
	('b70fbc3a-cf72-4ed7-8888-775197bf09f9', 'tools_nearby', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 18, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 10:48:43.231125+00'),
	('0bca685d-2f34-401d-9bb7-558a6d01e87f', 'tools_nearby', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 18, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 10:48:51.080283+00'),
	('e1e85ee1-2ed6-4349-b482-1394c669db93', 'tools_nearby', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 18, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 10:49:28.398165+00'),
	('420ed2d5-da65-46a7-a397-4d15823f13fc', 'tools_nearby', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 18, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 10:49:33.206173+00'),
	('3c1e691c-c0f4-42d6-b9f4-fe205bcc234c', 'tools_nearby', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 18, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 10:49:33.236787+00'),
	('d690759c-5c17-4ecd-b8a3-6539ca763cf4', 'tools_nearby', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 18, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 10:49:33.336068+00'),
	('d372c4ac-b34a-4bd3-bb77-aa3ed961ecc3', 'tools_nearby', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 18, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 10:50:35.300093+00'),
	('443f7f6c-dc20-49a0-8208-05991e468390', 'tools_nearby', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 18, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 10:50:48.225436+00'),
	('7b49ee82-c4d9-4fde-9e6c-0f38b39d0221', 'tools_nearby', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 18, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 10:50:55.516176+00'),
	('b1ef73bc-a595-4d0d-9c13-9f37665ef972', 'tools_nearby', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 18, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 10:51:19.841642+00'),
	('8f44369c-2a58-4729-9a27-fee8a37d1afd', 'tools_nearby', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 18, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 10:51:25.96863+00'),
	('b8d2b277-9250-4648-b4f9-31808e8f7cbb', 'tools_nearby', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 18, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 10:51:52.259294+00'),
	('193469d6-e3c4-4e97-8228-2900f5ff3bbd', 'tools_nearby', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 18, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 10:51:53.56501+00'),
	('9a101e61-b358-4970-ad36-9fa0b0189ec5', 'tools_nearby', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 18, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 10:52:03.40339+00'),
	('37c88a14-6417-4d2e-87bc-8f7515786888', 'tools_nearby', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 18, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 10:58:24.385008+00'),
	('07fb87dd-e6f9-4c1c-a3c7-0eb06987ddaa', 'tools_nearby', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 18, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 11:01:25.53168+00'),
	('30ed4b27-9f8f-4dd0-89cd-1bcbf15692a4', 'tools_nearby', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 18, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 11:01:36.591984+00'),
	('ca76514d-287c-4e62-92cd-454028c26066', 'tools_nearby', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 18, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 11:01:47.410009+00'),
	('4fefe667-e6f8-4fcd-8e09-e714070178aa', 'tools_nearby', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 18, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 11:02:28.47648+00'),
	('ab7ec482-5cc4-4d0e-bcca-b6342f29c5bf', 'tools_nearby', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 18, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 11:03:06.245831+00'),
	('2b0d2d52-171b-439b-af53-6a797f2bdd5e', 'tools_nearby', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 18, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 11:03:14.791237+00'),
	('36dda954-de4d-4580-97f5-256caf40cf0d', 'tools_nearby', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 18, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 11:03:22.450473+00'),
	('05bb3a0a-b69e-4d1e-8a3f-2c7c9910d5ae', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 1, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-15 11:04:17.350774+00'),
	('200593c6-d8f2-4d64-8d4f-8bf76791c1db', 'tools_search', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 1, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-15 11:04:17.585645+00'),
	('65f51e37-a483-478e-89a3-194b70e38232', 'tools_nearby', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 18, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 11:04:22.714036+00'),
	('515fa427-f8e2-413d-b711-4cdbba78adb0', 'profile_read', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"endpoint": "/api/profile", "profile_id": "0fc43071-195f-445a-ac6c-80319d362d66"}', '2025-11-15 11:05:06.175482+00'),
	('33eb1059-1062-4e80-ba0e-70c1a70a70d9', 'profile_update', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"endpoint": "/api/profile", "profile_id": "0fc43071-195f-445a-ac6c-80319d362d66", "geocode_triggered": false}', '2025-11-15 11:05:15.921777+00'),
	('04662213-0975-4bbb-a400-96d935bfad22', 'profile_read', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"endpoint": "/api/profile", "profile_id": "0fc43071-195f-445a-ac6c-80319d362d66"}', '2025-11-15 11:05:16.18822+00'),
	('e40f72f0-d21f-4e30-bb45-5424eb5898ae', 'profile_read', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"endpoint": "/api/profile", "profile_id": "0fc43071-195f-445a-ac6c-80319d362d66"}', '2025-11-15 11:05:38.435811+00'),
	('f5456755-d1a2-4504-b47a-656f480a73ce', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 11:05:39.423281+00'),
	('f0690eab-94e4-4e43-8826-55bcfafae5ba', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 11:06:04.148991+00'),
	('865f872b-f971-4808-97f8-f7a37b19d357', 'tools_search', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 1, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-15 11:06:07.849942+00'),
	('7454830a-a30e-4e8b-a2e1-a8762de25dba', 'tools_search', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 1, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-15 11:06:08.108474+00'),
	('cc530e2c-cc38-4305-9fec-797f40641202', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 11:06:15.368564+00'),
	('1a26e93c-9af2-41eb-a22b-64c77bab039b', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 11:06:20.196355+00'),
	('10dbf95c-88e8-4eef-ba85-6c8f0c19a138', 'tools_search', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 1, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-15 11:06:26.889357+00'),
	('b9be32da-ae99-48fd-bf68-137b8ac5e4a8', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 11:06:31.958033+00'),
	('ab1c2683-a185-49bc-9175-bfa003de3fb6', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 11:08:48.36493+00'),
	('00ee57af-baa7-41ae-93b3-aef9678435e2', 'tools_search', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 1, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-15 11:09:01.492318+00'),
	('2600f7b2-cd68-49fb-8ab4-8eeb2e637782', 'tools_search', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 1, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-15 11:09:01.755258+00'),
	('21a11db7-9a88-49a6-9026-8befed162376', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 11:09:07.681118+00'),
	('40f804bd-0b6d-4423-a8fb-b912573027bf', 'tools_search', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-15 11:10:11.950172+00'),
	('4dad50fb-b2bf-4dc5-86a0-4174c00214aa', 'tools_search', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-15 11:10:15.487686+00'),
	('b65bdd88-e4a3-422b-91b8-abb0807e2560', 'tools_search', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 1, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-15 11:10:16.434245+00'),
	('f437653f-f872-4dd1-bd38-a902fcca5c85', 'tools_search', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 1, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-15 11:10:27.562133+00'),
	('72ec2803-0518-4704-bcad-729edcd0ccdf', 'tools_search', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-15 11:14:12.465953+00'),
	('1022de41-b93e-4b1e-ae89-611040ef23be', 'tools_search', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-15 11:14:14.722297+00'),
	('79bdf852-cad9-48e1-a6b0-90b17cb9efde', 'tools_search', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-15 11:14:15.962841+00'),
	('a8274f93-8a4a-46f0-8ca2-1e0d80276ef4', 'tools_search', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-15 11:14:16.970437+00'),
	('d05ff917-accf-406d-86a1-76b5d612c345', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 11:14:19.550039+00'),
	('05ec296b-d5f3-447a-a2eb-a3c10e88e153', 'tools_search', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-15 11:14:21.776193+00'),
	('3c5ef0a9-167f-4998-ae15-1fa782bae228', 'tools_search', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-15 11:14:22.366707+00'),
	('2e79081b-ba92-4aae-b99a-4f4c9ebd04b4', 'tools_search', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-15 11:14:23.166096+00'),
	('c981c7cd-e3a7-4099-bb8f-b59848ec25fd', 'tools_search', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-15 11:14:24.060637+00'),
	('11f8d14d-4607-4870-95e7-aa1889043597', 'tools_search', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-15 11:14:25.153445+00'),
	('9311508f-8c10-44c3-8bcd-46f33c284138', 'tools_search', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 1, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-15 11:14:26.507838+00'),
	('cc3896b0-efcb-4b87-9f20-9208e2b5c918', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 11:16:15.819463+00'),
	('d911ca6b-602f-4970-ab3a-aacb27ca88c5', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 11:16:21.933371+00'),
	('277f3e0d-4402-4e97-b224-48794d119a43', 'tools_search', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-15 11:16:27.10958+00'),
	('4b7322f1-2bbc-4eb2-a1de-a428c0ff09ce', 'tools_search', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-15 11:16:30.944707+00'),
	('e960877b-b357-4e38-bce0-170c14789310', 'tools_search', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 1, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-15 11:16:31.92422+00'),
	('069ace6c-5945-410b-acdf-6e09622f52d3', 'tools_search', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-15 11:16:34.139939+00'),
	('0137929e-8736-4e24-99bd-2eba988f09fb', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 11:18:26.146391+00'),
	('0db9b399-eb36-41d7-86d5-cadd4d846fb2', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 11:19:09.259496+00'),
	('df9908fb-1094-4e84-a928-31015d478be0', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 11:19:13.152388+00'),
	('4640d731-19b6-459d-b2c8-423bd710ac83', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 11:32:46.132165+00'),
	('a15e814d-b4c0-4355-be19-57307ecd014e', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 14:39:45.369089+00'),
	('a48f04e8-afb3-4101-a591-4a44c7e4847d', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 14:46:39.11329+00'),
	('a1c69f38-aeb2-4a1d-be31-ced79489d68b', 'tools_search', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 1, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-15 14:46:40.924044+00'),
	('4208038a-9d46-4723-9710-a90ea3107268', 'tools_search', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 1, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-15 14:46:41.376767+00'),
	('11c5f577-b218-4556-9c21-183c6bdaa437', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 14:46:49.262155+00'),
	('3feeb37e-ddaf-4e3d-abd0-39d51cd25787', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 14:49:19.206053+00'),
	('53c9f4a9-27a8-477e-a96b-335709bfd556', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 14:49:26.364237+00'),
	('e64f33f0-6551-42f1-8287-8f2f6095da41', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 14:49:57.59727+00'),
	('e034f864-2014-4259-9813-3c3488b3b047', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 14:50:13.321243+00'),
	('7dc8d75d-2877-4fcc-a8e5-684c033f272a', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 15:16:32.411371+00'),
	('e981d82e-99cb-48c6-948f-d53ef1fd5412', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 15:16:39.252744+00'),
	('551bb21d-ab4e-474d-8759-8f01482e1218', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 15:16:58.339902+00'),
	('1735970f-37ce-4051-a607-f32864807912', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 15:17:04.85816+00'),
	('b5324343-2b47-464a-b506-8807d0f176dd', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 15:18:14.674283+00'),
	('56d5ff08-d02d-4273-89e6-c461bcac1690', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 15:18:14.739294+00'),
	('bb35972f-fba5-44cb-a3fd-29804708eee4', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 15:18:17.533577+00'),
	('9e6f9e3f-4371-499f-a38c-6b7770844a96', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 15:18:36.003432+00'),
	('cfbd3ec8-624d-42de-87ab-07d923977a23', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 15:18:36.06841+00'),
	('16cf5e1b-e1b6-444c-9fe0-39b8ce68a988', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 15:18:36.035943+00'),
	('437223ff-e1a3-4303-aae1-a68cecae4bd7', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 15:19:57.609877+00'),
	('d9b2828f-9823-4671-9ff7-85e8c1be7255', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 15:19:57.714794+00'),
	('b5ee2d23-fae7-4fcd-ada2-5f6836e8f099', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 15:19:57.779708+00'),
	('8d8d008c-da49-48b1-91b9-0834d9101714', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 15:22:56.16923+00'),
	('0531705d-25a1-4335-9d3c-d8d45698bd17', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 15:22:56.690406+00'),
	('514788ca-7637-40e7-aa54-e22d904335f4', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 15:22:56.716509+00'),
	('36fb48cc-3357-48ed-ab2d-4269de204d74', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 15:23:01.53617+00'),
	('0df504bc-b86e-4b9a-971e-9c27f5bf97a3', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 15:23:01.574545+00'),
	('6cddcabb-0db7-4127-a114-b173d05320a1', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 15:23:01.602386+00'),
	('fb861705-4029-410d-b5fe-8c37025a56c6', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 15:23:10.629377+00'),
	('6aba0911-fbaf-456c-b544-e97d55b15ee8', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 15:23:10.688376+00'),
	('cff9e34a-c2a2-4302-ae7a-8729747e7d35', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 15:23:10.722569+00'),
	('cfb5816b-90fc-4511-b47b-1c7c9f1401d2', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 15:23:30.357+00'),
	('006f629a-f97e-4ce3-a60f-ef9f35a85522', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 15:23:30.530896+00'),
	('6eabc739-07c6-4687-b58e-38f134d59f7b', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 15:23:30.559815+00'),
	('3d17b773-d0fb-4920-bf18-afeb304e8b70', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 15:23:43.94558+00'),
	('673c35bc-2380-475a-9203-aba30168e05e', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 15:23:44.566774+00'),
	('7e6369a2-9b0a-433d-8f65-3e89ab09a791', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 15:23:44.599922+00'),
	('23c90752-6a42-416b-b579-5d99a9b0dc08', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 15:23:49.881305+00'),
	('f095c1ef-04fa-43bd-8073-2489f7ebc2b5', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 15:23:50.25319+00'),
	('66bf3471-be76-4b02-9aa7-27ff72323793', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 15:23:50.285735+00'),
	('a305770e-e4d8-41c6-8f85-4bcb00fdfba1', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 15:23:57.991492+00'),
	('ad1d66dc-8955-46e9-b53b-e964cce94be8', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 15:23:58.013948+00'),
	('9bace86f-4351-41b8-944e-cba7d846279a', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 15:23:58.039433+00'),
	('5e1001dd-4cad-47c0-8ff2-659e904ea124', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 15:45:25.894401+00'),
	('10da9ef4-8ac3-49f4-847f-fb8dcdb9aca0', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 15:47:16.359509+00'),
	('6662a267-5b3c-472a-b33f-293dd3a0141a', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 15:47:16.883156+00'),
	('94f08d00-56fa-4e29-9512-7d4c64e38e20', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 15:47:16.909331+00'),
	('94649abb-ec96-47d3-a865-f8fb72732162', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 15:47:23.10869+00'),
	('53c917d1-9a73-4630-9213-e03f5dafb359', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 15:47:23.433798+00'),
	('ef6ff801-06fa-4844-8bf8-399bd23501e6', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 15:47:23.462448+00'),
	('6ca1ff3a-a288-4ca1-ab65-75c410b32a16', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 15:49:24.179024+00'),
	('1f6466ed-0d37-45ef-bab9-e9ef9818988a', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 18:50:47.13899+00'),
	('39cd4779-0c4f-47f2-8709-49b982ed3c3a', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 18:50:47.719418+00'),
	('bc9627c7-7f3f-49bb-9f0b-2c3304ae600e', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 18:50:47.742378+00'),
	('bd69e2da-f19a-46db-b65b-4005b788ec65', 'tools_nearby', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 18, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 18:51:48.553312+00'),
	('ad022bcd-b436-4163-a19f-92a54ca99c60', 'tools_nearby', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 18, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 18:51:48.618371+00'),
	('fe5c4b47-83a4-42a4-b7b4-3c1e0f8eb7a8', 'profile_read', '3973b11e-118a-4933-b752-f78cc7469daf', NULL, '{"endpoint": "/api/profile", "profile_id": "3973b11e-118a-4933-b752-f78cc7469daf"}', '2025-11-15 18:52:05.739266+00'),
	('2617a245-3b7b-4c3a-91a1-3b85f3de9862', 'profile_read', '3973b11e-118a-4933-b752-f78cc7469daf', NULL, '{"endpoint": "/api/profile", "profile_id": "3973b11e-118a-4933-b752-f78cc7469daf"}', '2025-11-15 18:52:05.789432+00'),
	('66da94bd-6f27-4af7-ac10-49cb89c0f520', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 18:52:16.178303+00'),
	('eefbade4-b527-4ce0-baaf-a1ac57893ea3', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 18:52:16.252105+00'),
	('9ff55fc8-4168-40b1-bfc1-314814a1cc99', 'tools_search', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 1, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-15 18:52:30.01395+00'),
	('f5358ec7-e1fc-4cd9-99e8-0392b014e5ea', 'tools_search', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 1, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-15 18:52:30.209371+00'),
	('4f8ad0e3-8c05-4605-8340-9b4eb65a7e33', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 18:53:28.249736+00'),
	('c058fe17-82d2-44bc-a7d9-888971c3051b', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 18:53:28.566232+00'),
	('3d51e261-1a63-4c6a-acea-16504dc89a26', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 18:53:32.777056+00'),
	('27a1785b-9c09-43ae-9697-f15e86436915', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 18:53:33.229428+00'),
	('73b8b139-921b-4322-bcef-5b035164548b', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 18:54:40.722561+00'),
	('ef9b6ddf-5730-46ad-b027-834819bba7e6', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 18:54:40.971053+00'),
	('66ebbc8c-8074-4c0d-9422-99eed450b9b6', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 18:54:46.073372+00'),
	('5e6a414d-8a08-46ad-b244-fb0cd891748a', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 18:54:46.600648+00'),
	('7c519373-981f-49ad-ae10-b85fc6d9d008', 'tools_search', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 1, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-15 18:54:52.487433+00'),
	('06339177-35ed-4d41-84ce-9404e5025f37', 'tools_search', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 1, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-15 18:54:52.610367+00'),
	('649b25f2-4a62-489c-85f7-46cd1401f8b4', 'tools_search', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 1, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-15 18:54:54.63153+00'),
	('5ccfd951-e7d5-442c-9c58-5b304aee1c1d', 'tools_search', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 1, "endpoint": "/api/tools/search", "has_next": true}', '2025-11-15 18:54:54.67073+00'),
	('f5c59462-1974-465f-b48f-cc960b879c35', 'tools_search', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-15 18:54:57.508022+00'),
	('bfed09c8-d71c-4bf2-bb4b-35c61cf9391e', 'tools_search', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 0, "endpoint": "/api/tools/search", "has_next": false}', '2025-11-15 18:54:57.618663+00'),
	('7cad37cf-febe-4dab-8fa1-9b31c55f11f5', 'profile_read', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"endpoint": "/api/profile", "profile_id": "0fc43071-195f-445a-ac6c-80319d362d66"}', '2025-11-15 18:55:06.35846+00'),
	('03f01615-f92c-4a63-8b8d-b6e7e12abe4a', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 18:55:08.662579+00'),
	('0d379d41-2af1-4458-a79e-c6b499791461', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 19:00:55.54696+00'),
	('b043ee14-e1b1-4776-a52d-00c83eb7972f', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 19:00:55.634706+00'),
	('560f0b54-903c-4a55-b80b-4549e8b7b83f', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 19:02:50.405118+00'),
	('3ed524f5-5c77-4d87-81a5-4ff47a260d43', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 19:02:50.435616+00'),
	('c6d7c062-cc01-419f-b523-6967ef39938b', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 19:03:26.688782+00'),
	('bab85183-bc8a-474f-8b5b-688ab06d099f', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 19:03:26.8903+00'),
	('003741b7-af7c-446c-8dde-79271bfcff3e', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 19:31:37.408065+00'),
	('dbda10e4-041d-4424-800f-418a13640a5d', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 19:31:56.098533+00'),
	('1bb8f850-b5fa-44ae-86aa-693236515265', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 19:31:56.581055+00'),
	('f3f399ca-2257-4db2-9e00-35bf81b403ec', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 19:32:07.201124+00'),
	('daded2a1-486f-448c-9f9f-b61bbcf1cc7e', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 20, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 19:32:32.002393+00'),
	('866e273f-1a6d-4b6e-8455-5fffdb56a13e', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 19, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 19:33:52.346956+00'),
	('a6156e65-c916-48ad-9216-d9759d3f4b80', 'tools_nearby', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 18, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 19:34:48.353083+00'),
	('e79cbf53-0cb3-4d0c-b95a-3fe739640378', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 19, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 19:46:20.22273+00'),
	('5547240b-fcd8-4ceb-a5f0-91230c13dc93', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 19, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 19:46:29.167747+00'),
	('8700ef37-80ea-45fe-8bf5-01689966fa25', 'tools_nearby', '0fc43071-195f-445a-ac6c-80319d362d66', NULL, '{"items": 19, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 19:46:34.586679+00'),
	('6b15fbd5-73ba-4220-a824-ab91b62d4249', 'tools_nearby', '3973b11e-118a-4933-b752-f78cc7469daf', NULL, '{"items": 19, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 19:46:44.283996+00'),
	('1367b0a2-0b0d-4b71-8938-c518dc299b8c', 'profile_read', '3973b11e-118a-4933-b752-f78cc7469daf', NULL, '{"endpoint": "/api/profile", "profile_id": "3973b11e-118a-4933-b752-f78cc7469daf"}', '2025-11-15 19:47:02.723398+00'),
	('bf02a00f-e099-4e04-8064-0b4ff4458a7c', 'tools_nearby', '3973b11e-118a-4933-b752-f78cc7469daf', NULL, '{"items": 19, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 19:47:04.979887+00'),
	('8edebece-8c17-4511-a903-d8880276a96e', 'profile_read', '3973b11e-118a-4933-b752-f78cc7469daf', NULL, '{"endpoint": "/api/profile", "profile_id": "3973b11e-118a-4933-b752-f78cc7469daf"}', '2025-11-15 19:47:06.763102+00'),
	('5cb7b468-d256-49a4-8ce4-0f55b76e5075', 'tools_nearby', '3973b11e-118a-4933-b752-f78cc7469daf', NULL, '{"items": 19, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 19:47:08.303171+00'),
	('1a52cffb-4fa8-4c5a-ba82-e925ae6431ae', 'tools_nearby', '3973b11e-118a-4933-b752-f78cc7469daf', NULL, '{"items": 19, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 19:52:03.453685+00'),
	('4b15f71c-5ec6-4858-b443-6b626c99a93c', 'tools_nearby', '3973b11e-118a-4933-b752-f78cc7469daf', NULL, '{"items": 19, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 19:52:57.176029+00'),
	('db01992b-915f-4272-82ed-599e0ededbeb', 'tools_nearby', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 18, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 19:58:43.925794+00'),
	('65c80d63-1777-4e39-913b-65d51328b7c9', 'tools_nearby', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 18, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 20:00:23.828355+00'),
	('540b93be-2bd2-4f16-a7c8-ecd6e5024ede', 'profile_read', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080"}', '2025-11-15 20:02:30.79674+00'),
	('6165b3d4-d6b4-4692-8e34-fb49692c50cf', 'profile_read', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080"}', '2025-11-15 20:02:49.516685+00'),
	('b424a32d-99f9-4088-8bba-80d5beff143b', 'tools_nearby', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 18, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 20:02:53.121721+00'),
	('fb9139b3-ca30-4005-b51f-da0a31192de5', 'tools_nearby', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 18, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 20:03:12.364541+00'),
	('35c20aee-cdee-49b3-9774-f2cf843a9244', 'profile_read', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080"}', '2025-11-15 20:03:13.492011+00'),
	('f29c7925-126b-48f2-b4c1-63c3367d90f9', 'tools_nearby', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 18, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 20:03:24.952346+00'),
	('f001c6d7-cc77-4c51-ab0f-b92e3de58032', 'tools_nearby', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 18, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 20:03:27.801477+00'),
	('c6a61fd1-c620-4081-ada5-9c1e50f9f093', 'profile_read', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080"}', '2025-11-15 20:03:32.10186+00'),
	('731aa521-9485-47a8-9d77-a4ee10f4acc1', 'tools_nearby', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 18, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 20:03:42.425813+00'),
	('3d0fa7ad-803c-405f-8fc7-4b27651b2d47', 'profile_read', '3973b11e-118a-4933-b752-f78cc7469daf', NULL, '{"endpoint": "/api/profile", "profile_id": "3973b11e-118a-4933-b752-f78cc7469daf"}', '2025-11-15 20:04:03.364461+00'),
	('d171720d-d8b7-4038-a02b-7ecc5072f553', 'profile_read', '3973b11e-118a-4933-b752-f78cc7469daf', NULL, '{"endpoint": "/api/profile", "profile_id": "3973b11e-118a-4933-b752-f78cc7469daf"}', '2025-11-15 20:04:06.666265+00'),
	('b8620e4a-18e7-4528-844f-5d020061c2d2', 'profile_read', '3973b11e-118a-4933-b752-f78cc7469daf', NULL, '{"endpoint": "/api/profile", "profile_id": "3973b11e-118a-4933-b752-f78cc7469daf"}', '2025-11-15 20:04:50.412402+00'),
	('d69cbe98-c296-4aad-824e-e6ac6668079a', 'profile_read', '3973b11e-118a-4933-b752-f78cc7469daf', NULL, '{"endpoint": "/api/profile", "profile_id": "3973b11e-118a-4933-b752-f78cc7469daf"}', '2025-11-15 20:05:18.016929+00'),
	('4237c936-b77b-420e-8aea-22f6fcbfafc2', 'profile_read', '3973b11e-118a-4933-b752-f78cc7469daf', NULL, '{"endpoint": "/api/profile", "profile_id": "3973b11e-118a-4933-b752-f78cc7469daf"}', '2025-11-15 20:06:25.609834+00'),
	('beb1d43d-b0c8-4e18-98c8-bd7c3360f724', 'profile_read', '3973b11e-118a-4933-b752-f78cc7469daf', NULL, '{"endpoint": "/api/profile", "profile_id": "3973b11e-118a-4933-b752-f78cc7469daf"}', '2025-11-15 20:06:32.825011+00'),
	('f58df751-8c53-4a52-afcd-177b320a0080', 'profile_read', '3973b11e-118a-4933-b752-f78cc7469daf', NULL, '{"endpoint": "/api/profile", "profile_id": "3973b11e-118a-4933-b752-f78cc7469daf"}', '2025-11-15 20:12:39.406276+00'),
	('2c50a693-2116-49a4-b785-5525df1c7c09', 'profile_read', '3973b11e-118a-4933-b752-f78cc7469daf', NULL, '{"endpoint": "/api/profile", "profile_id": "3973b11e-118a-4933-b752-f78cc7469daf"}', '2025-11-15 20:12:47.278714+00'),
	('0428d5c2-5db0-4274-9fb6-e74522a1a86b', 'profile_read', '3973b11e-118a-4933-b752-f78cc7469daf', NULL, '{"endpoint": "/api/profile", "profile_id": "3973b11e-118a-4933-b752-f78cc7469daf"}', '2025-11-15 20:13:02.384619+00'),
	('e6f32487-ff84-476b-8fd5-1e3ba1613cfb', 'profile_read', '3973b11e-118a-4933-b752-f78cc7469daf', NULL, '{"endpoint": "/api/profile", "profile_id": "3973b11e-118a-4933-b752-f78cc7469daf"}', '2025-11-15 20:13:09.245768+00'),
	('08bf6252-f009-44f1-9409-fdb92cab5c9c', 'profile_read', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080"}', '2025-11-15 20:15:41.413776+00'),
	('7da0c36c-12d8-489a-a165-fb2dc39a36b6', 'tools_nearby', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 18, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 20:15:47.837905+00'),
	('5377a66b-cdfa-47eb-acf9-edddba580ca2', 'tools_nearby', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 18, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 20:24:46.650577+00'),
	('8a8ef8e2-6455-42d7-82ca-0af8c876a65b', 'tools_nearby', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 18, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 20:25:54.57693+00'),
	('753b4dce-acf9-4aaa-bf4d-93969895b21c', 'tools_nearby', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"items": 18, "endpoint": "/api/tools/nearby", "has_next": true}', '2025-11-15 20:28:17.670047+00'),
	('6f4fc6f5-cbbe-4e35-a076-17297b2b0802', 'profile_read', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080"}', '2025-11-15 20:28:46.936802+00'),
	('de457834-9544-464c-901d-5e98dbc7e3eb', 'profile_read', '3973b11e-118a-4933-b752-f78cc7469daf', NULL, '{"endpoint": "/api/profile", "profile_id": "3973b11e-118a-4933-b752-f78cc7469daf"}', '2025-11-15 20:29:21.58649+00'),
	('f5c34780-3093-4cc8-86cb-a1540ed7664f', 'profile_read', '3973b11e-118a-4933-b752-f78cc7469daf', NULL, '{"endpoint": "/api/profile", "profile_id": "3973b11e-118a-4933-b752-f78cc7469daf"}', '2025-11-15 20:34:00.984169+00'),
	('55da9f63-ee0a-4c81-94b2-a36c2e18440f', 'profile_read', '3973b11e-118a-4933-b752-f78cc7469daf', NULL, '{"endpoint": "/api/profile", "profile_id": "3973b11e-118a-4933-b752-f78cc7469daf"}', '2025-11-15 20:35:10.282123+00'),
	('8569be19-5499-45b4-bbd4-49f710ff4201', 'profile_read', '3973b11e-118a-4933-b752-f78cc7469daf', NULL, '{"endpoint": "/api/profile", "profile_id": "3973b11e-118a-4933-b752-f78cc7469daf"}', '2025-11-15 20:37:11.468028+00'),
	('7762951a-346c-44f7-bc2e-1e5469612c51', 'profile_read', '3973b11e-118a-4933-b752-f78cc7469daf', NULL, '{"endpoint": "/api/profile", "profile_id": "3973b11e-118a-4933-b752-f78cc7469daf"}', '2025-11-15 20:37:20.927502+00'),
	('ffbb792b-2a88-4899-b82d-2f23cbf12720', 'profile_read', '3973b11e-118a-4933-b752-f78cc7469daf', NULL, '{"endpoint": "/api/profile", "profile_id": "3973b11e-118a-4933-b752-f78cc7469daf"}', '2025-11-15 20:37:58.798452+00'),
	('febc6922-1e1c-4a72-a735-aa60f2790992', 'profile_read', '3973b11e-118a-4933-b752-f78cc7469daf', NULL, '{"endpoint": "/api/profile", "profile_id": "3973b11e-118a-4933-b752-f78cc7469daf"}', '2025-11-15 20:38:06.678653+00'),
	('22f784b1-28fb-41ea-8456-c16b98affada', 'profile_read', '3973b11e-118a-4933-b752-f78cc7469daf', NULL, '{"endpoint": "/api/profile", "profile_id": "3973b11e-118a-4933-b752-f78cc7469daf"}', '2025-11-15 20:38:12.005658+00'),
	('3f565c6e-f2ef-4c94-a9d9-0d47f2f92ffe', 'profile_read', '3973b11e-118a-4933-b752-f78cc7469daf', NULL, '{"endpoint": "/api/profile", "profile_id": "3973b11e-118a-4933-b752-f78cc7469daf"}', '2025-11-15 20:38:32.262973+00'),
	('20575692-99d2-409d-b6b7-8ac635f3d796', 'profile_read', '3973b11e-118a-4933-b752-f78cc7469daf', NULL, '{"endpoint": "/api/profile", "profile_id": "3973b11e-118a-4933-b752-f78cc7469daf"}', '2025-11-15 20:39:20.790611+00'),
	('980b63f9-80d8-44f3-b2e8-964602db0847', 'profile_read', '3973b11e-118a-4933-b752-f78cc7469daf', NULL, '{"endpoint": "/api/profile", "profile_id": "3973b11e-118a-4933-b752-f78cc7469daf"}', '2025-11-15 20:41:45.278858+00'),
	('4936c96b-bfc2-43c2-9f84-8a66311db172', 'profile_read', '3973b11e-118a-4933-b752-f78cc7469daf', NULL, '{"endpoint": "/api/profile", "profile_id": "3973b11e-118a-4933-b752-f78cc7469daf"}', '2025-11-15 20:42:32.878137+00'),
	('adab2e14-4431-404a-9fd3-3036aebb62c4', 'profile_read', '3973b11e-118a-4933-b752-f78cc7469daf', NULL, '{"endpoint": "/api/profile", "profile_id": "3973b11e-118a-4933-b752-f78cc7469daf"}', '2025-11-15 20:43:08.507764+00'),
	('3cc5ed8f-e420-41f0-a419-894477917dcd', 'profile_read', '3973b11e-118a-4933-b752-f78cc7469daf', NULL, '{"endpoint": "/api/profile", "profile_id": "3973b11e-118a-4933-b752-f78cc7469daf"}', '2025-11-15 20:43:55.335079+00'),
	('59e243b0-484f-4342-a469-97c61d6b726a', 'profile_read', '3973b11e-118a-4933-b752-f78cc7469daf', NULL, '{"endpoint": "/api/profile", "profile_id": "3973b11e-118a-4933-b752-f78cc7469daf"}', '2025-11-15 20:44:02.141272+00'),
	('9a7fc91c-15f7-4bb4-ba1e-60f183acb479', 'profile_read', '3973b11e-118a-4933-b752-f78cc7469daf', NULL, '{"endpoint": "/api/profile", "profile_id": "3973b11e-118a-4933-b752-f78cc7469daf"}', '2025-11-15 20:44:40.11898+00'),
	('0e1e59a1-06ff-44eb-8d74-53c5f88b7a8b', 'profile_read', '1f587053-c01e-4aa6-8931-33567ca6a080', NULL, '{"endpoint": "/api/profile", "profile_id": "1f587053-c01e-4aa6-8931-33567ca6a080"}', '2025-11-15 20:45:00.214657+00'),
	('9068091e-6224-4563-9abf-71a8bbee493c', 'profile_read', '3973b11e-118a-4933-b752-f78cc7469daf', NULL, '{"endpoint": "/api/profile", "profile_id": "3973b11e-118a-4933-b752-f78cc7469daf"}', '2025-11-15 20:45:20.731473+00'),
	('770e508b-4b58-4b80-a42e-d102e8af015a', 'profile_read', '3973b11e-118a-4933-b752-f78cc7469daf', NULL, '{"endpoint": "/api/profile", "profile_id": "3973b11e-118a-4933-b752-f78cc7469daf"}', '2025-11-15 21:11:04.940523+00'),
	('f2584518-424a-4162-b3ec-f2ae4b9201e5', 'profile_read', '3973b11e-118a-4933-b752-f78cc7469daf', NULL, '{"endpoint": "/api/profile", "profile_id": "3973b11e-118a-4933-b752-f78cc7469daf"}', '2025-11-15 21:28:10.685881+00'),
	('b8085120-bc79-480e-a5e1-78dd710ba6d6', 'profile_read', '3973b11e-118a-4933-b752-f78cc7469daf', NULL, '{"endpoint": "/api/profile", "profile_id": "3973b11e-118a-4933-b752-f78cc7469daf"}', '2025-11-15 21:28:11.878852+00'),
	('befc6e89-9d77-4935-8f07-aeba426e0e7a', 'profile_read', '3973b11e-118a-4933-b752-f78cc7469daf', NULL, '{"endpoint": "/api/profile", "profile_id": "3973b11e-118a-4933-b752-f78cc7469daf"}', '2025-11-15 21:28:16.868963+00'),
	('77ea0e05-8ace-4d93-ac0f-102ad2b25466', 'profile_read', '3973b11e-118a-4933-b752-f78cc7469daf', NULL, '{"endpoint": "/api/profile", "profile_id": "3973b11e-118a-4933-b752-f78cc7469daf"}', '2025-11-15 21:28:19.39429+00'),
	('04cc948b-b833-4e71-aff4-ae8ce09bad24', 'profile_read', '3973b11e-118a-4933-b752-f78cc7469daf', NULL, '{"endpoint": "/api/profile", "profile_id": "3973b11e-118a-4933-b752-f78cc7469daf"}', '2025-11-15 21:28:22.566279+00'),
	('0298b0ad-f63e-4968-b17f-a5bdfa56b611', 'profile_read', '3973b11e-118a-4933-b752-f78cc7469daf', NULL, '{"endpoint": "/api/profile", "profile_id": "3973b11e-118a-4933-b752-f78cc7469daf"}', '2025-11-15 21:28:24.556222+00'),
	('da6133b2-5fa3-48da-8825-34c4731f0d1f', 'profile_read', '3973b11e-118a-4933-b752-f78cc7469daf', NULL, '{"endpoint": "/api/profile", "profile_id": "3973b11e-118a-4933-b752-f78cc7469daf"}', '2025-11-15 21:28:59.611453+00'),
	('3db3ce93-e67a-43a4-84f6-b80e71e1a82e', 'profile_read', '3973b11e-118a-4933-b752-f78cc7469daf', NULL, '{"endpoint": "/api/profile", "profile_id": "3973b11e-118a-4933-b752-f78cc7469daf"}', '2025-11-15 21:34:04.483362+00'),
	('3f1a7b9f-3638-40cd-8869-3c414daf373f', 'profile_read', '3973b11e-118a-4933-b752-f78cc7469daf', NULL, '{"endpoint": "/api/profile", "profile_id": "3973b11e-118a-4933-b752-f78cc7469daf"}', '2025-11-15 21:34:19.677192+00'),
	('08d357c7-22e9-4947-aba5-1627e637f17c', 'profile_read', '3973b11e-118a-4933-b752-f78cc7469daf', NULL, '{"endpoint": "/api/profile", "profile_id": "3973b11e-118a-4933-b752-f78cc7469daf"}', '2025-11-15 21:35:27.469937+00'),
	('13b0feb1-5466-473e-b712-0a74247e5b83', 'profile_read', '09021b77-3bfb-4c88-82d9-a723f3499892', NULL, '{"endpoint": "/api/profile", "profile_id": "09021b77-3bfb-4c88-82d9-a723f3499892"}', '2025-11-15 22:57:31.219602+00'),
	('c19cf6f8-a6ed-49fa-807c-2c31adf14027', 'profile_read', '09021b77-3bfb-4c88-82d9-a723f3499892', NULL, '{"endpoint": "/api/profile", "profile_id": "09021b77-3bfb-4c88-82d9-a723f3499892"}', '2025-11-15 22:57:36.219823+00'),
	('8216e6e6-2f3b-4072-ad85-086c2910c2a6', 'profile_update', '09021b77-3bfb-4c88-82d9-a723f3499892', NULL, '{"endpoint": "/api/profile", "profile_id": "09021b77-3bfb-4c88-82d9-a723f3499892", "geocode_triggered": false}', '2025-11-15 22:58:46.277389+00'),
	('03735b77-36e0-412b-b844-a63dceec8026', 'profile_read', '70b079c7-e216-4084-b96a-7f4de3ea23cc', NULL, '{"endpoint": "/api/profile", "profile_id": "70b079c7-e216-4084-b96a-7f4de3ea23cc"}', '2025-11-15 23:31:29.046788+00'),
	('8847c418-d8a9-4173-ac2f-e9d77655e913', 'profile_read', '70b079c7-e216-4084-b96a-7f4de3ea23cc', NULL, '{"endpoint": "/api/profile", "profile_id": "70b079c7-e216-4084-b96a-7f4de3ea23cc"}', '2025-11-15 23:34:25.410363+00'),
	('0fa27d0a-d46a-4167-8cac-893232cfea51', 'profile_read', '70b079c7-e216-4084-b96a-7f4de3ea23cc', NULL, '{"endpoint": "/api/profile", "profile_id": "70b079c7-e216-4084-b96a-7f4de3ea23cc"}', '2025-11-15 23:34:26.658541+00'),
	('aaa90084-4289-444b-916e-3398219e81ae', 'profile_read', '87330a64-e6b2-496b-b8d9-8bbbf5c138ec', NULL, '{"endpoint": "/api/profile", "profile_id": "87330a64-e6b2-496b-b8d9-8bbbf5c138ec"}', '2025-11-15 23:48:09.509461+00'),
	('19d0c8ac-3c19-44b4-aa78-af69d193b602', 'profile_read', '3973b11e-118a-4933-b752-f78cc7469daf', NULL, '{"endpoint": "/api/profile", "profile_id": "3973b11e-118a-4933-b752-f78cc7469daf"}', '2025-11-16 07:12:36.180872+00'),
	('67fd3f81-1322-4938-8c13-343cb3fc7525', 'profile_read', '3973b11e-118a-4933-b752-f78cc7469daf', NULL, '{"endpoint": "/api/profile", "profile_id": "3973b11e-118a-4933-b752-f78cc7469daf"}', '2025-11-16 07:14:17.886913+00'),
	('8af81bd8-5971-4774-9280-a612f3644ea1', 'profile_read', '3973b11e-118a-4933-b752-f78cc7469daf', NULL, '{"endpoint": "/api/profile", "profile_id": "3973b11e-118a-4933-b752-f78cc7469daf"}', '2025-11-16 07:14:50.252917+00'),
	('7326b5cf-e6ae-4c11-a92c-553b37d82fab', 'profile_read', '3973b11e-118a-4933-b752-f78cc7469daf', NULL, '{"endpoint": "/api/profile", "profile_id": "3973b11e-118a-4933-b752-f78cc7469daf"}', '2025-11-16 07:15:20.26057+00'),
	('58eb42a0-6545-4d4d-a939-8ab9a25e29ba', 'profile_read', '3973b11e-118a-4933-b752-f78cc7469daf', NULL, '{"endpoint": "/api/profile", "profile_id": "3973b11e-118a-4933-b752-f78cc7469daf"}', '2025-11-16 07:15:22.692328+00'),
	('c05d7f2a-8e76-4255-8b68-fe4c49969251', 'profile_read', '3973b11e-118a-4933-b752-f78cc7469daf', NULL, '{"endpoint": "/api/profile", "profile_id": "3973b11e-118a-4933-b752-f78cc7469daf"}', '2025-11-16 07:15:38.055617+00'),
	('8f74054c-25e1-4045-8b5b-0f2fd565aaf4', 'profile_read', '3973b11e-118a-4933-b752-f78cc7469daf', NULL, '{"endpoint": "/api/profile", "profile_id": "3973b11e-118a-4933-b752-f78cc7469daf"}', '2025-11-16 07:15:59.661486+00'),
	('a91e6768-1619-4450-a61d-736999f01bea', 'profile_read', '3973b11e-118a-4933-b752-f78cc7469daf', NULL, '{"endpoint": "/api/profile", "profile_id": "3973b11e-118a-4933-b752-f78cc7469daf"}', '2025-11-16 07:18:19.051988+00'),
	('dee4f72c-a3f1-400b-acf9-464e935e475c', 'profile_read', '3973b11e-118a-4933-b752-f78cc7469daf', NULL, '{"endpoint": "/api/profile", "profile_id": "3973b11e-118a-4933-b752-f78cc7469daf"}', '2025-11-16 07:18:29.104729+00'),
	('8fb76dc9-0a35-46a5-b380-7e7e1c3f8ad4', 'profile_read', '3973b11e-118a-4933-b752-f78cc7469daf', NULL, '{"endpoint": "/api/profile", "profile_id": "3973b11e-118a-4933-b752-f78cc7469daf"}', '2025-11-16 07:18:46.027905+00'),
	('75cc42d6-217d-4dbb-bb60-b8ae664ada9e', 'profile_read', '3973b11e-118a-4933-b752-f78cc7469daf', NULL, '{"endpoint": "/api/profile", "profile_id": "3973b11e-118a-4933-b752-f78cc7469daf"}', '2025-11-16 07:18:56.889445+00'),
	('954cf294-d244-48e9-8e18-7461e65b1f8e', 'profile_read', '3973b11e-118a-4933-b752-f78cc7469daf', NULL, '{"endpoint": "/api/profile", "profile_id": "3973b11e-118a-4933-b752-f78cc7469daf"}', '2025-11-16 07:19:14.721388+00'),
	('695a8636-4d95-48ff-939c-ef3ebf018e45', 'profile_read', '3973b11e-118a-4933-b752-f78cc7469daf', NULL, '{"endpoint": "/api/profile", "profile_id": "3973b11e-118a-4933-b752-f78cc7469daf"}', '2025-11-16 07:19:25.234646+00'),
	('a1f57e9c-fda4-4a5f-9d8b-e9db6d8ce2b4', 'profile_read', '3973b11e-118a-4933-b752-f78cc7469daf', NULL, '{"endpoint": "/api/profile", "profile_id": "3973b11e-118a-4933-b752-f78cc7469daf"}', '2025-11-16 07:19:37.635193+00'),
	('e9ff9819-c4ed-4380-9737-e18bdbf6c846', 'profile_read', '3973b11e-118a-4933-b752-f78cc7469daf', NULL, '{"endpoint": "/api/profile", "profile_id": "3973b11e-118a-4933-b752-f78cc7469daf"}', '2025-11-16 07:19:37.816167+00'),
	('9758adb1-0c1d-4a06-9f50-1739a803098f', 'profile_read', '3973b11e-118a-4933-b752-f78cc7469daf', NULL, '{"endpoint": "/api/profile", "profile_id": "3973b11e-118a-4933-b752-f78cc7469daf"}', '2025-11-16 07:19:45.80929+00');


--
-- Data for Name: award_events; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: ratings; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: rescue_claims; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: spatial_ref_sys; Type: TABLE DATA; Schema: public; Owner: supabase_admin
--



--
-- Data for Name: token_ledger; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: tool_images; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."tool_images" ("id", "tool_id", "storage_key", "position", "created_at") VALUES
	('a7f7edfb-b552-448d-92f3-e57b07aa5000', '3195257d-f050-4fdd-b73f-2c7691ea1c5b', 'tools/3195257d-f050-4fdd-b73f-2c7691ea1c5b/1.jpg', 0, '2025-11-07 15:30:57.476+00'),
	('35056ec1-6a25-48ff-be02-336bf82d6c29', '395101c6-e505-4b99-877b-d21ef1fbe4e0', 'tools/395101c6-e505-4b99-877b-d21ef1fbe4e0/1.jpg', 0, '2025-11-07 15:30:57.476+00'),
	('2f935c06-5984-4aaa-970f-6c70638cca4e', 'd6877d21-70dd-4cb1-900e-ac43e881dd28', 'tools/d6877d21-70dd-4cb1-900e-ac43e881dd28/1.jpg', 0, '2025-11-07 15:30:57.476+00'),
	('fefd70c0-8b6b-43ba-bcc9-cb57ed84765a', '942bbe95-2f85-4943-93f3-179485f824a6', 'tools/942bbe95-2f85-4943-93f3-179485f824a6/1.jpg', 0, '2025-11-07 15:30:57.476+00'),
	('2eea7618-5919-40bb-82a2-14784905e1e8', '83fdef2a-cff6-4bc1-a029-d84c9d7d3a54', 'tools/83fdef2a-cff6-4bc1-a029-d84c9d7d3a54/1.jpg', 0, '2025-11-07 15:30:57.476+00'),
	('631c95da-c3db-4bb1-a626-b023bfeed75a', '54b4d70f-3f01-4cb6-a94d-61bed16ab11a', 'tools/54b4d70f-3f01-4cb6-a94d-61bed16ab11a/1.jpg', 0, '2025-11-07 15:30:57.476+00'),
	('a3732d80-17ff-4848-87ac-b22aaeb4db89', 'e4f2b658-373c-4656-bcee-472cfb84ea74', 'tools/e4f2b658-373c-4656-bcee-472cfb84ea74/1.jpg', 0, '2025-11-07 15:30:57.476+00'),
	('2a579c66-b8f2-416e-b304-4e9ed5418f62', '0ddcf029-df3c-420a-90d7-afa7f49cfafc', 'tools/0ddcf029-df3c-420a-90d7-afa7f49cfafc/1.jpg', 0, '2025-11-07 15:30:57.476+00'),
	('4ef79680-a3ce-43b4-8a09-3586f230b6dc', '9b35c494-e01c-4a34-89a2-959efe5ac2c6', 'tools/9b35c494-e01c-4a34-89a2-959efe5ac2c6/1.jpg', 0, '2025-11-07 15:30:57.476+00'),
	('4557cd89-defd-42fd-b876-490e8a54a2d8', '35089eb7-36ec-48c3-b779-19105c034e53', 'tools/35089eb7-36ec-48c3-b779-19105c034e53/1.jpg', 0, '2025-11-07 15:30:57.476+00'),
	('0831f23f-3d72-4b5e-a879-ad633c6a5d43', '76ea0bbf-a9eb-4144-abeb-f590fb8cde02', 'tools/76ea0bbf-a9eb-4144-abeb-f590fb8cde02/1.jpg', 0, '2025-11-07 15:30:57.476+00'),
	('81189718-d124-43c7-9974-aab472569288', '71b2d07e-63d4-4f1d-84d7-b0c10e1527d2', 'tools/71b2d07e-63d4-4f1d-84d7-b0c10e1527d2/1.jpg', 0, '2025-11-07 15:30:57.476+00'),
	('c8ce1be3-992b-43ef-9719-04823f5a9eff', '1c975e66-1466-411d-a3a2-eff960eec214', 'tools/1c975e66-1466-411d-a3a2-eff960eec214/1.jpg', 0, '2025-11-07 15:30:57.476+00'),
	('ad004b63-f39d-49c9-9aba-417e2378dc44', '87476300-72db-48bc-9184-bb8aacaa4387', 'tools/87476300-72db-48bc-9184-bb8aacaa4387/1.jpg', 0, '2025-11-07 15:30:57.476+00'),
	('80e6ae43-748e-49db-9df5-a11b369de24b', '236fb360-277b-43a6-8f00-c3355703926e', 'tools/236fb360-277b-43a6-8f00-c3355703926e/1.jpg', 0, '2025-11-07 15:30:57.476+00'),
	('4378e7ed-64e0-4a1b-802a-b70d4a5c383e', '1b422aaf-99cb-43d5-bc9f-e4a852c25039', 'tools/1b422aaf-99cb-43d5-bc9f-e4a852c25039/1.jpg', 0, '2025-11-07 15:30:57.476+00'),
	('46385bdb-a3d1-4017-814e-12e4b3a7cfb1', 'd374081d-292c-4716-a7c2-cdc72d54aee9', 'tools/d374081d-292c-4716-a7c2-cdc72d54aee9/1.jpg', 0, '2025-11-07 15:30:57.476+00'),
	('26cb6263-6e7e-4f76-b8be-f2c749776ea9', 'd824714a-3d41-4398-8943-783c03db3395', 'tools/d824714a-3d41-4398-8943-783c03db3395/1.jpg', 0, '2025-11-07 15:30:57.476+00'),
	('fef947d4-8670-4b3c-a46f-c0adcb50e218', '9a0db2e0-de38-4192-8d32-bd9d33c976de', 'tools/9a0db2e0-de38-4192-8d32-bd9d33c976de/1.jpg', 0, '2025-11-07 15:30:57.476+00'),
	('f0deb4c1-1c95-49c2-81fe-27aa586cc8a8', '6fe0f3d2-4ad5-4f2c-b21d-d4a066e50eb8', 'tools/6fe0f3d2-4ad5-4f2c-b21d-d4a066e50eb8/1.jpg', 0, '2025-11-07 15:30:57.476+00'),
	('f20a2b99-b1cd-467e-86a7-26d1693c8154', 'b86baca8-04f7-4df6-94f9-b5c2f67eb1f1', 'tools/b86baca8-04f7-4df6-94f9-b5c2f67eb1f1/1.jpg', 0, '2025-11-07 15:30:57.476+00'),
	('1026f8f6-a530-4dea-8e6e-ffa1d5c0f7be', 'd213d69e-7975-4c52-bde8-1950c3c38279', 'tools/d213d69e-7975-4c52-bde8-1950c3c38279/1.jpg', 0, '2025-11-07 15:30:57.476+00'),
	('eaed665b-1c0f-4830-ab17-2932f18381b2', 'cd727031-ac68-49ee-b262-3a4b4dec2d8f', 'tools/cd727031-ac68-49ee-b262-3a4b4dec2d8f/1.jpg', 0, '2025-11-07 15:30:57.476+00'),
	('5ed4bd4b-df59-4a07-a867-8747c2b4ba6f', 'a75a901c-cfee-421c-b34b-92a3c34fe890', 'tools/a75a901c-cfee-421c-b34b-92a3c34fe890/e74770d3-52dd-49ce-b464-e800589b70fe.jpg', 0, '2025-11-12 12:30:38.990025+00'),
	('c09f6bf8-33de-49ca-afee-ed9439640980', '47d5ffc8-e25b-4bab-b2de-7558cdd4901e', 'tools/47d5ffc8-e25b-4bab-b2de-7558cdd4901e/c548d8b9-96aa-4c25-b327-373d48ff4912.jpg', 0, '2025-11-12 12:36:11.319339+00'),
	('32e0741d-daf8-41d8-baa4-efd8f18b3530', '5405bb7b-fb21-47df-b9b2-e4db81bc9bbd', 'tools/5405bb7b-fb21-47df-b9b2-e4db81bc9bbd/d02a6097-cc0f-4d48-8d05-9f63f5d1592d.jpg', 0, '2025-11-12 12:39:40.364988+00'),
	('abf99f23-64c9-45cc-a279-d3f6987beda2', 'be84b6fa-294f-43f8-bef5-6977906c9e74', 'tools/be84b6fa-294f-43f8-bef5-6977906c9e74/ac2432ab-d122-4e5b-a649-c754d23adf79.jpg', 0, '2025-11-12 13:58:57.242208+00'),
	('e79e8afa-b7c2-4eca-9a25-e3f29d796b16', '3ba54133-fba5-4b73-9ce4-8f3939eccc2a', 'tools/3ba54133-fba5-4b73-9ce4-8f3939eccc2a/734dfb6e-fccc-4979-93bb-923cd6431d15.jpg', 0, '2025-11-12 14:18:20.489868+00'),
	('fa12f0ae-25d5-4352-87d2-7984e34ccd20', '70c34f24-3723-48f2-8354-c59880b7144b', 'tools/70c34f24-3723-48f2-8354-c59880b7144b/d8efcb46-05d5-4068-bd6a-72c377a81e31.jpg', 0, '2025-11-12 14:23:30.686642+00'),
	('12d8f710-1423-4fc1-b842-dd37dc91f4e8', 'be84b6fa-294f-43f8-bef5-6977906c9e74', 'tools/be84b6fa-294f-43f8-bef5-6977906c9e74/99a42b43-fce5-4bd9-b453-e23f9198e57a.jpg', 1, '2025-11-12 15:12:29.195345+00'),
	('a5b8a8eb-b7c6-4a06-8bda-909848b8d8ab', '8ffebbb4-4c1c-4a1f-a478-7be74a5b95a0', 'tools/8ffebbb4-4c1c-4a1f-a478-7be74a5b95a0/9b63c7dd-dfde-4651-9d48-0c2cdb4085a5.jpg', 0, '2025-11-12 15:13:22.445249+00'),
	('031c83d0-8398-4bf0-b430-a226a60e36e8', 'be84b6fa-294f-43f8-bef5-6977906c9e74', 'tools/be84b6fa-294f-43f8-bef5-6977906c9e74/be3ff420-5ed8-40ed-aa39-9643a77a4994.jpg', 2, '2025-11-12 15:19:03.242274+00'),
	('e8f34eb7-bcf7-4bf0-bb7f-db7344865b0f', '8ffebbb4-4c1c-4a1f-a478-7be74a5b95a0', 'tools/8ffebbb4-4c1c-4a1f-a478-7be74a5b95a0/c5e3ce15-08ee-4dec-9cb5-b07c3c1c3837.jpg', 1, '2025-11-14 11:01:34.436738+00'),
	('fd8eff75-c3fc-4db7-9c6a-175a4d367ba7', '65c7c171-a92e-4bcc-a2ad-1c8d350fd1f6', 'tools/65c7c171-a92e-4bcc-a2ad-1c8d350fd1f6/167541a9-7387-437b-b5f8-db37595ccf08.jpg', 0, '2025-11-14 11:37:23.268684+00'),
	('1ce6e3bb-e609-4d67-9455-1c1ab53440bb', '06ff89c9-3fbc-46ef-8f85-3f36adea1f2a', 'tools/06ff89c9-3fbc-46ef-8f85-3f36adea1f2a/db1785ea-f549-47d8-a765-b635a0ed283a.jpg', 0, '2025-11-15 09:37:34.230986+00'),
	('f9b4637a-1e61-44e6-9000-3938abb07948', '2082c326-6fbe-4bb5-9689-5257bb1ad7c2', 'tools/2082c326-6fbe-4bb5-9689-5257bb1ad7c2/7ac59679-975f-4fc3-aa9b-fccb70d1f849.jpg', 0, '2025-11-15 09:37:58.173559+00'),
	('e5acd518-a27d-412c-aa47-325efac625ae', '89d7ee5c-902b-42e3-baba-d1310828888e', 'tools/89d7ee5c-902b-42e3-baba-d1310828888e/6027faff-ce26-4bc7-9dd4-4679c70bb711.jpg', 0, '2025-11-15 09:40:32.388715+00'),
	('7b3354af-8817-4238-94b5-760f17c861f5', 'de889366-c54a-4de5-aaf8-308a7e5b6c23', 'tools/de889366-c54a-4de5-aaf8-308a7e5b6c23/33f43268-5988-4623-a717-3b55ab1d386f.png', 0, '2025-11-15 09:42:31.065242+00'),
	('9515bc04-981f-4ae5-add1-3bb459670e14', '4eb130a6-855b-4d1d-ab64-2b0b85575101', 'tools/4eb130a6-855b-4d1d-ab64-2b0b85575101/ba6ba7fa-a0c6-4c7a-ab10-f367e5414d68.jpg', 0, '2025-11-15 09:42:56.264015+00'),
	('2ba8408b-e084-4db9-a1c7-d3549a09b1a7', '614c7653-94f2-48d2-bb65-c443663efb88', 'tools/614c7653-94f2-48d2-bb65-c443663efb88/011968ea-1bd0-4217-9095-c5d99a77a397.jpg', 0, '2025-11-15 09:43:34.941285+00'),
	('d1f8f736-6b49-4071-bfce-a6c8414be184', '01156fb3-785b-4b49-b512-c8966ba50f0c', 'tools/01156fb3-785b-4b49-b512-c8966ba50f0c/30726358-1a8c-4d53-be2e-6a53a031ffce.jpg', 0, '2025-11-15 09:45:27.34928+00'),
	('906719fe-c080-45f4-8801-7d05b9fd645a', '7ad85121-c17f-4c91-960f-2c713170a98c', 'tools/7ad85121-c17f-4c91-960f-2c713170a98c/b3463a89-8fa7-4078-b109-0d7b5cbbd90d.jpg', 0, '2025-11-15 09:47:04.308909+00'),
	('f28d89e2-d959-4224-b9d3-8bcf9fa7aabd', 'd3e51fbf-9167-4a04-adc4-a85e007937a9', 'tools/d3e51fbf-9167-4a04-adc4-a85e007937a9/b6e337b0-c28d-463f-8b2d-55535954325d.jpg', 0, '2025-11-15 10:02:15.820798+00');


--
-- Data for Name: buckets; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

INSERT INTO "storage"."buckets" ("id", "name", "owner", "created_at", "updated_at", "public", "avif_autodetection", "file_size_limit", "allowed_mime_types", "owner_id", "type") VALUES
	('tool_images', 'tool_images', NULL, '2025-11-12 12:05:24.280503+00', '2025-11-12 12:05:24.280503+00', true, false, NULL, NULL, NULL, 'STANDARD');


--
-- Data for Name: buckets_analytics; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: iceberg_namespaces; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: iceberg_tables; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: objects; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

INSERT INTO "storage"."objects" ("id", "bucket_id", "name", "owner", "created_at", "updated_at", "last_accessed_at", "metadata", "version", "owner_id", "user_metadata", "level") VALUES
	('af9217f2-5098-4b62-8210-c6a171a49a91', 'tool_images', 'tools/7145701e-6bfe-4f53-a0ac-096cc1c4c5cb/e63595bf-c5ae-44be-b6f8-ccb8db2891a7.jpg', NULL, '2025-11-12 12:16:50.385748+00', '2025-11-12 12:16:50.385748+00', '2025-11-12 12:16:50.385748+00', '{"eTag": "\"3bcadb3852cd60ca227657e5be33db11\"", "size": 94067, "mimetype": "image/jpeg", "cacheControl": "no-cache", "lastModified": "2025-11-12T12:16:50.376Z", "contentLength": 94067, "httpStatusCode": 200}', 'f6014a1d-641a-4819-af33-98ff2d8b1651', NULL, '{}', 3),
	('d54c3252-47c2-4219-96ba-c2aad4fa3f64', 'tool_images', 'tools/3d9036e2-9ec3-4101-8fbf-794922d52ea4/c14ad70c-b540-4577-ae78-11838018542b.jpg', NULL, '2025-11-12 12:17:07.955549+00', '2025-11-12 12:17:07.955549+00', '2025-11-12 12:17:07.955549+00', '{"eTag": "\"3bcadb3852cd60ca227657e5be33db11\"", "size": 94067, "mimetype": "image/jpeg", "cacheControl": "no-cache", "lastModified": "2025-11-12T12:17:07.951Z", "contentLength": 94067, "httpStatusCode": 200}', '9b6e8827-13aa-4f96-a23a-3e5efc0a0f18', NULL, '{}', 3),
	('2cca34ae-583e-4284-b814-f46a4bf96600', 'tool_images', 'tools/3d9036e2-9ec3-4101-8fbf-794922d52ea4/87d1fe85-a13f-418d-92e8-9793594ddbdb.jpg', NULL, '2025-11-12 12:17:20.254763+00', '2025-11-12 12:17:20.254763+00', '2025-11-12 12:17:20.254763+00', '{"eTag": "\"4284bc70de17ee15d4f7fde4b8852736\"", "size": 84541, "mimetype": "image/jpeg", "cacheControl": "no-cache", "lastModified": "2025-11-12T12:17:20.251Z", "contentLength": 84541, "httpStatusCode": 200}', '335548e1-8013-4445-8fb6-f92b53066c71', NULL, '{}', 3),
	('ff687ea3-e735-4def-8ee2-7d7d33aeae7d', 'tool_images', 'tools/3d9036e2-9ec3-4101-8fbf-794922d52ea4/e5fa70b5-1eea-4b46-82aa-298dc103ae75.jpg', NULL, '2025-11-12 12:18:19.201635+00', '2025-11-12 12:18:19.201635+00', '2025-11-12 12:18:19.201635+00', '{"eTag": "\"43bfb7f05b95217ceab2ca5de49c32d3\"", "size": 90125, "mimetype": "image/jpeg", "cacheControl": "no-cache", "lastModified": "2025-11-12T12:18:19.198Z", "contentLength": 90125, "httpStatusCode": 200}', '1bb538c0-23b3-4d56-9a68-50ed2592bef2', NULL, '{}', 3),
	('3c4ca0ce-cf9f-40a4-a128-f95a35dae726', 'tool_images', 'tools/444a9570-9eab-4aeb-a585-b524f3f8f424/5a4478c6-728f-4d28-8b18-002638663c93.jpg', NULL, '2025-11-12 12:20:17.864422+00', '2025-11-12 12:20:17.864422+00', '2025-11-12 12:20:17.864422+00', '{"eTag": "\"58e24ed3ae35e977a1b9ed703e3375c7\"", "size": 111371, "mimetype": "image/jpeg", "cacheControl": "no-cache", "lastModified": "2025-11-12T12:20:17.859Z", "contentLength": 111371, "httpStatusCode": 200}', '72903131-379a-4568-8aa9-f57d95d9f1d2', NULL, '{}', 3),
	('ed8b6234-f08f-432f-bfe9-44676524af21', 'tool_images', 'tools/6419bf4e-1a53-4985-bc14-993159cf6a6b/05a84c0e-e68e-4b66-8490-df30c12cab58.jpg', NULL, '2025-11-12 12:21:50.459083+00', '2025-11-12 12:21:50.459083+00', '2025-11-12 12:21:50.459083+00', '{"eTag": "\"2e0946ad3d3116f91cb8ede98bd24853\"", "size": 134184, "mimetype": "image/jpeg", "cacheControl": "no-cache", "lastModified": "2025-11-12T12:21:50.454Z", "contentLength": 134184, "httpStatusCode": 200}', 'a6b68d32-dec6-45dc-b344-db93563f316e', NULL, '{}', 3),
	('f1dbbf46-a7a6-49eb-9d8b-e2b739c10473', 'tool_images', 'tools/ab0ed76f-4a67-48c6-9ffa-8c37b93ab630/2cea6da8-3ec2-4d46-b1e7-1038cda4c3c5.jpg', NULL, '2025-11-12 12:27:32.130461+00', '2025-11-12 12:27:32.130461+00', '2025-11-12 12:27:32.130461+00', '{"eTag": "\"3bcadb3852cd60ca227657e5be33db11\"", "size": 94067, "mimetype": "image/jpeg", "cacheControl": "no-cache", "lastModified": "2025-11-12T12:27:32.121Z", "contentLength": 94067, "httpStatusCode": 200}', 'f6edcb41-a853-4b1a-a7c2-30305c9d498a', NULL, '{}', 3),
	('26466bca-f326-44e2-8457-501186219f08', 'tool_images', 'tools/a75a901c-cfee-421c-b34b-92a3c34fe890/e74770d3-52dd-49ce-b464-e800589b70fe.jpg', NULL, '2025-11-12 12:30:38.969911+00', '2025-11-12 12:30:38.969911+00', '2025-11-12 12:30:38.969911+00', '{"eTag": "\"49b5dea0765eb82e94d727c38a947b8b\"", "size": 105822, "mimetype": "image/jpeg", "cacheControl": "no-cache", "lastModified": "2025-11-12T12:30:38.964Z", "contentLength": 105822, "httpStatusCode": 200}', '24ad130a-ad28-41c2-98f2-3a2450163519', NULL, '{}', 3),
	('31de1eee-6d70-42a2-9db6-8da1e96a6083', 'tool_images', 'tools/47d5ffc8-e25b-4bab-b2de-7558cdd4901e/c548d8b9-96aa-4c25-b327-373d48ff4912.jpg', NULL, '2025-11-12 12:36:11.294451+00', '2025-11-12 12:36:11.294451+00', '2025-11-12 12:36:11.294451+00', '{"eTag": "\"43bfb7f05b95217ceab2ca5de49c32d3\"", "size": 90125, "mimetype": "image/jpeg", "cacheControl": "no-cache", "lastModified": "2025-11-12T12:36:11.284Z", "contentLength": 90125, "httpStatusCode": 200}', 'd3af5bd5-d078-4830-ad7a-16e07b0becc3', NULL, '{}', 3),
	('b738eee1-51a8-42f9-98b6-935481521013', 'tool_images', 'tools/5405bb7b-fb21-47df-b9b2-e4db81bc9bbd/d02a6097-cc0f-4d48-8d05-9f63f5d1592d.jpg', NULL, '2025-11-12 12:39:40.351559+00', '2025-11-12 12:39:40.351559+00', '2025-11-12 12:39:40.351559+00', '{"eTag": "\"247d59929c617413929aaa6298aba27c\"", "size": 73300, "mimetype": "image/jpeg", "cacheControl": "no-cache", "lastModified": "2025-11-12T12:39:40.344Z", "contentLength": 73300, "httpStatusCode": 200}', '1b5b1893-0adc-46df-9ec2-b8347131bce7', NULL, '{}', 3),
	('04df67c4-0b84-49f6-ba8c-96d55566163f', 'tool_images', 'tools/be84b6fa-294f-43f8-bef5-6977906c9e74/ac2432ab-d122-4e5b-a649-c754d23adf79.jpg', NULL, '2025-11-12 13:58:57.213477+00', '2025-11-12 13:58:57.213477+00', '2025-11-12 13:58:57.213477+00', '{"eTag": "\"6fb5cf6d959908bff3bf192762b95565\"", "size": 28477, "mimetype": "image/jpeg", "cacheControl": "no-cache", "lastModified": "2025-11-12T13:58:57.206Z", "contentLength": 28477, "httpStatusCode": 200}', '4178bb0a-0664-477d-aacd-72a8e2492b13', NULL, '{}', 3),
	('532cb49e-a83f-4fbd-98b1-2eef0b54f33e', 'tool_images', 'tools/3ba54133-fba5-4b73-9ce4-8f3939eccc2a/734dfb6e-fccc-4979-93bb-923cd6431d15.jpg', NULL, '2025-11-12 14:18:20.407322+00', '2025-11-12 14:18:20.407322+00', '2025-11-12 14:18:20.407322+00', '{"eTag": "\"49b5dea0765eb82e94d727c38a947b8b\"", "size": 105822, "mimetype": "image/jpeg", "cacheControl": "no-cache", "lastModified": "2025-11-12T14:18:20.397Z", "contentLength": 105822, "httpStatusCode": 200}', 'cac690b9-e0fb-479f-a207-2f2c4963554d', NULL, '{}', 3),
	('02d074bd-2b64-42c7-a21f-af5d04527070', 'tool_images', 'tools/70c34f24-3723-48f2-8354-c59880b7144b/d8efcb46-05d5-4068-bd6a-72c377a81e31.jpg', NULL, '2025-11-12 14:23:30.666754+00', '2025-11-12 14:23:30.666754+00', '2025-11-12 14:23:30.666754+00', '{"eTag": "\"58e24ed3ae35e977a1b9ed703e3375c7\"", "size": 111371, "mimetype": "image/jpeg", "cacheControl": "no-cache", "lastModified": "2025-11-12T14:23:30.662Z", "contentLength": 111371, "httpStatusCode": 200}', '5f8b22f1-3d41-4dd0-829e-3c1de446fec1', NULL, '{}', 3),
	('197b71c4-1920-4484-b962-8ac0c76c6a08', 'tool_images', 'tools/da2f331f-814a-435b-94dd-97e57c881632/df6d36dc-9c6f-4346-9217-668f8b36c73d.jpg', NULL, '2025-11-12 15:09:03.956213+00', '2025-11-12 15:09:03.956213+00', '2025-11-12 15:09:03.956213+00', '{"eTag": "\"49b5dea0765eb82e94d727c38a947b8b\"", "size": 105822, "mimetype": "image/jpeg", "cacheControl": "no-cache", "lastModified": "2025-11-12T15:09:03.945Z", "contentLength": 105822, "httpStatusCode": 200}', '90908779-fc2a-4ebb-9af0-8f373a7890e6', NULL, '{}', 3),
	('cb491210-66f3-41f8-9d41-2676cc43597d', 'tool_images', 'tools/be84b6fa-294f-43f8-bef5-6977906c9e74/99a42b43-fce5-4bd9-b453-e23f9198e57a.jpg', NULL, '2025-11-12 15:12:29.180578+00', '2025-11-12 15:12:29.180578+00', '2025-11-12 15:12:29.180578+00', '{"eTag": "\"49b5dea0765eb82e94d727c38a947b8b\"", "size": 105822, "mimetype": "image/jpeg", "cacheControl": "no-cache", "lastModified": "2025-11-12T15:12:29.173Z", "contentLength": 105822, "httpStatusCode": 200}', '4399d86f-5f6f-4a38-96dd-892de61ba6b6', NULL, '{}', 3),
	('429318b4-de79-437c-90c7-10ba07e4a4d1', 'tool_images', 'tools/8ffebbb4-4c1c-4a1f-a478-7be74a5b95a0/9b63c7dd-dfde-4651-9d48-0c2cdb4085a5.jpg', NULL, '2025-11-12 15:13:22.428971+00', '2025-11-12 15:13:22.428971+00', '2025-11-12 15:13:22.428971+00', '{"eTag": "\"49b5dea0765eb82e94d727c38a947b8b\"", "size": 105822, "mimetype": "image/jpeg", "cacheControl": "no-cache", "lastModified": "2025-11-12T15:13:22.425Z", "contentLength": 105822, "httpStatusCode": 200}', '6798013f-4e77-4991-a2e3-16e8c7caa724', NULL, '{}', 3),
	('e69a9d9c-ab2c-4aeb-8bd7-503e3b98b737', 'tool_images', 'tools/be84b6fa-294f-43f8-bef5-6977906c9e74/be3ff420-5ed8-40ed-aa39-9643a77a4994.jpg', NULL, '2025-11-12 15:19:03.223758+00', '2025-11-12 15:19:03.223758+00', '2025-11-12 15:19:03.223758+00', '{"eTag": "\"58e24ed3ae35e977a1b9ed703e3375c7\"", "size": 111371, "mimetype": "image/jpeg", "cacheControl": "no-cache", "lastModified": "2025-11-12T15:19:03.218Z", "contentLength": 111371, "httpStatusCode": 200}', '4004b53d-8c23-4084-9266-5e11dd3b0901', NULL, '{}', 3),
	('ec8a5c05-b9eb-4ac1-921d-31528a5b5370', 'tool_images', 'tools/8ffebbb4-4c1c-4a1f-a478-7be74a5b95a0/dacc5082-3c79-4c42-8d79-97b02055ba93.jpg', NULL, '2025-11-14 11:01:30.619371+00', '2025-11-14 11:01:30.619371+00', '2025-11-14 11:01:30.619371+00', '{"eTag": "\"49b5dea0765eb82e94d727c38a947b8b\"", "size": 105822, "mimetype": "image/jpeg", "cacheControl": "no-cache", "lastModified": "2025-11-14T11:01:30.612Z", "contentLength": 105822, "httpStatusCode": 200}', 'b91dec2c-f3c7-4a72-9c5b-21837aed6f8a', NULL, '{}', 3),
	('f4f05f18-9144-4504-93a6-8e1782fc9f0e', 'tool_images', 'tools/8ffebbb4-4c1c-4a1f-a478-7be74a5b95a0/c5e3ce15-08ee-4dec-9cb5-b07c3c1c3837.jpg', NULL, '2025-11-14 11:01:34.421202+00', '2025-11-14 11:01:34.421202+00', '2025-11-14 11:01:34.421202+00', '{"eTag": "\"58e24ed3ae35e977a1b9ed703e3375c7\"", "size": 111371, "mimetype": "image/jpeg", "cacheControl": "no-cache", "lastModified": "2025-11-14T11:01:34.414Z", "contentLength": 111371, "httpStatusCode": 200}', '16064f43-92a2-4f96-bd4e-2f925a15ac3c', NULL, '{}', 3),
	('b32574d0-2a1d-4657-ab1a-a0b870afbf69', 'tool_images', 'tools/aa8cff83-dcc8-4753-85e5-6b158d964614/bf1864b8-dd1e-43d9-8514-2f6750298e43.jpg', NULL, '2025-11-14 11:32:43.912418+00', '2025-11-14 11:32:43.912418+00', '2025-11-14 11:32:43.912418+00', '{"eTag": "\"5bc9e467d96be5cd287cae7f58c8c6e7\"", "size": 138141, "mimetype": "image/jpeg", "cacheControl": "no-cache", "lastModified": "2025-11-14T11:32:43.906Z", "contentLength": 138141, "httpStatusCode": 200}', '107fa775-6702-4013-8e0e-2474c14f6835', NULL, '{}', 3),
	('99c0acbc-aa1c-4819-91e0-5fb9f2f5ea4a', 'tool_images', 'tools/65c7c171-a92e-4bcc-a2ad-1c8d350fd1f6/167541a9-7387-437b-b5f8-db37595ccf08.jpg', NULL, '2025-11-14 11:37:23.254181+00', '2025-11-14 11:37:23.254181+00', '2025-11-14 11:37:23.254181+00', '{"eTag": "\"247d59929c617413929aaa6298aba27c\"", "size": 73300, "mimetype": "image/jpeg", "cacheControl": "no-cache", "lastModified": "2025-11-14T11:37:23.248Z", "contentLength": 73300, "httpStatusCode": 200}', '0bc61adf-67f7-4ea7-becb-e86b768528d7', NULL, '{}', 3),
	('490b1baa-1bc5-40f2-99b1-2afad3ff055a', 'tool_images', 'tools/06ff89c9-3fbc-46ef-8f85-3f36adea1f2a/db1785ea-f549-47d8-a765-b635a0ed283a.jpg', NULL, '2025-11-15 09:37:34.198411+00', '2025-11-15 09:37:34.198411+00', '2025-11-15 09:37:34.198411+00', '{"eTag": "\"49b5dea0765eb82e94d727c38a947b8b\"", "size": 105822, "mimetype": "image/jpeg", "cacheControl": "no-cache", "lastModified": "2025-11-15T09:37:34.189Z", "contentLength": 105822, "httpStatusCode": 200}', 'ccb4c16a-ca43-4a8d-bf99-0303893a6a13', NULL, '{}', 3),
	('5120daf8-9915-4e9b-bf0b-c211a8f52dda', 'tool_images', 'tools/2082c326-6fbe-4bb5-9689-5257bb1ad7c2/7ac59679-975f-4fc3-aa9b-fccb70d1f849.jpg', NULL, '2025-11-15 09:37:58.153015+00', '2025-11-15 09:37:58.153015+00', '2025-11-15 09:37:58.153015+00', '{"eTag": "\"49b5dea0765eb82e94d727c38a947b8b\"", "size": 105822, "mimetype": "image/jpeg", "cacheControl": "no-cache", "lastModified": "2025-11-15T09:37:58.147Z", "contentLength": 105822, "httpStatusCode": 200}', '3ceed323-a65e-43fa-ba8a-11e4ba11f584', NULL, '{}', 3),
	('8f89de26-d003-4e0d-853a-9f0a312a88ba', 'tool_images', 'tools/89d7ee5c-902b-42e3-baba-d1310828888e/6027faff-ce26-4bc7-9dd4-4679c70bb711.jpg', NULL, '2025-11-15 09:40:32.369692+00', '2025-11-15 09:40:32.369692+00', '2025-11-15 09:40:32.369692+00', '{"eTag": "\"6fb5cf6d959908bff3bf192762b95565\"", "size": 28477, "mimetype": "image/jpeg", "cacheControl": "no-cache", "lastModified": "2025-11-15T09:40:32.363Z", "contentLength": 28477, "httpStatusCode": 200}', 'a2de9e2d-20bf-4301-9364-741f31c5878f', NULL, '{}', 3),
	('a72bb348-6cf5-4db6-a8c8-792e7f4d9bb7', 'tool_images', 'tools/9587c284-e961-4a5c-9c84-d1dcb874fc83/cfac71e4-f14e-405b-8269-0432dd488351.jpg', NULL, '2025-11-15 09:41:27.727125+00', '2025-11-15 09:41:27.727125+00', '2025-11-15 09:41:27.727125+00', '{"eTag": "\"4bb54b23c04ce9df71d53c5e39bed6c0\"", "size": 493253, "mimetype": "image/jpeg", "cacheControl": "no-cache", "lastModified": "2025-11-15T09:41:27.715Z", "contentLength": 493253, "httpStatusCode": 200}', '62ef07e6-8b4e-4e4e-8cb8-9a8d1cc050ac', NULL, '{}', 3),
	('d0eee1b8-f206-48c2-8ac4-8ca9f052755d', 'tool_images', 'tools/de889366-c54a-4de5-aaf8-308a7e5b6c23/33f43268-5988-4623-a717-3b55ab1d386f.png', NULL, '2025-11-15 09:42:31.0454+00', '2025-11-15 09:42:31.0454+00', '2025-11-15 09:42:31.0454+00', '{"eTag": "\"d80ff3fe996070393869032e2f362f58\"", "size": 233159, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-11-15T09:42:31.037Z", "contentLength": 233159, "httpStatusCode": 200}', '71b0debd-99f3-4b0f-940b-07aca95a6669', NULL, '{}', 3),
	('8bad6fad-77be-4917-937b-508134b6053c', 'tool_images', 'tools/4eb130a6-855b-4d1d-ab64-2b0b85575101/ba6ba7fa-a0c6-4c7a-ab10-f367e5414d68.jpg', NULL, '2025-11-15 09:42:56.244402+00', '2025-11-15 09:42:56.244402+00', '2025-11-15 09:42:56.244402+00', '{"eTag": "\"7496a049e689c77fa006fa4ec7d92bb5\"", "size": 141275, "mimetype": "image/jpeg", "cacheControl": "no-cache", "lastModified": "2025-11-15T09:42:56.239Z", "contentLength": 141275, "httpStatusCode": 200}', '7cac57bf-8e13-4426-b8b6-f7f61aa524b7', NULL, '{}', 3),
	('f705ae0d-3b5b-4a91-9814-7368c6ba0606', 'tool_images', 'tools/614c7653-94f2-48d2-bb65-c443663efb88/011968ea-1bd0-4217-9095-c5d99a77a397.jpg', NULL, '2025-11-15 09:43:34.913474+00', '2025-11-15 09:43:34.913474+00', '2025-11-15 09:43:34.913474+00', '{"eTag": "\"2f4475e4bcd85cb7ab15a2ce33d59ae5\"", "size": 99024, "mimetype": "image/jpeg", "cacheControl": "no-cache", "lastModified": "2025-11-15T09:43:34.907Z", "contentLength": 99024, "httpStatusCode": 200}', 'c9a377f8-4fe9-45a4-bb6a-1031871b0627', NULL, '{}', 3),
	('12fe8ca8-0093-4a22-84ab-01b32fd076a1', 'tool_images', 'tools/01156fb3-785b-4b49-b512-c8966ba50f0c/30726358-1a8c-4d53-be2e-6a53a031ffce.jpg', NULL, '2025-11-15 09:45:27.329115+00', '2025-11-15 09:45:27.329115+00', '2025-11-15 09:45:27.329115+00', '{"eTag": "\"2e0946ad3d3116f91cb8ede98bd24853\"", "size": 134184, "mimetype": "image/jpeg", "cacheControl": "no-cache", "lastModified": "2025-11-15T09:45:27.324Z", "contentLength": 134184, "httpStatusCode": 200}', '2293ca67-b98a-45cd-b019-5116bd01dabd', NULL, '{}', 3),
	('04e13c0c-40fb-4ba7-bcfe-f77faa9d1534', 'tool_images', 'tools/7ad85121-c17f-4c91-960f-2c713170a98c/b3463a89-8fa7-4078-b109-0d7b5cbbd90d.jpg', NULL, '2025-11-15 09:47:04.289117+00', '2025-11-15 09:47:04.289117+00', '2025-11-15 09:47:04.289117+00', '{"eTag": "\"247d59929c617413929aaa6298aba27c\"", "size": 73300, "mimetype": "image/jpeg", "cacheControl": "no-cache", "lastModified": "2025-11-15T09:47:04.282Z", "contentLength": 73300, "httpStatusCode": 200}', '3cbec26f-a357-411b-957f-df8c4e181a3a', NULL, '{}', 3),
	('0046400f-a1f2-49b7-baa8-4b637a46b3ff', 'tool_images', 'tools/d3e51fbf-9167-4a04-adc4-a85e007937a9/b6e337b0-c28d-463f-8b2d-55535954325d.jpg', NULL, '2025-11-15 10:02:15.73799+00', '2025-11-15 10:02:15.73799+00', '2025-11-15 10:02:15.73799+00', '{"eTag": "\"2e0946ad3d3116f91cb8ede98bd24853\"", "size": 134184, "mimetype": "image/jpeg", "cacheControl": "no-cache", "lastModified": "2025-11-15T10:02:15.733Z", "contentLength": 134184, "httpStatusCode": 200}', '2256b798-5a31-4922-a697-0b3163ebf638', NULL, '{}', 3),
	('2a63e6e0-965d-4ee9-85ef-115131832a62', 'tool_images', 'tools/3195257d-f050-4fdd-b73f-2c7691ea1c5b/b13f19e3-0e09-4708-949f-679e00d25e79.jpg', NULL, '2025-11-15 19:44:55.111502+00', '2025-11-15 19:44:55.111502+00', '2025-11-15 19:44:55.111502+00', '{"eTag": "\"2e0946ad3d3116f91cb8ede98bd24853\"", "size": 134184, "mimetype": "image/jpeg", "cacheControl": "no-cache", "lastModified": "2025-11-15T19:44:55.106Z", "contentLength": 134184, "httpStatusCode": 200}', 'c0653e9a-809b-425c-bbaa-4277fcae4d5b', NULL, '{}', 3),
	('e93640a0-c62b-43e8-b600-b26fd669012e', 'tool_images', 'tools/4a57b044-c675-4418-ae8d-00cbc6d4ac7f/5932a12c-5243-4bd1-9650-5c19191c813e.jpg', NULL, '2025-11-15 19:46:14.057259+00', '2025-11-15 19:46:14.057259+00', '2025-11-15 19:46:14.057259+00', '{"eTag": "\"247d59929c617413929aaa6298aba27c\"", "size": 73300, "mimetype": "image/jpeg", "cacheControl": "no-cache", "lastModified": "2025-11-15T19:46:14.051Z", "contentLength": 73300, "httpStatusCode": 200}', '5d818dcb-cd01-48da-8d8c-e47abb3444d5', NULL, '{}', 3),
	('67a4ea78-68f0-46ce-b0cd-2d8c28f16748', 'tool_images', 'tools/71b2d07e-63d4-4f1d-84d7-b0c10e1527d2/9cd904ca-0482-44a3-a9cf-88c65ee3effc.jpg', NULL, '2025-11-15 19:46:53.951675+00', '2025-11-15 19:46:53.951675+00', '2025-11-15 19:46:53.951675+00', '{"eTag": "\"2e0946ad3d3116f91cb8ede98bd24853\"", "size": 134184, "mimetype": "image/jpeg", "cacheControl": "no-cache", "lastModified": "2025-11-15T19:46:53.947Z", "contentLength": 134184, "httpStatusCode": 200}', '71ec7f3f-c93f-455a-aa93-e1dd7b081377', NULL, '{}', 3);


--
-- Data for Name: prefixes; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

INSERT INTO "storage"."prefixes" ("bucket_id", "name", "created_at", "updated_at") VALUES
	('tool_images', 'tools', '2025-11-12 12:16:50.385748+00', '2025-11-12 12:16:50.385748+00'),
	('tool_images', 'tools/7145701e-6bfe-4f53-a0ac-096cc1c4c5cb', '2025-11-12 12:16:50.385748+00', '2025-11-12 12:16:50.385748+00'),
	('tool_images', 'tools/3d9036e2-9ec3-4101-8fbf-794922d52ea4', '2025-11-12 12:17:07.955549+00', '2025-11-12 12:17:07.955549+00'),
	('tool_images', 'tools/444a9570-9eab-4aeb-a585-b524f3f8f424', '2025-11-12 12:20:17.864422+00', '2025-11-12 12:20:17.864422+00'),
	('tool_images', 'tools/6419bf4e-1a53-4985-bc14-993159cf6a6b', '2025-11-12 12:21:50.459083+00', '2025-11-12 12:21:50.459083+00'),
	('tool_images', 'tools/ab0ed76f-4a67-48c6-9ffa-8c37b93ab630', '2025-11-12 12:27:32.130461+00', '2025-11-12 12:27:32.130461+00'),
	('tool_images', 'tools/a75a901c-cfee-421c-b34b-92a3c34fe890', '2025-11-12 12:30:38.969911+00', '2025-11-12 12:30:38.969911+00'),
	('tool_images', 'tools/47d5ffc8-e25b-4bab-b2de-7558cdd4901e', '2025-11-12 12:36:11.294451+00', '2025-11-12 12:36:11.294451+00'),
	('tool_images', 'tools/5405bb7b-fb21-47df-b9b2-e4db81bc9bbd', '2025-11-12 12:39:40.351559+00', '2025-11-12 12:39:40.351559+00'),
	('tool_images', 'tools/be84b6fa-294f-43f8-bef5-6977906c9e74', '2025-11-12 13:58:57.213477+00', '2025-11-12 13:58:57.213477+00'),
	('tool_images', 'tools/3ba54133-fba5-4b73-9ce4-8f3939eccc2a', '2025-11-12 14:18:20.407322+00', '2025-11-12 14:18:20.407322+00'),
	('tool_images', 'tools/70c34f24-3723-48f2-8354-c59880b7144b', '2025-11-12 14:23:30.666754+00', '2025-11-12 14:23:30.666754+00'),
	('tool_images', 'tools/da2f331f-814a-435b-94dd-97e57c881632', '2025-11-12 15:09:03.956213+00', '2025-11-12 15:09:03.956213+00'),
	('tool_images', 'tools/8ffebbb4-4c1c-4a1f-a478-7be74a5b95a0', '2025-11-12 15:13:22.428971+00', '2025-11-12 15:13:22.428971+00'),
	('tool_images', 'tools/aa8cff83-dcc8-4753-85e5-6b158d964614', '2025-11-14 11:32:43.912418+00', '2025-11-14 11:32:43.912418+00'),
	('tool_images', 'tools/65c7c171-a92e-4bcc-a2ad-1c8d350fd1f6', '2025-11-14 11:37:23.254181+00', '2025-11-14 11:37:23.254181+00'),
	('tool_images', 'tools/06ff89c9-3fbc-46ef-8f85-3f36adea1f2a', '2025-11-15 09:37:34.198411+00', '2025-11-15 09:37:34.198411+00'),
	('tool_images', 'tools/2082c326-6fbe-4bb5-9689-5257bb1ad7c2', '2025-11-15 09:37:58.153015+00', '2025-11-15 09:37:58.153015+00'),
	('tool_images', 'tools/89d7ee5c-902b-42e3-baba-d1310828888e', '2025-11-15 09:40:32.369692+00', '2025-11-15 09:40:32.369692+00'),
	('tool_images', 'tools/9587c284-e961-4a5c-9c84-d1dcb874fc83', '2025-11-15 09:41:27.727125+00', '2025-11-15 09:41:27.727125+00'),
	('tool_images', 'tools/de889366-c54a-4de5-aaf8-308a7e5b6c23', '2025-11-15 09:42:31.0454+00', '2025-11-15 09:42:31.0454+00'),
	('tool_images', 'tools/4eb130a6-855b-4d1d-ab64-2b0b85575101', '2025-11-15 09:42:56.244402+00', '2025-11-15 09:42:56.244402+00'),
	('tool_images', 'tools/614c7653-94f2-48d2-bb65-c443663efb88', '2025-11-15 09:43:34.913474+00', '2025-11-15 09:43:34.913474+00'),
	('tool_images', 'tools/01156fb3-785b-4b49-b512-c8966ba50f0c', '2025-11-15 09:45:27.329115+00', '2025-11-15 09:45:27.329115+00'),
	('tool_images', 'tools/7ad85121-c17f-4c91-960f-2c713170a98c', '2025-11-15 09:47:04.289117+00', '2025-11-15 09:47:04.289117+00'),
	('tool_images', 'tools/d3e51fbf-9167-4a04-adc4-a85e007937a9', '2025-11-15 10:02:15.73799+00', '2025-11-15 10:02:15.73799+00'),
	('tool_images', 'tools/3195257d-f050-4fdd-b73f-2c7691ea1c5b', '2025-11-15 19:44:55.111502+00', '2025-11-15 19:44:55.111502+00'),
	('tool_images', 'tools/4a57b044-c675-4418-ae8d-00cbc6d4ac7f', '2025-11-15 19:46:14.057259+00', '2025-11-15 19:46:14.057259+00'),
	('tool_images', 'tools/71b2d07e-63d4-4f1d-84d7-b0c10e1527d2', '2025-11-15 19:46:53.951675+00', '2025-11-15 19:46:53.951675+00');


--
-- Data for Name: s3_multipart_uploads; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: s3_multipart_uploads_parts; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: hooks; Type: TABLE DATA; Schema: supabase_functions; Owner: supabase_functions_admin
--



--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE SET; Schema: auth; Owner: supabase_auth_admin
--

SELECT pg_catalog.setval('"auth"."refresh_tokens_id_seq"', 60, true);


--
-- Name: hooks_id_seq; Type: SEQUENCE SET; Schema: supabase_functions; Owner: supabase_functions_admin
--

SELECT pg_catalog.setval('"supabase_functions"."hooks_id_seq"', 1, false);


--
-- PostgreSQL database dump complete
--

-- \unrestrict Lb0YZ537vydZno93t9kmOAkVRezr9fVBtm6szpa49o55VltUHWdEgfQeonXTvhA

RESET ALL;
