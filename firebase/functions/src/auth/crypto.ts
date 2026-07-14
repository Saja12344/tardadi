import { createHmac, randomBytes, scryptSync, timingSafeEqual } from "crypto";

const SCRYPT_PARAMS = { N: 16384, r: 8, p: 1 };
const KEY_LEN = 64;

export function hashPassword(password: string): string {
  const salt = randomBytes(16).toString("hex");
  const hash = scryptSync(password, salt, KEY_LEN, SCRYPT_PARAMS).toString("hex");
  return `scrypt:${salt}:${hash}`;
}

export function verifyPassword(password: string, stored: string): boolean {
  const [algo, salt, hash] = stored.split(":");
  if (algo !== "scrypt" || !salt || !hash) return false;
  const derived = scryptSync(password, salt, KEY_LEN, SCRYPT_PARAMS);
  const expected = Buffer.from(hash, "hex");
  if (derived.length !== expected.length) return false;
  return timingSafeEqual(derived, expected);
}

export interface JwtPayload {
  sub: string;
  role: string;
  businessId: string | null;
  name: string;
  phone: string;
  iat: number;
  exp: number;
}

function base64UrlEncode(data: string): string {
  return Buffer.from(data).toString("base64url");
}

function base64UrlDecode(data: string): string {
  return Buffer.from(data, "base64url").toString("utf8");
}

function signSegment(segment: string, secret: string): string {
  return createHmac("sha256", secret).update(segment).digest("base64url");
}

export function signJwt(
  payload: Omit<JwtPayload, "iat" | "exp">,
  secret: string,
  ttlSeconds = 60 * 60 * 24 * 7
): string {
  const header = base64UrlEncode(JSON.stringify({ alg: "HS256", typ: "JWT" }));
  const body = base64UrlEncode(
    JSON.stringify({
      ...payload,
      iat: Math.floor(Date.now() / 1000),
      exp: Math.floor(Date.now() / 1000) + ttlSeconds,
    })
  );
  const signature = signSegment(`${header}.${body}`, secret);
  return `${header}.${body}.${signature}`;
}

export function verifyJwt(token: string, secret: string): JwtPayload | null {
  const parts = token.split(".");
  if (parts.length !== 3) return null;

  const [header, body, signature] = parts;
  const expected = signSegment(`${header}.${body}`, secret);
  const sigBuf = Buffer.from(signature);
  const expBuf = Buffer.from(expected);
  if (sigBuf.length !== expBuf.length || !timingSafeEqual(sigBuf, expBuf)) {
    return null;
  }

  try {
    const payload = JSON.parse(base64UrlDecode(body)) as JwtPayload;
    if (payload.exp < Math.floor(Date.now() / 1000)) return null;
    return payload;
  } catch {
    return null;
  }
}

export function getJwtSecret(): string {
  return (
    process.env.ADMIN_JWT_SECRET ||
    process.env.ADMIN_API_TOKEN ||
    "tardadi-dev-jwt-secret-change-in-production"
  );
}
