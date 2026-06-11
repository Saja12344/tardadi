"use client";

import { useEffect, useState } from "react";
import type { Route } from "@tardadi/shared";
import { api } from "@/lib/api";

export default function RoutesPage() {
  const [routes, setRoutes] = useState<Route[]>([]);
  const [name, setName] = useState("");
  const [code, setCode] = useState("");
  const [error, setError] = useState("");

  async function load() {
    try {
      const data = (await api.getRoutes()) as Route[];
      setRoutes(data);
    } catch (e) {
      setError((e as Error).message);
    }
  }

  async function createRoute(e: React.FormEvent) {
    e.preventDefault();
    setError("");
    try {
      await fetch(
        `${process.env.NEXT_PUBLIC_API_URL || "http://127.0.0.1:5001/demo-org/us-central1/api"}/api/routes?organizationId=${process.env.NEXT_PUBLIC_ORG_ID || "demo-org"}`,
        {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ name, code, colorHex: "#FF6B00" }),
        }
      );
      setName("");
      setCode("");
      await load();
    } catch (e) {
      setError((e as Error).message);
    }
  }

  useEffect(() => {
    load();
  }, []);

  return (
    <main className="container">
      <h1>الخطوط</h1>
      <form className="card" onSubmit={createRoute}>
        <h3>إضافة خط</h3>
        <input
          placeholder="اسم الخط"
          value={name}
          onChange={(e) => setName(e.target.value)}
          required
        />
        <input
          placeholder="كود الخط (مثال: R-A)"
          value={code}
          onChange={(e) => setCode(e.target.value)}
          required
        />
        <button className="btn" type="submit">
          إضافة
        </button>
      </form>
      {error && <p style={{ color: "#ff6b6b" }}>{error}</p>}
      <div className="card">
        <table>
          <thead>
            <tr>
              <th>الاسم</th>
              <th>الكود</th>
              <th>اللون</th>
              <th>الحالة</th>
            </tr>
          </thead>
          <tbody>
            {routes.map((route) => (
              <tr key={route.routeId}>
                <td>{route.name}</td>
                <td>{route.code}</td>
                <td>
                  <span
                    style={{
                      display: "inline-block",
                      width: 16,
                      height: 16,
                      borderRadius: 4,
                      background: route.colorHex,
                    }}
                  />
                </td>
                <td>{route.status}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </main>
  );
}
