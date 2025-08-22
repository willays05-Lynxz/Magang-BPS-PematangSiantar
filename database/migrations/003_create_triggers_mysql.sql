-- Migration 003: Create Triggers (MySQL Version)
-- Membuat trigger dan fungsi audit untuk MySQL

-- MySQL doesn't have the same trigger functions as PostgreSQL
-- We'll create individual triggers for each table

-- Audit trigger for users table
DELIMITER $$
CREATE TRIGGER audit_users_insert
    AFTER INSERT ON users
    FOR EACH ROW
BEGIN
    INSERT INTO audit_logs (
        user_id, table_name, record_id, action, new_values, 
        ip_address, user_agent, description
    ) VALUES (
        NEW.id, 'users', NEW.id, 'CREATE', 
        JSON_OBJECT(
            'id', NEW.id,
            'email', NEW.email,
            'name', NEW.name,
            'role', NEW.role,
            'is_active', NEW.is_active,
            'created_at', NEW.created_at
        ),
        @current_ip_address, @current_user_agent, 
        CONCAT('User created: ', NEW.name)
    );
END$$

CREATE TRIGGER audit_users_update
    AFTER UPDATE ON users
    FOR EACH ROW
BEGIN
    INSERT INTO audit_logs (
        user_id, table_name, record_id, action, old_values, new_values,
        ip_address, user_agent, description
    ) VALUES (
        NEW.id, 'users', NEW.id, 'UPDATE',
        JSON_OBJECT(
            'id', OLD.id,
            'email', OLD.email,
            'name', OLD.name,
            'role', OLD.role,
            'is_active', OLD.is_active,
            'updated_at', OLD.updated_at
        ),
        JSON_OBJECT(
            'id', NEW.id,
            'email', NEW.email,
            'name', NEW.name,
            'role', NEW.role,
            'is_active', NEW.is_active,
            'updated_at', NEW.updated_at
        ),
        @current_ip_address, @current_user_agent,
        CONCAT('User updated: ', NEW.name)
    );
END$$

CREATE TRIGGER audit_users_delete
    AFTER DELETE ON users
    FOR EACH ROW
BEGIN
    INSERT INTO audit_logs (
        user_id, table_name, record_id, action, old_values,
        ip_address, user_agent, description
    ) VALUES (
        OLD.id, 'users', OLD.id, 'DELETE',
        JSON_OBJECT(
            'id', OLD.id,
            'email', OLD.email,
            'name', OLD.name,
            'role', OLD.role,
            'is_active', OLD.is_active
        ),
        @current_ip_address, @current_user_agent,
        CONCAT('User deleted: ', OLD.name)
    );
END$$
DELIMITER ;

-- Audit triggers for businesses table
DELIMITER $$
CREATE TRIGGER audit_businesses_insert
    AFTER INSERT ON businesses
    FOR EACH ROW
BEGIN
    INSERT INTO audit_logs (
        user_id, table_name, record_id, action, new_values,
        ip_address, user_agent, description
    ) VALUES (
        NEW.user_id, 'businesses', NEW.id, 'CREATE',
        JSON_OBJECT(
            'id', NEW.id,
            'nama_usaha', NEW.nama_usaha,
            'nama_komersil', NEW.nama_komersil,
            'alamat', NEW.alamat,
            'kecamatan', NEW.kecamatan,
            'kelurahan', NEW.kelurahan,
            'status', NEW.status,
            'latitude', NEW.latitude,
            'longitude', NEW.longitude
        ),
        @current_ip_address, @current_user_agent,
        CONCAT('Business created: ', NEW.nama_usaha)
    );
END$$

CREATE TRIGGER audit_businesses_update
    AFTER UPDATE ON businesses
    FOR EACH ROW
BEGIN
    INSERT INTO audit_logs (
        user_id, table_name, record_id, action, old_values, new_values,
        ip_address, user_agent, description
    ) VALUES (
        NEW.user_id, 'businesses', NEW.id, 'UPDATE',
        JSON_OBJECT(
            'nama_usaha', OLD.nama_usaha,
            'status', OLD.status,
            'latitude', OLD.latitude,
            'longitude', OLD.longitude,
            'verified_at', OLD.verified_at
        ),
        JSON_OBJECT(
            'nama_usaha', NEW.nama_usaha,
            'status', NEW.status,
            'latitude', NEW.latitude,
            'longitude', NEW.longitude,
            'verified_at', NEW.verified_at
        ),
        @current_ip_address, @current_user_agent,
        CONCAT('Business updated: ', NEW.nama_usaha)
    );
END$$

CREATE TRIGGER audit_businesses_delete
    AFTER DELETE ON businesses
    FOR EACH ROW
BEGIN
    INSERT INTO audit_logs (
        user_id, table_name, record_id, action, old_values,
        ip_address, user_agent, description
    ) VALUES (
        OLD.user_id, 'businesses', OLD.id, 'DELETE',
        JSON_OBJECT(
            'id', OLD.id,
            'nama_usaha', OLD.nama_usaha,
            'alamat', OLD.alamat,
            'status', OLD.status
        ),
        @current_ip_address, @current_user_agent,
        CONCAT('Business deleted: ', OLD.nama_usaha)
    );
