'use client'

import { useState, useEffect } from 'react'
import { useAuth } from '@/lib/auth-context'
import { useRouter } from 'next/navigation'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'
import Link from 'next/link'
import dynamic from 'next/dynamic'
import {
  MapPin,
  Building2,
  Phone,
  Mail,
  Calendar,
  FileText,
  Network,
  Save,
  Loader,
  Map
} from 'lucide-react'
import { KECAMATAN_OPTIONS, KELURAHAN_OPTIONS, Business } from '@/lib/types'

// Dynamically import map components to avoid SSR issues
const MapContainer = dynamic(() => import('react-leaflet').then(mod => mod.MapContainer), { ssr: false })
const TileLayer = dynamic(() => import('react-leaflet').then(mod => mod.TileLayer), { ssr: false })
const Marker = dynamic(() => import('react-leaflet').then(mod => mod.Marker), { ssr: false })
const Popup = dynamic(() => import('react-leaflet').then(mod => mod.Popup), { ssr: false })

const businessSchema = z.object({
  namaUsaha: z.string().min(3, 'Nama usaha minimal 3 karakter').max(100, 'Nama usaha maksimal 100 karakter'),
  namaKomersil: z.string().min(3, 'Nama komersil minimal 3 karakter').max(100, 'Nama komersil maksimal 100 karakter'),
  alamat: z.string().min(10, 'Alamat minimal 10 karakter').max(200, 'Alamat maksimal 200 karakter'),
  kecamatan: z.enum(KECAMATAN_OPTIONS as [string, ...string[]], {
    errorMap: () => ({ message: 'Pilih kecamatan yang valid' })
  }),
  kelurahan: z.enum(KELURAHAN_OPTIONS as [string, ...string[]], {
    errorMap: () => ({ message: 'Pilih kelurahan yang valid' })
  }),
  kodeSLS: z.string().regex(/^[0-9]{10}$/, 'Kode SLS harus 10 digit angka'),
  telepon: z.string().regex(/^(\+62|62|0)[0-9]{9,12}$/, 'Format nomor telepon tidak valid'),
  email: z.string().email('Format email tidak valid'),
  tahunBerdiri: z.number().min(1900, 'Tahun minimal 1900').max(new Date().getFullYear(), 'Tahun tidak boleh lebih dari tahun sekarang'),
  deskripsiKegiatan: z.string().min(20, 'Deskripsi minimal 20 karakter').max(500, 'Deskripsi maksimal 500 karakter'),
  jaringanUsaha: z.enum(['Tunggal', 'Cabang'], {
    errorMap: () => ({ message: 'Pilih jenis jaringan usaha' })
  }),
})

type BusinessFormData = z.infer<typeof businessSchema>

