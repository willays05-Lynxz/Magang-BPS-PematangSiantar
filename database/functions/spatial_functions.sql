-- Spatial Functions
-- Fungsi-fungsi untuk operasi geografis dan spatial

-- Function untuk menghitung jarak antara dua titik koordinat (dalam meter)
CREATE OR REPLACE FUNCTION calculate_distance(
    lat1 DECIMAL, lon1 DECIMAL, 
    lat2 DECIMAL, lon2 DECIMAL
) RETURNS DECIMAL AS $$
DECLARE
    earth_radius DECIMAL := 6371000; -- radius bumi dalam meter
    dlat DECIMAL;
    dlon DECIMAL;
    a DECIMAL;
    c DECIMAL;
    distance DECIMAL;
BEGIN
    dlat := radians(lat2 - lat1);
    dlon := radians(lon2 - lon1);
    
    a := sin(dlat/2) * sin(dlat/2) + 
         cos(radians(lat1)) * cos(radians(lat2)) * 
         sin(dlon/2) * sin(dlon/2);
    c := 2 * atan2(sqrt(a), sqrt(1-a));
    distance := earth_radius * c;
    
    RETURN distance;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Function untuk mencari usaha dalam radius tertentu
CREATE OR REPLACE FUNCTION find_businesses_in_radius(
    center_lat DECIMAL,
    center_lon DECIMAL,
    radius_meters DECIMAL DEFAULT 1000
) RETURNS TABLE (
    id UUID,
    nama_usaha VARCHAR(100),
    nama_komersil VARCHAR(100),
    alamat TEXT,
    latitude DECIMAL,
    longitude DECIMAL,
    distance_meters DECIMAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        b.id,
        b.nama_usaha,
        b.nama_komersil,
        b.alamat,
        b.latitude,
        b.longitude,
        calculate_distance(center_lat, center_lon, b.latitude, b.longitude) as distance_meters
    FROM businesses b
    WHERE b.status = 'active'
    AND calculate_distance(center_lat, center_lon, b.latitude, b.longitude) <= radius_meters
    ORDER BY distance_meters ASC;
END;
$$ LANGUAGE plpgsql;

-- Function untuk validasi koordinat dalam batas Pematang Siantar
CREATE OR REPLACE FUNCTION is_coordinate_in_pematangsiantar(
    lat DECIMAL,
    lon DECIMAL
) RETURNS BOOLEAN AS $$
BEGIN
    -- Batas koordinat Pematang Siantar
    -- Latitude: 2.8° - 3.1° LU
    -- Longitude: 98.9° - 99.2° BT
    RETURN (lat >= 2.8 AND lat <= 3.1 AND lon >= 98.9 AND lon <= 99.2);
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Function untuk mendapatkan usaha terdekat dari koordinat
CREATE OR REPLACE FUNCTION get_nearest_businesses(
    center_lat DECIMAL,
    center_lon DECIMAL,
    limit_count INTEGER DEFAULT 10
) RETURNS TABLE (
    id UUID,
    nama_usaha VARCHAR(100),
    alamat TEXT,
    kecamatan VARCHAR(50),
    kelurahan VARCHAR(50),
    latitude DECIMAL,
    longitude DECIMAL,
    distance_meters DECIMAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        b.id,
        b.nama_usaha,
        b.alamat,
        b.kecamatan,
        b.kelurahan,
        b.latitude,
        b.longitude,
        calculate_distance(center_lat, center_lon, b.latitude, b.longitude) as distance_meters
    FROM businesses b
    WHERE b.status = 'active'
    ORDER BY distance_meters ASC
    LIMIT limit_count;
END;
$$ LANGUAGE plpgsql;

-- Function untuk menghitung density usaha per kecamatan
CREATE OR REPLACE FUNCTION calculate_business_density_by_kecamatan()
RETURNS TABLE (
    kecamatan VARCHAR(50),
    total_businesses BIGINT,
    active_businesses BIGINT,
    density_per_km2 DECIMAL
) AS $$
DECLARE
    -- Perkiraan luas area per kecamatan (km²)
    kecamatan_areas JSONB := '{
        "Siantar Barat": 15.2,
        "Siantar Timur": 12.8,
        "Siantar Utara": 18.5,
        "Siantar Selatan": 14.3,
        "Siantar Marihat": 16.7,
        "Siantar Marimbun": 13.9,
        "Siantar Martoba": 11.4,
        "Siantar Sitalasari": 17.2
    }';
BEGIN
    RETURN QUERY
    SELECT 
        b.kecamatan,
        COUNT(*)::BIGINT as total_businesses,
        COUNT(CASE WHEN b.status = 'active' THEN 1 END)::BIGINT as active_businesses,
        ROUND(
            COUNT(CASE WHEN b.status = 'active' THEN 1 END)::DECIMAL / 
            (kecamatan_areas->b.kecamatan)::DECIMAL, 
            2
        ) as density_per_km2
    FROM businesses b
    GROUP BY b.kecamatan
    ORDER BY active_businesses DESC;
END;
$$ LANGUAGE plpgsql;

-- Function untuk deteksi potensi duplikasi usaha berdasarkan proximitas
CREATE OR REPLACE FUNCTION detect_potential_duplicates(
    distance_threshold DECIMAL DEFAULT 50.0
) RETURNS TABLE (
    business1_id UUID,
    business1_name VARCHAR(100),
    business2_id UUID,
    business2_name VARCHAR(100),
    distance_meters DECIMAL,
    similarity_score DECIMAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        b1.id as business1_id,
        b1.nama_usaha as business1_name,
        b2.id as business2_id,
        b2.nama_usaha as business2_name,
        calculate_distance(b1.latitude, b1.longitude, b2.latitude, b2.longitude) as distance_meters,
        ROUND(
            similarity(
                lower(b1.nama_usaha || ' ' || b1.alamat), 
                lower(b2.nama_usaha || ' ' || b2.alamat)
            ), 
            3
        ) as similarity_score
    FROM businesses b1
    CROSS JOIN businesses b2
    WHERE b1.id < b2.id
    AND b1.status = 'active'
    AND b2.status = 'active'
    AND calculate_distance(b1.latitude, b1.longitude, b2.latitude, b2.longitude) <= distance_threshold
    AND similarity(
        lower(b1.nama_usaha || ' ' || b1.alamat), 
        lower(b2.nama_usaha || ' ' || b2.alamat)
    ) > 0.3
    ORDER BY similarity_score DESC, distance_meters ASC;
END;
$$ LANGUAGE plpgsql;

-- Comments
COMMENT ON FUNCTION calculate_distance IS 'Menghitung jarak antara dua titik koordinat menggunakan formula Haversine';
COMMENT ON FUNCTION find_businesses_in_radius IS 'Mencari usaha dalam radius tertentu dari titik koordinat';
COMMENT ON FUNCTION is_coordinate_in_pematangsiantar IS 'Validasi apakah koordinat berada dalam batas Pematang Siantar';
COMMENT ON FUNCTION get_nearest_businesses IS 'Mendapatkan usaha terdekat dari koordinat tertentu';
COMMENT ON FUNCTION calculate_business_density_by_kecamatan IS 'Menghitung kepadatan usaha per kecamatan';
COMMENT ON FUNCTION detect_potential_duplicates IS 'Deteksi potensi duplikasi usaha berdasarkan proximitas dan similarity';
