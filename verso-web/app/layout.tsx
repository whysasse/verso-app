import type { Metadata } from "next";
import { ThemeProvider } from "./providers/ThemeProvider";
import "./globals.css";

export const metadata: Metadata = {
  title: "Verso",
  description: "A minimalist article reader",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" data-theme="paper" className="h-full antialiased">
      <body className="min-h-full flex flex-col">
        <ThemeProvider>{children}</ThemeProvider>
      </body>
    </html>
  );
}
