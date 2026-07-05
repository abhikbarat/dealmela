import { query } from '../lib/db.js';

export const prerender = false;

export async function GET({ site, url }) {
  const origin = site?.toString().replace(/\/$/, '') || url.origin;

  const { rows: categories } = await query(
    `SELECT slug, parent_id, (SELECT slug FROM categories p WHERE p.id = c.parent_id) AS parent_slug
     FROM categories c`
  );
  const { rows: products } = await query(
    `SELECT p.slug, c.slug AS category_slug, sc.slug AS subcategory_slug, p.updated_at
     FROM products p
     JOIN categories c ON c.id = p.category_id
     LEFT JOIN categories sc ON sc.id = p.subcategory_id
     WHERE p.status = 'active'`
  );

  const staticPaths = ['', '/about', '/affiliate-disclosure', '/privacy-policy', '/contact'];
  const categoryPaths = categories
    .filter((c) => !c.parent_id)
    .map((c) => `/${c.slug}`);
  const subcategoryPaths = categories
    .filter((c) => c.parent_id)
    .map((c) => `/${c.parent_slug}/${c.slug}`);
  const productPaths = products.map(
    (p) => `/${p.category_slug}/${p.subcategory_slug}/${p.slug}`
  );

  const urls = [
    ...staticPaths.map((p) => ({ loc: p, priority: p === '' ? '1.0' : '0.6' })),
    ...categoryPaths.map((p) => ({ loc: p, priority: '0.8' })),
    ...subcategoryPaths.map((p) => ({ loc: p, priority: '0.7' })),
    ...productPaths.map((p) => ({ loc: p, priority: '0.5' })),
  ];

  const body = `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
${urls.map((u) => `  <url><loc>${origin}${u.loc}</loc><priority>${u.priority}</priority></url>`).join('\n')}
</urlset>`;

  return new Response(body, {
    status: 200,
    headers: { 'Content-Type': 'application/xml' },
  });
}
