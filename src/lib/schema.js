// Builds JSON-LD Product schema — Section 8. Deliberately generated straight
// from the same product record the page renders, so the visible price and the
// schema price can never drift apart (a mismatch risks losing rich-result
// eligibility entirely). This is a Product snippet, never "Merchant listing" —
// that type is reserved for pages where the customer buys directly from us,
// which is never the case here.
export function buildProductSchema(product, canonicalUrl) {
  const schema = {
    '@context': 'https://schema.org',
    '@type': 'Product',
    name: product.name,
    image: Array.isArray(product.images) ? product.images : JSON.parse(product.images || '[]'),
    description: product.editorial_note,
    brand: {
      '@type': 'Brand',
      name: product.brand || product.category_name,
    },
    offers: {
      '@type': 'Offer',
      url: canonicalUrl,
      priceCurrency: product.currency || 'INR',
      price: String(product.current_price),
      availability: 'https://schema.org/InStock',
    },
  };

  if (product.source_rating && product.source_review_count) {
    schema.aggregateRating = {
      '@type': 'AggregateRating',
      ratingValue: String(product.source_rating),
      reviewCount: String(product.source_review_count),
    };
  }

  return schema;
}
