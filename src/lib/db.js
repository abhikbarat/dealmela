// Thin Postgres connection wrapper.
//
// In production on Netlify, DATABASE_URL is injected automatically by
// Netlify Database (see README "Deploying to Netlify"). Locally, it comes
// from .env. Either way this file doesn't need to know the difference.

import pg from 'pg';

const { Pool } = pg;

let pool;

function getPool() {
  if (!pool) {
    const connectionString = process.env.DATABASE_URL;
    if (!connectionString) {
      throw new Error(
        'DATABASE_URL is not set. Locally: copy .env.example to .env and fill it in. ' +
        'On Netlify: run `netlify db init` (or link a database in the dashboard) so it is injected automatically.'
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
