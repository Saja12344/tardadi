"use client";

import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useState,
} from "react";
import { useRouter } from "next/navigation";
import type { AdminSession } from "@tardadi/shared";
import { isSuperAdmin } from "@/lib/auth.constants";

interface AuthContextValue {
  user: AdminSession | null;
  loading: boolean;
  businessContextId: string | null;
  setBusinessContext: (businessId: string) => Promise<void>;
  logout: () => Promise<void>;
  refresh: () => Promise<void>;
}

const AuthContext = createContext<AuthContextValue | null>(null);

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const router = useRouter();
  const [user, setUser] = useState<AdminSession | null>(null);
  const [businessContextId, setBusinessContextId] = useState<string | null>(
    null
  );
  const [loading, setLoading] = useState(true);

  const refresh = useCallback(async () => {
    try {
      const res = await fetch("/api/auth/session", { cache: "no-store" });
      if (!res.ok) {
        setUser(null);
        setBusinessContextId(null);
        return;
      }
      const body = await res.json();
      const sessionUser = body.data as AdminSession;
      setUser(sessionUser);
      if (sessionUser.role === "business_admin") {
        setBusinessContextId(sessionUser.businessId);
      }
    } catch {
      setUser(null);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    refresh();
  }, [refresh]);

  const setBusinessContext = useCallback(
    async (businessId: string) => {
      if (!isSuperAdmin(user)) return;
      await fetch("/api/auth/business-context", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ businessId }),
      });
      setBusinessContextId(businessId);
      router.refresh();
    },
    [user, router]
  );

  const logout = useCallback(async () => {
    await fetch("/api/auth/logout", { method: "POST" });
    setUser(null);
    setBusinessContextId(null);
    router.push("/login");
    router.refresh();
  }, [router]);

  const value = useMemo(
    () => ({
      user,
      loading,
      businessContextId,
      setBusinessContext,
      logout,
      refresh,
    }),
    [user, loading, businessContextId, setBusinessContext, logout, refresh]
  );

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error("useAuth must be used within AuthProvider");
  return ctx;
}
