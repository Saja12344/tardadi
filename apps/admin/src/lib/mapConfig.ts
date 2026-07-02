/** Modern dark map tiles — matches admin UI (Carto Dark Matter). */
export const MAP_TILES = {
  url: "https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png",
  attribution:
    '&copy; <a href="https://www.openstreetmap.org/copyright">OSM</a> &copy; <a href="https://carto.com/attributions">CARTO</a>',
  subdomains: "abcd",
} as const;

export const ROUTE_LINE = {
  color: "#EB4F26",
  weight: 5,
  opacity: 0.92,
} as const;
