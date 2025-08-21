'use client'

import { useAuth } from '@/lib/auth-context'
import { useRouter } from 'next/navigation'
import { useEffect } from 'react'
import Link from 'next/link'
import { MapPin, Building2, Users, BarChart3, LogIn, UserPlus } from 'lucide-react'

export default function Home() {
  const { user, isLoading } = useAuth()
  const router = useRouter()

  useEffect(() => {
    if (!isLoading && user) {
      router.push('/dashboard')
    }
  }, [user, isLoading, router])

  if (isLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="loading-spinner"></div>
      </div>
    )
  }

  return (
    <main className="min-h-screen">
      {/* Header */}
      <header className="bg-white shadow-sm border-b border-gray-100">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center py-4">
            <div className="flex items-center space-x-3">
              <div className="h-10 w-10 flex items-center justify-center rounded-full gradient-orange text-white">
                <MapPin className="h-6 w-6" />
              </div>
              <div>
                <h1 className="text-xl font-bold text-gray-900">Sistem Geotagging Usaha</h1>
                <p className="text-sm text-gray-600">Pematang Siantar</p>
              </div>
            </div>
            <div className="flex space-x-3">
              <Link
                href="/login"
                className="flex items-center space-x-2 px-4 py-2 text-orange-600 hover:text-orange-700 font-medium"
              >
                <LogIn className="h-4 w-4" />
                <span>Masuk</span>
              </Link>
              <Link
                href="/register"
                className="flex items-center space-x-2 px-4 py-2 bg-orange-600 text-white rounded-lg hover:bg-orange-700 font-medium"
              >
                <UserPlus className="h-4 w-4" />
                <span>Daftar</span>
              </Link>
            </div>
          </div>
        </div>
      </header>

      {/* Hero Section */}
      <section className="gradient-orange text-white py-20">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <h1 className="text-4xl md:text-6xl font-extrabold mb-6">
            Sistem Geotagging Usaha
          </h1>
          <h2 className="text-xl md:text-2xl mb-8 opacity-90">
            Pemetaan dan Pendataan Usaha di Pematang Siantar
          </h2>
          <p className="text-lg md:text-xl mb-10 max-w-3xl mx-auto opacity-90">
            Platform digital untuk mendaftarkan, memetakan, dan memantau usaha-usaha 
            di wilayah Pematang Siantar dengan teknologi geotagging terkini.
          </p>
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <Link
              href="/register"
              className="px-8 py-3 bg-white text-orange-600 font-semibold rounded-lg hover:bg-gray-100 transition-colors duration-200"
            >
              Daftarkan Usaha Anda
            </Link>
            <Link
              href="/login"
              className="px-8 py-3 border-2 border-white text-white font-semibold rounded-lg hover:bg-white hover:text-orange-600 transition-colors duration-200"
            >
              Masuk ke Dashboard
            </Link>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section className="py-20 bg-gray-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-16">
            <h2 className="text-3xl md:text-4xl font-bold text-gray-900 mb-4">
              Fitur Unggulan
            </h2>
            <p className="text-lg text-gray-600 max-w-2xl mx-auto">
              Sistem yang lengkap untuk pendataan dan pemetaan usaha dengan teknologi modern
            </p>
          </div>
          
          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
            <div className="card text-center">
              <div className="h-16 w-16 mx-auto mb-4 flex items-center justify-center rounded-full gradient-orange text-white">
                <Building2 className="h-8 w-8" />
              </div>
              <h3 className="text-xl font-semibold text-gray-900 mb-3">
                Pendaftaran Usaha
              </h3>
              <p className="text-gray-600">
                Form pendaftaran lengkap dengan validasi data dan sistem keamanan yang terjamin
              </p>
            </div>

            <div className="card text-center">
              <div className="h-16 w-16 mx-auto mb-4 flex items-center justify-center rounded-full gradient-orange text-white">
                <MapPin className="h-8 w-8" />
              </div>
              <h3 className="text-xl font-semibold text-gray-900 mb-3">
                Geotagging Otomatis
              </h3>
              <p className="text-gray-600">
                Penandaan lokasi otomatis dengan GPS dan visualisasi peta interaktif
              </p>
            </div>

            <div className="card text-center">
              <div className="h-16 w-16 mx-auto mb-4 flex items-center justify-center rounded-full gradient-orange text-white">
                <BarChart3 className="h-8 w-8" />
              </div>
              <h3 className="text-xl font-semibold text-gray-900 mb-3">
                Dashboard Analytics
              </h3>
              <p className="text-gray-600">
                Statistik dan visualisasi data usaha per kecamatan dan kelurahan
              </p>
            </div>

            <div className="card text-center">
              <div className="h-16 w-16 mx-auto mb-4 flex items-center justify-center rounded-full gradient-orange text-white">
                <Users className="h-8 w-8" />
              </div>
              <h3 className="text-xl font-semibold text-gray-900 mb-3">
                Multi-User Access
              </h3>
              <p className="text-gray-600">
                Akses berbeda untuk admin dan pengguna biasa dengan kontrol yang tepat
              </p>
            </div>

            <div className="card text-center">
              <div className="h-16 w-16 mx-auto mb-4 flex items-center justify-center rounded-full gradient-orange text-white">
                <MapPin className="h-8 w-8" />
              </div>
              <h3 className="text-xl font-semibold text-gray-900 mb-3">
                Peta Interaktif
              </h3>
              <p className="text-gray-600">
                Peta dengan markers usaha, filter lokasi, dan detail popup informatif
              </p>
            </div>

            <div className="card text-center">
              <div className="h-16 w-16 mx-auto mb-4 flex items-center justify-center rounded-full gradient-orange text-white">
                <BarChart3 className="h-8 w-8" />
              </div>
              <h3 className="text-xl font-semibold text-gray-900 mb-3">
                Monitoring Sistem
              </h3>
              <p className="text-gray-600">
                Deteksi data duplikat, validasi missing value, dan quality control
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-16 bg-white">
        <div className="max-w-4xl mx-auto text-center px-4 sm:px-6 lg:px-8">
          <h2 className="text-3xl font-bold text-gray-900 mb-4">
            Siap Mendaftarkan Usaha Anda?
          </h2>
          <p className="text-lg text-gray-600 mb-8">
            Bergabunglah dengan sistem geotagging usaha Pematang Siantar dan 
            jadilah bagian dari pemetaan ekonomi digital kota.
          </p>
          <Link
            href="/register"
            className="inline-flex items-center px-8 py-3 bg-orange-600 text-white font-semibold rounded-lg hover:bg-orange-700 transition-colors duration-200"
          >
            <UserPlus className="h-5 w-5 mr-2" />
            Mulai Daftar Sekarang
          </Link>
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-gray-900 text-white py-12">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center">
            <div className="flex items-center justify-center space-x-3 mb-4">
              <div className="h-10 w-10 flex items-center justify-center rounded-full gradient-orange text-white">
                <MapPin className="h-6 w-6" />
              </div>
              <div>
                <h3 className="text-xl font-bold">Sistem Geotagging Usaha</h3>
                <p className="text-gray-400">Pematang Siantar</p>
              </div>
            </div>
            <p className="text-gray-400 mb-8">
              Sistem digital untuk pemetaan dan pendataan usaha di wilayah Pematang Siantar
            </p>
            <p className="text-gray-500 text-sm">
              © 2024 Sistem Geotagging Usaha Pematang Siantar. All rights reserved.
            </p>
          </div>
        </div>
      </footer>
    </main>
  )
}
