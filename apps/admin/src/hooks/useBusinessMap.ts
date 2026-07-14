"use client";

import { useEffect, useState } from "react";
import type { BusinessListItem } from "@tardadi/shared";
import { adminFetch } from "@/lib/adminFetch";
import { useAuth } from "@/components/AuthProvider";
import { isSuperAdmin } from "@/lib/auth.constants";

export function useBusinessMap(): Record<string, string> {
  const { user } = useAuth();
  const [map, setMap] = useState<Record<string, string>>({});

  useEffect(() => {
    if (!isSuperAdmin(user)) {
      setMap({});
      return;
    }

    adminFetch<BusinessListItem[]>("/api/businesses")
      .then((list) => {
        if (!Array.isArray(list)) {
          setMap({});
          return;
        }
        setMap(Object.fromEntries(list.map((b) => [b.businessId, b.name])));
      })
      .catch(() => setMap({}));
  }, [user]);

  return map;
}

export function useShowBusinessColumn(): boolean {
  const { user } = useAuth();
  return isSuperAdmin(user);
}
