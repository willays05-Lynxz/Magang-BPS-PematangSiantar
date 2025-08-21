-- Migration 001: Initial Schema Setup
-- Membuat struktur database awal untuk sistem geotagging usaha

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";
CREATE EXTENSION IF NOT EXISTS "unaccent";

-- Set timezone
SET timezone = 'Asia/Jakarta';

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create audit action enum
CREATE TYPE audit_action AS ENUM (
    'CREATE', 'UPDATE', 'DELETE', 'LOGIN', 'LOGOUT', 
    'VERIFY', 'REJECT', 'ACTIVATE', 'DEACTIVATE'
);

-- Users table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(100) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'user' CHECK (role IN ('admin', 'user')),
    is_active BOOLEAN DEFAULT TRUE,
    email_verified BOOLEAN DEFAULT FALSE,
    phone VARCHAR(20),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP WITH TIME ZONE,
    
    CONSTRAINT users_email_check CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

-- Businesses table
CREATE TABLE businesses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nama_usaha VARCHAR(100) NOT NULL,
    nama_komersil VARCHAR(100) NOT NULL,
    alamat TEXT NOT NULL,
    kecamatan VARCHAR(50) NOT NULL,
    kelurahan VARCHAR(50) NOT NULL,
    kode_sls VARCHAR(10) NOT NULL,
    telepon VARCHAR(20) NOT NULL,
    email VARCHAR(255) NOT NULL,
    tahun_berdiri INTEGER NOT NULL,
    deskripsi_kegiatan TEXT NOT NULL,
    jaringan_usaha VARCHAR(20) NOT NULL CHECK (jaringan_usaha IN ('Tunggal', 'Cabang')),
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'pending', 'rejected')),
    verified_at TIMESTAMP WITH TIME ZONE,
    verified_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT businesses_email_check CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    CONSTRAINT businesses_tahun_check CHECK (tahun_berdiri >= 1900 AND tahun_berdiri <= EXTRACT(YEAR FROM CURRENT_DATE)),
    CONSTRAINT businesses_latitude_check CHECK (latitude >= -90 AND latitude <= 90),
    CONSTRAINT businesses_longitude_check CHECK (longitude >= -180 AND longitude <= 180),
    CONSTRAINT businesses_kode_sls_check CHECK (kode_sls ~ '^[0-9]{10}$'),
    CONSTRAINT businesses_kecamatan_check CHECK (kecamatan IN (
        'Siantar Barat', 'Siantar Timur', 'Siantar Utara', 'Siantar Selatan',
        'Siantar Marihat', 'Siantar Marimbun', 'Siantar Martoba', 'Siantar Sitalasari'
    )),
    CONSTRAINT businesses_kelurahan_check CHECK (kelurahan IN (
        'Timbang Galung', 'Sipispis', 'Sukadame', 'Toba', 'Bah Kapul',
        'Simbolon Purba', 'Martoba', 'Sitalasari', 'Marihat', 'Marimbun',
        'Teladan', 'Pahlawan', 'Proklamasi', 'Merdeka'
    ))
);

-- User Sessions table
CREATE TABLE user_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    session_token VARCHAR(255) UNIQUE NOT NULL,
    refresh_token VARCHAR(255) UNIQUE,
    ip_address INET,
    user_agent TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_activity TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Audit Logs table
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    table_name VARCHAR(50),
    record_id UUID,
    action audit_action NOT NULL,
    old_values JSONB,
    new_values JSONB,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    description TEXT,
    metadata JSONB DEFAULT '{}'::jsonb
);

-- Create all indexes
\i database/migrations/002_create_indexes.sql

-- Create all triggers
\i database/migrations/003_create_triggers.sql

-- Insert initial data
\i database/migrations/004_seed_data.sql

-- Comments
COMMENT ON DATABASE current_database() IS 'Database sistem geotagging usaha Pematang Siantar';
