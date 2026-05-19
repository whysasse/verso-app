"use client";

import { createContext, useContext, useEffect, useState } from "react";

export type VersoTheme = "paper" | "sepia" | "night" | "ink";

const STORAGE_KEY = "verso-theme";

interface ThemeContextValue {
  theme: VersoTheme;
  setTheme: (theme: VersoTheme) => void;
}

const ThemeContext = createContext<ThemeContextValue | null>(null);

function resolveInitialTheme(): VersoTheme {
  if (typeof window === "undefined") return "paper";
  const stored = localStorage.getItem(STORAGE_KEY) as VersoTheme | null;
  if (stored && ["paper", "sepia", "night", "ink"].includes(stored)) return stored;
  return window.matchMedia("(prefers-color-scheme: dark)").matches ? "night" : "paper";
}

export function ThemeProvider({ children }: { children: React.ReactNode }) {
  const [theme, setThemeState] = useState<VersoTheme>("paper");

  useEffect(() => {
    const initial = resolveInitialTheme();
    setThemeState(initial);
    document.documentElement.setAttribute("data-theme", initial);
  }, []);

  function setTheme(next: VersoTheme) {
    setThemeState(next);
    localStorage.setItem(STORAGE_KEY, next);
    document.documentElement.setAttribute("data-theme", next);
  }

  return (
    <ThemeContext.Provider value={{ theme, setTheme }}>
      {children}
    </ThemeContext.Provider>
  );
}

export function useTheme(): ThemeContextValue {
  const ctx = useContext(ThemeContext);
  if (!ctx) throw new Error("useTheme must be used within ThemeProvider");
  return ctx;
}
