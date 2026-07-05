// Loads schema.sql and seed.sql against DATABASE_URL using the same `pg`
// package the app already depends on — so there's nothing extra to install
// beyond what deploying to Netlify already needs (Node.js + npm).
//
// Usage:
//   DATABASE_URL="postgresql://..." node scripts/setup-db.js
//   (or just `npm run db:setup` if DATABASE_URL is already in your .env)
//
// Safe to re-run: it will simply error out on the CREATE TABLE statements
// if the schema already exists, which just means it's already set up.

import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';
import pg from 'pg';

const __dirname = dirname(fileURLToPath(import.meta.url));

const connectionString = process.env.DATABASE_URL;
if (!connectionString) {
  console.error('DATABASE_URL is not set. Either export it in your shell first, or put it in .env and run this with a tool that loads .env (e.g. `node --env-file=.env scripts/setup-db.js`).');
  process.exit(1);
}

const client = new pg.Client({
  connectionString,
  ssl: /localhost|127\.0\.0\.1/.test(connectionString) ? false : { rejectUnauthorized: false },
});

async function run(label, filename) {
  const sql = readFileSync(join(__dirname, '..', 'database', filename), 'utf8');
  console.log(`\nRunning ${label} (${filename})...`);
  await client.query(sql);
  console.log(`✓ ${label} applied.`);
}

async function main() {
  await client.connect();
  console.log('Connected to database.');
  try {
    await run('schema', 'schema.sql');
  } catch (err) {
    console.error(`✗ Schema step failed: ${err.message}`);
    console.error('If this says relations/tables already exist, the schema is likely already set up — you can skip straight to seeding, or ignore this if you only meant to re-seed.');
    process.exit(1);
  }
  try {
    await run('seed data', 'seed.sql');
  } catch (err) {
    console.error(`✗ Seed step failed: ${err.message}`);
    console.error('If this says duplicate key/already exists, seed data is likely already loaded — that\'s fine, nothing to do.');
    process.exit(1);
  }
  await client.end();
  console.log('\nDone. Schema and seed data are live on this database.');
}

main().catch(async (err) => {
  console.error('Unexpected error:', err.message);
  await client.end().catch(() => {});
  process.exit(1);
});
