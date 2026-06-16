"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";

const navItems = [
  { href: "/", label: "الرئيسية", icon: "🏠" },
  { href: "/routes", label: "الخطوط", icon: "🛤️" },
  { href: "/buses", label: "الباصات", icon: "🚌" },
  { href: "/drivers", label: "السائقين", icon: "👤" },
  { href: "/trips", label: "الرحلات", icon: "📡" },
];

export default function AdminShell({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();

  return (
    <div className="admin-layout">
      <aside className="sidebar">
        <div className="brand">
          <span className="brand-icon">ت</span>
          <div>
            <strong>ترددي</strong>
            <small>لوحة الإدارة</small>
          </div>
        </div>

        <nav className="sidebar-nav">
          {navItems.map((item) => {
            const active = pathname === item.href;
            return (
              <Link
                key={item.href}
                href={item.href}
                className={`nav-item ${active ? "active" : ""}`}
              >
                <span>{item.icon}</span>
                <span>{item.label}</span>
              </Link>
            );
          })}
        </nav>

        <div className="sidebar-footer">
          <p>السائق يسجّل دخوله برقم الجوال فقط</p>
        </div>
      </aside>

      <main className="main-content">{children}</main>
    </div>
  );
}
