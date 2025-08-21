# Sistem Geotagging Usaha di PematangSiantar

Sistem informasi untuk pemetaan dan pendataan usaha-usaha di Kota PematangSiantar menggunakan teknologi geotagging.

## 🚀 Panduan Instalasi

### Prasyarat

Pastikan telah menginstall:
- **Node.js** (versi 18.0 atau lebih baru)
- **npm** atau **yarn**
- **Git**

### 1. Clone Repository

```bash
# Clone repository dari GitHub
git clone https://github.com/[username]/magang-bps-pematangsiantar.git

# Masuk ke direktori project
cd magang-bps-pematangsiantar
```

### 2. Install Dependencies

```bash
# Menggunakan npm
npm install

# Atau menggunakan yarn
yarn install
```

### 3. Menjalankan Development Server

```bash
# Menjalankan server development
npm run dev

# Atau menggunakan yarn
yarn dev
```

Buka browser dan akses [http://localhost:3000](http://localhost:3000) untuk melihat aplikasi.

### 4. Build untuk Production

```bash
# Build aplikasi untuk production
npm run build

# Menjalankan aplikasi production
npm start
```

## 📁 Struktur Project

```
magang-bps-pematangsiantar/
├── app/                    # App router Next.js 14
│   ├── daftar-usaha/      # Halaman pendaftaran usaha
│   ├── dashboard/         # Dashboard admin
│   ├── login/             # Halaman login
│   └── register/          # Halaman registrasi
├── lib/                   # Utilities dan context
├── components/            # Komponen React
└── public/               # Asset statis
```

## 🔧 Git Commands - Panduan Kerja

### Setup Awal

```bash
# Konfigurasi git (jika belum)
git config --global user.name "Nama Anda"
git config --global user.email "email@anda.com"

# Melihat status repository
git status
```

### Workflow Development

#### 1. Membuat Branch Baru

```bash
# Membuat branch baru untuk fitur
git checkout -b nama-fitur

# Atau menggunakan git switch (cara modern)
git switch -c nama-fitur
```

#### 2. Menambah dan Commit Perubahan

```bash
# Melihat file yang berubah
git status

# Menambahkan file ke staging area
git add .                  # Menambah semua file
git add nama-file.js       # Menambah file spesifik

# Commit perubahan
git commit -m "feat: menambahkan fitur pemetaan usaha"
```

#### 3. Push ke Repository

```bash
# Push branch pertama kali
git push -u origin nama-fitur

# Push selanjutnya
git push
```

#### 4. Pull dari Repository

```bash
# Pull perubahan terbaru dari main branch
git pull origin main

# Pull perubahan dari branch saat ini
git pull
```

#### 5. Merge dan Update

```bash
# Pindah ke main branch
git checkout main

# Pull perubahan terbaru
git pull origin main

# Merge branch fitur ke main
git merge nama-fitur

# Push hasil merge
git push origin main

# Hapus branch yang sudah tidak digunakan
git branch -d nama-fitur
```

### Commands Penting Lainnya

```bash
# Melihat history commit
git log --oneline

# Melihat perbedaan file
git diff

# Membatalkan perubahan yang belum di-commit
git checkout -- nama-file.js

# Membatalkan commit terakhir (soft reset)
git reset --soft HEAD~1

# Melihat branch yang ada
git branch -a

# Pindah branch
git checkout nama-branch
# atau
git switch nama-branch
```

## 🌟 Fitur Utama

- **Pemetaan Interaktif**: Menggunakan Leaflet untuk visualisasi lokasi usaha
- **Dashboard Analytics**: Statistik dan grafik menggunakan Chart.js
- **Form Validation**: Validasi form menggunakan React Hook Form + Zod
- **Responsive Design**: UI yang responsif menggunakan Tailwind CSS
- **Authentication**: Sistem login dan registrasi pengguna

## 🛠️ Teknologi yang Digunakan

- **Framework**: Next.js 14 (App Router)
- **Frontend**: React 18, TypeScript
- **Styling**: Tailwind CSS
- **Maps**: Leaflet, React Leaflet
- **Charts**: Chart.js, React ChartJS 2
- **Forms**: React Hook Form, Zod
- **Icons**: Lucide React

## 📱 Halaman Aplikasi

1. **Landing Page** (`/`) - Halaman utama
2. **Login** (`/login`) - Autentikasi pengguna
3. **Register** (`/register`) - Pendaftaran pengguna baru
4. **Dashboard** (`/dashboard`) - Panel admin
5. **Analytics** (`/dashboard/analytics`) - Statistik dan laporan
6. **Map** (`/dashboard/map`) - Peta interaktif
7. **Daftar Usaha** (`/daftar-usaha`) - Form pendaftaran usaha

## 🤝 Kontribusi

1. Fork repository ini
2. Buat branch fitur (`git checkout -b fitur/AmazingFeature`)
3. Commit perubahan (`git commit -m 'feat: Add some AmazingFeature'`)
4. Push ke branch (`git push origin fitur/AmazingFeature`)
5. Buat Pull Request

## 📄 Lisensi

Project ini menggunakan lisensi MIT - lihat file [LICENSE](LICENSE) untuk detail.

## 📞 Kontak

Untuk pertanyaan atau dukungan, silakan hubungi tim pengembang BPS PematangSiantar.
