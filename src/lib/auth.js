import bcrypt from 'bcryptjs';

const SALT_ROUNDS = 12;

export async function hashPassword(plain) {
  return bcrypt.hash(plain, SALT_ROUNDS);
}

export async function verifyPassword(plain, hash) {
  return bcrypt.compare(plain, hash);
}

/** Minimal sanity checks — not a full password-strength policy, just guards against accidents. */
export function validatePassword(plain) {
  if (typeof plain !== 'string' || plain.length < 8) {
    return 'Password must be at least 8 characters.';
  }
  return null;
}
