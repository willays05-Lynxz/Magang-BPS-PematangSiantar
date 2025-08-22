-- Migration 004: Seed Data (MySQL Version)
-- Menambahkan data awal sistem

-- Insert default admin user (password: admin123)
INSERT INTO users (id, email, password_hash, name, role, is_active, email_verified) VALUES
(
    UUID(),
    'admin@bps-pematangsiantar.go.id',
    '$2b$12$LQv3c1yqBw.XqXBJnE8e4O9W1WL3KG7J9Q6R2Z5J8N3M4L5K6H7I8J',
    'Administrator BPS',
    'admin',
    TRUE,
    TRUE
);

-- Insert default user (password: user123)
INSERT INTO users (id, email, password_hash, name, role, is_active, email_verified) VALUES
(
    UUID(),
    'petugas1@bps-pematangsiantar.go.id',
    '$2b$12$KQv3c1yqBw.XqXBJnE8e4O9W1WL3KG7J9Q6R2Z5J8N3M4L5K6H7I9K',
    'Petugas BPS 1',
    'user',
    TRUE,
    TRUE
);

-- Insert additional sample users
INSERT INTO users (id, email, password_hash, name, role, is_active, email_verified) VALUES
(
    UUID(),
    'petugas2@bps-pematangsiantar.go.id',
    '$2b$12$KQv3c1yqBw.XqXBJnE8e4O9W1WL3KG7J9Q6R2Z5J8N3M4L5K6H7I9K',
    'Petugas BPS 2',
    'user',
    TRUE,
    TRUE
);

-- Insert sample businesses data (for testing)
-- Note: MySQL doesn't have DO blocks like PostgreSQL, so we'll use variables

-- Create a stored procedure to insert sample data
DELIMITER $$
CREATE PROCEDURE insert_sample_businesses()
BEGIN
    DECLARE admin_id CHAR(36);
    DECLARE user1_id CHAR(36);
    DECLARE user2_id CHAR(36);
    
    -- Get user IDs
    SELECT id INTO admin_id FROM users WHERE email = 'admin@bps-pematangsiantar.go.id' LIMIT 1;
    SELECT id INTO user1_id FROM users WHERE email = 'petugas1@bps-pematangsiantar.go.id' LIMIT 1;
    SELECT id INTO user2_id FROM users WHERE email = 'petugas2@bps-pematangsiantar.go.id' LIMIT 1;
    
    -- Insert sample businesses
    INSERT INTO businesses (
        nama_usaha, nama_komersil, alamat, kecamatan, kelurahan, kode_sls,
        telepon, email, tahun_berdiri, deskripsi_kegiatan, jaringan_usaha,
        latitude, longitude, user_id, status
    ) VALUES
    (
        'Toko Kelontong Maju Jaya',
        'Toko Maju',
        'Jl. Sudirman No. 123, RT 02/RW 05',
        'Siantar Utara',
        'Toba',
        '1234567001',
        '081234567001',
        'tokumaju@email.com',
        2015,
        'Menjual kebutuhan sehari-hari seperti beras, minyak goreng, gula, dan sembako lainnya untuk masyarakat sekitar',
        'Tunggal',
        2.9641,
        99.0687,
        user1_id,
        'active'
    ),
    (
        'Warung Makan Padang Sederhana',
        'RM Sederhana',
        'Jl. Merdeka No. 45, RT 01/RW 03',
        'Siantar Timur',
        'Merdeka',
        '1234567002',
        '081234567002',
        'rmsederhana@email.com',
        2018,
        'Rumah makan yang menyajikan masakan padang dengan berbagai pilihan lauk pauk dan sayuran',
        'Tunggal',
        2.9598,
        99.0734,
        user1_id,
        'active'
    ),
    (
        'Bengkel Motor Jaya',
        'Bengkel Jaya',
        'Jl. Ahmad Yani No. 67, RT 03/RW 02',
        'Siantar Barat',
        'Pahlawan',
        '1234567003',
        '081234567003',
        'bengkeljaya@email.com',
        2012,
        'Jasa service dan reparasi sepeda motor semua merk, penjualan spare part dan oli',
        'Tunggal',
        2.9678,
        99.0645,
        user1_id,
        'pending'
    ),
    (
        'Salon Cantik Indah',
        'Salon Indah',
        'Jl. Proklamasi No. 89, RT 04/RW 01',
        'Siantar Selatan',
        'Proklamasi',
        '1234567004',
        '081234567004',
        'salonindah@email.com',
        2020,
        'Salon kecantikan dengan layanan potong rambut, cat rambut, facial, dan perawatan kecantikan lainnya',
        'Tunggal',
        2.9612,
        99.0702,
        user2_id,
        'active'
    ),
    (
        'Warung Kopi Tradisional',
        'Warung Kopi Toba',
        'Jl. Pahlawan No. 156, RT 05/RW 04',
        'Siantar Marihat',
        'Marihat',
        '1234567005',
        '081234567005',
        'warungkopitoba@email.com',
        2019,
        'Warung kopi tradisional dengan menu kopi robusta dan arabika asli Sumatera, serta aneka kue tradisional',
        'Tunggal',
        2.9665,
        99.0723,
        user2_id,
        'active'
    ),
    (
        'Toko Material Bangunan',
        'Toko Material Siantar',
        'Jl. Teladan No. 234, RT 06/RW 03',
        'Siantar Marimbun',
        'Teladan',
        '1234567006',
        '081234567006',
        'materialsiantar@email.com',
        2010,
        'Menjual berbagai material bangunan seperti semen, besi, cat, keramik, dan perlengkapan konstruksi lainnya',
        'Cabang',
        2.9587,
        99.0756,
        user2_id,
        'active'
    ),
    (
        'Apotek Sehat Bersama',
        'Apotek Sehat',
        'Jl. Martoba No. 78, RT 02/RW 05',
        'Siantar Martoba',
        'Martoba',
        '1234567007',
        '081234567007',
        'apoteksehat@email.com',
        2016,
        'Apotek lengkap dengan obat-obatan, vitamin, alat kesehatan, dan konsultasi farmasi',
        'Tunggal',
        2.9623,
        99.0689,
        user1_id,
        'active'
    ),
    (
        'Laundry Express',
        'Clean & Fresh Laundry',
        'Jl. Sitalasari No. 45, RT 01/RW 02',
        'Siantar Sitalasari',
        'Sitalasari',
        '1234567008',
        '081234567008',
        'cleanfresh@email.com',
        2021,
        'Layanan laundry kiloan, dry cleaning, cuci sepatu, dan cuci karpet dengan sistem antar jemput',
        'Tunggal',
        2.9634,
        99.0698,
        user2_id,
        'pending'
    );
