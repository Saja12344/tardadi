"use client";

import { useEffect, useState } from "react";
import type { Bus } from "@tardadi/shared";
import { api } from "@/lib/api";
import { adminFetch } from "@/lib/adminFetch";

export default function BusesPage() {
  const [buses, setBuses] = useState<Bus[]>([]);
  const [plateNo, setPlateNo] = useState("");
  const [label, setLabel] = useState("");
  const [error, setError] = useState("");
  const [success, setSuccess] = useState("");

  async function load() {
    try {
      const data = (await api.getBuses()) as Bus[];
      setBuses(data);
      setError("");
    } catch (e) {
      setError((e as Error).message);
    }
  }

  async function createBus(e: React.FormEvent) {
    e.preventDefault();
    setError("");
    setSuccess("");
    try {
      await adminFetch<Bus>("/api/buses", {
        method: "POST",
        body: JSON.stringify({ plateNo, label }),
      });
      setPlateNo("");
      setLabel("");
      setSuccess("تمت إضافة الباص");
      await load();
    } catch (e) {
      setError((e as Error).message);
    }
  }

  useEffect(() => {
    load();
  }, []);

  return (
    <>
      <div className="page-header">
        <h1>الباصات</h1>
        <p>أضف مركبات النقل — المسار يُحدَّد على الخط، مو على الباص.</p>
      </div>

      <div className="grid-2">
        <form className="card" onSubmit={createBus}>
          <h3>إضافة باص جديد</h3>
          {error && <div className="alert alert-error">{error}</div>}
          {success && <div className="alert alert-success">{success}</div>}

          <div className="field">
            <label>رقم اللوحة</label>
            <input
              placeholder="مثال: ABC-1234"
              value={plateNo}
              onChange={(e) => setPlateNo(e.target.value)}
              required
            />
          </div>

          <div className="field">
            <label>اسم الباص</label>
            <input
              placeholder="مثال: باص 12"
              value={label}
              onChange={(e) => setLabel(e.target.value)}
              required
            />
          </div>

          <button className="btn" type="submit">
            حفظ الباص
          </button>
        </form>

        <div className="card table-wrap">
          <h3>الباصات ({buses.length})</h3>
          <table>
            <thead>
              <tr>
                <th>الاسم</th>
                <th>اللوحة</th>
                <th>الحالة</th>
              </tr>
            </thead>
            <tbody>
              {buses.map((bus) => (
                <tr key={bus.busId}>
                  <td>{bus.label}</td>
                  <td>{bus.plateNo}</td>
                  <td>{bus.status}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </>
  );
}
