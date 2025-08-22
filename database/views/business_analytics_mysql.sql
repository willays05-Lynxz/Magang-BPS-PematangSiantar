-- Database Views for Analytics (MySQL Version)
-- Views untuk keperluan analitik dan reporting

-- View summary usaha per kecamatan
CREATE OR REPLACE VIEW v_business_summary_by_kecamatan AS
SELECT 
    kecamatan,
    COUNT(*) as total_usaha,
    SUM(CASE WHEN status = 'active' THEN 1 ELSE 0 END) as usaha_aktif,
    SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) as usaha_pending,
    SUM(CASE WHEN status = 'inactive' THEN 1 ELSE 0 END) as usaha_nonaktif,
    SUM(CASE WHEN jaringan_usaha = 'Tunggal' THEN 1 ELSE 0 END) as usaha_tunggal,
    SUM(CASE WHEN jaringan_usaha = 'Cabang' THEN 1 ELSE 0 END) as usaha_cabang,
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
    SUM(CASE WHEN status = 'active' THEN 1 ELSE 0 END) as usaha_aktif,
    SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) as usaha_pending,
    ROUND(AVG(tahun_berdiri), 0) as rata_rata_tahun_berdiri,
    GROUP_CONCAT(DISTINCT jaringan_usaha SEPARATOR ', ') as jenis_jaringan
FROM businesses
GROUP BY kecamatan, kelurahan
ORDER BY kecamatan, total_usaha DESC;

-- View distribusi usaha per tahun berdiri
CREATE OR REPLACE VIEW v_business_by_year AS
SELECT 
    tahun_berdiri,
    COUNT(*) as jumlah_usaha,
    SUM(CASE WHEN status = 'active' THEN 1 ELSE 0 END) as usaha_aktif,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM businesses), 2) as persentase
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
    DATEDIFF(CURDATE(), DATE(b.created_at)) as hari_pending
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
    SUM(CASE WHEN b.status = 'active' THEN 1 ELSE 0 END) as usaha_aktif,
    SUM(CASE WHEN b.status = 'pending' THEN 1 ELSE 0 END) as usaha_pending,
    SUM(CASE WHEN b.created_at >= DATE_SUB(CURDATE(), INTERVAL 30 DAY) THEN 1 ELSE 0 END) as usaha_bulan_ini,
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
WHERE created_at >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
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
    TIMESTAMPDIFF(HOUR, NOW(), us.expires_at) as hours_until_expiry
FROM user_sessions us
JOIN users u ON us.user_id = u.id
WHERE us.is_active = TRUE
AND us.expires_at > NOW()
ORDER BY us.last_activity DESC;

