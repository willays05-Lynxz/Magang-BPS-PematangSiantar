-- Business Categories table schema
-- Table untuk menyimpan kategori usaha berdasarkan KBLI (Klasifikasi Baku Lapangan Usaha Indonesia)

CREATE TABLE IF NOT EXISTS business_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    kode_kbli VARCHAR(10) NOT NULL UNIQUE,
    nama_kategori VARCHAR(200) NOT NULL,
    deskripsi TEXT,
    parent_id UUID REFERENCES business_categories(id),
    level INTEGER NOT NULL DEFAULT 1,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Business Categories junction table
CREATE TABLE IF NOT EXISTS business_category_mappings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
    category_id UUID NOT NULL REFERENCES business_categories(id) ON DELETE CASCADE,
    is_primary BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(business_id, category_id)
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_business_categories_kode_kbli ON business_categories(kode_kbli);
CREATE INDEX IF NOT EXISTS idx_business_categories_parent_id ON business_categories(parent_id);
CREATE INDEX IF NOT EXISTS idx_business_categories_level ON business_categories(level);
CREATE INDEX IF NOT EXISTS idx_business_categories_is_active ON business_categories(is_active);

CREATE INDEX IF NOT EXISTS idx_business_category_mappings_business_id ON business_category_mappings(business_id);
CREATE INDEX IF NOT EXISTS idx_business_category_mappings_category_id ON business_category_mappings(category_id);
CREATE INDEX IF NOT EXISTS idx_business_category_mappings_is_primary ON business_category_mappings(is_primary);

-- Create updated_at trigger
CREATE TRIGGER update_business_categories_updated_at 
    BEFORE UPDATE ON business_categories 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Insert default categories (KBLI Level 1)
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

-- Comments
COMMENT ON TABLE business_categories IS 'Tabel kategori usaha berdasarkan KBLI (Klasifikasi Baku Lapangan Usaha Indonesia)';
COMMENT ON TABLE business_category_mappings IS 'Tabel penghubung antara usaha dan kategori KBLI';
COMMENT ON COLUMN business_categories.kode_kbli IS 'Kode KBLI unik';
COMMENT ON COLUMN business_categories.nama_kategori IS 'Nama kategori KBLI';
COMMENT ON COLUMN business_categories.parent_id IS 'ID kategori parent (untuk hierarki)';
COMMENT ON COLUMN business_categories.level IS 'Level hierarki kategori (1=utama, 2=sub, dst)';
COMMENT ON COLUMN business_category_mappings.is_primary IS 'Apakah kategori ini adalah kategori utama untuk usaha tersebut';
