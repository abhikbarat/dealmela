// Data-access layer — every DB query the public site needs lives here,
// so pages stay thin and nobody has to hand-write SQL in a .astro file.

import { query } from './db.js';

/** Top-level categories with their subcategories nested, ordered for nav/tiles. */
export async function getCategoryTree() {
  const { rows } = await query(
    `SELECT id, name, slug, parent_id, icon, sort_order
     FROM categories
     ORDER BY parent_id NULLS FIRST, sort_order, name`
  );
  const topLevel = rows.filter((c) => c.parent_id === null);
  return topLevel.map((cat) => ({
    ...cat,
    subcategories: rows.filter((c) => c.parent_id === cat.id),
  }));
}

export async function getCategoryBySlug(slug) {
  const { rows } = await query(`SELECT * FROM categories WHERE slug = $1 AND parent_id IS NULL`, [slug]);
  return rows[0] || null;
}

export async function getSubcategoryBySlug(categoryId, slug) {
  const { rows } = await query(
    `SELECT * FROM categories WHERE slug = $1 AND parent_id = $2`,
    [slug, categoryId]
  );
  return rows[0] || null;
}

/**
 * Picks the banner to show right now: the highest-priority *scheduled* banner whose
 * date range covers today, or the permanent default if nothing is currently scheduled.
 * Never returns nothing — Section 6.2 requires the site to never look empty/broken.
 */
export async function getActiveBanner() {
  const { rows } = await query(
    `SELECT * FROM banners
     WHERE is_active = true AND is_default = false
       AND (start_date IS NULL OR start_date <= CURRENT_DATE)
       AND (end_date IS NULL OR end_date >= CURRENT_DATE)
     ORDER BY sort_order ASC LIMIT 1`
  );
  if (rows[0]) return rows[0];

  const fallback = await query(
    `SELECT * FROM banners WHERE is_default = true AND is_active = true LIMIT 1`
  );
  return fallback.rows[0] || null;
}

/** Real click-data-driven trending — Section 3, lever 2. Returns [] rather than faking data. */
export async function getTrendingProducts({ days = 7, limit = 8 } = {}) {
  const { rows } = await query(
    `SELECT p.*, c.name AS category_name, c.slug AS category_slug,
            sc.name AS subcategory_name, sc.slug AS subcategory_slug,
            count(ce.id) AS click_count
     FROM products p
     JOIN click_events ce ON ce.product_id = p.id AND ce.clicked_at > now() - ($1 || ' days')::interval
     JOIN categories c ON c.id = p.category_id
     LEFT JOIN categories sc ON sc.id = p.subcategory_id
     WHERE p.status = 'active'
     GROUP BY p.id, c.name, c.slug, sc.name, sc.slug
     ORDER BY click_count DESC, p.created_at DESC
     LIMIT $2`,
    [days, limit]
  );
  return rows;
}

/** Reverse-chronological by admin-entry date — Section 5.1 "Latest Deals". */
export async function getLatestProducts({ limit = 12, offset = 0 } = {}) {
  const { rows } = await query(
    `SELECT p.*, c.name AS category_name, c.slug AS category_slug,
            sc.name AS subcategory_name, sc.slug AS subcategory_slug
     FROM products p
     JOIN categories c ON c.id = p.category_id
     LEFT JOIN categories sc ON sc.id = p.subcategory_id
     WHERE p.status = 'active'
     ORDER BY p.created_at DESC
     LIMIT $1 OFFSET $2`,
    [limit, offset]
  );
  return rows;
}

const SORT_MAP = {
  newest: 'p.created_at DESC',
  price_low: 'p.current_price ASC',
  price_high: 'p.current_price DESC',
  discount: '(1 - p.current_price / NULLIF(p.original_price, 0)) DESC',
};

