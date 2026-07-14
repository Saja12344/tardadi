"use client";

import Link from "next/link";
import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import type { BusinessListItem } from "@tardadi/shared";
import { adminFetch } from "@/lib/adminFetch";
import { getUserErrorMessage } from "@/lib/errorMessage";
import { useAuth } from "@/components/AuthProvider";

export default function BusinessesPage() {
  const router = useRouter();
  const { user } = useAuth();
  const [businesses, setBusinesses] = useState<BusinessListItem[]>([]);
  const [error, setError] = useState("");
  const [showForm, setShowForm] = useState(false);
  const [form, setForm] = useState({
    name: "",
    adminName: "",
    adminPhone: "",
    adminPassword: "",
  });

  async function load() {
    setError("");
    try {
      const data = await adminFetch<BusinessListItem[]>("/api/businesses");
      setBusinesses(Array.isArray(data) ? data : []);
    } catch (e) {
      setError(getUserErrorMessage(e));
      setBusinesses([]);
    }
  }

  async function createBusiness(e: React.FormEvent) {
    e.preventDefault();
    setError("");
    try {
      await adminFetch("/api/businesses", {
        method: "POST",
        body: JSON.stringify(form),
      });
      setForm({ name: "", adminName: "", adminPhone: "", adminPassword: "" });
      setShowForm(false);
      await load();
    } catch (err) {
      setError(getUserErrorMessage(err));
    }
  }

  async function disableBusiness(businessId: string) {
    if (!confirm("تعطيل هذه الشركة؟")) return;
    try {
      await adminFetch(`/api/businesses/${businessId}/disable`, {
        method: "PATCH",
      });
      await load();
    } catch (err) {
      setError(getUserErrorMessage(err));
    }
  }

  async function deleteBusiness(businessId: string) {
    if (!confirm("حذف الشركة نهائياً؟ لا يمكن التراجع.")) return;
    try {
      await adminFetch(`/api/businesses/${businessId}`, { method: "DELETE" });
      await load();
    } catch (err) {
      setError(getUserErrorMessage(err));
    }
  }

  useEffect(() => {
    if (user?.role === "business_admin" && user.businessId) {
      router.replace(`/businesses/${user.businessId}`);
      return;
    }
    load();
  }, [user, router]);

  return (
    <>
      <div className="page-header row-between">
        <div>
          <h1>الشركات</h1>
          <p>إدارة شركات النقل ومديريها</p>
        </div>
        <button
          type="button"
          className={`btn btn-inline ${showForm ? "btn-secondary" : "btn-primary"}`}
          onClick={() => setShowForm((v) => !v)}
        >
          {showForm ? "إلغاء" : "+ شركة جديدة"}
        </button>
      </div>

      {error && <div className="alert alert-error">{error}</div>}

      {showForm && (
        <form className="card form-card mb-20" onSubmit={createBusiness}>
          <div className="form-card-header">
            <h3>إضافة شركة جديدة</h3>
            <p>أنشئ مساحة عمل للشركة وحدّد مديرها</p>
          </div>

          <div className="form-section">
            <h4 className="form-section-title">بيانات الشركة</h4>
            <div className="field">
              <label htmlFor="biz-name">اسم الشركة</label>
              <input
                id="biz-name"
                placeholder="مثال: روشن، سابتكو..."
                value={form.name}
                onChange={(e) => setForm({ ...form, name: e.target.value })}
                required
              />
            </div>
          </div>

          <div className="form-section">
            <h4 className="form-section-title">مدير الشركة</h4>
            <p className="form-section-hint">
              رقم الجوال يصبح اسم المستخدم لتسجيل الدخول
            </p>
            <div className="form-grid">
              <div className="field">
                <label htmlFor="admin-name">الاسم الكامل</label>
                <input
                  id="admin-name"
                  placeholder="مثال: أحمد محمد"
                  value={form.adminName}
                  onChange={(e) =>
                    setForm({ ...form, adminName: e.target.value })
                  }
                  required
                />
              </div>
              <div className="field">
                <label htmlFor="admin-phone">رقم الجوال</label>
                <input
                  id="admin-phone"
                  type="tel"
                  dir="ltr"
                  placeholder="05xxxxxxxx"
                  value={form.adminPhone}
                  onChange={(e) =>
                    setForm({ ...form, adminPhone: e.target.value })
                  }
                  required
                />
              </div>
              <div className="field form-grid-full">
                <label htmlFor="admin-pass">كلمة المرور</label>
                <input
                  id="admin-pass"
                  type="password"
                  placeholder="كلمة مرور قوية"
                  value={form.adminPassword}
                  onChange={(e) =>
                    setForm({ ...form, adminPassword: e.target.value })
                  }
                  required
                />
              </div>
            </div>
          </div>

          <div className="form-actions">
            <button type="submit" className="btn btn-primary btn-inline">
              إنشاء الشركة
            </button>
            <button
              type="button"
              className="btn btn-secondary btn-inline"
              onClick={() => setShowForm(false)}
            >
              إلغاء
            </button>
          </div>
        </form>
      )}

      <div className="card table-card">
        <table className="data-table">
          <thead>
            <tr>
              <th>الشعار</th>
              <th>الشركة</th>
              <th>المدير</th>
              <th>الجوال</th>
              <th>سائقين</th>
              <th>باصات</th>
              <th>خطوط</th>
              <th>محطات</th>
              <th>الحالة</th>
              <th>إجراءات</th>
            </tr>
          </thead>
          <tbody>
            {businesses.map((b) => (
              <tr key={b.businessId}>
                <td>
                  {b.logo ? (
                    <img src={b.logo} alt="" className="business-logo" />
                  ) : (
                    <span className="logo-placeholder">—</span>
                  )}
                </td>
                <td className="cell-strong">{b.name}</td>
                <td>{b.adminName || "—"}</td>
                <td dir="ltr" className="cell-mono">
                  {b.adminPhone || "—"}
                </td>
                <td>{b.driverCount}</td>
                <td>{b.busCount}</td>
                <td>{b.routeCount}</td>
                <td>{b.stationCount}</td>
                <td>
                  <span
                    className={`badge ${b.status === "active" ? "badge-success" : "badge-muted"}`}
                  >
                    {b.status === "active" ? "نشطة" : "معطّلة"}
                  </span>
                </td>
                <td>
                  <div className="action-buttons">
                    <Link
                      href={`/businesses/${b.businessId}`}
                      className="action-btn action-btn-view"
                      title="عرض التفاصيل"
                    >
                      عرض
                    </Link>
                    {b.status === "active" && (
                      <button
                        type="button"
                        className="action-btn action-btn-warn"
                        title="تعطيل الشركة"
                        onClick={() => disableBusiness(b.businessId)}
                      >
                        تعطيل
                      </button>
                    )}
                    <button
                      type="button"
                      className="action-btn action-btn-danger"
                      title="حذف نهائي"
                      onClick={() => deleteBusiness(b.businessId)}
                    >
                      حذف
                    </button>
                  </div>
                </td>
              </tr>
            ))}
            {businesses.length === 0 && (
              <tr>
                <td colSpan={10} className="empty-cell">
                  لا توجد شركات بعد — اضغط «شركة جديدة» للبدء
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    </>
  );
}
