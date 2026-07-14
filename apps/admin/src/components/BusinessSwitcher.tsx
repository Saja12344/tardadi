"use client";

import { useEffect, useState } from "react";
import type { BusinessListItem } from "@tardadi/shared";
import SelectInput from "./SelectInput";
import { useAuth } from "./AuthProvider";
import { isSuperAdmin } from "@/lib/auth.constants";
import { adminFetch } from "@/lib/adminFetch";

export default function BusinessSwitcher() {
  const { user, businessContextId, setBusinessContext } = useAuth();
  const [businesses, setBusinesses] = useState<BusinessListItem[]>([]);

  useEffect(() => {
    if (!isSuperAdmin(user)) return;
    adminFetch<BusinessListItem[]>("/api/businesses")
      .then((list) => {
        setBusinesses(Array.isArray(list) ? list : []);
      })
      .catch(() => setBusinesses([]));
  }, [user]);

  if (!isSuperAdmin(user)) return null;

  return (
    <div className="business-switcher">
      <span className="business-switcher-label">الشركة النشطة</span>
      <SelectInput
        value={businessContextId || ""}
        onChange={(e) => {
          if (e.target.value) void setBusinessContext(e.target.value);
        }}
      >
        <option value="">اختر شركة للإدارة</option>
        {(businesses ?? []).map((b) => (
          <option key={b.businessId} value={b.businessId}>
            {b.name}
          </option>
        ))}
      </SelectInput>
    </div>
  );
}
