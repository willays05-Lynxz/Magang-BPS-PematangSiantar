-- Audit Logs table schema
-- Table untuk menyimpan log aktivitas sistem

CREATE TYPE audit_action AS ENUM (
    'CREATE', 'UPDATE', 'DELETE', 'LOGIN', 'LOGOUT', 
    'VERIFY', 'REJECT', 'ACTIVATE', 'DEACTIVATE'
);

CREATE TABLE IF NOT EXISTS audit_logs (
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
    
    -- Additional context fields
    description TEXT,
    metadata JSONB DEFAULT '{}'::jsonb
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_table_name ON audit_logs(table_name);
CREATE INDEX IF NOT EXISTS idx_audit_logs_record_id ON audit_logs(record_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_action ON audit_logs(action);
CREATE INDEX IF NOT EXISTS idx_audit_logs_created_at ON audit_logs(created_at);
CREATE INDEX IF NOT EXISTS idx_audit_logs_ip_address ON audit_logs(ip_address);

-- GIN index for JSONB columns
CREATE INDEX IF NOT EXISTS idx_audit_logs_old_values ON audit_logs USING GIN (old_values);
CREATE INDEX IF NOT EXISTS idx_audit_logs_new_values ON audit_logs USING GIN (new_values);
CREATE INDEX IF NOT EXISTS idx_audit_logs_metadata ON audit_logs USING GIN (metadata);

-- Comments
COMMENT ON TABLE audit_logs IS 'Tabel audit log untuk tracking aktivitas sistem';
COMMENT ON COLUMN audit_logs.user_id IS 'ID pengguna yang melakukan aksi';
COMMENT ON COLUMN audit_logs.table_name IS 'Nama tabel yang diubah';
COMMENT ON COLUMN audit_logs.record_id IS 'ID record yang diubah';
COMMENT ON COLUMN audit_logs.action IS 'Jenis aksi yang dilakukan';
COMMENT ON COLUMN audit_logs.old_values IS 'Nilai sebelum perubahan (JSON)';
COMMENT ON COLUMN audit_logs.new_values IS 'Nilai setelah perubahan (JSON)';
COMMENT ON COLUMN audit_logs.ip_address IS 'IP address pengguna';
COMMENT ON COLUMN audit_logs.user_agent IS 'User agent browser';
COMMENT ON COLUMN audit_logs.description IS 'Deskripsi tambahan aktivitas';
COMMENT ON COLUMN audit_logs.metadata IS 'Metadata tambahan (JSON)';
