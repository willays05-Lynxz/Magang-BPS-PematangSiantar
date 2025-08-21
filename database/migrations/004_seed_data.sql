-- Migration 004: Seed Data
-- Menambahkan data awal sistem

-- Insert default admin user (password: admin123)
INSERT INTO users (id, email, password_hash, name, role, is_active, email_verified) VALUES
(
    gen_random_uuid(),
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
    gen_random_uuid(),
    'petugas1@bps-pematangsiantar.go.id',
    '$2b$12$KQv3c1yqBw.XqXBJnE8e4O9W1WL3KG7J9Q6R2Z5J8N3M4L5K6H7I9K',
    'Petugas BPS 1',
    'user',
    TRUE,
    TRUE
);

-- Insert KBLI Level 1 categories
INSERT INTO business_categories (kode_kbli, nama_kategori, deskripsi, level) VALUES
('A', 'Pertanian, Kehutanan dan Perikanan', 'Mencakup usaha pertanian tanaman pangan, hortikultura, perkebunan, peternakan, kehutanan dan perikanan', 1),
('B', 'Pertambangan dan Penggalian', 'Mencakup usaha ekstraksi mineral yang terjadi secara alami', 1),
('C', 'Industri Pengolahan', 'Mencakup kegiatan ekonomi yang melakukan transformasi secara fisik atau kimia dari bahan atau komponen menjadi produk baru', 1),
('D', 'Pengadaan Listrik, Gas, Uap dan Udara Dingin', 'Mencakup usaha pengadaan tenaga listrik, gas alam, uap/steam, udara dingin dan sejenisnya', 1),
('E', 'Pengelolaan Air, Pengelolaan Air Limbah, Pengelolaan dan Daur Ulang Sampah, dan Kegiatan Remediasi', 'Mencakup usaha pengelolaan air, pengelolaan air limbah, dan kegiatan remediasi', 1),
('F', 'Konstruksi', 'Mencakup usaha konstruksi gedung, konstruksi bangunan sipil dan konstruksi khusus', 1),
('G', 'Perdagangan Besar dan Eceran; Reparasi dan Perawatan Mobil dan Sepeda Motor', 'Mencakup usaha perdagangan besar dan eceran serta reparasi kendaraan bermotor', 1),
('H', 'Transportasi dan Pergudangan', 'Mencakup usaha angkutan darat, air, udara dan usaha pergudangan', 1),
('I', 'Penyediaan Akomodasi dan Penyediaan Makan Minum', 'Mencakup usaha penyediaan akomodasi jangka pendek dan penyediaan makanan dan minuman', 1),
('J', 'Informasi dan Komunikasi', 'Mencakup usaha penerbitan, produksi dan distribusi film, siaran radio dan televisi, telekomunikasi dan jasa informasi', 1),
('K', 'Jasa Keuangan dan Asuransi', 'Mencakup usaha jasa keuangan dan asuransi', 1),
('L', 'Real Estat', 'Mencakup usaha real estat atas dasar balas jasa atau kontrak', 1),
('M', 'Jasa Profesional, Ilmiah dan Teknis', 'Mencakup kegiatan profesional, ilmiah dan teknis yang memerlukan tingkat keahlian yang tinggi', 1),
('N', 'Jasa Persewaan dan Sewa Guna Usaha Tanpa Hak Opsi, Ketenagakerjaan, Agen Perjalanan dan Penunjang Usaha Lainnya', 'Mencakup usaha persewaan dan sewa guna, jasa ketenagakerjaan, agen perjalanan dan jasa penunjang usaha lainnya', 1),
('O', 'Administrasi Pemerintahan, Pertahanan dan Jaminan Sosial Wajib', 'Mencakup kegiatan administrasi pemerintahan dan kebijakan ekonomi dan sosial masyarakat', 1),
('P', 'Jasa Pendidikan', 'Mencakup pendidikan pada berbagai tingkat dan untuk berbagai mata pelajaran', 1),
('Q', 'Jasa Kesehatan dan Kegiatan Sosial', 'Mencakup penyediaan layanan kesehatan dan kegiatan sosial', 1),
('R', 'Kesenian, Hiburan dan Rekreasi', 'Mencakup berbagai kegiatan budaya, hiburan dan rekreasi', 1),
('S', 'Kegiatan Jasa Lainnya', 'Mencakup kegiatan organisasi dan badan internasional dan kegiatan jasa perorangan lainnya', 1),
('T', 'Kegiatan Rumah Tangga sebagai Pemberi Kerja; Kegiatan yang Menghasilkan Barang dan Jasa oleh Rumah Tangga yang Digunakan untuk Memenuhi Kebutuhan Sendiri', 'Mencakup kegiatan rumah tangga sebagai pemberi kerja dan kegiatan rumah tangga yang menghasilkan barang dan jasa untuk kebutuhan sendiri', 1),
('U', 'Kegiatan Badan Internasional dan Badan Ekstra Internasional Lainnya', 'Mencakup kegiatan badan internasional seperti PBB dan badan-badan khususnya, bank dunia, dan lain-lain', 1)
ON CONFLICT (kode_kbli) DO NOTHING;

