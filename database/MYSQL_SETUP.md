# 🚀 Setup Database MySQL di Laragon

Panduan lengkap untuk setup database MySQL di environment Laragon setelah migrasi dari PostgreSQL.

## 📋 Prerequisites

✅ **Laragon sudah terinstall**  
✅ **MySQL sudah terinstall di Laragon**  
✅ **Git sudah terinstall**

## 🔧 Langkah Setup

### 1. **Start MySQL di Laragon**

1. Buka Laragon
2. Klik **Start All** atau start MySQL service
3. Pastikan MySQL berjalan (icon hijau)

### 2. **Copy Environment Configuration**

```bash
# Copy konfigurasi MySQL untuk Laragon
copy database\.env.laragon.mysql .env
```

Atau manual copy isi `database/.env.laragon.mysql` ke file `.env` di root project.

### 3. **Run Setup Script (Otomatis)**

**Option A: Gunakan Batch Script**
```cmd
# Jalankan script setup otomatis untuk MySQL
database\scripts\setup-laragon-mysql.bat
```

**Option B: Manual Setup**
Jika script tidak jalan, ikuti langkah manual di bawah.

### 4. **Manual Setup (Jika Script Gagal)**

#### 4.1 Buka Command Prompt/Terminal

```cmd
# Masuk ke folder project
cd path\to\your\project

# Pastikan MySQL accessible
mysql --version
```

#### 4.2 Create Database

```cmd
# Connect ke MySQL
mysql -h localhost -u root -p

# Create databases
CREATE DATABASE geotagging_usaha_dev CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE geotagging_usaha_test CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

# Exit mysql
exit
```

#### 4.3 Run Migrations

```cmd
# 1. Initial schema
mysql -h localhost -u root -p geotagging_usaha_dev < database/migrations/001_initial_schema_mysql.sql

# 2. Create indexes
mysql -h localhost -u root -p geotagging_usaha_dev < database/migrations/002_create_indexes_mysql.sql

# 3. Create triggers
mysql -h localhost -u root -p geotagging_usaha_dev < database/migrations/003_create_triggers_mysql.sql

# 4. Seed data
mysql -h localhost -u root -p geotagging_usaha_dev < database/migrations/004_seed_data_mysql.sql
```

#### 4.4 Load Functions & Views

```cmd
# Spatial functions
mysql -h localhost -u root -p geotagging_usaha_dev < database/functions/spatial_functions_mysql.sql

# Analytics views
mysql -h localhost -u root -p geotagging_usaha_dev < database/views/business_analytics_mysql.sql
```

## ✅ Verifikasi Setup

### 1. **Check Connection**

```cmd
# Test koneksi database
mysql -h localhost -u root -p geotagging_usaha_dev -e "SELECT VERSION();"
```

### 2. **Check Tables**

```cmd
# Lihat semua tabel
mysql -h localhost -u root -p geotagging_usaha_dev -e "SHOW TABLES;"
```

Expected output:
```
+-------------------------------+
| Tables_in_geotagging_usaha_dev|
+-------------------------------+
| audit_logs                    |
| businesses                    |
| user_sessions                 |
| users                         |
+-------------------------------+
```

### 3. **Check Sample Data**

```cmd
# Check users
mysql -h localhost -u root -p geotagging_usaha_dev -e "SELECT name, email, role FROM users;"

# Check businesses
mysql -h localhost -u root -p geotagging_usaha_dev -e "SELECT nama_usaha, kecamatan, status FROM businesses;"
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
mysql -h localhost -u root -p geotagging_usaha_dev

# Useful commands
SHOW TABLES;           # List tables
DESCRIBE users;        # Describe table
SHOW DATABASES;        # List databases
exit                   # Quit
```

### **Backup Database**
```cmd
# Create backup
mysqldump -h localhost -u root -p geotagging_usaha_dev > backup.sql

# Or use npm script
npm run db:backup
```

### **Restore Database**
```cmd
# Restore from backup
mysql -h localhost -u root -p geotagging_usaha_dev < backup.sql
```

## 🔧 Configuration untuk Next.js

Update `next.config.js` untuk database connection:

```javascript
/** @type {import('next').NextConfig} */
const nextConfig = {
  env: {
    DATABASE_URL: process.env.DATABASE_URL || 'mysql://root@localhost:3306/geotagging_usaha_dev',
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
  // Implementation for MySQL
}
```

### **Environment Variables Check**

Pastikan file `.env` berisi:
```
DATABASE_URL=mysql://root@localhost:3306/geotagging_usaha_dev
DB_HOST=localhost
DB_PORT=3306
DB_NAME=geotagging_usaha_dev
DB_USER=root
DB_PASSWORD=
```

## 🔄 Perbedaan dari PostgreSQL

### **Spatial Data**
- PostgreSQL: Menggunakan PostGIS extension
- MySQL: Menggunakan built-in spatial functions dan POINT data type

### **Full-Text Search**
- PostgreSQL: `to_tsvector()` dan GIN indexes
- MySQL: `FULLTEXT` indexes dan `MATCH ... AGAINST` syntax

### **UUID Generation**
- PostgreSQL: `gen_random_uuid()`
- MySQL: `UUID()`

### **JSON Data**
- PostgreSQL: `JSONB` type
- MySQL: `JSON` type

### **Functions & Triggers**
- PostgreSQL: PL/pgSQL language
- MySQL: MySQL stored procedure syntax

## ❗ Troubleshooting

### **Error: mysql command not found**
```cmd
# Add MySQL to PATH
set PATH=C:\laragon\bin\mysql\mysql-8.0.30-winx64\bin;%PATH%
```

### **Error: Access denied for user 'root'**
Laragon MySQL biasanya tidak menggunakan password. Pastikan:
- Password kosong di config
- Atau set password di MySQL jika diperlukan

### **Error: database tidak exist**
```cmd
# Manually create database
mysql -h localhost -u root -p -e "CREATE DATABASE geotagging_usaha_dev;"
```

### **Error: permission denied**
```cmd
# Grant permissions (jika diperlukan)
mysql -h localhost -u root -p -e "GRANT ALL PRIVILEGES ON geotagging_usaha_dev.* TO 'root'@'localhost';"
```

### **Error: spatial functions not working**
Pastikan MySQL version 5.7+ dengan InnoDB engine yang mendukung spatial indexes.

## 🎯 Next Steps

Setelah database setup berhasil:

1. ✅ **Test Next.js connection** - Update aplikasi untuk connect ke MySQL
2. ✅ **Test CRUD operations** - Pastikan semua operasi database berjalan
3. ✅ **Test authentication** - Login dengan credentials default
4. ✅ **Test geotagging** - Coba fitur peta dan koordinat spatial
5. ✅ **Test search** - Coba fitur pencarian fulltext

## 🔗 Tools untuk MySQL Management

- **phpMyAdmin** - http://localhost/phpmyadmin (tersedia di Laragon)
- **MySQL Workbench** - GUI client untuk MySQL
- **Laragon Database tab** - Built-in database manager
- **Command line** - `mysql -h localhost -u root -p`

## 📞 Support

Jika ada masalah:
1. Check Laragon logs
2. Check MySQL service status
3. Verify file permissions
4. Check error messages di terminal
5. Pastikan semua file MySQL sudah ter-upload dengan benar

Database MySQL siap digunakan untuk development! 🎉
