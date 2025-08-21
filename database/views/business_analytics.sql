-- Database Views for Analytics
-- Views untuk keperluan analitik dan reporting

-- View summary usaha per kecamatan
CREATE OR REPLACE VIEW v_business_summary_by_kecamatan AS
SELECT 
    kecamatan,
    COUNT(*) as total_usaha,
    COUNT(CASE WHEN status = 'active' THEN 1 END) as usaha_aktif,
    COUNT(CASE WHEN status = 'pending' THEN 1 END) as usaha_pending,
    COUNT(CASE WHEN status = 'inactive' THEN 1 END) as usaha_nonaktif,
    COUNT(CASE WHEN jaringan_usaha = 'Tunggal' THEN 1 END) as usaha_tunggal,
    COUNT(CASE WHEN jaringan_usaha = 'Cabang' THEN 1 END) as usaha_cabang,
    ROUND(AVG(tahun_berdiri), 0) as rata_rata_tahun_berdiri,
    MIN(created_at) as pertama_terdaftar,
    MAX(created_at) as terakhir_terdaftar
FROM businesses
GROUP BY kecamatan
ORDER BY total_usaha DESC;

-- View summary usaha per kelurahan
CREATE OR REPLACE VIEW v_business_summary_by_kelurahan AS
SELECT 
    kecamatan,
    kelurahan,
    COUNT(*) as total_usaha,
    COUNT(CASE WHEN status = 'active' THEN 1 END) as usaha_aktif,
    COUNT(CASE WHEN status = 'pending' THEN 1 END) as usaha_pending,
    ROUND(AVG(tahun_berdiri), 0) as rata_rata_tahun_berdiri,
    STRING_AGG(DISTINCT jaringan_usaha, ', ') as jenis_jaringan
FROM businesses
GROUP BY kecamatan, kelurahan
ORDER BY kecamatan, total_usaha DESC;

-- View distribusi usaha per tahun berdiri
CREATE OR REPLACE VIEW v_business_by_year AS
SELECT 
    tahun_berdiri,
    COUNT(*) as jumlah_usaha,
    COUNT(CASE WHEN status = 'active' THEN 1 END) as usaha_aktif,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) as persentase
FROM businesses
WHERE tahun_berdiri IS NOT NULL
GROUP BY tahun_berdiri
ORDER BY tahun_berdiri DESC;

-- View top 10 usaha terbaru
CREATE OR REPLACE VIEW v_latest_businesses AS
SELECT 
    b.id,
    b.nama_usaha,
    b.nama_komersil,
    b.alamat,
    b.kecamatan,
    b.kelurahan,
    b.status,
    b.created_at,
    u.name as petugas_pendaftar
FROM businesses b
LEFT JOIN users u ON b.user_id = u.id
ORDER BY b.created_at DESC
LIMIT 10;

-- View usaha yang perlu verifikasi
CREATE OR REPLACE VIEW v_businesses_pending_verification AS
SELECT 
    b.id,
    b.nama_usaha,
    b.nama_komersil,
    b.alamat,
    b.kecamatan,
    b.kelurahan,
    b.telepon,
    b.email,
    b.created_at,
    u.name as petugas_pendaftar,
    EXTRACT(DAY FROM (CURRENT_TIMESTAMP - b.created_at)) as hari_pending
FROM businesses b
LEFT JOIN users u ON b.user_id = u.id
WHERE b.status = 'pending'
ORDER BY b.created_at ASC;

-- View statistik petugas
CREATE OR REPLACE VIEW v_petugas_statistics AS
SELECT 
    u.id,
    u.name as nama_petugas,
    u.email,
    COUNT(b.id) as total_usaha_didaftar,
    COUNT(CASE WHEN b.status = 'active' THEN 1 END) as usaha_aktif,
    COUNT(CASE WHEN b.status = 'pending' THEN 1 END) as usaha_pending,
    COUNT(CASE WHEN b.created_at >= CURRENT_DATE - INTERVAL '30 days' THEN 1 END) as usaha_bulan_ini,
    MIN(b.created_at) as pendaftaran_pertama,
    MAX(b.created_at) as pendaftaran_terakhir,
    u.last_login
FROM users u
LEFT JOIN businesses b ON u.id = b.user_id
WHERE u.role = 'user'
GROUP BY u.id, u.name, u.email, u.last_login
ORDER BY total_usaha_didaftar DESC;

