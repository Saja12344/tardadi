/** Client-side API base — all calls go through the secure BFF proxy. */
const PROXY_BASE = "/api/proxy";

export async function adminFetch<T = unknown>(
  path: string,
  options: RequestInit = {}
): Promise<T> {
  const normalizedPath = path.startsWith("/") ? path : `/${path}`;
  const url = `${PROXY_BASE}${normalizedPath}`;

  const response = await fetch(url, {
    ...options,
    headers: {
      "Content-Type": "application/json",
      ...options.headers,
    },
  });

  const body = await response.json().catch(() => ({}));

  if (!response.ok || body.success === false) {
    throw new Error(
      body.error ||
        `Request failed (${response.status}). تأكد أن Backend شغال: npm run dev:backend`
    );
  }

  return body.data as T;
}
