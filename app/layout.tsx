import type { Metadata } from 'next'
import './globals.css'

export const metadata: Metadata = {
  title: 'Sistem Geotagging Usaha - Pematang Siantar',
  description: 'Sistem Geotagging Usaha di PematangSiantar',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="id">
      <body>{children}</body>
    </html>
  )
}
