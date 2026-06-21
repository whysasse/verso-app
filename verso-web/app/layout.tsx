import type { Metadata } from "next";
import { NextIntlClientProvider } from "next-intl";
import { getLocale } from "next-intl/server";
import { ThemeProvider } from "./providers/ThemeProvider";
import { LocaleProvider, type VersoLocale } from "./providers/LocaleProvider";
import "./globals.css";

export const metadata: Metadata = {
  title: "Verso",
  description: "A minimalist article reader",
};

export default async function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  const locale = (await getLocale()) as VersoLocale;

  return (
    <html lang={locale} data-theme="paper" className="h-full antialiased">
      <body className="min-h-full flex flex-col">
        <NextIntlClientProvider>
          <LocaleProvider initialLocale={locale}>
            <ThemeProvider>{children}</ThemeProvider>
          </LocaleProvider>
        </NextIntlClientProvider>
      </body>
    </html>
  );
}
