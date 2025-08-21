'use client'

import { useState, useEffect } from 'react'
import { useAuth } from '@/lib/auth-context'
import { useRouter } from 'next/navigation'
import Link from 'next/link'
import dynamic from 'next/dynamic'
import { 
  ArrowLeft,
  MapPin,
  Filter,
  Search,
  Building2,
  Phone,
  Mail,
  Calendar
} from 'lucide-react'
import { Business, KECAMATAN_OPTIONS, KELURAHAN_OPTIONS } from '@/lib/types'

// Dynamically import map components to avoid SSR issues
const MapContainer = dynamic(() => import('react-leaflet').then(mod => mod.MapContainer), { ssr: false })
const TileLayer = dynamic(() => import('react-leaflet').then(mod => mod.TileLayer), { ssr: false })
const Marker = dynamic(() => import('react-leaflet').then(mod => mod.Marker), { ssr: false })
const Popup = dynamic(() => import('react-leaflet').then(mod => mod.Popup), { ssr: false })

export default function MapPage() {
  const { user } = useAuth()
  const router = useRouter()
  const [businesses, setBusinesses] = useState<Business[]>([])
  const [filteredBusinesses, setFilteredBusinesses] = useState<Business[]>([])
  const [loading, setLoading] = useState(true)
  const [searchTerm, setSearchTerm] = useState('')
  const [filterKecamatan, setFilterKecamatan] = useState('')
  const [filterKelurahan, setFilterKelurahan] = useState('')
  const [selectedBusiness, setSelectedBusiness] = useState<Business | null>(null)

  useEffect(() => {
    if (!user) {
      router.push('/login')
      return
    }

    // Load businesses from localStorage
    const storedBusinesses = JSON.parse(localStorage.getItem('businesses') || '[]')
    
    if (user.role === 'admin') {
      setBusinesses(storedBusinesses)
      setFilteredBusinesses(storedBusinesses)
    } else {
      const userBusinesses = storedBusinesses.filter((b: Business) => b.userId === user.id)
      setBusinesses(userBusinesses)
      setFilteredBusinesses(userBusinesses)
    }
    
    setLoading(false)
  }, [user, router])

  useEffect(() => {
    let filtered = businesses

    if (searchTerm) {
      filtered = filtered.filter(business =>
        business.namaUsaha.toLowerCase().includes(searchTerm.toLowerCase()) ||
        business.namaKomersil.toLowerCase().includes(searchTerm.toLowerCase()) ||
        business.alamat.toLowerCase().includes(searchTerm.toLowerCase())
      )
    }

    if (filterKecamatan) {
      filtered = filtered.filter(business => business.kecamatan === filterKecamatan)
    }

    if (filterKelurahan) {
      filtered = filtered.filter(business => business.kelurahan === filterKelurahan)
    }

    setFilteredBusinesses(filtered)
  }, [businesses, searchTerm, filterKecamatan, filterKelurahan])

  // Default center for Pematang Siantar
  const defaultCenter: [number, number] = [2.9595, 99.0687]
  const defaultZoom = 13

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

  if (!user || loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="loading-spinner"></div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white shadow-sm border-b border-gray-100">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center py-4">
            <div className="flex items-center space-x-3">
              <Link
                href="/dashboard"
                className="p-2 text-gray-400 hover:text-gray-600"
              >
                <ArrowLeft className="h-6 w-6" />
              </Link>
              <div className="h-10 w-10 flex items-center justify-center rounded-full gradient-orange text-white">
                <MapPin className="h-6 w-6" />
              </div>
              <div>
                <h1 className="text-xl font-bold text-gray-900">Peta Interaktif</h1>
                <p className="text-sm text-gray-600">Lokasi Usaha di Pematang Siantar</p>
              </div>
            </div>
          </div>
        </div>
      </header>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="grid lg:grid-cols-4 gap-8">
          {/* Sidebar Filters */}
          <div className="lg:col-span-1 space-y-6">
            {/* Search */}
            <div className="card">
              <div className="flex items-center mb-4">
                <Search className="h-5 w-5 text-orange-600 mr-2" />
                <h3 className="text-lg font-semibold text-gray-900">Pencarian</h3>
              </div>
              <input
                type="text"
                className="input-field"
                placeholder="Cari nama usaha..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
              />
            </div>

            {/* Filters */}
            <div className="card">
              <div className="flex items-center mb-4">
                <Filter className="h-5 w-5 text-orange-600 mr-2" />
                <h3 className="text-lg font-semibold text-gray-900">Filter Lokasi</h3>
              </div>
              
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Kecamatan
                  </label>
                  <select
                    className="input-field"
                    value={filterKecamatan}
                    onChange={(e) => setFilterKecamatan(e.target.value)}
                  >
                    <option value="">Semua Kecamatan</option>
                    {KECAMATAN_OPTIONS.map((kec) => (
                      <option key={kec} value={kec}>{kec}</option>
                    ))}
                  </select>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Kelurahan
                  </label>
                  <select
                    className="input-field"
                    value={filterKelurahan}
                    onChange={(e) => setFilterKelurahan(e.target.value)}
                  >
                    <option value="">Semua Kelurahan</option>
                    {KELURAHAN_OPTIONS.map((kel) => (
                      <option key={kel} value={kel}>{kel}</option>
                    ))}
                  </select>
                </div>

                <button
                  onClick={() => {
                    setSearchTerm('')
                    setFilterKecamatan('')
                    setFilterKelurahan('')
                  }}
                  className="btn-secondary w-full"
                >
                  Reset Filter
                </button>
              </div>
            </div>

            {/* Business List */}
            <div className="card">
              <div className="flex items-center mb-4">
                <Building2 className="h-5 w-5 text-orange-600 mr-2" />
                <h3 className="text-lg font-semibold text-gray-900">
                  Daftar Usaha ({filteredBusinesses.length})
                </h3>
              </div>
              
              <div className="space-y-3 max-h-96 overflow-y-auto custom-scrollbar">
                {filteredBusinesses.length === 0 ? (
                  <p className="text-gray-500 text-sm text-center py-4">
                    Tidak ada usaha ditemukan
                  </p>
                ) : (
                  filteredBusinesses.map((business) => (
                    <div
                      key={business.id}
                      className={`p-3 border rounded-lg cursor-pointer transition-colors ${
                        selectedBusiness?.id === business.id
                          ? 'border-orange-500 bg-orange-50'
                          : 'border-gray-200 hover:border-gray-300'
                      }`}
                      onClick={() => setSelectedBusiness(business)}
                    >
                      <h4 className="font-medium text-gray-900 text-sm">
                        {business.namaUsaha}
                      </h4>
                      <p className="text-xs text-gray-600 mt-1">
                        {business.kecamatan}, {business.kelurahan}
                      </p>
                      <div className="flex items-center text-xs text-gray-500 mt-1">
                        <MapPin className="h-3 w-3 mr-1" />
                        <span>{business.latitude.toFixed(4)}, {business.longitude.toFixed(4)}</span>
                      </div>
                    </div>
                  ))
                )}
              </div>
            </div>
          </div>

          {/* Map */}
          <div className="lg:col-span-3">
            <div className="card p-0 overflow-hidden">
              <div style={{ height: '600px', width: '100%' }}>
                {typeof window !== 'undefined' && (
                  <MapContainer
                    center={defaultCenter}
                    zoom={defaultZoom}
                    style={{ height: '100%', width: '100%' }}
                    className="rounded-lg"
                  >
                    <TileLayer
                      attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
                      url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
                    />
                    
                    {filteredBusinesses.map((business) => (
                      <Marker
                        key={business.id}
                        position={[business.latitude, business.longitude]}
                        icon={createCustomIcon()}
                      >
                        <Popup className="custom-popup">
                          <div className="p-2 min-w-64">
                            <h3 className="font-bold text-gray-900 mb-2">
                              {business.namaUsaha}
                            </h3>
                            <p className="text-sm text-gray-700 mb-2">
                              {business.namaKomersil}
                            </p>
                            
                            <div className="space-y-2 text-sm">
                              <div className="flex items-start">
                                <MapPin className="h-4 w-4 text-gray-500 mr-2 mt-0.5 flex-shrink-0" />
                                <span className="text-gray-700">{business.alamat}</span>
                              </div>
                              
                              <div className="flex items-center">
                                <Phone className="h-4 w-4 text-gray-500 mr-2 flex-shrink-0" />
                                <span className="text-gray-700">{business.telepon}</span>
                              </div>
                              
                              <div className="flex items-center">
                                <Mail className="h-4 w-4 text-gray-500 mr-2 flex-shrink-0" />
                                <span className="text-gray-700">{business.email}</span>
                              </div>
                              
                              <div className="flex items-center">
                                <Calendar className="h-4 w-4 text-gray-500 mr-2 flex-shrink-0" />
                                <span className="text-gray-700">Berdiri {business.tahunBerdiri}</span>
                              </div>
                            </div>

                            <div className="flex flex-wrap gap-1 mt-3">
                              <span className="px-2 py-1 bg-orange-100 text-orange-800 rounded text-xs">
                                {business.kecamatan}
                              </span>
                              <span className="px-2 py-1 bg-blue-100 text-blue-800 rounded text-xs">
                                {business.kelurahan}
                              </span>
                              <span className="px-2 py-1 bg-gray-100 text-gray-800 rounded text-xs">
                                {business.jaringanUsaha}
                              </span>
                            </div>

                            <p className="text-xs text-gray-600 mt-3 line-clamp-3">
                              {business.deskripsiKegiatan}
                            </p>
                          </div>
                        </Popup>
                      </Marker>
                    ))}
                  </MapContainer>
                )}
              </div>
            </div>

            {/* Map Info */}
            <div className="mt-4 grid md:grid-cols-3 gap-4">
              <div className="card text-center">
                <div className="text-2xl font-bold text-orange-600 mb-1">
                  {filteredBusinesses.length}
                </div>
                <div className="text-sm text-gray-600">Usaha Ditampilkan</div>
              </div>
              
              <div className="card text-center">
                <div className="text-2xl font-bold text-blue-600 mb-1">
                  {new Set(filteredBusinesses.map(b => b.kecamatan)).size}
                </div>
                <div className="text-sm text-gray-600">Kecamatan</div>
              </div>
              
              <div className="card text-center">
                <div className="text-2xl font-bold text-green-600 mb-1">
                  {new Set(filteredBusinesses.map(b => b.kelurahan)).size}
                </div>
                <div className="text-sm text-gray-600">Kelurahan</div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