END$$
DELIMITER ;

-- Business validation trigger
DELIMITER $$
CREATE TRIGGER validate_business_data
    BEFORE INSERT ON businesses
    FOR EACH ROW
BEGIN
    -- Validate coordinates are within Pematang Siantar bounds
    IF NEW.latitude < 2.8 OR NEW.latitude > 3.1 OR 
       NEW.longitude < 98.9 OR NEW.longitude > 99.2 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Koordinat berada di luar batas Pematang Siantar';
    END IF;
    
    -- Validate phone number format (Indonesian)
    IF NEW.telepon NOT REGEXP '^(\\+62|62|0)[0-9]{8,13}$' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Format nomor telepon tidak valid';
    END IF;
    
    -- Set location point
    SET NEW.location = POINT(NEW.longitude, NEW.latitude);
END$$

CREATE TRIGGER validate_business_data_update
    BEFORE UPDATE ON businesses
    FOR EACH ROW
BEGIN
    -- Validate coordinates are within Pematang Siantar bounds
    IF NEW.latitude < 2.8 OR NEW.latitude > 3.1 OR 
       NEW.longitude < 98.9 OR NEW.longitude > 99.2 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Koordinat berada di luar batas Pematang Siantar';
    END IF;
    
    -- Validate phone number format (Indonesian)
    IF NEW.telepon NOT REGEXP '^(\\+62|62|0)[0-9]{8,13}$' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Format nomor telepon tidak valid';
    END IF;
    
    -- Update location point if coordinates changed
    IF NEW.latitude != OLD.latitude OR NEW.longitude != OLD.longitude THEN
        SET NEW.location = POINT(NEW.longitude, NEW.latitude);
    END IF;
END$$
DELIMITER ;

-- Auto cleanup expired sessions
DELIMITER $$
CREATE EVENT auto_cleanup_sessions
ON SCHEDULE EVERY 1 HOUR
DO
BEGIN
    -- Archive expired sessions to audit log before deletion
    INSERT INTO audit_logs (
        user_id, table_name, record_id, action, old_values,
        description, created_at
    )
    SELECT 
        user_id, 'user_sessions', id, 'DELETE',
        JSON_OBJECT(
            'id', id,
            'session_token', LEFT(session_token, 10),
            'expires_at', expires_at
        ),
        'Auto cleanup expired session',
        NOW()
    FROM user_sessions 
    WHERE expires_at < NOW() OR is_active = FALSE;
    
    -- Delete expired sessions
    DELETE FROM user_sessions 
    WHERE expires_at < NOW() OR is_active = FALSE;
END$$
DELIMITER ;

-- Enable event scheduler
SET GLOBAL event_scheduler = ON;

-- User login tracking procedure (to be called from application)
DELIMITER $$
CREATE PROCEDURE track_user_login(
    IN p_user_id CHAR(36),
    IN p_ip_address VARCHAR(45),
    IN p_user_agent TEXT
)
BEGIN
    -- Update last login
    UPDATE users 
    SET last_login = NOW() 
    WHERE id = p_user_id;
    
    -- Log login action
    INSERT INTO audit_logs (
        user_id, table_name, record_id, action,
        ip_address, user_agent, description
    ) VALUES (
        p_user_id, 'users', p_user_id, 'LOGIN',
        p_ip_address, p_user_agent, 'User logged in'
    );
END$$
DELIMITER ;

-- Business verification procedure
DELIMITER $$
CREATE PROCEDURE handle_business_verification(
    IN p_business_id CHAR(36),
    IN p_verified_by CHAR(36),
    IN p_action VARCHAR(10), -- 'VERIFY' or 'REJECT'
    IN p_ip_address VARCHAR(45),
    IN p_user_agent TEXT
)
BEGIN
    DECLARE v_nama_usaha VARCHAR(100);
    
    -- Get business name for logging
    SELECT nama_usaha INTO v_nama_usaha 
    FROM businesses 
    WHERE id = p_business_id;
    
    IF p_action = 'VERIFY' THEN
        UPDATE businesses 
        SET status = 'active', 
            verified_at = NOW(), 
            verified_by = p_verified_by 
        WHERE id = p_business_id;
        
        INSERT INTO audit_logs (
            user_id, table_name, record_id, action,
            ip_address, user_agent, description
        ) VALUES (
            p_verified_by, 'businesses', p_business_id, 'VERIFY',
            p_ip_address, p_user_agent, 
            CONCAT('Business verified: ', v_nama_usaha)
        );
    ELSE
        UPDATE businesses 
        SET status = 'rejected', 
            verified_by = p_verified_by 
        WHERE id = p_business_id;
        
        INSERT INTO audit_logs (
            user_id, table_name, record_id, action,
            ip_address, user_agent, description
        ) VALUES (
            p_verified_by, 'businesses', p_business_id, 'REJECT',
            p_ip_address, p_user_agent, 
            CONCAT('Business rejected: ', v_nama_usaha)
        );
    END IF;
END$$
DELIMITER ;
