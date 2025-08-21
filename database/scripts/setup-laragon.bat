@echo off
REM Setup Database untuk Laragon PostgreSQL
REM Script untuk membuat database dan menjalankan migrasi

echo ==========================================
echo    Setup Database Geotagging Usaha
echo          untuk Laragon PostgreSQL
echo ==========================================
echo.

REM Check if PostgreSQL is running
echo [INFO] Checking PostgreSQL service...
sc query postgresql-x64-13 >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] PostgreSQL service tidak berjalan!
    echo [INFO] Silakan start PostgreSQL dari Laragon terlebih dahulu.
    pause
    exit /b 1
)

echo [INFO] PostgreSQL service berjalan.
echo.

REM Set PostgreSQL path (adjust based on your Laragon installation)
set PSQL_PATH="C:\laragon\bin\postgresql\postgresql-13.12-1-windows-x64\bin"
set PATH=%PSQL_PATH%;%PATH%

REM Database configuration
set DB_HOST=localhost
set DB_PORT=5432
set DB_USER=postgres
set DB_NAME=geotagging_usaha_dev
set DB_TEST=geotagging_usaha_test

echo [INFO] Konfigurasi Database:
echo        Host: %DB_HOST%
echo        Port: %DB_PORT%
echo        User: %DB_USER%
echo        Database: %DB_NAME%
echo.

REM Create databases
echo [STEP 1] Membuat database...
psql -h %DB_HOST% -p %DB_PORT% -U %DB_USER% -d postgres -c "CREATE DATABASE %DB_NAME%;" 2>nul
if %errorlevel% equ 0 (
    echo [SUCCESS] Database %DB_NAME% berhasil dibuat.
) else (
    echo [INFO] Database %DB_NAME% sudah ada atau gagal dibuat.
)

psql -h %DB_HOST% -p %DB_PORT% -U %DB_USER% -d postgres -c "CREATE DATABASE %DB_TEST%;" 2>nul
if %errorlevel% equ 0 (
    echo [SUCCESS] Database %DB_TEST% berhasil dibuat.
) else (
    echo [INFO] Database %DB_TEST% sudah ada atau gagal dibuat.
)

echo.

REM Run migrations
echo [STEP 2] Menjalankan migrasi database...

echo [INFO] Migrasi 1/4: Initial Schema...
psql -h %DB_HOST% -p %DB_PORT% -U %DB_USER% -d %DB_NAME% -f "database/migrations/001_initial_schema.sql"
if %errorlevel% neq 0 (
    echo [ERROR] Gagal menjalankan initial schema!
    pause
    exit /b 1
)

echo [INFO] Migrasi 2/4: Creating Indexes...
psql -h %DB_HOST% -p %DB_PORT% -U %DB_USER% -d %DB_NAME% -f "database/migrations/002_create_indexes.sql"
if %errorlevel% neq 0 (
    echo [ERROR] Gagal membuat indexes!
    pause
    exit /b 1
)

echo [INFO] Migrasi 3/4: Creating Triggers...
psql -h %DB_HOST% -p %DB_PORT% -U %DB_USER% -d %DB_NAME% -f "database/migrations/003_create_triggers.sql"
if %errorlevel% neq 0 (
    echo [ERROR] Gagal membuat triggers!
    pause
    exit /b 1
)

echo [INFO] Migrasi 4/4: Seed Data...
psql -h %DB_HOST% -p %DB_PORT% -U %DB_USER% -d %DB_NAME% -f "database/migrations/004_seed_data.sql"
if %errorlevel% neq 0 (
    echo [ERROR] Gagal insert seed data!
    pause
    exit /b 1
)

echo.

REM Load functions and views
echo [STEP 3] Loading functions dan views...

echo [INFO] Loading spatial functions...
psql -h %DB_HOST% -p %DB_PORT% -U %DB_USER% -d %DB_NAME% -f "database/functions/spatial_functions.sql"

echo [INFO] Loading analytics views...
psql -h %DB_HOST% -p %DB_PORT% -U %DB_USER% -d %DB_NAME% -f "database/views/business_analytics.sql"

echo.

REM Verify installation
echo [STEP 4] Verifikasi instalasi...
echo [INFO] Checking tables...
psql -h %DB_HOST% -p %DB_PORT% -U %DB_USER% -d %DB_NAME% -c "\dt"

echo.
echo [INFO] Checking sample data...
psql -h %DB_HOST% -p %DB_PORT% -U %DB_USER% -d %DB_NAME% -c "SELECT COUNT(*) as total_users FROM users;"
psql -h %DB_HOST% -p %DB_PORT% -U %DB_USER% -d %DB_NAME% -c "SELECT COUNT(*) as total_businesses FROM businesses;"
psql -h %DB_HOST% -p %DB_PORT% -U %DB_USER% -d %DB_NAME% -c "SELECT COUNT(*) as total_categories FROM business_categories;"

echo.
echo ==========================================
echo          SETUP BERHASIL SELESAI!
echo ==========================================
echo.
echo Database geotagging usaha telah siap digunakan.
echo.
echo Default login:
echo   Admin: admin@bps-pematangsiantar.go.id / admin123
echo   User:  petugas1@bps-pematangsiantar.go.id / user123
echo.
echo Connection string:
echo   postgresql://postgres@localhost:5432/%DB_NAME%
echo.
echo Untuk mengakses database:
echo   psql -h localhost -U postgres -d %DB_NAME%
echo.
pause
