import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "ترددي — لوحة الإدارة",
  description: "إدارة الخطوط والباصات والسائقين",
  manifest: "/manifest.json",
  icons: {
    icon: [
      { url: "/favicon-orange-only.svg", type: "image/svg+xml" },
      { url: "/favicon-orange-only.png", sizes: "32x32", type: "image/png" },
      { url: "/icons/tardadi-bus-orange-only-192.png", sizes: "192x192", type: "image/png" },
      { url: "/icons/tardadi-bus-orange-only-512.png", sizes: "512x512", type: "image/png" },
    ],
    apple: [
      { url: "/apple-touch-icon-orange-only.png", sizes: "180x180", type: "image/png" },
    ],
  },
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="ar" dir="rtl">
      <body>{children}</body>
    </html>
  );
}