-- Insert some common KBLI Level 2 categories
INSERT INTO business_categories (kode_kbli, nama_kategori, deskripsi, parent_id, level) VALUES
-- Perdagangan Eceran (G47)
('47', 'Perdagangan Eceran, Bukan Mobil dan Sepeda Motor', 'Perdagangan eceran barang baru atau bekas untuk konsumsi atau penggunaan pribadi atau rumah tangga', 
 (SELECT id FROM business_categories WHERE kode_kbli = 'G'), 2),
 
-- Industri Makanan (C10)
('10', 'Industri Makanan', 'Industri pengolahan makanan dan minuman',
 (SELECT id FROM business_categories WHERE kode_kbli = 'C'), 2),
 
-- Konstruksi Bangunan (F41)
('41', 'Konstruksi Bangunan', 'Konstruksi bangunan gedung tempat tinggal dan bukan tempat tinggal',
 (SELECT id FROM business_categories WHERE kode_kbli = 'F'), 2),
 
-- Restoran dan Rumah Makan (I56)
('56', 'Kegiatan Penyediaan Makan dan Minum', 'Restoran, rumah makan, warung, dan sejenisnya',
 (SELECT id FROM business_categories WHERE kode_kbli = 'I'), 2),
 
-- Jasa Keuangan (K64)
('64', 'Kegiatan Jasa Keuangan, Bukan Asuransi dan Dana Pensiun', 'Bank, koperasi, dan lembaga keuangan lainnya',
 (SELECT id FROM business_categories WHERE kode_kbli = 'K'), 2),
 
-- Jasa Kesehatan (Q86)
('86', 'Kegiatan Kesehatan Manusia', 'Rumah sakit, klinik, praktek dokter, dan fasilitas kesehatan lainnya',
 (SELECT id FROM business_categories WHERE kode_kbli = 'Q'), 2),
 
-- Jasa Pendidikan (P85)
('85', 'Jasa Pendidikan', 'Kegiatan pendidikan formal dan non-formal',
 (SELECT id FROM business_categories WHERE kode_kbli = 'P'), 2),
 
-- Transportasi Darat (H49)
('49', 'Angkutan Darat dan Angkutan Melalui Saluran Pipa', 'Angkutan darat penumpang dan barang',
 (SELECT id FROM business_categories WHERE kode_kbli = 'H'), 2)
ON CONFLICT (kode_kbli) DO NOTHING;

-- Insert sample Level 3 categories for common businesses
INSERT INTO business_categories (kode_kbli, nama_kategori, deskripsi, parent_id, level) VALUES
-- Toko kelontong (47211)
('472', 'Perdagangan Eceran Makanan, Minuman dan Tembakau di Toko Khusus', 'Toko kelontong, minimarket, supermarket',
 (SELECT id FROM business_categories WHERE kode_kbli = '47'), 3),
 
-- Warung makan (56101)
('561', 'Restoran dan Rumah Makan', 'Restoran, rumah makan, warung nasi, dll',
 (SELECT id FROM business_categories WHERE kode_kbli = '56'), 3),
 
-- Bengkel motor (45201)
('452', 'Perawatan dan Reparasi Sepeda Motor', 'Bengkel sepeda motor dan penjualan suku cadang',
 (SELECT id FROM business_categories WHERE kode_kbli = 'G'), 3),
 
-- Salon/barbershop (96021)
('960', 'Kegiatan Jasa Perorangan yang Melayani Rumah Tangga', 'Salon, barbershop, spa, dan jasa perawatan',
 (SELECT id FROM business_categories WHERE kode_kbli = 'S'), 3)
ON CONFLICT (kode_kbli) DO NOTHING;

-- Create sample businesses data (for testing)
DO $$
DECLARE
    admin_id UUID;
    user_id UUID;
BEGIN
    -- Get user IDs
    SELECT id INTO admin_id FROM users WHERE email = 'admin@bps-pematangsiantar.go.id';
    SELECT id INTO user_id FROM users WHERE email = 'petugas1@bps-pematangsiantar.go.id';
    
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
        user_id,
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
        user_id,
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
        user_id,
        'pending'
    );
END $$;
