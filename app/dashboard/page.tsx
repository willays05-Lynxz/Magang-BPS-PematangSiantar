'use client'

import { useState, useEffect } from 'react'
import { useAuth } from '@/lib/auth-context'
import { useRouter, useSearchParams } from 'next/navigation'
import Link from 'next/link'
import { 
  Building2, 
  Plus, 
  LogOut, 
  Users, 
  MapPin, 
  BarChart3,
  AlertCircle,
  Filter,
  Search,
  Eye,
  Edit,
  Trash2
} from 'lucide-react'
import { Business, KECAMATAN_OPTIONS, KELURAHAN_OPTIONS } from '@/lib/types'

export default function DashboardPage() {
  const { user, logout } = useAuth()
  const router = useRouter()
  const searchParams = useSearchParams()
  const [businesses, setBusinesses] = useState<Business[]>([])
  const [filteredBusinesses, setFilteredBusinesses] = useState<Business[]>([])
  const [searchTerm, setSearchTerm] = useState('')
  const [filterKecamatan, setFilterKecamatan] = useState('')
  const [filterKelurahan, setFilterKelurahan] = useState('')
  const [showSuccess, setShowSuccess] = useState(false)

  useEffect(() => {
    if (!user) {
      router.push('/login')
      return
    }

    // Check for success message
    if (searchParams.get('success')) {
      setShowSuccess(true)
      setTimeout(() => setShowSuccess(false), 5000)
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
  }, [user, router, searchParams])

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

  const handleLogout = () => {
    logout()
    router.push('/')
  }

  const deleteBusiness = (businessId: string) => {
    if (confirm('Apakah Anda yakin ingin menghapus usaha ini?')) {
      const storedBusinesses = JSON.parse(localStorage.getItem('businesses') || '[]')
      const updatedBusinesses = storedBusinesses.filter((b: Business) => b.id !== businessId)
      localStorage.setItem('businesses', JSON.stringify(updatedBusinesses))
      
      setBusinesses(updatedBusinesses)
      setFilteredBusinesses(updatedBusinesses.filter((b: Business) => 
        user?.role === 'admin' || b.userId === user?.id
      ))
    }
  }

  const getStats = () => {
    const kecamatanStats = KECAMATAN_OPTIONS.map(kec => ({
      name: kec,
      count: businesses.filter(b => b.kecamatan === kec).length
    }))

    const kelurahanStats = KELURAHAN_OPTIONS.map(kel => ({
      name: kel,
      count: businesses.filter(b => b.kelurahan === kel).length
    }))

    return {
      total: businesses.length,
      kecamatanStats,
      kelurahanStats
    }
  }

  const stats = getStats()

  if (!user) {
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
              <div className="h-10 w-10 flex items-center justify-center rounded-full gradient-orange text-white">
                <MapPin className="h-6 w-6" />
              </div>
              <div>
                <h1 className="text-xl font-bold text-gray-900">
                  {user.role === 'admin' ? 'Admin Dashboard' : 'Dashboard Petugas BPS'}
                </h1>
                <p className="text-sm text-gray-600">
                  Selamat datang, {user.name}
                </p>
              </div>
            </div>
            <div className="flex items-center space-x-4">
              {user.role === 'admin' && (
                <>
                  <Link
                    href="/dashboard/analytics"
                    className="flex items-center space-x-2 px-4 py-2 text-gray-600 hover:text-gray-800"
                  >
                    <BarChart3 className="h-5 w-5" />
                    <span>Analytics</span>
                  </Link>
                  <Link
                    href="/dashboard/map"
                    className="flex items-center space-x-2 px-4 py-2 text-gray-600 hover:text-gray-800"
                  >
                    <MapPin className="h-5 w-5" />
                    <span>Peta</span>
                  </Link>
                </>
              )}
              <Link
                href="/daftar-usaha"
                className="flex items-center space-x-2 px-4 py-2 bg-orange-600 text-white rounded-lg hover:bg-orange-700"
              >
                <Plus className="h-5 w-5" />
                <span>Daftar Usaha</span>
              </Link>
              <button
                onClick={handleLogout}
                className="flex items-center space-x-2 px-4 py-2 text-gray-600 hover:text-gray-800"
              >
                <LogOut className="h-5 w-5" />
                <span>Keluar</span>
              </button>
            </div>
          </div>
        </div>
      </header>

      {/* Success Message */}
      {showSuccess && (
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pt-4">
          <div className="bg-green-50 border border-green-200 text-green-800 px-4 py-3 rounded-lg">
            ✓ Usaha berhasil didaftarkan!
          </div>
        </div>
      )}

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Stats Cards */}
        <div className="grid md:grid-cols-4 gap-6 mb-8">
          <div className="card">
            <div className="flex items-center">
              <div className="p-3 rounded-full bg-orange-100 text-orange-600">
                <Building2 className="h-6 w-6" />
              </div>
              <div className="ml-4">
                <p className="text-sm text-gray-600">Total Usaha</p>
                <p className="text-2xl font-bold text-gray-900">{stats.total}</p>
              </div>
            </div>
          </div>

          <div className="card">
            <div className="flex items-center">
              <div className="p-3 rounded-full bg-blue-100 text-blue-600">
                <Users className="h-6 w-6" />
              </div>
              <div className="ml-4">
                <p className="text-sm text-gray-600">Kecamatan Aktif</p>
                <p className="text-2xl font-bold text-gray-900">
                  {stats.kecamatanStats.filter(k => k.count > 0).length}
                </p>
              </div>
            </div>
          </div>

          <div className="card">
            <div className="flex items-center">
              <div className="p-3 rounded-full bg-green-100 text-green-600">
                <MapPin className="h-6 w-6" />
              </div>
              <div className="ml-4">
                <p className="text-sm text-gray-600">Kelurahan Aktif</p>
                <p className="text-2xl font-bold text-gray-900">
                  {stats.kelurahanStats.filter(k => k.count > 0).length}
                </p>
              </div>
            </div>
          </div>

          <div className="card">
            <div className="flex items-center">
              <div className="p-3 rounded-full bg-red-100 text-red-600">
                <AlertCircle className="h-6 w-6" />
              </div>
              <div className="ml-4">
                <p className="text-sm text-gray-600">
                  {user.role === 'admin' ? 'Total Pengguna' : 'Usaha yang Didaftarkan'}
                </p>
                <p className="text-2xl font-bold text-gray-900">
                  {user.role === 'admin' ?
                    JSON.parse(localStorage.getItem('users') || '[]').length + 1 :
                    businesses.filter(b => b.userId === user.id).length
                  }
                </p>
              </div>
            </div>
          </div>
        </div>

        {/* Filters */}
        <div className="card mb-8">
          <div className="flex items-center mb-4">
            <Filter className="h-5 w-5 text-orange-600 mr-2" />
            <h2 className="text-lg font-semibold text-gray-900">Filter & Pencarian</h2>
          </div>
          
          <div className="grid md:grid-cols-4 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Cari Usaha
              </label>
              <div className="relative">
                <Search className="absolute left-3 top-2.5 h-5 w-5 text-gray-400" />
                <input
                  type="text"
                  className="pl-10 input-field"
                  placeholder="Nama usaha, alamat..."
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                />
              </div>
            </div>

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

            <div className="flex items-end">
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
        </div>

        {/* Business List */}
        <div className="card">
          <div className="flex items-center justify-between mb-6">
            <h2 className="text-lg font-semibold text-gray-900">
              Daftar Usaha ({filteredBusinesses.length})
            </h2>
          </div>

          {filteredBusinesses.length === 0 ? (
            <div className="text-center py-12">
              <Building2 className="h-12 w-12 text-gray-400 mx-auto mb-4" />
              <h3 className="text-lg font-medium text-gray-900 mb-2">
                {businesses.length === 0 ? 'Belum ada usaha yang didaftarkan' : 'Tidak ada usaha ditemukan'}
              </h3>
              <p className="text-gray-600 mb-4">
                {businesses.length === 0
                  ? 'Mulai dengan mendaftarkan usaha pertama sebagai petugas BPS'
                  : 'Coba ubah kriteria pencarian atau filter'
                }
              </p>
              {businesses.length === 0 && (
                <Link href="/daftar-usaha" className="btn-primary">
                  <Plus className="h-5 w-5 mr-2" />
                  Daftarkan Usaha Pertama
                </Link>
              )}
            </div>
          ) : (
            <div className="space-y-4">
              {filteredBusinesses.map((business) => (
                <div key={business.id} className="border border-gray-200 rounded-lg p-4 hover:shadow-md transition-shadow">
                  <div className="flex justify-between items-start">
                    <div className="flex-1">
                      <div className="flex items-start justify-between">
                        <div>
                          <h3 className="text-lg font-semibold text-gray-900 mb-1">
                            {business.namaUsaha}
                          </h3>
                          <p className="text-gray-600 mb-2">{business.namaKomersil}</p>
                          <div className="flex items-center text-sm text-gray-500 mb-2">
                            <MapPin className="h-4 w-4 mr-1" />
                            <span>{business.alamat}</span>
                          </div>
                          <div className="flex flex-wrap gap-2 text-xs">
                            <span className="px-2 py-1 bg-orange-100 text-orange-800 rounded">
                              {business.kecamatan}
                            </span>
                            <span className="px-2 py-1 bg-blue-100 text-blue-800 rounded">
                              {business.kelurahan}
                            </span>
                            <span className="px-2 py-1 bg-gray-100 text-gray-800 rounded">
                              {business.jaringanUsaha}
                            </span>
                            <span className="px-2 py-1 bg-green-100 text-green-800 rounded">
                              {business.tahunBerdiri}
                            </span>
                          </div>
                        </div>
                        <div className="flex space-x-2 ml-4">
                          <button className="p-2 text-gray-400 hover:text-blue-600">
                            <Eye className="h-4 w-4" />
                          </button>
                          {(user.role === 'admin' || business.userId === user.id) && (
                            <>
                              <button className="p-2 text-gray-400 hover:text-green-600">
                                <Edit className="h-4 w-4" />
                              </button>
                              <button 
                                onClick={() => deleteBusiness(business.id)}
                                className="p-2 text-gray-400 hover:text-red-600"
                              >
                                <Trash2 className="h-4 w-4" />
                              </button>
                            </>
                          )}
                        </div>
                      </div>
                      <p className="text-sm text-gray-600 mt-2 line-clamp-2">
                        {business.deskripsiKegiatan}
                      </p>
                      <div className="flex items-center justify-between mt-3 text-xs text-gray-500">
                        <span>SLS: {business.kodeSLS}</span>
                        <span>📱 {business.telepon}</span>
                        <span>📧 {business.email}</span>
                        <span>📍 {business.latitude.toFixed(4)}, {business.longitude.toFixed(4)}</span>
                      </div>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  )
}
