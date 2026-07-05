# DealMela — Festive Affiliate Deals Website

Phase 1 build: the full public-facing site, running against seed data. No admin
panel yet — that's Phase 2 (see **What's next** below).

## Why this stack, not the original brief's PHP/MySQL

The brief was written for shared cPanel hosting. Once Netlify (free tier) was
chosen instead, PHP + MySQL weren't options — Netlify doesn't run either. This
build re-implements the exact same spec on a Netlify-native stack:

| Brief asked for | This build uses |
|---|---|
| PHP 8.x, server-rendered | **Astro** (SSR mode, `@astrojs/netlify` adapter) — renders full HTML per request, same as PHP did, including JSON-LD in the initial response |
| MySQL/MariaDB + FULLTEXT search | **Postgres** (targets **Netlify Database**, zero-config Postgres built on Neon) + native `tsvector` full-text search |
| Alpine.js interactivity | **Alpine.js** — unchanged, works identically |
| Tailwind CSS | **Tailwind CSS v4** — unchanged |
| Image hosting: Cloudinary or on-host | **Cloudinary free tier** (Google Drive isn't built for hotlinking at any real traffic and Google actively rate-limits it) |

Everything in Sections 2 (Compliance), 3 (Conversion Psychology), and 7–9
(Performance/SEO/Visual) of the original brief is implemented as written —
only the *how it runs on a server* layer changed.

## Local development

**Prerequisites:** Node 20+, a local Postgres (or any reachable Postgres connection string).

```bash
npm install
cp .env.example .env      # then edit .env with your DATABASE_URL

# Create the schema and load seed/dummy data (first time only):
npm run db:setup
# (this just runs schema.sql then seed.sql via Node + pg — no psql install needed.
# Already have psql and prefer it? `psql "$DATABASE_URL" -f database/schema.sql`
# then the same for seed.sql works identically.)

npm run dev                # http://localhost:4321
```

## Deploying to Netlify

1. **Push this project to a GitHub repo**, then in the Netlify dashboard:
   **Add new site → Import an existing project** and pick the repo. Netlify
   will detect `netlify.toml` and use the right build settings automatically.

2. **Provision the database.** Easiest path is the Netlify CLI from your machine:
   ```bash
   npm install -g netlify-cli
   netlify link                 # connect this repo to the site you just created
   netlify db init              # provisions Netlify Database, wires DATABASE_URL automatically
   ```
   If you'd rather do it from the dashboard: **Project → Database → Create database**.
   Either way, `DATABASE_URL` gets injected into your site's environment automatically —
   you shouldn't need to set it by hand.

3. **Load the schema and seed data against the new database** — same idea as
   local dev, just pointed at the production connection string (`netlify db
   init` prints it, or find it under **Project → Database → Connection
   string**):
   ```bash
   DATABASE_URL="<the connection string Netlify gave you>" npm run db:setup
   ```

4. **Deploy**: `git push`, or `netlify deploy --prod` from the CLI.

5. **Set up your admin account**: visit `https://your-site.netlify.app/admin`
   once — since no admin account exists yet, you'll get a one-time account
   creation form instead of a login screen. Sessions are handled by Netlify
   Blobs, which is on by default for every Netlify site — no extra setup
   needed beyond the deploy itself.

### Two things worth checking before you lean on this in production

- **Free tier is credit-based with a hard cap** (300 credits/month as of this
  build, covering bandwidth + function compute + database usage combined). Fine
  for a new site; if a deal genuinely goes viral, the site can go fully offline
  until the next billing cycle rather than just slowing down. Worth monitoring
  once real traffic starts, especially around festive spikes.
- **Netlify Database storage pricing**: it was free through July 1, 2026, which
  has just passed as of this build. Check current storage pricing in the
  Netlify dashboard before you commit — compute/bandwidth costs should stay
  small at this catalogue size regardless.

## Replacing the seed data

Every product, image, and editorial note in `database/seed.sql` is **fictional
placeholder content** — invented brand names, invented specs, placeholder
images from placehold.co. None of it is real. Two ways to replace it:

- **Now, by hand**: `UPDATE`/`INSERT` directly against the database with real
  products, real Cloudinary image URLs, and a genuinely human-written
  "why we picked this" note for each (required — see the brief's Section 2.1
  on Amazon's original-content policy).
- **Once Phase 2 ships**: through the admin panel's product form instead.

Either way, replace *all* seed products before pointing real affiliate links
at real traffic — the seed rows use fake `amazon.in`/`flipkart.com` URLs that
don't go anywhere real.

## Cloudinary setup (for real product images)

1. Create a free account at cloudinary.com.
2. Upload product photos there (free tier covers this project's scale many times over).
3. Use the resulting URLs in the `images` field when you add real products —
   the schema just expects a JSON array of image URLs, minimum 3 per product.

## Using the admin panel

Go to `/admin/products` (or just `/admin`, which redirects there). The first
time anyone visits with no admin account yet in the database, you'll get a
one-time **"Create the admin account"** form instead of a login screen —
whatever email/password you set there becomes the one login for the site.
After that it behaves like a normal login.

Set `ADMIN_EMAIL` in your environment variables (see `.env.example`) to
pre-fill that email field on the setup screen — it doesn't create the account
or set a password, it just saves typing it once. You still choose your own
password directly on that screen, live on the deployed site — it never needs
to pass through anyone else, including me.

From there:
- **Products → + Add product** is how you enter a new deal: name, category/
  subcategory, retailer + affiliate link, pricing, at least 3 image URLs
  (upload to Cloudinary first, paste the URLs in), specs, and a required
  "why we picked this" note. The URL slug auto-fills from the name as you
  type but you can override it.
- The product list lets you filter by status, edit anything, do a quick
  "Mark verified" (bumps the price-last-checked timestamp shown to visitors
  without a full edit), or permanently delete a listing.
- Setting a product's status to **Inactive** or **Expired** takes it off the
  public site immediately without deleting its click history — that's the
  normal way to pause or retire a deal. Permanent delete is for genuine
  mistakes (test entries, duplicates).
- **Analytics** shows most-clicked deals (7/30-day toggle) and recent search
  queries, with zero-result searches flagged — that list is your best signal
  for what to add next.

This part of the admin panel doesn't have its own signup page by design (only
the account-creation form appears, and only when zero admin accounts exist) —
there's deliberately no way for a second account to get created through the
UI.

## What's built (Phase 1 + admin)

- Homepage: animated festive banner (date-scheduled, falls back to a permanent
  default automatically), category tiles, sticky search, Trending This Week
  (real click-data-driven), Latest Deals
- Category & subcategory pages: filters (price, platform, discount%, sort),
  true infinite scroll, back-to-top
- Product detail page: swipeable image gallery, price block with savings
  badge, "why we picked this," specs, sourced rating, price-freshness line,
  primary CTA + mobile sticky CTA, related deals
- Search: Postgres full-text + SKU fallback, logs every query including
  zero-result ones, "trending instead" fallback on no matches
- Static pages: About, Affiliate Disclosure, Privacy Policy, Contact
- Compliance layer throughout: verbatim Amazon disclosure in the footer, "Ad ·"
  disclosure beside every CTA, `rel="noopener noreferrer sponsored"` + new-tab
  on every affiliate link, no dark patterns
- SEO: server-rendered JSON-LD Product schema per listing, dynamic XML
  sitemap, clean `/category/subcategory/product` URLs, canonical redirects
- **Admin panel**: session-based single-admin auth (first-run account setup,
  no visible signup after that), full product CRUD with validation
  (duplicate-slug protection, minimum-3-images, price sanity checks, required
  editorial note), and an analytics dashboard reading real click/search data
- Click-through analytics logging (`click_events`) and search logging
  (`search_queries`) — both wired and populating

## What's next

- **Category management UI** — right now adding a brand-new top-level category
  or subcategory (beyond the 8 that already exist) means one SQL `INSERT`
  against the `categories` table; there's no admin form for it yet since the
  product form just needs categories to already exist for its dropdowns.
- **Banner management UI** — the scheduling logic is fully live (the homepage
  already picks the right banner by date range, tested with a real
  currently-active example), there's just no admin form yet to create new
  banners or set their dates without SQL.
- **Phase 3**: replace all seed data with your real catalogue via the admin
  panel, then a Lighthouse pass against production.

Say the word whenever you want either of those.

## Design system reference

| Token | Value | Use |
|---|---|---|
| `paper` | `#FFF8EF` | Background |
| `ink` / `ink-soft` / `ink-faint` | `#241708` / `#6B5842` / `#A6957E` | Text, by emphasis |
| `brick` | `#A32C1E` | Primary CTA, price |
| `gold` | `#B8802A` | Accents, discount badge |
| `marigold` | `#E67E22` | Secondary festive accent |
| Display font | Fraunces | Headings, prices |
| Body font | Manrope | Everything else |

All defined as CSS custom properties in `src/styles/global.css` via Tailwind
v4's `@theme` block — change a value there and it propagates everywhere.