export default function DaftarUsahaPage() {
  const { user } = useAuth()
  const router = useRouter()
  const [loading, setLoading] = useState(false)
  const [gettingLocation, setGettingLocation] = useState(false)
  const [currentLocation, setCurrentLocation] = useState<{ lat: number; lng: number } | null>(null)
  const [locationError, setLocationError] = useState('')

  const {
    register,
    handleSubmit,
    formState: { errors },
    setValue,
    watch
  } = useForm<BusinessFormData>({
    resolver: zodResolver(businessSchema)
  })

  useEffect(() => {
    if (!user) {
      router.push('/login')
    }
  }, [user, router])

  const getCurrentLocation = () => {
    setGettingLocation(true)
    setLocationError('')

    if (!navigator.geolocation) {
      setLocationError('Browser Anda tidak mendukung geolocation')
      setGettingLocation(false)
      return
    }

    navigator.geolocation.getCurrentPosition(
      (position) => {
        const { latitude, longitude } = position.coords
        setCurrentLocation({ lat: latitude, lng: longitude })
        setGettingLocation(false)
      },
      (error) => {
        let errorMessage = 'Gagal mendapatkan lokasi'
        switch (error.code) {
          case error.PERMISSION_DENIED:
            errorMessage = 'Akses lokasi ditolak. Silakan aktifkan GPS dan berikan izin lokasi.'
            break
          case error.POSITION_UNAVAILABLE:
            errorMessage = 'Informasi lokasi tidak tersedia'
            break
          case error.TIMEOUT:
            errorMessage = 'Request lokasi timeout'
            break
        }
        setLocationError(errorMessage)
        setGettingLocation(false)
      },
      {
        enableHighAccuracy: true,
        timeout: 10000,
        maximumAge: 0
      }
    )
  }

  const createCustomIcon = () => {
    if (typeof window === 'undefined') return null

    const L = require('leaflet')
    return L.divIcon({
      html: `<div style="background-color: #FF6B35; width: 20px; height: 20px; border-radius: 50%; border: 2px solid white; box-shadow: 0 2px 4px rgba(0,0,0,0.3);"></div>`,
      className: 'custom-marker',
      iconSize: [20, 20],
      iconAnchor: [10, 10]
    })
  }

  const onSubmit = async (data: BusinessFormData) => {
    if (!currentLocation) {
      setLocationError('Silakan ambil lokasi terlebih dahulu')
      return
    }

    setLoading(true)

    const businessData: Business = {
      ...data,
      id: Date.now().toString(),
      latitude: currentLocation.lat,
      longitude: currentLocation.lng,
      userId: user!.id,
      createdAt: new Date().toISOString()
    }

    // Save to localStorage (simulating database)
    const businesses = JSON.parse(localStorage.getItem('businesses') || '[]')
    businesses.push(businessData)
    localStorage.setItem('businesses', JSON.stringify(businesses))

    setLoading(false)
    router.push('/dashboard?success=true')
  }

  if (!user) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="loading-spinner"></div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gray-50 py-8">
      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Header */}
        <div className="mb-8">
          <div className="flex items-center justify-between">
            <div>
              <h1 className="text-3xl font-bold text-gray-900 mb-2">
                Daftarkan Usaha Baru
              </h1>
              <p className="text-gray-600">
                Lengkapi form berikut untuk mendaftarkan usaha yang akan didata
              </p>
            </div>
            <Link
              href="/dashboard"
              className="px-4 py-2 text-gray-600 hover:text-gray-800 font-medium"
            >
              ← Kembali ke Dashboard
            </Link>
          </div>
        </div>

        <form onSubmit={handleSubmit(onSubmit)} className="space-y-8">
          {/* Informasi Usaha */}
          <div className="card">
            <div className="flex items-center mb-6">
              <Building2 className="h-6 w-6 text-orange-600 mr-3" />
              <h2 className="text-xl font-semibold text-gray-900">Informasi Usaha</h2>
            </div>
            
            <div className="grid md:grid-cols-2 gap-6">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Nama Usaha *
                </label>
                <input
                  {...register('namaUsaha')}
                  type="text"
                  className="input-field"
                  placeholder="Contoh: Toko Kelontong Maju"
                />
                {errors.namaUsaha && (
                  <p className="mt-1 text-sm text-red-600">{errors.namaUsaha.message}</p>
                )}
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Nama Komersil *
                </label>
                <input
                  {...register('namaKomersil')}
                  type="text"
                  className="input-field"
                  placeholder="Contoh: Toko Maju Jaya"
                />
                {errors.namaKomersil && (
                  <p className="mt-1 text-sm text-red-600">{errors.namaKomersil.message}</p>
                )}
              </div>

              <div className="md:col-span-2">
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Alamat Lengkap *
                </label>
                <textarea
                  {...register('alamat')}
                  rows={3}
                  className="input-field"
                  placeholder="Jalan, Nomor, RT/RW, Desa/Kelurahan"
                />
                {errors.alamat && (
                  <p className="mt-1 text-sm text-red-600">{errors.alamat.message}</p>
                )}
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Kecamatan *
                </label>
                <select {...register('kecamatan')} className="input-field">
                  <option value="">Pilih Kecamatan</option>
                  {KECAMATAN_OPTIONS.map((kec) => (
                    <option key={kec} value={kec}>{kec}</option>
                  ))}
                </select>
                {errors.kecamatan && (
                  <p className="mt-1 text-sm text-red-600">{errors.kecamatan.message}</p>
                )}
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Kelurahan *
                </label>
                <select {...register('kelurahan')} className="input-field">
                  <option value="">Pilih Kelurahan</option>
                  {KELURAHAN_OPTIONS.map((kel) => (
                    <option key={kel} value={kel}>{kel}</option>
                  ))}
                </select>
                {errors.kelurahan && (
                  <p className="mt-1 text-sm text-red-600">{errors.kelurahan.message}</p>
                )}
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Kode SLS *
                </label>
                <input
                  {...register('kodeSLS')}
                  type="text"
                  className="input-field"
                  placeholder="1234567890"
                  maxLength={10}
                />
                {errors.kodeSLS && (
                  <p className="mt-1 text-sm text-red-600">{errors.kodeSLS.message}</p>
                )}
              </div>
            </div>
          </div>

          {/* Kontak */}
          <div className="card">
            <div className="flex items-center mb-6">
              <Phone className="h-6 w-6 text-orange-600 mr-3" />
              <h2 className="text-xl font-semibold text-gray-900">Informasi Kontak</h2>
            </div>
            
            <div className="grid md:grid-cols-2 gap-6">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Nomor Telepon/WhatsApp *
                </label>
                <input
                  {...register('telepon')}
                  type="tel"
                  className="input-field"
                  placeholder="08123456789 atau +6281234567890"
                />
                {errors.telepon && (
                  <p className="mt-1 text-sm text-red-600">{errors.telepon.message}</p>
                )}
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Email *
                </label>
                <input
                  {...register('email')}
                  type="email"
                  className="input-field"
                  placeholder="email@domain.com"
                />
                {errors.email && (
                  <p className="mt-1 text-sm text-red-600">{errors.email.message}</p>
                )}
              </div>
            </div>
          </div>

          {/* Detail Usaha */}
          <div className="card">
            <div className="flex items-center mb-6">
              <FileText className="h-6 w-6 text-orange-600 mr-3" />
              <h2 className="text-xl font-semibold text-gray-900">Detail Usaha</h2>
            </div>
            
            <div className="grid md:grid-cols-2 gap-6">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Tahun Berdiri *
                </label>
                <input
                  {...register('tahunBerdiri', { valueAsNumber: true })}
                  type="number"
                  min="1900"
                  max={new Date().getFullYear()}
                  className="input-field"
                  placeholder="2020"
                />
                {errors.tahunBerdiri && (
                  <p className="mt-1 text-sm text-red-600">{errors.tahunBerdiri.message}</p>
                )}
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Jaringan Usaha *
                </label>
                <select {...register('jaringanUsaha')} className="input-field">
                  <option value="">Pilih Jenis</option>
                  <option value="Tunggal">Tunggal</option>
                  <option value="Cabang">Cabang</option>
                </select>
                {errors.jaringanUsaha && (
                  <p className="mt-1 text-sm text-red-600">{errors.jaringanUsaha.message}</p>
                )}
              </div>

              <div className="md:col-span-2">
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Deskripsi Kegiatan Usaha *
                </label>
                <textarea
                  {...register('deskripsiKegiatan')}
                  rows={4}
                  className="input-field"
                  placeholder="Jelaskan kegiatan usaha, produk/jasa yang ditawarkan, target pasar, dll."
                />
                {errors.deskripsiKegiatan && (
                  <p className="mt-1 text-sm text-red-600">{errors.deskripsiKegiatan.message}</p>
                )}
              </div>
            </div>
          </div>

          {/* Geotagging */}
          <div className="card">
            <div className="flex items-center mb-6">
              <MapPin className="h-6 w-6 text-orange-600 mr-3" />
              <h2 className="text-xl font-semibold text-gray-900">Lokasi Usaha</h2>
            </div>

            <div className="space-y-4">
              <button
                type="button"
                onClick={getCurrentLocation}
                disabled={gettingLocation}
                className="flex items-center space-x-2 px-4 py-2 bg-orange-600 text-white rounded-lg hover:bg-orange-700 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                {gettingLocation ? (
                  <Loader className="h-5 w-5 animate-spin" />
                ) : (
                  <Map className="h-5 w-5" />
                )}
                <span>
                  {gettingLocation ? 'Mengambil Lokasi...' : 'Ambil Lokasi Saat Ini'}
                </span>
              </button>

              {currentLocation && (
                <div className="space-y-4">
                  <div className="p-4 bg-green-50 border border-green-200 rounded-lg">
                    <p className="text-green-800 font-medium">✓ Lokasi berhasil diambil</p>
                    <p className="text-green-700 text-sm">
                      Latitude: {currentLocation.lat.toFixed(6)},
                      Longitude: {currentLocation.lng.toFixed(6)}
                    </p>
                  </div>

                  {/* Map Display */}
                  <div className="border border-gray-200 rounded-lg overflow-hidden">
                    <div style={{ height: '300px', width: '100%' }}>
                      {typeof window !== 'undefined' && (
                        <MapContainer
                          center={[currentLocation.lat, currentLocation.lng]}
                          zoom={16}
                          style={{ height: '100%', width: '100%' }}
                          className="rounded-lg"
                        >
                          <TileLayer
                            attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
                            url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
                          />

                          <Marker
                            position={[currentLocation.lat, currentLocation.lng]}
                            icon={createCustomIcon()}
                          >
                            <Popup className="custom-popup">
                              <div className="p-2">
                                <h3 className="font-bold text-gray-900 mb-2">
                                  📍 Lokasi Usaha
                                </h3>
                                <p className="text-sm text-gray-700">
                                  Lat: {currentLocation.lat.toFixed(6)}<br/>
                                  Lng: {currentLocation.lng.toFixed(6)}
                                </p>
                              </div>
                            </Popup>
                          </Marker>
                        </MapContainer>
                      )}
                    </div>
                  </div>
                </div>
              )}

              {locationError && (
                <div className="p-4 bg-red-50 border border-red-200 rounded-lg">
                  <p className="text-red-800">{locationError}</p>
                </div>
              )}
            </div>
          </div>

          {/* Submit Button */}
          <div className="flex justify-end space-x-4">
            <Link
              href="/dashboard"
              className="btn-secondary"
            >
              Batal
            </Link>
            <button
              type="submit"
              disabled={loading || !currentLocation}
              className="flex items-center space-x-2 btn-primary disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {loading ? (
                <Loader className="h-5 w-5 animate-spin" />
              ) : (
                <Save className="h-5 w-5" />
              )}
              <span>{loading ? 'Menyimpan...' : 'Simpan Usaha'}</span>
            </button>
          </div>
        </form>
      </div>
    </div>
  )
}
