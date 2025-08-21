'use client'

import { useState, useEffect } from 'react'
import { useAuth } from '@/lib/auth-context'
import { useRouter } from 'next/navigation'
import Link from 'next/link'
import { 
  ArrowLeft,
  BarChart3,
  TrendingUp,
  AlertTriangle,
  CheckCircle,
  XCircle,
  MapPin
} from 'lucide-react'
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  BarElement,
  Title,
  Tooltip,
  Legend,
  ArcElement,
  PointElement,
  LineElement,
} from 'chart.js'
import { Bar, Pie, Line } from 'react-chartjs-2'
import { Business, KECAMATAN_OPTIONS, KELURAHAN_OPTIONS } from '@/lib/types'

ChartJS.register(
  CategoryScale,
  LinearScale,
  BarElement,
  Title,
  Tooltip,
  Legend,
  ArcElement,
  PointElement,
  LineElement
)

export default function AnalyticsPage() {
  const { user } = useAuth()
  const router = useRouter()
  const [businesses, setBusinesses] = useState<Business[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    if (!user) {
      router.push('/login')
      return
    }

    if (user.role !== 'admin') {
      router.push('/dashboard')
      return
    }

    // Load businesses from localStorage
    const storedBusinesses = JSON.parse(localStorage.getItem('businesses') || '[]')
    setBusinesses(storedBusinesses)
    setLoading(false)
  }, [user, router])

  // Data quality checks
  const getDataQuality = () => {
    const issues = []
    const duplicates = []
    const missing = []

    businesses.forEach((business, index) => {
      // Check for missing data
      const requiredFields = ['namaUsaha', 'alamat', 'kecamatan', 'kelurahan', 'telepon', 'email']
      const missingFields = requiredFields.filter(field => !business[field as keyof Business])
      
      if (missingFields.length > 0) {
        missing.push({
          business: business.namaUsaha,
          fields: missingFields
        })
      }

      // Check for duplicates (by name and address)
      const duplicate = businesses.find((b, i) => 
        i !== index && 
        b.namaUsaha.toLowerCase() === business.namaUsaha.toLowerCase() &&
        b.alamat.toLowerCase() === business.alamat.toLowerCase()
      )
      
      if (duplicate && !duplicates.find(d => d.id === business.id)) {
        duplicates.push({
          id: business.id,
          name: business.namaUsaha,
          address: business.alamat
        })
      }
    })

    return { missing, duplicates, total: businesses.length }
  }

  // Statistics by Kecamatan
  const getKecamatanStats = () => {
    const stats = KECAMATAN_OPTIONS.map(kec => ({
      name: kec,
      count: businesses.filter(b => b.kecamatan === kec).length
    }))

    return {
      labels: stats.map(s => s.name),
      datasets: [{
        label: 'Jumlah Usaha',
        data: stats.map(s => s.count),
        backgroundColor: [
          '#FF6B35', '#FFA366', '#FF8659', '#E55A2B',
          '#FF9473', '#FFB899', '#CC5529', '#B84A22',
        ],
        borderColor: '#FF6B35',
        borderWidth: 1
      }]
    }
  }

  // Statistics by Kelurahan (top 8)
  const getKelurahanStats = () => {
    const stats = KELURAHAN_OPTIONS.map(kel => ({
      name: kel,
      count: businesses.filter(b => b.kelurahan === kel).length
    })).sort((a, b) => b.count - a.count).slice(0, 8)

    return {
      labels: stats.map(s => s.name),
      datasets: [{
        label: 'Jumlah Usaha',
        data: stats.map(s => s.count),
        backgroundColor: 'rgba(255, 107, 53, 0.7)',
        borderColor: '#FF6B35',
        borderWidth: 2
      }]
    }
  }

  // Business network distribution
  const getNetworkStats = () => {
    const tunggal = businesses.filter(b => b.jaringanUsaha === 'Tunggal').length
    const cabang = businesses.filter(b => b.jaringanUsaha === 'Cabang').length

    return {
      labels: ['Usaha Tunggal', 'Usaha Cabang'],
      datasets: [{
        data: [tunggal, cabang],
        backgroundColor: ['#FF6B35', '#FFA366'],
        borderColor: ['#E55A2B', '#FF8659'],
        borderWidth: 2
      }]
    }
  }

  // Business growth over years
  const getGrowthStats = () => {
    const currentYear = new Date().getFullYear()
    const years = Array.from({length: 10}, (_, i) => currentYear - 9 + i)
    
    const yearStats = years.map(year => ({
      year,
      count: businesses.filter(b => b.tahunBerdiri === year).length
    }))

    return {
      labels: yearStats.map(s => s.year.toString()),
      datasets: [{
        label: 'Usaha Berdiri',
        data: yearStats.map(s => s.count),
        borderColor: '#FF6B35',
        backgroundColor: 'rgba(255, 107, 53, 0.1)',
        tension: 0.4,
        fill: true
      }]
    }
  }

  const dataQuality = getDataQuality()

  const chartOptions = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: {
        position: 'top' as const,
      },
      title: {
        display: false,
      },
    },
    scales: {
      y: {
        beginAtZero: true,
        ticks: {
          stepSize: 1
        }
      }
    }
  }

  const pieOptions = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: {
        position: 'bottom' as const,
      },
    },
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
                <BarChart3 className="h-6 w-6" />
              </div>
              <div>
                <h1 className="text-xl font-bold text-gray-900">Analytics Dashboard</h1>
                <p className="text-sm text-gray-600">Statistik dan Monitoring Usaha</p>
              </div>
            </div>
          </div>
        </div>
      </header>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Summary Cards */}
        <div className="grid md:grid-cols-4 gap-6 mb-8">
          <div className="card">
            <div className="flex items-center">
              <div className="p-3 rounded-full bg-orange-100 text-orange-600">
                <BarChart3 className="h-6 w-6" />
              </div>
              <div className="ml-4">
                <p className="text-sm text-gray-600">Total Usaha</p>
                <p className="text-2xl font-bold text-gray-900">{businesses.length}</p>
              </div>
            </div>
          </div>

          <div className="card">
            <div className="flex items-center">
              <div className="p-3 rounded-full bg-green-100 text-green-600">
                <CheckCircle className="h-6 w-6" />
              </div>
              <div className="ml-4">
                <p className="text-sm text-gray-600">Data Lengkap</p>
                <p className="text-2xl font-bold text-gray-900">
                  {businesses.length - dataQuality.missing.length}
                </p>
              </div>
            </div>
          </div>

          <div className="card">
            <div className="flex items-center">
              <div className="p-3 rounded-full bg-yellow-100 text-yellow-600">
                <AlertTriangle className="h-6 w-6" />
              </div>
              <div className="ml-4">
                <p className="text-sm text-gray-600">Data Tidak Lengkap</p>
                <p className="text-2xl font-bold text-gray-900">{dataQuality.missing.length}</p>
              </div>
            </div>
          </div>

          <div className="card">
            <div className="flex items-center">
              <div className="p-3 rounded-full bg-red-100 text-red-600">
                <XCircle className="h-6 w-6" />
              </div>
              <div className="ml-4">
                <p className="text-sm text-gray-600">Duplikat</p>
                <p className="text-2xl font-bold text-gray-900">{dataQuality.duplicates.length}</p>
              </div>
            </div>
          </div>
        </div>

        {/* Charts Grid */}
        <div className="grid lg:grid-cols-2 gap-8 mb-8">
          {/* Kecamatan Chart */}
          <div className="card">
            <h3 className="text-lg font-semibold text-gray-900 mb-4">
              Distribusi Usaha per Kecamatan
            </h3>
            <div className="chart-container">
              <Bar data={getKecamatanStats()} options={chartOptions} />
            </div>
          </div>

          {/* Kelurahan Chart */}
          <div className="card">
            <h3 className="text-lg font-semibold text-gray-900 mb-4">
              Top 8 Kelurahan dengan Usaha Terbanyak
            </h3>
            <div className="chart-container">
              <Bar data={getKelurahanStats()} options={chartOptions} />
            </div>
          </div>

          {/* Network Distribution */}
          <div className="card">
            <h3 className="text-lg font-semibold text-gray-900 mb-4">
              Distribusi Jenis Jaringan Usaha
            </h3>
            <div className="chart-container">
              <Pie data={getNetworkStats()} options={pieOptions} />
            </div>
          </div>

          {/* Growth Trend */}
          <div className="card">
            <h3 className="text-lg font-semibold text-gray-900 mb-4">
              Tren Pendirian Usaha (10 Tahun Terakhir)
            </h3>
            <div className="chart-container">
              <Line data={getGrowthStats()} options={chartOptions} />
            </div>
          </div>
        </div>

        {/* Data Quality Issues */}
        {(dataQuality.missing.length > 0 || dataQuality.duplicates.length > 0) && (
          <div className="grid lg:grid-cols-2 gap-8">
            {/* Missing Data */}
            {dataQuality.missing.length > 0 && (
              <div className="card">
                <div className="flex items-center mb-4">
                  <AlertTriangle className="h-5 w-5 text-yellow-600 mr-2" />
                  <h3 className="text-lg font-semibold text-gray-900">
                    Data Tidak Lengkap ({dataQuality.missing.length})
                  </h3>
                </div>
                <div className="space-y-3 max-h-60 overflow-y-auto custom-scrollbar">
                  {dataQuality.missing.map((item, index) => (
                    <div key={index} className="border border-yellow-200 rounded-lg p-3 bg-yellow-50">
                      <p className="font-medium text-gray-900">{item.business}</p>
                      <p className="text-sm text-gray-600">
                        Field kosong: {item.fields.join(', ')}
                      </p>
                    </div>
                  ))}
                </div>
              </div>
            )}

            {/* Duplicate Data */}
            {dataQuality.duplicates.length > 0 && (
              <div className="card">
                <div className="flex items-center mb-4">
                  <XCircle className="h-5 w-5 text-red-600 mr-2" />
                  <h3 className="text-lg font-semibold text-gray-900">
                    Data Duplikat ({dataQuality.duplicates.length})
                  </h3>
                </div>
                <div className="space-y-3 max-h-60 overflow-y-auto custom-scrollbar">
                  {dataQuality.duplicates.map((item, index) => (
                    <div key={index} className="border border-red-200 rounded-lg p-3 bg-red-50">
                      <p className="font-medium text-gray-900">{item.name}</p>
                      <p className="text-sm text-gray-600">{item.address}</p>
                    </div>
                  ))}
                </div>
              </div>
            )}
          </div>
        )}

        {/* No Issues Message */}
        {dataQuality.missing.length === 0 && dataQuality.duplicates.length === 0 && businesses.length > 0 && (
          <div className="card text-center">
            <CheckCircle className="h-12 w-12 text-green-600 mx-auto mb-4" />
            <h3 className="text-lg font-medium text-gray-900 mb-2">
              Data Quality Excellent!
            </h3>
            <p className="text-gray-600">
              Semua data usaha lengkap dan tidak ada duplikat yang terdeteksi.
            </p>
          </div>
        )}
      </div>
    </div>
  )
}
