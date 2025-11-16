-- remove obsolete unique constraint blocking multiple award events per user
alter table if exists public.award_events
  drop constraint if exists award_signup_unique;

