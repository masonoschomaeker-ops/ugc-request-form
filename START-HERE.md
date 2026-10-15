# UGC Form — Render + Supabase conversion

This is a standalone conversion of your existing unbranded yellow/orange form.
Customers submit without an account. The creator inbox has an email/password login,
sign-out, search, status filters, and status updates. It uses Supabase, not ChatGPT
sign-in or Cloudflare Workers. Your current live site and DNS have not changed.

## What is ready and what still needs setup

The application, database schema, creator access rules, and Render build configuration
are included. You still need a Supabase project, a GitHub repository, and a Render
Static Site. This ZIP does not include credentials or existing customer orders.
Live sign-in and submission must be verified after connecting your Supabase project.

## 1. Set up Supabase

1. Create a new Free project at https://supabase.com/dashboard.
2. Open SQL Editor and run the complete `supabase/schema.sql` file ONCE in the new project.
3. In Authentication > Users, use Add user > Create new user. Enter your creator email
   and a strong password; enable Auto Confirm User. Copy the created user's UUID.
4. Open `supabase/add-creator.sql`, replace its UUID placeholder, and run it in SQL Editor.
   This step grants inbox access. A normal signed-in user cannot view orders.
5. In Authentication settings, disable new user sign-ups. The form never requires
   customers to create accounts. Do not disable email/password sign-in.
6. In the project's Connect/API settings, copy the Project URL and PUBLIC publishable
   key (or legacy anon key). Never put a secret/service-role key in the website or VITE variables.
7. Set Auth Site URL to your Render URL first, then to https://bwottlf.online after cutover.

Password recovery is included. Add both your Render origin and https://bwottlf.online
with `/?view=inbox` to Authentication > URL Configuration > Redirect URLs. Set the
Site URL as described above. The default Supabase mail service restricts recipients;
configure SMTP if recovery email must reach an address outside your Supabase team.
The owner can manage creator accounts in Supabase. Never give customer accounts
creator membership.

## 2. Upload to GitHub

Create a private repository and upload the CONTENTS of this folder at the repository
root. Include package.json, package-lock.json, src/, index.html, tsconfig.json,
vite.config.ts, render.yaml, and supabase/. Do not upload node_modules, dist, real .env
files, passwords, secret keys, or customer order exports.

## 3. Deploy on Render

1. In https://dashboard.render.com choose New > Static Site and connect the repository.
2. Set Build Command: `npm ci && npm run build`
3. Set Publish Directory: `dist`
4. Add these environment variables BEFORE building:
   - VITE_SUPABASE_URL = your project URL
   - VITE_SUPABASE_PUBLISHABLE_KEY = your public publishable/anon key
   - NODE_VERSION = 22.16.0 (or a newer supported Node 22 release)
5. Create Static Site. No start command or Render database is required.
6. You can alternatively use New > Blueprint with the included render.yaml.

VITE variables become public build output by design. Only use public Supabase keys.
Redeploy after changing variables. Row-level security and the creator membership table,
not hiding a public key or button, protect customer details.

## 4. Verify before switching the domain

- Submit one test order on the Render URL while signed out. Save its receipt.
- Open Creator inbox: it must show a login form and no orders while signed out.
- Sign in as the creator. Confirm the test order appears, then update its status.
- Sign out. Confirm the inbox clears. Also confirm refresh after signing out remains locked.
- Check mobile layout and both necklace/non-necklace branches.

The inbox shows the newest 1,000 orders. This app accepts request details and reference
links; it does not collect payments, upload images, send email notifications, or offer
customer order tracking. Those match the scope of this conversion.

## 5. Existing orders

Old orders stay in the current site's database; they are NOT automatically copied into
Supabase. Keep the current creator inbox available until any existing requests are exported
and imported. Do not delete the old site as part of domain cutover. Order migration is a
separate step requiring an authorized export of the existing requests.

## 6. Connect bwottlf.online last

After the Render version passes the checks, open its Settings > Custom Domains and add
bwottlf.online. Follow the exact DNS targets Render provides. Replace the two old hosting
A records at Namecheap with Render's instructions; do not guess a Render IP address.
Wait for Render to verify DNS and issue HTTPS before sharing the new version.

## Local development / verification

Install Node.js 22.13+ (Vite requires this version or newer), then run:

    npm ci

Copy `.env.example` to `.env` and fill in only the URL and public key. Then:

    npm run dev
    npm run build
    npm test

Tests use embedded Postgres (PGlite) to check anonymous submission, creator-only reading
and updates, rejection of invalid input, and blocked customer privilege escalation.
They do not log into a live Supabase project.

## Free service limits

Render static sites are free within included bandwidth/build usage. Supabase Free has
storage/auth/usage quotas and may pause low-activity projects. Domain renewal is separate.
Monitor both dashboards. Public submissions can attract spam; add a server-verified CAPTCHA
or a rate-limited submission backend if needed before broad advertising.

## References

- https://render.com/docs/static-sites
- https://render.com/docs/custom-domains
- https://supabase.com/docs/guides/auth
- https://supabase.com/docs/guides/database/postgres/row-level-security
- https://supabase.com/docs/guides/database/functions
