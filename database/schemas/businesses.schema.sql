-- Businesses table schema
-- Table untuk menyimpan data usaha yang didaftarkan

CREATE TABLE IF NOT EXISTS businesses (
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
    
    -- Constraints
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

-- Create spatial index for location-based queries
CREATE INDEX IF NOT EXISTS idx_businesses_location ON businesses USING GIST (
    point(longitude, latitude)
);

-- Create other indexes for performance
CREATE INDEX IF NOT EXISTS idx_businesses_user_id ON businesses(user_id);
CREATE INDEX IF NOT EXISTS idx_businesses_kecamatan ON businesses(kecamatan);
CREATE INDEX IF NOT EXISTS idx_businesses_kelurahan ON businesses(kelurahan);
CREATE INDEX IF NOT EXISTS idx_businesses_status ON businesses(status);
CREATE INDEX IF NOT EXISTS idx_businesses_created_at ON businesses(created_at);
CREATE INDEX IF NOT EXISTS idx_businesses_tahun_berdiri ON businesses(tahun_berdiri);
CREATE INDEX IF NOT EXISTS idx_businesses_jaringan_usaha ON businesses(jaringan_usaha);
CREATE INDEX IF NOT EXISTS idx_businesses_kode_sls ON businesses(kode_sls);

-- Full text search index
CREATE INDEX IF NOT EXISTS idx_businesses_search ON businesses USING GIN (
    to_tsvector('indonesian', nama_usaha || ' ' || nama_komersil || ' ' || deskripsi_kegiatan)
);

-- Create updated_at trigger
CREATE TRIGGER update_businesses_updated_at 
    BEFORE UPDATE ON businesses 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Comments
COMMENT ON TABLE businesses IS 'Tabel data usaha yang didaftarkan dalam sistem geotagging';
COMMENT ON COLUMN businesses.id IS 'Primary key UUID usaha';
COMMENT ON COLUMN businesses.nama_usaha IS 'Nama resmi usaha';
COMMENT ON COLUMN businesses.nama_komersil IS 'Nama komersil/brand usaha';
COMMENT ON COLUMN businesses.alamat IS 'Alamat lengkap usaha';
COMMENT ON COLUMN businesses.kecamatan IS 'Kecamatan lokasi usaha';
COMMENT ON COLUMN businesses.kelurahan IS 'Kelurahan lokasi usaha';
COMMENT ON COLUMN businesses.kode_sls IS 'Kode SLS (Satuan Lingkungan Setempat) 10 digit';
COMMENT ON COLUMN businesses.telepon IS 'Nomor telepon/WhatsApp usaha';
COMMENT ON COLUMN businesses.email IS 'Email usaha';
COMMENT ON COLUMN businesses.tahun_berdiri IS 'Tahun berdiri usaha';
COMMENT ON COLUMN businesses.deskripsi_kegiatan IS 'Deskripsi kegiatan usaha';
COMMENT ON COLUMN businesses.jaringan_usaha IS 'Jenis jaringan: Tunggal atau Cabang';
COMMENT ON COLUMN businesses.latitude IS 'Koordinat lintang lokasi usaha';
COMMENT ON COLUMN businesses.longitude IS 'Koordinat bujur lokasi usaha';
COMMENT ON COLUMN businesses.user_id IS 'ID petugas yang mendaftarkan usaha';
COMMENT ON COLUMN businesses.status IS 'Status usaha: active, inactive, pending, rejected';
COMMENT ON COLUMN businesses.verified_at IS 'Waktu verifikasi usaha';
COMMENT ON COLUMN businesses.verified_by IS 'ID admin yang memverifikasi';
COMMENT ON COLUMN businesses.created_at IS 'Waktu pendaftaran usaha';
COMMENT ON COLUMN businesses.updated_at IS 'Waktu terakhir update';
