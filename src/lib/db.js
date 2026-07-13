// Thin Postgres connection wrapper.
//
// Netlify Database auto-injects a connection string into the deployed
// environment, but the exact variable name has shifted across Netlify's own
// docs/tooling versions (NETLIFY_DB_URL vs NETLIFY_DATABASE_URL). Rather than
// bet on one, this checks DATABASE_URL first (what you'd set locally or on
// any other host) and falls back to whichever Netlify-specific name is
// actually present at runtime.

import pg from 'pg';

const { Pool } = pg;

let pool;

function resolveConnectionString() {
  return (
    process.env.DATABASE_URL ||
    process.env.NETLIFY_DATABASE_URL ||
    process.env.NETLIFY_DB_URL ||
    null
  );
}

function getPool() {
  if (!pool) {
    const connectionString = resolveConnectionString();
    if (!connectionString) {
      throw new Error(
        'No database connection string found (checked DATABASE_URL, NETLIFY_DATABASE_URL, NETLIFY_DB_URL). ' +
        'Locally: copy .env.example to .env and fill it in. ' +
        'On Netlify: run `netlify database init` (or create a database in the dashboard) so one is injected automatically.'
      );
    }
    pool = new Pool({
      connectionString,
      // Netlify Database (Neon) and most managed Postgres hosts require SSL.
      // Local dev Postgres does not speak SSL at all, so only request it
      // when the connection string isn't pointing at localhost.
      ssl: /localhost|127\.0\.0\.1/.test(connectionString) ? false : { rejectUnauthorized: false },
      max: 5,
    });
  }
  return pool;
}

/** Run a parameterized query. Always use $1, $2… placeholders — never string-concatenate values in. */
export async function query(text, params = []) {
  const client = getPool();
  return client.query(text, params);
}

/** Run a function inside a transaction. */
export async function withTransaction(fn) {
  const client = await getPool().connect();
  try {
    await client.query('BEGIN');
    const result = await fn(client);
    await client.query('COMMIT');
    return result;
  } catch (err) {
    await client.query('ROLLBACK');
    throw err;
  } finally {
    client.release();
  }
}
