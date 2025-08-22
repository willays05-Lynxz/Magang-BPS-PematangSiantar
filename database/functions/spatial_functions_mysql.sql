-- Spatial Functions (MySQL Version)
-- Fungsi-fungsi untuk operasi geografis dan spatial

-- Function untuk menghitung jarak antara dua titik koordinat (dalam meter)
-- MySQL has ST_Distance_Sphere function for Haversine distance
DELIMITER $$
CREATE FUNCTION calculate_distance(
    lat1 DECIMAL(10,8), 
    lon1 DECIMAL(11,8), 
    lat2 DECIMAL(10,8), 
    lon2 DECIMAL(11,8)
) RETURNS DECIMAL(10,2)
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE earth_radius DECIMAL := 6371000; -- radius bumi dalam meter
    DECLARE dlat DECIMAL;
    DECLARE dlon DECIMAL;
    DECLARE a DECIMAL;
    DECLARE c DECIMAL;
    DECLARE distance DECIMAL;
    
    SET dlat = RADIANS(lat2 - lat1);
    SET dlon = RADIANS(lon2 - lon1);
    
    SET a = SIN(dlat/2) * SIN(dlat/2) + 
            COS(RADIANS(lat1)) * COS(RADIANS(lat2)) * 
            SIN(dlon/2) * SIN(dlon/2);
    SET c = 2 * ATAN2(SQRT(a), SQRT(1-a));
    SET distance = earth_radius * c;
    
    RETURN ROUND(distance, 2);
END$$
DELIMITER ;

-- Alternative using MySQL built-in spatial functions (MySQL 5.7+)
DELIMITER $$
CREATE FUNCTION calculate_distance_spatial(
    lat1 DECIMAL(10,8), 
    lon1 DECIMAL(11,8), 
    lat2 DECIMAL(10,8), 
    lon2 DECIMAL(11,8)
) RETURNS DECIMAL(10,2)
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE point1 POINT;
    DECLARE point2 POINT;
    DECLARE distance DECIMAL;
    
    SET point1 = POINT(lon1, lat1);
    SET point2 = POINT(lon2, lat2);
    
    -- ST_Distance_Sphere calculates distance in meters
    SET distance = ST_Distance_Sphere(point1, point2);
    
    RETURN ROUND(distance, 2);
END$$
DELIMITER ;

-- Procedure untuk mencari usaha dalam radius tertentu
DELIMITER $$
CREATE PROCEDURE find_businesses_in_radius(
    IN center_lat DECIMAL(10,8),
    IN center_lon DECIMAL(11,8),
    IN radius_meters DECIMAL(10,2)
)
BEGIN
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
END$$
DELIMITER ;

-- Alternative using spatial index (more efficient for large datasets)
DELIMITER $$
CREATE PROCEDURE find_businesses_in_radius_spatial(
    IN center_lat DECIMAL(10,8),
    IN center_lon DECIMAL(11,8),
    IN radius_meters DECIMAL(10,2)
)
BEGIN
    DECLARE center_point POINT;
    SET center_point = POINT(center_lon, center_lat);
    
    SELECT 
        b.id,
        b.nama_usaha,
        b.nama_komersil,
        b.alamat,
        b.latitude,
        b.longitude,
        ST_Distance_Sphere(b.location, center_point) as distance_meters
    FROM businesses b
    WHERE b.status = 'active'
    AND ST_Distance_Sphere(b.location, center_point) <= radius_meters
    ORDER BY distance_meters ASC;
END$$
DELIMITER ;

-- Function untuk validasi koordinat dalam batas Pematang Siantar
DELIMITER $$
CREATE FUNCTION is_coordinate_in_pematangsiantar(
    lat DECIMAL(10,8),
    lon DECIMAL(11,8)
) RETURNS BOOLEAN
READS SQL DATA
DETERMINISTIC
BEGIN
    -- Batas koordinat Pematang Siantar
    -- Latitude: 2.8° - 3.1° LU
    -- Longitude: 98.9° - 99.2° BT
    RETURN (lat >= 2.8 AND lat <= 3.1 AND lon >= 98.9 AND lon <= 99.2);
END$$
DELIMITER ;

-- Procedure untuk mendapatkan usaha terdekat dari koordinat
DELIMITER $$
CREATE PROCEDURE get_nearest_businesses(
    IN center_lat DECIMAL(10,8),
    IN center_lon DECIMAL(11,8),
    IN limit_count INTEGER
)
BEGIN
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
END$$
DELIMITER ;

