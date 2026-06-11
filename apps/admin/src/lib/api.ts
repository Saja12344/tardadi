import { TardadiApiClient } from "@tardadi/shared";

const API_URL = process.env.NEXT_PUBLIC_API_URL || "http://127.0.0.1:5001/demo-org/us-central1/api";
const ORG_ID = process.env.NEXT_PUBLIC_ORG_ID || "demo-org";

export const api = new TardadiApiClient(API_URL, ORG_ID);
