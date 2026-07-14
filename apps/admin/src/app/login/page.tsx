"use client";

import { useState } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import { getUserErrorMessage } from "@/lib/errorMessage";

export default function LoginPage() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const [phone, setPhone] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError("");
    setLoading(true);
    try {
      const res = await fetch("/api/auth/login", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ phone, password }),
      });
      const body = await res.json();
      if (!res.ok || !body.success) {
        throw new Error(body.error || "فشل تسجيل الدخول");
      }

      const user = body.data.user as {
        role: string;
        businessId: string | null;
      };
      const next = searchParams.get("next");

      if (user.role === "business_admin" && user.businessId) {
        router.replace(next || `/businesses/${user.businessId}`);
      } else {
        router.replace(next || "/");
      }
      router.refresh();
    } catch (err) {
      setError(getUserErrorMessage(err));
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="login-page">
      <div className="login-card card">
        <div className="login-card-header">
          <img
            className="login-logo"
            src="/icons/tardadi-wordmark.png"
            alt="ترددي"
          />
          <h1>تسجيل الدخول</h1>
          <p>لوحة إدارة ترددي — ادخل برقم الجوال وكلمة المرور</p>
        </div>

        <form className="login-form" onSubmit={handleSubmit}>
          {error && <div className="alert alert-error">{error}</div>}

          <div className="field">
            <label htmlFor="login-phone">رقم الجوال</label>
            <input
              id="login-phone"
              type="tel"
              value={phone}
              onChange={(e) => setPhone(e.target.value)}
              placeholder="05xxxxxxxx"
              dir="ltr"
              autoComplete="tel"
              required
            />
          </div>

          <div className="field">
            <label htmlFor="login-password">كلمة المرور</label>
            <input
              id="login-password"
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              placeholder="••••••••"
              autoComplete="current-password"
              required
            />
          </div>

          <button
            type="submit"
            className="btn btn-primary"
            disabled={loading}
          >
            {loading ? "جاري الدخول..." : "دخول"}
          </button>
        </form>
      </div>
    </div>
  );
}
