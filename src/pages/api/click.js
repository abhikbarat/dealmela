import { logClick } from '../../lib/queries.js';

export const prerender = false;

export async function POST({ request }) {
  try {
    const { productId, sourcePage } = await request.json();
    const id = Number(productId);
    if (!Number.isInteger(id) || id <= 0) {
      return new Response(JSON.stringify({ ok: false, error: 'Invalid productId' }), { status: 400 });
    }
    await logClick(id, String(sourcePage || 'unknown').slice(0, 30));
    return new Response(JSON.stringify({ ok: true }), {
      status: 200,
      headers: { 'Content-Type': 'application/json' },
    });
  } catch (err) {
    // Analytics failures should never surface to the visitor — log and move on.
    console.error('click tracking error:', err);
    return new Response(JSON.stringify({ ok: false }), { status: 200 });
  }
}