/** Category (or category+subcategory) listing with filters, sort, and pagination for infinite scroll. */
export async function getProductsByCategory({
  categoryId,
  subcategoryId = null,
  sort = 'newest',
  priceMin = null,
  priceMax = null,
  platform = null,
  minDiscount = null,
  limit = 24,
  offset = 0,
}) {
  const clauses = [`p.status = 'active'`, `p.category_id = $1`];
  const params = [categoryId];

  if (subcategoryId) {
    params.push(subcategoryId);
    clauses.push(`p.subcategory_id = $${params.length}`);
  }
  if (priceMin !== null) {
    params.push(priceMin);
    clauses.push(`p.current_price >= $${params.length}`);
  }
  if (priceMax !== null) {
    params.push(priceMax);
    clauses.push(`p.current_price <= $${params.length}`);
  }
  if (platform) {
    params.push(platform);
    clauses.push(`p.source_platform = $${params.length}`);
  }
  if (minDiscount !== null) {
    params.push(minDiscount / 100);
    clauses.push(`(1 - p.current_price / NULLIF(p.original_price, 0)) >= $${params.length}`);
  }

  const orderBy = SORT_MAP[sort] || SORT_MAP.newest;
  params.push(limit);
  const limitIdx = params.length;
  params.push(offset);
  const offsetIdx = params.length;

  const { rows } = await query(
    `SELECT p.*, c.name AS category_name, c.slug AS category_slug,
            sc.name AS subcategory_name, sc.slug AS subcategory_slug
     FROM products p
     JOIN categories c ON c.id = p.category_id
     LEFT JOIN categories sc ON sc.id = p.subcategory_id
     WHERE ${clauses.join(' AND ')}
     ORDER BY ${orderBy}
     LIMIT $${limitIdx} OFFSET $${offsetIdx}`,
    params
  );

  const countResult = await query(
    `SELECT count(*)::int AS total FROM products p WHERE ${clauses.join(' AND ')}`,
    params.slice(0, params.length - 2)
  );

  return { products: rows, total: countResult.rows[0].total };
}

export async function getProductBySlug(slug) {
  const { rows } = await query(
    `SELECT p.*, c.name AS category_name, c.slug AS category_slug,
            sc.name AS subcategory_name, sc.slug AS subcategory_slug
     FROM products p
     JOIN categories c ON c.id = p.category_id
     LEFT JOIN categories sc ON sc.id = p.subcategory_id
     WHERE p.slug = $1 AND p.status = 'active'`,
    [slug]
  );
  return rows[0] || null;
}

/** "Related Deals" carousel — same subcategory first, falls back to same category. */
export async function getRelatedProducts({ productId, categoryId, subcategoryId, limit = 8 }) {
  const { rows } = await query(
    `SELECT p.*, c.slug AS category_slug, sc.slug AS subcategory_slug
     FROM products p
     JOIN categories c ON c.id = p.category_id
     LEFT JOIN categories sc ON sc.id = p.subcategory_id
     WHERE p.status = 'active' AND p.id != $1
       AND (p.subcategory_id = $2 OR p.category_id = $3)
     ORDER BY (p.subcategory_id = $2) DESC, p.created_at DESC
     LIMIT $4`,
    [productId, subcategoryId, categoryId, limit]
  );
  return rows;
}

/**
 * Primary search: full-text on name/brand/sku/editorial_note (Section 5.4).
 * Secondary fast-path: exact/partial SKU match folded into the same result set.
 */
export async function searchProducts(searchQuery, { limit = 24, offset = 0 } = {}) {
  const { rows } = await query(
    `SELECT p.*, c.name AS category_name, c.slug AS category_slug,
            sc.name AS subcategory_name, sc.slug AS subcategory_slug,
            ts_rank(p.search_vector, plainto_tsquery('english', $1)) AS rank
     FROM products p
     JOIN categories c ON c.id = p.category_id
     LEFT JOIN categories sc ON sc.id = p.subcategory_id
     WHERE p.status = 'active'
       AND (p.search_vector @@ plainto_tsquery('english', $1) OR p.sku ILIKE '%' || $1 || '%')
     ORDER BY rank DESC NULLS LAST, p.created_at DESC
     LIMIT $2 OFFSET $3`,
    [searchQuery, limit, offset]
  );

  const countResult = await query(
    `SELECT count(*)::int AS total FROM products p
     WHERE p.status = 'active'
       AND (p.search_vector @@ plainto_tsquery('english', $1) OR p.sku ILIKE '%' || $1 || '%')`,
    [searchQuery]
  );

  return { products: rows, total: countResult.rows[0].total };
}

/** Logs every search, including zero-result ones — Section 5.4, the Admin's "what to add next" signal. */
export async function logSearchQuery(searchQuery, resultsCount) {
  await query(`INSERT INTO search_queries (query, results_count) VALUES ($1, $2)`, [
    searchQuery,
    resultsCount,
  ]);
}

/** Logs an affiliate click-through — the site's only first-party analytics signal. */
export async function logClick(productId, sourcePage) {
  await query(`INSERT INTO click_events (product_id, source_page) VALUES ($1, $2)`, [
    productId,
    sourcePage,
  ]);
}

// ============================================================
// ADMIN — everything below assumes the caller has already checked
// the session in middleware. These functions do not re-check auth.
// ============================================================

