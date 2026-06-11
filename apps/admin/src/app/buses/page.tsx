"use client";

import { useEffect, useState } from "react";
import type { Bus } from "@tardadi/shared";
import { api } from "@/lib/api";

export default function BusesPage() {
  const [buses, setBuses] = useState<Bus[]>([]);
  const [plateNo, setPlateNo] = useState("");
  const [label, setLabel] = useState("");
  const [error, setError] = useState("");

  async function load() {
    try {
      const data = (await api.getBuses()) as Bus[];
      setBuses(data);
    } catch (e) {
      setError((e as Error).message);
    }
  }

  async function createBus(e: React.FormEvent) {
    e.preventDefault();
    setError("");
    try {
      await fetch(
        `${process.env.NEXT_PUBLIC_API_URL || "http://127.0.0.1:5001/demo-org/us-central1/api"}/api/buses?organizationId=${process.env.NEXT_PUBLIC_ORG_ID || "demo-org"}`,
        {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ plateNo, label }),
        }
      );
      setPlateNo("");
      setLabel("");
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
      <h1>الباصات</h1>
      <form className="card" onSubmit={createBus}>
        <h3>إضافة باص</h3>
        <input
          placeholder="رقم اللوحة"
          value={plateNo}
          onChange={(e) => setPlateNo(e.target.value)}
          required
        />
        <input
          placeholder="الاسم (مثال: Bus 12)"
          value={label}
          onChange={(e) => setLabel(e.target.value)}
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
              <th>اللوحة</th>
              <th>آخر ظهور</th>
              <th>الحالة</th>
            </tr>
          </thead>
          <tbody>
            {buses.map((bus) => (
              <tr key={bus.busId}>
                <td>{bus.label}</td>
                <td>{bus.plateNo}</td>
                <td>{bus.lastSeenAt || "—"}</td>
                <td>{bus.status}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </main>
  );
}
