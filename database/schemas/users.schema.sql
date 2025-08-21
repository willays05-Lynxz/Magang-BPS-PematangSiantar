-- Users table schema
-- Table untuk menyimpan data pengguna sistem (Admin dan Petugas BPS)

CREATE TABLE IF NOT EXISTS users (
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
    
    -- Indexes
    CONSTRAINT users_email_check CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    CONSTRAINT users_role_check CHECK (role IN ('admin', 'user'))
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);
CREATE INDEX IF NOT EXISTS idx_users_is_active ON users(is_active);
CREATE INDEX IF NOT EXISTS idx_users_created_at ON users(created_at);

-- Create updated_at trigger
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_updated_at 
    BEFORE UPDATE ON users 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Comments
COMMENT ON TABLE users IS 'Tabel pengguna sistem geotagging usaha';
COMMENT ON COLUMN users.id IS 'Primary key UUID pengguna';
COMMENT ON COLUMN users.email IS 'Email unik pengguna';
COMMENT ON COLUMN users.password_hash IS 'Hash password pengguna';
COMMENT ON COLUMN users.name IS 'Nama lengkap pengguna';
COMMENT ON COLUMN users.role IS 'Role pengguna: admin atau user';
COMMENT ON COLUMN users.is_active IS 'Status aktif pengguna';
COMMENT ON COLUMN users.email_verified IS 'Status verifikasi email';
COMMENT ON COLUMN users.phone IS 'Nomor telepon pengguna';
COMMENT ON COLUMN users.created_at IS 'Waktu pembuatan akun';
COMMENT ON COLUMN users.updated_at IS 'Waktu terakhir update';
COMMENT ON COLUMN users.last_login IS 'Waktu login terakhir';