-- View top performing kecamatan
CREATE OR REPLACE VIEW v_top_kecamatan_performance AS
SELECT 
    kecamatan,
    COUNT(*) as total_usaha,
    SUM(CASE WHEN status = 'active' THEN 1 ELSE 0 END) as usaha_aktif,
    ROUND(SUM(CASE WHEN status = 'active' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as persentase_aktif,
    SUM(CASE WHEN created_at >= DATE_SUB(CURDATE(), INTERVAL 30 DAY) THEN 1 ELSE 0 END) as usaha_baru_bulan_ini,
    COUNT(DISTINCT user_id) as jumlah_petugas_aktif
FROM businesses
GROUP BY kecamatan
ORDER BY usaha_aktif DESC, persentase_aktif DESC;

-- View monthly business registration trend
CREATE OR REPLACE VIEW v_monthly_registration_trend AS
SELECT 
    DATE_FORMAT(created_at, '%Y-%m-01') as bulan,
    COUNT(*) as total_pendaftaran,
    SUM(CASE WHEN status = 'active' THEN 1 ELSE 0 END) as yang_disetujui,
    SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) as masih_pending,
    SUM(CASE WHEN status = 'rejected' THEN 1 ELSE 0 END) as ditolak
FROM businesses
WHERE created_at >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
GROUP BY DATE_FORMAT(created_at, '%Y-%m-01')
ORDER BY bulan DESC;

-- View business density per area (equivalent to PostgreSQL version)
CREATE OR REPLACE VIEW v_business_density_by_area AS
SELECT 
    kecamatan,
    COUNT(*) as total_businesses,
    SUM(CASE WHEN status = 'active' THEN 1 ELSE 0 END) as active_businesses,
    CASE kecamatan
        WHEN 'Siantar Barat' THEN ROUND(SUM(CASE WHEN status = 'active' THEN 1 ELSE 0 END) / 15.2, 2)
        WHEN 'Siantar Timur' THEN ROUND(SUM(CASE WHEN status = 'active' THEN 1 ELSE 0 END) / 12.8, 2)
        WHEN 'Siantar Utara' THEN ROUND(SUM(CASE WHEN status = 'active' THEN 1 ELSE 0 END) / 18.5, 2)
        WHEN 'Siantar Selatan' THEN ROUND(SUM(CASE WHEN status = 'active' THEN 1 ELSE 0 END) / 14.3, 2)
        WHEN 'Siantar Marihat' THEN ROUND(SUM(CASE WHEN status = 'active' THEN 1 ELSE 0 END) / 16.7, 2)
        WHEN 'Siantar Marimbun' THEN ROUND(SUM(CASE WHEN status = 'active' THEN 1 ELSE 0 END) / 13.9, 2)
        WHEN 'Siantar Martoba' THEN ROUND(SUM(CASE WHEN status = 'active' THEN 1 ELSE 0 END) / 11.4, 2)
        WHEN 'Siantar Sitalasari' THEN ROUND(SUM(CASE WHEN status = 'active' THEN 1 ELSE 0 END) / 17.2, 2)
        ELSE ROUND(SUM(CASE WHEN status = 'active' THEN 1 ELSE 0 END) / 15.0, 2)
    END as density_per_km2
FROM businesses
GROUP BY kecamatan
ORDER BY active_businesses DESC;

-- View business age distribution
CREATE OR REPLACE VIEW v_business_age_distribution AS
SELECT 
    CASE 
        WHEN YEAR(CURDATE()) - tahun_berdiri < 5 THEN 'Kurang dari 5 tahun'
        WHEN YEAR(CURDATE()) - tahun_berdiri < 10 THEN '5-10 tahun'
        WHEN YEAR(CURDATE()) - tahun_berdiri < 20 THEN '10-20 tahun'
        ELSE 'Lebih dari 20 tahun'
    END as kategori_umur,
    COUNT(*) as jumlah_usaha,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM businesses WHERE tahun_berdiri IS NOT NULL), 2) as persentase
FROM businesses
WHERE tahun_berdiri IS NOT NULL AND status = 'active'
GROUP BY kategori_umur
ORDER BY jumlah_usaha DESC;

-- View recent audit activities (last 7 days)
CREATE OR REPLACE VIEW v_recent_audit_activities AS
SELECT 
    al.created_at,
    al.action,
    al.table_name,
    al.description,
    u.name as user_name,
    u.email as user_email,
    al.ip_address
FROM audit_logs al
LEFT JOIN users u ON al.user_id = u.id
WHERE al.created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)
ORDER BY al.created_at DESC
LIMIT 50;

-- View business search analytics (for full-text search performance)
CREATE OR REPLACE VIEW v_business_search_data AS
SELECT 
    id,
    nama_usaha,
    nama_komersil,
    alamat,
    kecamatan,
    kelurahan,
    deskripsi_kegiatan,
    CONCAT_WS(' ', nama_usaha, nama_komersil, alamat, deskripsi_kegiatan) as searchable_text,
    status,
    latitude,
    longitude
FROM businesses
WHERE status = 'active';

-- Comments using ALTER TABLE (MySQL doesn't support COMMENT ON VIEW like PostgreSQL)
-- Instead, we'll add documentation as comments in the SQL
-- These views provide comprehensive analytics for the geotagging system:
-- - Business distribution by administrative areas
-- - Performance metrics for staff
-- - Temporal trends and patterns
-- - Active user sessions
-- - Audit trails for security
-- - Search optimization data