-- Procedure untuk menghitung density usaha per kecamatan
DELIMITER $$
CREATE PROCEDURE calculate_business_density_by_kecamatan()
BEGIN
    -- Perkiraan luas area per kecamatan (km²)
    -- MySQL doesn't have built-in JSON operators like PostgreSQL
    -- We'll use CASE statements instead
    
    SELECT 
        b.kecamatan,
        COUNT(*) as total_businesses,
        SUM(CASE WHEN b.status = 'active' THEN 1 ELSE 0 END) as active_businesses,
        ROUND(
            SUM(CASE WHEN b.status = 'active' THEN 1 ELSE 0 END) / 
            CASE b.kecamatan
                WHEN 'Siantar Barat' THEN 15.2
                WHEN 'Siantar Timur' THEN 12.8
                WHEN 'Siantar Utara' THEN 18.5
                WHEN 'Siantar Selatan' THEN 14.3
                WHEN 'Siantar Marihat' THEN 16.7
                WHEN 'Siantar Marimbun' THEN 13.9
                WHEN 'Siantar Martoba' THEN 11.4
                WHEN 'Siantar Sitalasari' THEN 17.2
                ELSE 15.0
            END, 
            2
        ) as density_per_km2
    FROM businesses b
    GROUP BY b.kecamatan
    ORDER BY active_businesses DESC;
END$$
DELIMITER ;

-- Procedure untuk deteksi potensi duplikasi usaha berdasarkan proximitas
-- Note: MySQL doesn't have similarity() function like PostgreSQL pg_trgm
-- We'll use SOUNDEX and string comparison as alternatives
DELIMITER $$
CREATE PROCEDURE detect_potential_duplicates(
    IN distance_threshold DECIMAL(10,2)
)
BEGIN
    SELECT 
        b1.id as business1_id,
        b1.nama_usaha as business1_name,
        b2.id as business2_id,
        b2.nama_usaha as business2_name,
        calculate_distance(b1.latitude, b1.longitude, b2.latitude, b2.longitude) as distance_meters,
        -- Simple similarity calculation using string comparison
        ROUND(
            (
                -- SOUNDEX similarity
                CASE WHEN SOUNDEX(b1.nama_usaha) = SOUNDEX(b2.nama_usaha) THEN 0.3 ELSE 0 END +
                -- Length difference factor
                (1 - ABS(LENGTH(b1.nama_usaha) - LENGTH(b2.nama_usaha)) / GREATEST(LENGTH(b1.nama_usaha), LENGTH(b2.nama_usaha))) * 0.2 +
                -- Common word check (simplified)
                CASE WHEN LOCATE(SUBSTRING(b1.nama_usaha, 1, 5), b2.nama_usaha) > 0 THEN 0.3 ELSE 0 END +
                -- Address similarity
                CASE WHEN SOUNDEX(b1.alamat) = SOUNDEX(b2.alamat) THEN 0.2 ELSE 0 END
            ), 
            3
        ) as similarity_score
    FROM businesses b1
    CROSS JOIN businesses b2
    WHERE b1.id < b2.id
    AND b1.status = 'active'
    AND b2.status = 'active'
    AND calculate_distance(b1.latitude, b1.longitude, b2.latitude, b2.longitude) <= distance_threshold
    HAVING similarity_score > 0.3
    ORDER BY similarity_score DESC, distance_meters ASC;
END$$
DELIMITER ;

-- Function untuk mendapatkan statistik usaha per kelurahan
DELIMITER $$
CREATE PROCEDURE get_business_stats_by_kelurahan(
    IN p_kecamatan VARCHAR(50)
)
BEGIN
    SELECT 
        kelurahan,
        COUNT(*) as total_businesses,
        SUM(CASE WHEN status = 'active' THEN 1 ELSE 0 END) as active_businesses,
        SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) as pending_businesses,
        SUM(CASE WHEN status = 'rejected' THEN 1 ELSE 0 END) as rejected_businesses,
        AVG(YEAR(CURDATE()) - tahun_berdiri) as avg_business_age,
        MIN(tahun_berdiri) as oldest_business_year,
        MAX(tahun_berdiri) as newest_business_year
    FROM businesses
    WHERE kecamatan = p_kecamatan OR p_kecamatan IS NULL
    GROUP BY kelurahan
    ORDER BY active_businesses DESC;
END$$
DELIMITER ;

-- Function untuk analisis distribusi jaringan usaha
DELIMITER $$
CREATE PROCEDURE analyze_business_network_distribution()
BEGIN
    SELECT 
        kecamatan,
        jaringan_usaha,
        COUNT(*) as total,
        ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY kecamatan), 2) as percentage_in_kecamatan,
        ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) as percentage_total
    FROM businesses
    WHERE status = 'active'
    GROUP BY kecamatan, jaringan_usaha
    ORDER BY kecamatan, jaringan_usaha;
END$$
DELIMITER ;
