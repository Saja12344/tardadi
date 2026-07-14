"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useAuth } from "./AuthProvider";
import BusinessSwitcher from "./BusinessSwitcher";
import { isSuperAdmin } from "@/lib/auth.constants";

type NavIcon =
  | "home"
  | "businesses"
  | "routes"
  | "buses"
  | "drivers"
  | "trips";

const allNavItems = [
  { href: "/", label: "الرئيسية", icon: "home" as const, superOnly: false },
  {
    href: "/businesses",
    label: "الشركات",
    icon: "businesses" as const,
    superOnly: true,
  },
  { href: "/routes", label: "الخطوط", icon: "routes" as const, superOnly: false },
  { href: "/buses", label: "الباصات", icon: "buses" as const, superOnly: false },
  {
    href: "/drivers",
    label: "السائقين",
    icon: "drivers" as const,
    superOnly: false,
  },
  { href: "/trips", label: "الرحلات", icon: "trips" as const, superOnly: false },
];

function NavIconGlyph({ icon }: { icon: NavIcon }) {
  const common = {
    className: "nav-icon",
    viewBox: "0 0 24 24",
    fill: "none",
    stroke: "currentColor",
    strokeWidth: 2,
    strokeLinecap: "round" as const,
    strokeLinejoin: "round" as const,
    "aria-hidden": true,
  };

  if (icon === "home") {
    return (
      <svg {...common}>
        <path d="M4 11.5 12 5l8 6.5" />
        <path d="M6.5 10.5V20h11v-9.5" />
        <path d="M10 20v-5h4v5" />
      </svg>
    );
  }

  if (icon === "businesses") {
    return (
      <svg {...common}>
        <path d="M3 21h18" />
        <path d="M6 21V7l6-4 6 4v14" />
        <path d="M10 11h4" />
        <path d="M10 15h4" />
      </svg>
    );
  }

  if (icon === "routes") {
    return (
      <svg {...common}>
        <path d="M6 5h.01" />
        <path d="M18 19h.01" />
        <path d="M6 5c7 0 1 14 12 14" />
        <path d="M9 12h6" />
      </svg>
    );
  }

  if (icon === "buses") {
    return (
      <svg {...common}>
        <path d="M6 5h12a2 2 0 0 1 2 2v8H4V7a2 2 0 0 1 2-2Z" />
        <path d="M4 11h16" />
        <path d="M7 19h.01" />
        <path d="M17 19h.01" />
        <path d="M7 15v4" />
        <path d="M17 15v4" />
      </svg>
    );
  }

  if (icon === "drivers") {
    return (
      <svg {...common}>
        <path d="M12 12a4 4 0 1 0 0-8 4 4 0 0 0 0 8Z" />
        <path d="M5 21a7 7 0 0 1 14 0" />
      </svg>
    );
  }

  return (
    <svg {...common}>
      <path d="M5 12a7 7 0 0 1 7-7" />
      <path d="M5 12a7 7 0 0 0 7 7" />
      <path d="M12 5a7 7 0 0 1 7 7" />
      <path d="M12 19a7 7 0 0 0 7-7" />
      <path d="M12 9v6" />
      <path d="M9 12h6" />
    </svg>
  );
}

export default function AdminShell({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();
  const { user, logout, loading } = useAuth();

  const navItems = allNavItems.filter(
    (item) => !item.superOnly || isSuperAdmin(user)
  );

  return (
    <div className="admin-layout">
      <aside className="sidebar">
        <div className="brand">
          <img
            className="brand-logo"
            src="/icons/tardadi-wordmark.png"
            alt="شعار ترددي"
          />
          <div className="brand-copy">
            <small>لوحة الإدارة</small>
            {!loading && user && (
              <small className="user-badge">
                {user.name} ·{" "}
                {user.role === "super_admin" ? "مدير النظام" : "مدير شركة"}
              </small>
            )}
          </div>
        </div>

        <BusinessSwitcher />

        <nav className="sidebar-nav">
          {navItems.map((item) => {
            const active =
              item.href === "/"
                ? pathname === "/"
                : pathname.startsWith(item.href);
            return (
              <Link
                key={item.href}
                href={item.href}
                className={`nav-item ${active ? "active" : ""}`}
              >
                <NavIconGlyph icon={item.icon} />
                <span>{item.label}</span>
              </Link>
            );
          })}
        </nav>

        <div className="sidebar-footer">
          <button type="button" className="btn btn-ghost btn-sm" onClick={() => logout()}>
            تسجيل الخروج
          </button>
        </div>
      </aside>

      <main className="main-content">{children}</main>
    </div>
  );
}