-- View heatmap data untuk peta
CREATE OR REPLACE VIEW v_business_heatmap AS
SELECT 
    latitude,
    longitude,
    COUNT(*) as business_count,
    kecamatan,
    kelurahan
FROM businesses
WHERE status = 'active'
AND latitude IS NOT NULL 
AND longitude IS NOT NULL
GROUP BY latitude, longitude, kecamatan, kelurahan
ORDER BY business_count DESC;

-- View audit trail summary
CREATE OR REPLACE VIEW v_audit_summary AS
SELECT 
    DATE(created_at) as tanggal,
    action,
    table_name,
    COUNT(*) as jumlah_aktivitas,
    COUNT(DISTINCT user_id) as jumlah_user_aktif
FROM audit_logs
WHERE created_at >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY DATE(created_at), action, table_name
ORDER BY tanggal DESC, jumlah_aktivitas DESC;

-- View active sessions
CREATE OR REPLACE VIEW v_active_sessions AS
SELECT 
    us.id,
    u.name as nama_user,
    u.email,
    u.role,
    us.ip_address,
    us.created_at as login_time,
    us.last_activity,
    us.expires_at,
    EXTRACT(HOUR FROM (us.expires_at - CURRENT_TIMESTAMP)) as hours_until_expiry
FROM user_sessions us
JOIN users u ON us.user_id = u.id
WHERE us.is_active = TRUE
AND us.expires_at > CURRENT_TIMESTAMP
ORDER BY us.last_activity DESC;

-- View top performing kecamatan
CREATE OR REPLACE VIEW v_top_kecamatan_performance AS
SELECT 
    kecamatan,
    COUNT(*) as total_usaha,
    COUNT(CASE WHEN status = 'active' THEN 1 END) as usaha_aktif,
    ROUND(COUNT(CASE WHEN status = 'active' THEN 1 END) * 100.0 / COUNT(*), 2) as persentase_aktif,
    COUNT(CASE WHEN created_at >= CURRENT_DATE - INTERVAL '30 days' THEN 1 END) as usaha_baru_bulan_ini,
    COUNT(DISTINCT user_id) as jumlah_petugas_aktif
FROM businesses
GROUP BY kecamatan
ORDER BY usaha_aktif DESC, persentase_aktif DESC;

-- View monthly business registration trend
CREATE OR REPLACE VIEW v_monthly_registration_trend AS
SELECT 
    DATE_TRUNC('month', created_at) as bulan,
    COUNT(*) as total_pendaftaran,
    COUNT(CASE WHEN status = 'active' THEN 1 END) as yang_disetujui,
    COUNT(CASE WHEN status = 'pending' THEN 1 END) as masih_pending,
    COUNT(CASE WHEN status = 'rejected' THEN 1 END) as ditolak
FROM businesses
WHERE created_at >= CURRENT_DATE - INTERVAL '12 months'
GROUP BY DATE_TRUNC('month', created_at)
ORDER BY bulan DESC;

-- Comments
COMMENT ON VIEW v_business_summary_by_kecamatan IS 'Summary statistik usaha per kecamatan';
COMMENT ON VIEW v_business_summary_by_kelurahan IS 'Summary statistik usaha per kelurahan';
COMMENT ON VIEW v_business_by_year IS 'Distribusi usaha berdasarkan tahun berdiri';
COMMENT ON VIEW v_latest_businesses IS 'Daftar 10 usaha terbaru yang didaftarkan';
COMMENT ON VIEW v_businesses_pending_verification IS 'Usaha yang menunggu verifikasi admin';
COMMENT ON VIEW v_petugas_statistics IS 'Statistik kinerja petugas BPS';
COMMENT ON VIEW v_business_heatmap IS 'Data untuk heatmap distribusi usaha di peta';
COMMENT ON VIEW v_audit_summary IS 'Summary aktivitas audit log';
COMMENT ON VIEW v_active_sessions IS 'Daftar session user yang sedang aktif';
COMMENT ON VIEW v_top_kecamatan_performance IS 'Performa kecamatan berdasarkan jumlah usaha aktif';
COMMENT ON VIEW v_monthly_registration_trend IS 'Trend pendaftaran usaha bulanan';
