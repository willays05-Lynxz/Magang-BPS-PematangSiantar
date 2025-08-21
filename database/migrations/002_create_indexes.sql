-- Migration 002: Create Indexes
-- Membuat semua index untuk optimasi performance

-- Users table indexes
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);
CREATE INDEX IF NOT EXISTS idx_users_is_active ON users(is_active);
CREATE INDEX IF NOT EXISTS idx_users_created_at ON users(created_at);
CREATE INDEX IF NOT EXISTS idx_users_email_verified ON users(email_verified);

-- Businesses table indexes
CREATE INDEX IF NOT EXISTS idx_businesses_user_id ON businesses(user_id);
CREATE INDEX IF NOT EXISTS idx_businesses_kecamatan ON businesses(kecamatan);
CREATE INDEX IF NOT EXISTS idx_businesses_kelurahan ON businesses(kelurahan);
CREATE INDEX IF NOT EXISTS idx_businesses_status ON businesses(status);
CREATE INDEX IF NOT EXISTS idx_businesses_created_at ON businesses(created_at);
CREATE INDEX IF NOT EXISTS idx_businesses_tahun_berdiri ON businesses(tahun_berdiri);
CREATE INDEX IF NOT EXISTS idx_businesses_jaringan_usaha ON businesses(jaringan_usaha);
CREATE INDEX IF NOT EXISTS idx_businesses_kode_sls ON businesses(kode_sls);
CREATE INDEX IF NOT EXISTS idx_businesses_verified_at ON businesses(verified_at);
CREATE INDEX IF NOT EXISTS idx_businesses_verified_by ON businesses(verified_by);

-- Spatial index for location-based queries
CREATE INDEX IF NOT EXISTS idx_businesses_location ON businesses USING GIST (
    point(longitude, latitude)
);

-- Full text search index for businesses
CREATE INDEX IF NOT EXISTS idx_businesses_search ON businesses USING GIN (
    to_tsvector('indonesian', nama_usaha || ' ' || nama_komersil || ' ' || deskripsi_kegiatan)
);

-- Composite indexes for common queries
CREATE INDEX IF NOT EXISTS idx_businesses_kecamatan_status ON businesses(kecamatan, status);
CREATE INDEX IF NOT EXISTS idx_businesses_kelurahan_status ON businesses(kelurahan, status);
CREATE INDEX IF NOT EXISTS idx_businesses_user_status ON businesses(user_id, status);
CREATE INDEX IF NOT EXISTS idx_businesses_tahun_status ON businesses(tahun_berdiri, status);

-- User Sessions indexes
CREATE INDEX IF NOT EXISTS idx_user_sessions_user_id ON user_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_user_sessions_session_token ON user_sessions(session_token);
CREATE INDEX IF NOT EXISTS idx_user_sessions_refresh_token ON user_sessions(refresh_token);
CREATE INDEX IF NOT EXISTS idx_user_sessions_expires_at ON user_sessions(expires_at);
CREATE INDEX IF NOT EXISTS idx_user_sessions_is_active ON user_sessions(is_active);
CREATE INDEX IF NOT EXISTS idx_user_sessions_ip_address ON user_sessions(ip_address);
CREATE INDEX IF NOT EXISTS idx_user_sessions_last_activity ON user_sessions(last_activity);

-- Audit Logs indexes
CREATE INDEX IF NOT EXISTS idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_table_name ON audit_logs(table_name);
CREATE INDEX IF NOT EXISTS idx_audit_logs_record_id ON audit_logs(record_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_action ON audit_logs(action);
CREATE INDEX IF NOT EXISTS idx_audit_logs_created_at ON audit_logs(created_at);
CREATE INDEX IF NOT EXISTS idx_audit_logs_ip_address ON audit_logs(ip_address);

-- GIN indexes for JSONB columns
CREATE INDEX IF NOT EXISTS idx_audit_logs_old_values ON audit_logs USING GIN (old_values);
CREATE INDEX IF NOT EXISTS idx_audit_logs_new_values ON audit_logs USING GIN (new_values);
CREATE INDEX IF NOT EXISTS idx_audit_logs_metadata ON audit_logs USING GIN (metadata);

-- Partial indexes for active records
CREATE INDEX IF NOT EXISTS idx_users_active_email ON users(email) WHERE is_active = TRUE;
CREATE INDEX IF NOT EXISTS idx_businesses_active_location ON businesses(kecamatan, kelurahan) WHERE status = 'active';
CREATE INDEX IF NOT EXISTS idx_user_sessions_active ON user_sessions(user_id, expires_at) WHERE is_active = TRUE;
