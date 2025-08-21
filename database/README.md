# Database Repository - Sistem Geotagging Usaha Pematang Siantar

Repository lengkap untuk database sistem geotagging usaha di Pematang Siantar menggunakan PostgreSQL.

## 📁 Struktur Direktori

```
database/
├── config/                 # Konfigurasi database
│   └── database.config.ts  # Konfigurasi koneksi database
├── schemas/                # Schema definisi tabel
│   ├── users.schema.sql
│   ├── businesses.schema.sql
│   ├── business_categories.schema.sql
│   ├── audit_logs.schema.sql
│   └── user_sessions.schema.sql
├── migrations/             # File migrasi database
│   ├── 001_initial_schema.sql
│   ├── 002_create_indexes.sql
│   ├── 003_create_triggers.sql
│   └── 004_seed_data.sql
├── functions/              # Fungsi database khusus
│   └── spatial_functions.sql
├── views/                  # Views untuk analytics
│   └── business_analytics.sql
├── scripts/                # Script utilitas
│   ├── backup.sh
│   └── restore.sh
├── backups/                # Direktori backup (auto-generated)
└── README.md
```

## 🗃️ Struktur Database

### Tabel Utama

#### 1. **users**
Tabel pengguna sistem (Admin dan Petugas BPS)
- Primary Key: `id` (UUID)
- Fields: email, password_hash, name, role, is_active, dll
- Roles: 'admin', 'user'

#### 2. **businesses**
Tabel data usaha yang didaftarkan
- Primary Key: `id` (UUID)
- Foreign Key: `user_id` → users(id)
- Fields: nama_usaha, alamat, koordinat, status, dll
- Constraints: validasi koordinat, email, kode SLS
- Fields: nama_usaha, alamat, koordinat, status, deskripsi_kegiatan

#### 3. **user_sessions**
Tabel session management
- Auto cleanup expired sessions
- Fields: session_token, refresh_token, expires_at

#### 4. **audit_logs**
Tabel audit trail aktivitas sistem
- JSONB fields untuk old_values dan new_values
- IP address dan user agent tracking

## 🚀 Setup Database

### Prerequisites
- PostgreSQL 13+
- Extensions: uuid-ossp, postgis, pg_trgm, unaccent

### 1. Environment Variables
Buat file `.env` dengan konfigurasi:

```env
# Database Configuration
DB_HOST=localhost
DB_PORT=5432
DB_NAME=geotagging_usaha_dev
DB_USER=postgres
DB_PASSWORD=your_password

# Test Database
DB_NAME_TEST=geotagging_usaha_test
DB_HOST_TEST=localhost
DB_PORT_TEST=5432
DB_USER_TEST=postgres
DB_PASSWORD_TEST=your_password
```

### 2. Run Migrations
Jalankan migrasi secara berurutan:

```bash
# 1. Initial schema
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f database/migrations/001_initial_schema.sql

# 2. Indexes
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f database/migrations/002_create_indexes.sql

# 3. Triggers
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f database/migrations/003_create_triggers.sql

# 4. Seed data
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f database/migrations/004_seed_data.sql
```

### 3. Load Functions dan Views

```bash
# Spatial functions
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f database/functions/spatial_functions.sql

# Analytics views
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f database/views/business_analytics.sql
```

## 🔧 Utilitas Database

### Backup Database
```bash
# Run backup script
chmod +x database/scripts/backup.sh
./database/scripts/backup.sh
```

### Restore Database
```bash
# Run restore script (interactive)
chmod +x database/scripts/restore.sh
./database/scripts/restore.sh

# Or specify backup file directly
./database/scripts/restore.sh database/backups/backup_geotagging_usaha_dev_20240101_120000.sql.gz
```

### Maintenance Tasks

#### Clean Expired Sessions
```sql
SELECT clean_expired_sessions();
```

#### Check Database Statistics
```sql
-- Lihat summary per kecamatan
SELECT * FROM v_business_summary_by_kecamatan;

-- Lihat statistik petugas
SELECT * FROM v_petugas_statistics;

-- Lihat usaha pending verifikasi
SELECT * FROM v_businesses_pending_verification;
```

## 🗂️ Fitur Spatial

### Fungsi Geografis

#### 1. **calculate_distance()**
Menghitung jarak antara dua koordinat menggunakan formula Haversine.

```sql
SELECT calculate_distance(2.9641, 99.0687, 2.9598, 99.0734) as distance_meters;
```

#### 2. **find_businesses_in_radius()**
Mencari usaha dalam radius tertentu.

```sql
SELECT * FROM find_businesses_in_radius(2.9641, 99.0687, 1000);
```

#### 3. **detect_potential_duplicates()**
Deteksi potensi duplikasi usaha berdasarkan proximitas dan similarity.

```sql
SELECT * FROM detect_potential_duplicates(50.0);
```

## 📊 Analytics Views

### Business Analytics
- `v_business_summary_by_kecamatan`: Summary per kecamatan
- `v_business_summary_by_kelurahan`: Summary per kelurahan  
- `v_business_by_year`: Distribusi per tahun berdiri
- `v_latest_businesses`: 10 usaha terbaru
- `v_businesses_pending_verification`: Usaha pending verifikasi
- `v_petugas_statistics`: Statistik kinerja petugas
- `v_business_heatmap`: Data untuk heatmap peta

### System Analytics
- `v_audit_summary`: Summary audit log
- `v_active_sessions`: Session aktif

## 🔒 Security Features

### 1. **Audit Trail**
Semua operasi CUD (Create, Update, Delete) pada tabel utama dicatat dalam audit_logs dengan:
- Old values dan new values (JSONB)
- User ID yang melakukan aksi
- IP address dan user agent
- Timestamp aktivitas

### 2. **Data Validation**
- Email format validation
- Koordinat validation (dalam batas Pematang Siantar)
- Kode SLS format (10 digit)
- Unique constraints untuk mencegah duplikasi

### 3. **Session Management**
- Token-based authentication
- Auto cleanup expired sessions
- IP address tracking
- Session activity monitoring

## 🛠️ Default Data

### Admin User
- Email: `admin@bps-pematangsiantar.go.id`
- Password: `admin123`
- Role: admin

### Petugas User
- Email: `petugas1@bps-pematangsiantar.go.id`
- Password: `user123`
- Role: user

### Sample Data
Database sudah include data sample usaha dari berbagai kecamatan di Pematang Siantar untuk testing.

## 📝 Catatan Penting

1. **Koordinat Validation**: Sistem memvalidasi koordinat berada dalam batas Pematang Siantar (2.8°-3.1° LU, 98.9°-99.2° BT)

2. **Backup Strategy**: Script backup otomatis mengkompresi dan membersihkan backup lama (>7 hari)

3. **Performance**: Database sudah dioptimasi dengan proper indexing, termasuk spatial index untuk query berbasis lokasi

4. **Extensibility**: Struktur database mendukung pengembangan fitur seperti multi-kategori per usaha, hierarchical categories, dan audit trail yang lengkap

## 🚨 Troubleshooting

### Common Issues

1. **Extension Missing**
```sql
-- Install required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";
CREATE EXTENSION IF NOT EXISTS "unaccent";
```

2. **Permission Issues**
```sql
-- Grant necessary permissions
GRANT ALL PRIVILEGES ON DATABASE geotagging_usaha_dev TO your_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO your_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO your_user;
```

3. **Timezone Issues**
```sql
-- Set timezone
SET timezone = 'Asia/Jakarta';
```

## 📞 Support

Untuk pertanyaan atau issues terkait database, silakan buat issue di repository atau hubungi tim development.