END$$
DELIMITER ;

-- Call the procedure to insert sample data
CALL insert_sample_businesses();

-- Drop the procedure after use
DROP PROCEDURE insert_sample_businesses;

-- Insert additional test data for comprehensive testing
INSERT INTO businesses (
    nama_usaha, nama_komersil, alamat, kecamatan, kelurahan, kode_sls,
    telepon, email, tahun_berdiri, deskripsi_kegiatan, jaringan_usaha,
    latitude, longitude, user_id, status
) 
SELECT 
    'Toko Elektronik Modern',
    'Elektronik Modern',
    'Jl. Sutomo No. 91, RT 05/RW 03',
    'Siantar Barat',
    'Sukadame',
    '1234567009',
    '081234567009',
    'elektronik@email.com',
    2014,
    'Menjual elektronik rumah tangga, gadget, dan aksesoris teknologi terbaru',
    'Tunggal',
    2.9654,
    99.0663,
    u.id,
    'active'
FROM users u WHERE u.email = 'petugas1@bps-pematangsiantar.go.id' LIMIT 1;

INSERT INTO businesses (
    nama_usaha, nama_komersil, alamat, kecamatan, kelurahan, kode_sls,
    telepon, email, tahun_berdiri, deskripsi_kegiatan, jaringan_usaha,
    latitude, longitude, user_id, status
) 
SELECT 
    'Kedai Bakso Malang',
    'Bakso Enak',
    'Jl. Diponegoro No. 134, RT 03/RW 01',
    'Siantar Timur',
    'Bah Kapul',
    '1234567010',
    '081234567010',
    'baksoenak@email.com',
    2017,
    'Kedai bakso dengan kuah kaldu sapi asli dan berbagai pilihan mie dan tahu',
    'Tunggal',
    2.9612,
    99.0745,
    u.id,
    'active'
FROM users u WHERE u.email = 'petugas2@bps-pematangsiantar.go.id' LIMIT 1;
