# 🚀 Setup Database di Laragon

Panduan lengkap untuk setup database PostgreSQL di environment Laragon.

## 📋 Prerequisites

✅ **Laragon sudah terinstall**  
✅ **PostgreSQL sudah terinstall di Laragon**  
✅ **Git sudah terinstall**

## 🔧 Langkah Setup

### 1. **Start PostgreSQL di Laragon**

1. Buka Laragon
2. Klik **Start All** atau start PostgreSQL service
3. Pastikan PostgreSQL berjalan (icon hijau)

### 2. **Copy Environment Configuration**

```bash
# Copy konfigurasi Laragon
copy database\.env.laragon .env
```

Atau manual copy isi `database/.env.laragon` ke file `.env` di root project.

### 3. **Run Setup Script (Otomatis)**

**Option A: Gunakan Batch Script**
```cmd
# Jalankan script setup otomatis
database\scripts\setup-laragon.bat
```

**Option B: Manual Setup**
Jika script tidak jalan, ikuti langkah manual di bawah.

### 4. **Manual Setup (Jika Script Gagal)**

#### 4.1 Buka Command Prompt/Terminal

```cmd
# Masuk ke folder project
cd path\to\your\project

# Pastikan PostgreSQL accessible
psql --version
```

#### 4.2 Create Database

```cmd
# Connect ke PostgreSQL
psql -h localhost -U postgres -d postgres

# Create databases
CREATE DATABASE geotagging_usaha_dev;
CREATE DATABASE geotagging_usaha_test;

# Exit psql
\q
```

#### 4.3 Run Migrations

```cmd
# 1. Initial schema
psql -h localhost -U postgres -d geotagging_usaha_dev -f database/migrations/001_initial_schema.sql

# 2. Create indexes
psql -h localhost -U postgres -d geotagging_usaha_dev -f database/migrations/002_create_indexes.sql

# 3. Create triggers
psql -h localhost -U postgres -d geotagging_usaha_dev -f database/migrations/003_create_triggers.sql

# 4. Seed data
psql -h localhost -U postgres -d geotagging_usaha_dev -f database/migrations/004_seed_data.sql
```

#### 4.4 Load Functions & Views

```cmd
# Spatial functions
psql -h localhost -U postgres -d geotagging_usaha_dev -f database/functions/spatial_functions.sql

# Analytics views
psql -h localhost -U postgres -d geotagging_usaha_dev -f database/views/business_analytics.sql
```

## ✅ Verifikasi Setup

### 1. **Check Connection**

```cmd
# Test koneksi database
psql -h localhost -U postgres -d geotagging_usaha_dev -c "SELECT version();"
```

### 2. **Check Tables**

```cmd
# Lihat semua tabel
psql -h localhost -U postgres -d geotagging_usaha_dev -c "\dt"
```

Expected output:
```
                List of relations
 Schema |            Name             | Type  |  Owner
--------+-----------------------------+-------+----------
 public | audit_logs                  | table | postgres
 public | business_categories         | table | postgres
 public | business_category_mappings  | table | postgres
 public | businesses                  | table | postgres
 public | user_sessions              | table | postgres
 public | users                      | table | postgres
```

### 3. **Check Sample Data**

```cmd
# Check users
psql -h localhost -U postgres -d geotagging_usaha_dev -c "SELECT name, email, role FROM users;"

# Check businesses
psql -h localhost -U postgres -d geotagging_usaha_dev -c "SELECT nama_usaha, kecamatan, status FROM businesses;"
```

## 🔑 Default Login Credentials

### Admin Account
- **Email:** `admin@bps-pematangsiantar.go.id`
- **Password:** `admin123`
- **Role:** admin

### User Account
- **Email:** `petugas1@bps-pematangsiantar.go.id`
- **Password:** `user123`
- **Role:** user

## 🛠️ Database Management

### **Access Database**
```cmd
# Connect ke database
psql -h localhost -U postgres -d geotagging_usaha_dev

# Useful commands
\dt          # List tables
\d+ users    # Describe table
\l           # List databases
\q           # Quit
```

### **Backup Database**
```cmd
# Create backup
pg_dump -h localhost -U postgres geotagging_usaha_dev > backup.sql

# Or use script
database\scripts\backup.sh
```

### **Restore Database**
```cmd
# Restore from backup
psql -h localhost -U postgres -d geotagging_usaha_dev < backup.sql

# Or use script
database\scripts\restore.sh
```

## 🔧 Configuration untuk Next.js

Update `next.config.js` untuk database connection:

```javascript
/** @type {import('next').NextConfig} */
const nextConfig = {
  env: {
    DATABASE_URL: process.env.DATABASE_URL || 'postgresql://postgres@localhost:5432/geotagging_usaha_dev',
  },
  // other config...
}

module.exports = nextConfig
```

## 📱 Integration dengan App

### **Database Connection dalam Next.js**

Create `lib/database.ts`:

```typescript
import { getDatabaseConfig } from '@/database/config/laragon.config'

const config = getDatabaseConfig()

// Your database connection logic here
export const connectDatabase = async () => {
  // Implementation
}
```

### **Environment Variables Check**

Pastikan file `.env` berisi:
```
DATABASE_URL=postgresql://postgres@localhost:5432/geotagging_usaha_dev
DB_HOST=localhost
DB_PORT=5432
DB_NAME=geotagging_usaha_dev
DB_USER=postgres
DB_PASSWORD=
```

## ❗ Troubleshooting

### **Error: psql command not found**
```cmd
# Add PostgreSQL to PATH
set PATH=C:\laragon\bin\postgresql\postgresql-13.12-1-windows-x64\bin;%PATH%
```

### **Error: password authentication failed**
Laragon PostgreSQL biasanya tidak menggunakan password. Pastikan:
- Password kosong di config
- Atau set password di PostgreSQL

### **Error: database tidak exist**
```cmd
# Manually create database
psql -h localhost -U postgres -c "CREATE DATABASE geotagging_usaha_dev;"
```

### **Error: permission denied**
```cmd
# Grant permissions
psql -h localhost -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE geotagging_usaha_dev TO postgres;"
```

## 🎯 Next Steps

Setelah database setup berhasil:

1. ✅ **Test Next.js connection** - Update aplikasi untuk connect ke database
2. ✅ **Test CRUD operations** - Pastikan semua operasi database berjalan
3. ✅ **Test authentication** - Login dengan credentials default
4. ✅ **Test geotagging** - Coba fitur peta dan koordinat

## 📞 Support

Jika ada masalah:
1. Check Laragon logs
2. Check PostgreSQL service status
3. Verify file permissions
4. Check error messages di terminal

Database siap digunakan untuk development! 🎉
