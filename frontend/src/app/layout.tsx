import type { Metadata } from "next";
import { Geist, Geist_Mono } from "next/font/google";
import "./globals.css";
import { AuthProvider } from "@/lib/auth-context";
import { Header } from "@/components/Header";
import { DemoBanner } from "@/components/DemoBanner";

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
});

export const metadata: Metadata = {
  title: "medimap — find medicine near you",
  description:
    "Search a medicine and see which nearby pharmacies have it in stock right now.",
};

export default function RootLayout({ children }: LayoutProps<"/">) {
  return (
    <html
      lang="en"
      className={`${geistSans.variable} ${geistMono.variable} h-full antialiased`}
    >
      <body className="h-full flex flex-col overflow-hidden bg-neutral-50 text-neutral-900">
        <AuthProvider>
          <DemoBanner />
          <Header />
          <main className="flex flex-1 flex-col overflow-hidden">{children}</main>
        </AuthProvider>
      </body>
    </html>
  );
}
