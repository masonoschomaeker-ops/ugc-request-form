-- First create the creator in Authentication > Users > Add user > Create new user.
-- Set its email/password and auto-confirm the email. Do not share the password.
-- Replace the placeholder below with that user's ID, then run this file.
insert into private.ugc_creators(user_id)
values ('REPLACE-WITH-CREATOR-USER-UUID'::uuid)
on conflict do nothing;