export async function countAdminUsers() {
  const { rows } = await query(`SELECT count(*)::int AS n FROM admin_users`);
  return rows[0].n;
}

export async function getAdminUserByEmail(email) {
  const { rows } = await query(`SELECT * FROM admin_users WHERE email = $1`, [email.toLowerCase().trim()]);
  return rows[0] || null;
}

export async function createAdminUser(email, passwordHash) {
  const { rows } = await query(
    `INSERT INTO admin_users (email, password_hash) VALUES ($1, $2) RETURNING id`,
    [email.toLowerCase().trim(), passwordHash]
  );
  return rows[0].id;
}

/** All products regardless of status, newest-edited first — for the admin list view. */
export async function getAllProductsForAdmin() {
  const { rows } = await query(
    `SELECT p.*, c.name AS category_name, sc.name AS subcategory_name
     FROM products p
     JOIN categories c ON c.id = p.category_id
     LEFT JOIN categories sc ON sc.id = p.subcategory_id
     ORDER BY p.updated_at DESC`
  );
  return rows;
}

export async function getProductByIdForAdmin(id) {
  const { rows } = await query(`SELECT * FROM products WHERE id = $1`, [id]);
  return rows[0] || null;
}

export async function createProduct(data) {
  const { rows } = await query(
    `INSERT INTO products (
       name, slug, category_id, subcategory_id, brand, source_platform, source_platform_label,
       affiliate_link, sku, current_price, original_price, images, specs, editorial_note,
       source_rating, source_review_count, rating_checked_at, status, is_featured
     ) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19)
     RETURNING id`,
    [
      data.name, data.slug, data.category_id, data.subcategory_id, data.brand || null,
      data.source_platform, data.source_platform_label || null, data.affiliate_link,
      data.sku || null, data.current_price, data.original_price,
      JSON.stringify(data.images), JSON.stringify(data.specs || []), data.editorial_note,
      data.source_rating || null, data.source_review_count || null, data.rating_checked_at || null,
      data.status || 'active', !!data.is_featured,
    ]
  );
  return rows[0].id;
}

export async function updateProduct(id, data) {
  await query(
    `UPDATE products SET
       name = $1, slug = $2, category_id = $3, subcategory_id = $4, brand = $5,
       source_platform = $6, source_platform_label = $7, affiliate_link = $8, sku = $9,
       current_price = $10, original_price = $11, images = $12, specs = $13, editorial_note = $14,
       source_rating = $15, source_review_count = $16, rating_checked_at = $17,
       status = $18, is_featured = $19
     WHERE id = $20`,
    [
      data.name, data.slug, data.category_id, data.subcategory_id, data.brand || null,
      data.source_platform, data.source_platform_label || null, data.affiliate_link,
      data.sku || null, data.current_price, data.original_price,
      JSON.stringify(data.images), JSON.stringify(data.specs || []), data.editorial_note,
      data.source_rating || null, data.source_review_count || null, data.rating_checked_at || null,
      data.status || 'active', !!data.is_featured, id,
    ]
  );
}

/** Bumps price_last_verified to now — a one-click "I checked, it's still correct" action. */
export async function touchPriceVerified(id) {
  await query(`UPDATE products SET price_last_verified = now() WHERE id = $1`, [id]);
}

export async function deleteProductPermanently(id) {
  await query(`DELETE FROM products WHERE id = $1`, [id]);
}

export async function isSlugTaken(slug, excludeId = null) {
  const { rows } = excludeId
    ? await query(`SELECT id FROM products WHERE slug = $1 AND id != $2`, [slug, excludeId])
    : await query(`SELECT id FROM products WHERE slug = $1`, [slug]);
  return rows.length > 0;
}

/** Most-clicked products in a trailing window — powers the admin analytics view. */
export async function getMostClickedForAdmin({ days = 7, limit = 15 } = {}) {
  const { rows } = await query(
    `SELECT p.id, p.name, p.slug, count(ce.id)::int AS clicks
     FROM click_events ce
     JOIN products p ON p.id = ce.product_id
     WHERE ce.clicked_at > now() - ($1 || ' days')::interval
     GROUP BY p.id, p.name, p.slug
     ORDER BY clicks DESC
     LIMIT $2`,
    [days, limit]
  );
  return rows;
}

/** Recent search queries, zero-result ones flagged — the "what to add next" signal. */
export async function getRecentSearchesForAdmin({ limit = 40 } = {}) {
  const { rows } = await query(
    `SELECT query, results_count, searched_at FROM search_queries ORDER BY searched_at DESC LIMIT $1`,
    [limit]
  );
  return rows;
}
