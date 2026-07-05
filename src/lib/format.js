// Pure formatting helpers — no DB access, safe to use in components directly.

const inr = new Intl.NumberFormat('en-IN', {
  style: 'currency',
  currency: 'INR',
  maximumFractionDigits: 0,
});

/** ₹2,499 */
export function formatPrice(amount) {
  return inr.format(Number(amount));
}

/** "You save ₹2,500" */
export function formatSavings(current, original) {
  return inr.format(Math.max(0, Number(original) - Number(current)));
}

/** 50 (integer percent, never negative, never >99 from bad data) */
export function computeDiscountPercent(current, original) {
  const c = Number(current);
  const o = Number(original);
  if (!o || o <= c) return 0;
  return Math.round((1 - c / o) * 100);
}

/**
 * "2 hours ago" / "3 days ago" / "just now" — used for both
 * "Price last verified…" and "Added…" freshness copy (Section 3, lever 4).
 * Deliberately coarse (no fake precision like "2 hours 14 minutes ago").
 */
export function formatRelativeTime(date) {
  const then = new Date(date).getTime();
  const now = Date.now();
  const seconds = Math.max(0, Math.round((now - then) / 1000));

  if (seconds < 60) return 'just now';
  const minutes = Math.round(seconds / 60);
  if (minutes < 60) return `${minutes} minute${minutes === 1 ? '' : 's'} ago`;
  const hours = Math.round(minutes / 60);
  if (hours < 24) return `${hours} hour${hours === 1 ? '' : 's'} ago`;
  const days = Math.round(hours / 24);
  if (days < 30) return `${days} day${days === 1 ? '' : 's'} ago`;
  const months = Math.round(days / 30);
  if (months < 12) return `${months} month${months === 1 ? '' : 's'} ago`;
  const years = Math.round(months / 12);
  return `${years} year${years === 1 ? '' : 's'} ago`;
}

/** Platform badge label + Tailwind-friendly theme key from source_platform. */
export function platformDisplay(product) {
  switch (product.source_platform) {
    case 'amazon':
      return { label: 'Amazon', key: 'amazon' };
    case 'flipkart':
      return { label: 'Flipkart', key: 'flipkart' };
    default:
      return { label: product.source_platform_label || 'Other retailer', key: 'other' };
  }
}

/** CTA copy per Section 3 copy bank — never promises a fixed price. */
export function ctaLabel(product) {
  if (product.source_platform === 'amazon') return 'View Live Deal on Amazon →';
  if (product.source_platform === 'flipkart') return 'Check Current Price on Flipkart →';
  return `Check Current Price on ${product.source_platform_label || 'Retailer'} →`;
}
