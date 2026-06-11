import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "ترددي — لوحة الإدارة",
  description: "إدارة الخطوط والباصات والسائقين",
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
