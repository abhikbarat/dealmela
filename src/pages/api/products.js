import { getProductsByCategory } from '../../lib/queries.js';
import { formatPrice, formatSavings, computeDiscountPercent, platformDisplay } from '../../lib/format.js';

export const prerender = false;

export async function GET({ url }) {
  const params = url.searchParams;
  const categoryId = Number(params.get('categoryId'));
  if (!Number.isInteger(categoryId) || categoryId <= 0) {
    return new Response(JSON.stringify({ error: 'categoryId is required' }), { status: 400 });
  }

  const subcategoryId = params.get('subcategoryId') ? Number(params.get('subcategoryId')) : null;
  const sort = params.get('sort') || 'newest';
  const platform = params.get('platform') || null;
  const priceMin = params.get('min') ? Number(params.get('min')) : null;
  const priceMax = params.get('max') ? Number(params.get('max')) : null;
  const minDiscount = params.get('discount') ? Number(params.get('discount')) : null;
  const offset = params.get('offset') ? Number(params.get('offset')) : 0;
  const limit = 12;

  const { products, total } = await getProductsByCategory({
    categoryId,
    subcategoryId,
    sort,
    platform,
    priceMin,
    priceMax,
    minDiscount,
    limit,
    offset,
  });

  const enriched = products.map((p) => ({
    id: p.id,
    name: p.name,
    slug: p.slug,
    category_slug: p.category_slug,
    subcategory_slug: p.subcategory_slug,
    is_featured: p.is_featured,
    image: (Array.isArray(p.images) ? p.images : JSON.parse(p.images))[0],
    priceLabel: formatPrice(p.current_price),
    originalLabel: formatPrice(p.original_price),
    savingsLabel: formatSavings(p.current_price, p.original_price),
    discountPercent: computeDiscountPercent(p.current_price, p.original_price),
    platform: platformDisplay(p),
  }));

  return new Response(
    JSON.stringify({ products: enriched, total, hasMore: offset + products.length < total }),
    { status: 200, headers: { 'Content-Type': 'application/json' } }
  );
}
