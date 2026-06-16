import { TardadiApiClient } from "@tardadi/shared";

/** All admin reads/writes go through the server-side BFF proxy — never call Firebase directly from the browser. */
export const api = new TardadiApiClient("/api/proxy", "proxy");
