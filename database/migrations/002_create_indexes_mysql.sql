-- Migration 002: Create Indexes (MySQL Version)
-- Membuat semua index untuk optimasi performance

-- Users table indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_is_active ON users(is_active);
CREATE INDEX idx_users_created_at ON users(created_at);
CREATE INDEX idx_users_email_verified ON users(email_verified);

-- Businesses table indexes
CREATE INDEX idx_businesses_user_id ON businesses(user_id);
CREATE INDEX idx_businesses_kecamatan ON businesses(kecamatan);
CREATE INDEX idx_businesses_kelurahan ON businesses(kelurahan);
CREATE INDEX idx_businesses_status ON businesses(status);
CREATE INDEX idx_businesses_created_at ON businesses(created_at);
CREATE INDEX idx_businesses_tahun_berdiri ON businesses(tahun_berdiri);
CREATE INDEX idx_businesses_jaringan_usaha ON businesses(jaringan_usaha);
CREATE INDEX idx_businesses_kode_sls ON businesses(kode_sls);
CREATE INDEX idx_businesses_verified_at ON businesses(verified_at);
CREATE INDEX idx_businesses_verified_by ON businesses(verified_by);

-- Spatial index for location-based queries (MySQL 5.7+ with InnoDB)
CREATE SPATIAL INDEX idx_businesses_location ON businesses(location);

-- Full text search index for businesses (MySQL FULLTEXT equivalent)
CREATE FULLTEXT INDEX idx_businesses_search ON businesses(nama_usaha, nama_komersil, deskripsi_kegiatan);

-- Composite indexes for common queries
CREATE INDEX idx_businesses_kecamatan_status ON businesses(kecamatan, status);
CREATE INDEX idx_businesses_kelurahan_status ON businesses(kelurahan, status);
CREATE INDEX idx_businesses_user_status ON businesses(user_id, status);
CREATE INDEX idx_businesses_tahun_status ON businesses(tahun_berdiri, status);

-- User Sessions indexes
CREATE INDEX idx_user_sessions_user_id ON user_sessions(user_id);
CREATE INDEX idx_user_sessions_session_token ON user_sessions(session_token);
CREATE INDEX idx_user_sessions_refresh_token ON user_sessions(refresh_token);
CREATE INDEX idx_user_sessions_expires_at ON user_sessions(expires_at);
CREATE INDEX idx_user_sessions_is_active ON user_sessions(is_active);
CREATE INDEX idx_user_sessions_ip_address ON user_sessions(ip_address);
CREATE INDEX idx_user_sessions_last_activity ON user_sessions(last_activity);

-- Audit Logs indexes
CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_table_name ON audit_logs(table_name);
CREATE INDEX idx_audit_logs_record_id ON audit_logs(record_id);
CREATE INDEX idx_audit_logs_action ON audit_logs(action);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at);
CREATE INDEX idx_audit_logs_ip_address ON audit_logs(ip_address);

-- JSON indexes for MySQL 8.0+ (using generated columns for older versions)
-- For MySQL 8.0+, you can create functional indexes on JSON fields
-- For older versions, you would need to create generated columns first

-- MySQL 8.0+ JSON functional indexes (comment out if using older MySQL)
-- CREATE INDEX idx_audit_logs_old_values_keys ON audit_logs((CAST(old_values->'$.keys' AS CHAR(255) ARRAY)));
-- CREATE INDEX idx_audit_logs_new_values_keys ON audit_logs((CAST(new_values->'$.keys' AS CHAR(255) ARRAY)));
-- CREATE INDEX idx_audit_logs_metadata_keys ON audit_logs((CAST(metadata->'$.keys' AS CHAR(255) ARRAY)));

-- Alternative for older MySQL versions using generated columns
-- ALTER TABLE audit_logs ADD COLUMN old_values_searchable TEXT GENERATED ALWAYS AS (JSON_UNQUOTE(JSON_EXTRACT(old_values, '$'))) STORED;
-- CREATE INDEX idx_audit_logs_old_values ON audit_logs(old_values_searchable);

-- Partial indexes equivalent using WHERE conditions in queries (MySQL doesn't support partial indexes)
-- Instead, we create conditional indexes by using expressions in WHERE clauses

-- For active users (equivalent to partial index)
CREATE INDEX idx_users_active_email ON users(email, is_active);
-- Query should use: WHERE is_active = TRUE

-- For active businesses (equivalent to partial index)
CREATE INDEX idx_businesses_active_location ON businesses(kecamatan, kelurahan, status);
-- Query should use: WHERE status = 'active'

-- For active user sessions (equivalent to partial index)
CREATE INDEX idx_user_sessions_active ON user_sessions(user_id, expires_at, is_active);
-- Query should use: WHERE is_active = TRUE
