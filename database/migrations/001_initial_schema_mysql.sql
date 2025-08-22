-- Migration 001: Initial Schema Setup (MySQL Version)
-- Membuat struktur database awal untuk sistem geotagging usaha

-- Set timezone
SET time_zone = '+07:00';

-- Set SQL mode for compatibility
SET sql_mode = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';

-- Create trigger function for updating updated_at column
DELIMITER $$
CREATE TRIGGER update_updated_at_users
    BEFORE UPDATE ON users
    FOR EACH ROW
BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END$$
DELIMITER ;

-- Users table
CREATE TABLE users (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(100) NOT NULL,
    role ENUM('admin', 'user') NOT NULL DEFAULT 'user',
    is_active BOOLEAN DEFAULT TRUE,
    email_verified BOOLEAN DEFAULT FALSE,
    phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL,
    
    CONSTRAINT users_email_check CHECK (email REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$')
);

-- Create trigger for users updated_at
DELIMITER $$
CREATE TRIGGER update_updated_at_businesses
    BEFORE UPDATE ON businesses
    FOR EACH ROW
BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END$$
DELIMITER ;

-- Businesses table
CREATE TABLE businesses (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    nama_usaha VARCHAR(100) NOT NULL,
    nama_komersil VARCHAR(100) NOT NULL,
    alamat TEXT NOT NULL,
    kecamatan VARCHAR(50) NOT NULL,
    kelurahan VARCHAR(50) NOT NULL,
    kode_sls VARCHAR(10) NOT NULL,
    telepon VARCHAR(20) NOT NULL,
    email VARCHAR(255) NOT NULL,
    tahun_berdiri INT NOT NULL,
    deskripsi_kegiatan TEXT NOT NULL,
    jaringan_usaha ENUM('Tunggal', 'Cabang') NOT NULL,
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    location POINT AS (POINT(longitude, latitude)) STORED,
    user_id CHAR(36) NOT NULL,
    status ENUM('active', 'inactive', 'pending', 'rejected') DEFAULT 'active',
    verified_at TIMESTAMP NULL,
    verified_by CHAR(36) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT businesses_email_check CHECK (email REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$'),
    CONSTRAINT businesses_tahun_check CHECK (tahun_berdiri >= 1900 AND tahun_berdiri <= YEAR(CURDATE())),
    CONSTRAINT businesses_latitude_check CHECK (latitude >= -90 AND latitude <= 90),
    CONSTRAINT businesses_longitude_check CHECK (longitude >= -180 AND longitude <= 180),
    CONSTRAINT businesses_kode_sls_check CHECK (kode_sls REGEXP '^[0-9]{10}$'),
    CONSTRAINT businesses_kecamatan_check CHECK (kecamatan IN (
        'Siantar Barat', 'Siantar Timur', 'Siantar Utara', 'Siantar Selatan',
        'Siantar Marihat', 'Siantar Marimbun', 'Siantar Martoba', 'Siantar Sitalasari'
    )),
    CONSTRAINT businesses_kelurahan_check CHECK (kelurahan IN (
        'Timbang Galung', 'Sipispis', 'Sukadame', 'Toba', 'Bah Kapul',
        'Simbolon Purba', 'Martoba', 'Sitalasari', 'Marihat', 'Marimbun',
        'Teladan', 'Pahlawan', 'Proklamasi', 'Merdeka'
    )),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (verified_by) REFERENCES users(id) ON DELETE SET NULL
);

-- Create trigger for businesses updated_at
DELIMITER $$
CREATE TRIGGER update_updated_at_user_sessions
    BEFORE UPDATE ON user_sessions
    FOR EACH ROW
BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END$$
DELIMITER ;

-- User Sessions table
CREATE TABLE user_sessions (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    user_id CHAR(36) NOT NULL,
    session_token VARCHAR(255) UNIQUE NOT NULL,
    refresh_token VARCHAR(255) UNIQUE,
    ip_address VARCHAR(45), -- Supports both IPv4 and IPv6
    user_agent TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_activity TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Audit Logs table
CREATE TABLE audit_logs (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    user_id CHAR(36) NULL,
    table_name VARCHAR(50),
    record_id CHAR(36),
    action ENUM('CREATE', 'UPDATE', 'DELETE', 'LOGIN', 'LOGOUT', 'VERIFY', 'REJECT', 'ACTIVATE', 'DEACTIVATE') NOT NULL,
    old_values JSON,
    new_values JSON,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    description TEXT,
    metadata JSON DEFAULT '{}',
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

-- Enable spatial indexing (MySQL 5.7+)
SET sql_mode = '';

-- Comments are not directly supported in MySQL like PostgreSQL
-- But we can add them at table level
ALTER TABLE users COMMENT = 'Table untuk menyimpan data pengguna sistem';
ALTER TABLE businesses COMMENT = 'Table untuk menyimpan data usaha yang di-geotag';
ALTER TABLE user_sessions COMMENT = 'Table untuk menyimpan session pengguna';
ALTER TABLE audit_logs COMMENT = 'Table untuk menyimpan log audit sistem';
