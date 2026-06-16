# Admin Panel — Security Guide

> **قاعدة ذهبية:** أي تعديل جديد في لوحة الإدارة يجب أن يمر عبر هذه الطبقات — لا تتجاوزها.

## Architecture

```
Browser  →  Next.js BFF (/api/proxy/*)  →  Firebase Functions API
              ↑ middleware (CSP, headers)
              ↑ env.server.ts (server-only secrets)
```

## Rules for New Features

### 1. Never call the backend directly from the browser

- Use `adminFetch()` or `api` from `@/lib/api` — both route through `/api/proxy`.
- Do **not** add `NEXT_PUBLIC_*` URLs pointing to Firebase/production APIs.

### 2. Extend the proxy allowlist deliberately

When adding a new backend resource, update `ADMIN_PROXY_ALLOWLIST` in:

`src/lib/env.server.ts`

Only add paths the admin panel actually needs. Unknown paths return **403**.

### 3. Keep secrets server-side

| Variable | Where | Safe? |
|----------|-------|-------|
| `TARDADI_API_URL` | `.env.local` (server) | ✅ |
| `TARDADI_ORG_ID` | `.env.local` (server) | ✅ |
| `ADMIN_API_TOKEN` | `.env.local` (server) | ✅ |
| `NEXT_PUBLIC_*` | bundled to browser | ⚠️ public only |

Copy `.env.example` → `.env.local` and fill values locally. Never commit `.env.local`.

### 4. Security headers

`src/middleware.ts` sets CSP, `X-Frame-Options`, `Referrer-Policy`, etc.
If you add external scripts or tiles, update CSP in the same file.

Current map tiles: OpenStreetMap (`*.tile.openstreetmap.org`) — no API key required.

### 5. Input validation (next steps)

Before production:

- [ ] Add admin authentication (Firebase Auth / session cookie)
- [ ] Validate request bodies in the BFF before forwarding
- [ ] Rate-limit `/api/proxy` routes
- [ ] Lock down CORS on Firebase Functions to admin domain only

### 6. Maps & geocoding

- Maps use **Leaflet + OpenStreetMap** (free, no exposed API keys).
- Map component: `src/components/MapView.tsx` (SSR disabled — client only).
- Location search goes through **server routes** only:
  - `/api/geocode/search` — address autocomplete
  - `/api/geocode/reverse` — pin → address
  - `/api/routing/route` — road-following path (OSRM, server-side)
- Never call Nominatim or Google Maps directly from the browser.
- Geocode queries are sanitized (max 120 chars) and biased to Saudi Arabia.

## Quick checklist for every PR

- [ ] No new `NEXT_PUBLIC_` secrets
- [ ] New API paths added to allowlist
- [ ] Mutations go through `adminFetch`, reads through `api`
- [ ] CSP updated if new external domains are used
