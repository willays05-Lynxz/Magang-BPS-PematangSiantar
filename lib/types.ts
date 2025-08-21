export interface Business {
  id: string
  namaUsaha: string
  namaKomersil: string
  alamat: string
  kecamatan: string
  kelurahan: string
  kodeSLS: string
  telepon: string
  email: string
  tahunBerdiri: number
  deskripsiKegiatan: string
  jaringanUsaha: 'Tunggal' | 'Cabang'
  latitude: number
  longitude: number
  userId: string
  createdAt: string
}

export interface User {
  id: string
  email: string
  name: string
  role: 'admin' | 'user'
}

export const KECAMATAN_OPTIONS = [
  'Siantar Barat',
  'Siantar Timur', 
  'Siantar Utara',
  'Siantar Selatan',
  'Siantar Marihat',
  'Siantar Marimbun',
  'Siantar Martoba',
  'Siantar Sitalasari'
]

export const KELURAHAN_OPTIONS = [
  'Timbang Galung',
  'Sipispis',
  'Sukadame',
  'Toba',
  'Bah Kapul',
  'Simbolon Purba',
  'Martoba',
  'Sitalasari',
  'Marihat',
  'Marimbun',
  'Teladan',
  'Pahlawan',
  'Proklamasi',
  'Merdeka'
]
