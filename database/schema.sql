-- DealMela — Festive Affiliate Deals Website
-- PostgreSQL schema (targets Netlify Database / any standard Postgres 14+)
-- Run once against a fresh database: psql "$DATABASE_URL" -f database/schema.sql

-- ============================================================
-- CATEGORIES (self-referential: parent_id NULL = top-level category)
-- ============================================================
CREATE TABLE categories (
  id            SERIAL PRIMARY KEY,
  name          VARCHAR(100) NOT NULL,
  slug          VARCHAR(100) NOT NULL UNIQUE,
  parent_id     INTEGER REFERENCES categories(id) ON DELETE SET NULL,
  icon          VARCHAR(50),
  sort_order    INTEGER NOT NULL DEFAULT 0,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_categories_parent ON categories(parent_id);

-- ============================================================
-- PRODUCTS
-- ============================================================
CREATE TABLE products (
  id                    SERIAL PRIMARY KEY,
  name                  VARCHAR(255) NOT NULL,
  slug                  VARCHAR(255) NOT NULL UNIQUE,
  category_id           INTEGER NOT NULL REFERENCES categories(id),
  subcategory_id        INTEGER REFERENCES categories(id),
  brand                 VARCHAR(100),

  source_platform       VARCHAR(20) NOT NULL CHECK (source_platform IN ('amazon','flipkart','other')),
  source_platform_label VARCHAR(100),           -- used when source_platform = 'other'
  affiliate_link        TEXT NOT NULL,
  sku                   VARCHAR(100),

  current_price         NUMERIC(10,2) NOT NULL CHECK (current_price >= 0),
  original_price        NUMERIC(10,2) NOT NULL CHECK (original_price >= 0),
  currency              VARCHAR(3) NOT NULL DEFAULT 'INR',

  images                JSONB NOT NULL,          -- array of image URLs, min. 3 enforced in app layer
  specs                 JSONB NOT NULL DEFAULT '[]',  -- array of {label, value} — flexible per category
  editorial_note        TEXT NOT NULL,           -- "Why we picked this" — human-authored, required (Amazon 2026 original-content policy)

  source_rating         NUMERIC(2,1) CHECK (source_rating IS NULL OR (source_rating >= 0 AND source_rating <= 5)),
  source_review_count   INTEGER,
  rating_checked_at     DATE,

  price_last_verified   TIMESTAMPTZ NOT NULL DEFAULT now(),
  deal_end_date         DATE,                    -- ONLY set if the source retailer page genuinely states one — never invented

  status                VARCHAR(10) NOT NULL DEFAULT 'active' CHECK (status IN ('active','inactive','expired')),
  is_featured           BOOLEAN NOT NULL DEFAULT false,

  created_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at            TIMESTAMPTZ NOT NULL DEFAULT now(),

  search_vector tsvector GENERATED ALWAYS AS (
    setweight(to_tsvector('english', coalesce(name, '')), 'A') ||
    setweight(to_tsvector('english', coalesce(brand, '')), 'B') ||
    setweight(to_tsvector('english', coalesce(sku, '')), 'B') ||
    setweight(to_tsvector('english', coalesce(editorial_note, '')), 'C')
  ) STORED
);

CREATE INDEX idx_products_search       ON products USING GIN (search_vector);
CREATE INDEX idx_products_category     ON products(category_id);
CREATE INDEX idx_products_subcategory  ON products(subcategory_id);
CREATE INDEX idx_products_status       ON products(status);
CREATE INDEX idx_products_created_at   ON products(created_at DESC);
CREATE INDEX idx_products_sku          ON products(sku);

-- ============================================================
-- CLICK EVENTS — first-party analytics, powers "Trending This Week" honestly
-- ============================================================
CREATE TABLE click_events (
  id            SERIAL PRIMARY KEY,
  product_id    INTEGER NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  source_page   VARCHAR(30) NOT NULL DEFAULT 'unknown', -- homepage | category | product_detail | search | trending | related
  clicked_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_click_events_product    ON click_events(product_id);
CREATE INDEX idx_click_events_clicked_at ON click_events(clicked_at DESC);

-- ============================================================
-- SEARCH QUERIES — logged including zero-result searches (Admin's "what to add next" signal)
-- ============================================================
CREATE TABLE search_queries (
  id              SERIAL PRIMARY KEY,
  query           TEXT NOT NULL,
  results_count   INTEGER NOT NULL DEFAULT 0,
  searched_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_search_queries_searched_at ON search_queries(searched_at DESC);

-- ============================================================
-- BANNERS — festive header banner, supports scheduling + a permanent neutral fallback
-- ============================================================
CREATE TABLE banners (
  id              SERIAL PRIMARY KEY,
  title           VARCHAR(150) NOT NULL,          -- internal label, e.g. "Diwali 2026"
  headline        VARCHAR(200) NOT NULL,
  subheadline     VARCHAR(200),
  cta_text        VARCHAR(60),
  cta_link        TEXT,
  theme           VARCHAR(20) NOT NULL DEFAULT 'gold' CHECK (theme IN ('gold','brick','marigold','neutral')),
  image_url       TEXT,
  lottie_url      TEXT,
  is_default      BOOLEAN NOT NULL DEFAULT false, -- the permanent fallback when nothing is scheduled
  is_active       BOOLEAN NOT NULL DEFAULT true,
  start_date      DATE,                            -- NULL start/end = always eligible (subject to is_active)
  end_date        DATE,
  sort_order      INTEGER NOT NULL DEFAULT 0,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_banners_active_dates ON banners(is_active, start_date, end_date);

-- Only one default banner should exist; enforced at app layer on write.

-- ============================================================
-- ADMIN USERS — single-admin login (Phase 2)
-- ============================================================
CREATE TABLE admin_users (
  id              SERIAL PRIMARY KEY,
  email           VARCHAR(255) NOT NULL UNIQUE,
  password_hash   TEXT NOT NULL,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================
-- updated_at auto-touch trigger for products
-- ============================================================
CREATE OR REPLACE FUNCTION touch_updated_at() RETURNS trigger AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_products_updated_at
  BEFORE UPDATE ON products
  FOR EACH ROW EXECUTE FUNCTION touch_updated_at();
