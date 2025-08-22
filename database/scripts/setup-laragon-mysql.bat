@echo off
REM Setup Database MySQL di Laragon
REM Script untuk setup otomatis database geotagging usaha dengan MySQL

echo ========================================
echo    SETUP DATABASE MYSQL - LARAGON
echo    Geotagging Usaha Pematang Siantar
echo ========================================
echo.

REM Check if MySQL is accessible
echo [1/7] Checking MySQL connection...
mysql --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: MySQL not found in PATH
    echo Please make sure MySQL is installed and accessible through Laragon
    echo Add MySQL bin directory to PATH: C:\laragon\bin\mysql\mysql-8.0.30-winx64\bin
    pause
    exit /b 1
)
echo ✓ MySQL found

REM Check if we can connect to MySQL
echo [2/7] Testing MySQL connection...
mysql -h localhost -u root -p -e "SELECT 1;" >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Cannot connect to MySQL
    echo Please check:
    echo - MySQL service is running in Laragon
    echo - MySQL credentials are correct
    echo - No password is set for root user (default Laragon setup)
    pause
    exit /b 1
)
echo ✓ MySQL connection successful

REM Create development database
echo [3/7] Creating development database...
mysql -h localhost -u root -p -e "CREATE DATABASE IF NOT EXISTS geotagging_usaha_dev CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
if %errorlevel% neq 0 (
    echo ERROR: Failed to create development database
    pause
    exit /b 1
)
echo ✓ Development database created

REM Create test database
echo [4/7] Creating test database...
mysql -h localhost -u root -p -e "CREATE DATABASE IF NOT EXISTS geotagging_usaha_test CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
if %errorlevel% neq 0 (
    echo ERROR: Failed to create test database
    pause
    exit /b 1
)
echo ✓ Test database created

REM Run migrations
echo [5/7] Running database migrations...
echo   - Initial schema...
mysql -h localhost -u root -p geotagging_usaha_dev < database/migrations/001_initial_schema_mysql.sql
if %errorlevel% neq 0 (
    echo ERROR: Failed to run initial schema migration
    pause
    exit /b 1
)

echo   - Creating indexes...
mysql -h localhost -u root -p geotagging_usaha_dev < database/migrations/002_create_indexes_mysql.sql
if %errorlevel% neq 0 (
    echo ERROR: Failed to create indexes
    pause
    exit /b 1
)

echo   - Creating triggers...
mysql -h localhost -u root -p geotagging_usaha_dev < database/migrations/003_create_triggers_mysql.sql
if %errorlevel% neq 0 (
    echo ERROR: Failed to create triggers
    pause
    exit /b 1
)

echo   - Inserting seed data...
mysql -h localhost -u root -p geotagging_usaha_dev < database/migrations/004_seed_data_mysql.sql
if %errorlevel% neq 0 (
    echo ERROR: Failed to insert seed data
    pause
    exit /b 1
)
echo ✓ Database migrations completed

REM Load functions
echo [6/7] Loading spatial functions...
mysql -h localhost -u root -p geotagging_usaha_dev < database/functions/spatial_functions_mysql.sql
if %errorlevel% neq 0 (
    echo ERROR: Failed to load spatial functions
    pause
    exit /b 1
)
echo ✓ Spatial functions loaded

REM Load views
echo [7/7] Loading business analytics views...
mysql -h localhost -u root -p geotagging_usaha_dev < database/views/business_analytics_mysql.sql
if %errorlevel% neq 0 (
    echo ERROR: Failed to load analytics views
    pause
    exit /b 1
)
echo ✓ Analytics views loaded

echo.
echo ========================================
echo         SETUP COMPLETED SUCCESSFULLY!
echo ========================================
echo.
echo Database Information:
echo - Host: localhost
echo - Port: 3306
echo - Database: geotagging_usaha_dev
echo - User: root
echo - Password: (empty - default Laragon)
echo.
echo Default Login Credentials:
echo - Admin: admin@bps-pematangsiantar.go.id / admin123
echo - User: petugas1@bps-pematangsiantar.go.id / user123
echo.
echo Next Steps:
echo 1. Copy database/.env.laragon.mysql to .env in root project
echo 2. Start your Next.js development server: npm run dev
echo 3. Access the application at http://localhost:3000
echo.
echo For database management, you can use:
echo - Laragon's Database tab
echo - phpMyAdmin (http://localhost/phpmyadmin)
echo - MySQL Workbench
echo - Command line: mysql -h localhost -u root -p geotagging_usaha_dev
echo.
pause
