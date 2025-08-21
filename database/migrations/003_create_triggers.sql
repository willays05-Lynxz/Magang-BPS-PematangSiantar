-- Migration 003: Create Triggers
-- Membuat triggers untuk audit, validasi, dan automasi

-- Updated_at triggers
CREATE TRIGGER update_users_updated_at 
    BEFORE UPDATE ON users 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_businesses_updated_at 
    BEFORE UPDATE ON businesses 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_business_categories_updated_at 
    BEFORE UPDATE ON business_categories 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_sessions_updated_at 
    BEFORE UPDATE ON user_sessions 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Audit trigger function
CREATE OR REPLACE FUNCTION audit_trigger_function()
RETURNS TRIGGER AS $$
BEGIN
    -- Insert audit log for all operations except SELECT
    IF TG_OP = 'DELETE' THEN
        INSERT INTO audit_logs (
            table_name, record_id, action, old_values, created_at
        ) VALUES (
            TG_TABLE_NAME, 
            OLD.id, 
            TG_OP::audit_action, 
            row_to_json(OLD)::jsonb, 
            CURRENT_TIMESTAMP
        );
        RETURN OLD;
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO audit_logs (
            table_name, record_id, action, old_values, new_values, created_at
        ) VALUES (
            TG_TABLE_NAME, 
            NEW.id, 
            TG_OP::audit_action, 
            row_to_json(OLD)::jsonb, 
            row_to_json(NEW)::jsonb, 
            CURRENT_TIMESTAMP
        );
        RETURN NEW;
    ELSIF TG_OP = 'INSERT' THEN
        INSERT INTO audit_logs (
            table_name, record_id, action, new_values, created_at
        ) VALUES (
            TG_TABLE_NAME, 
            NEW.id, 
            TG_OP::audit_action, 
            row_to_json(NEW)::jsonb, 
            CURRENT_TIMESTAMP
        );
        RETURN NEW;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Create audit triggers for main tables
CREATE TRIGGER audit_users_trigger
    AFTER INSERT OR UPDATE OR DELETE ON users
    FOR EACH ROW EXECUTE FUNCTION audit_trigger_function();

CREATE TRIGGER audit_businesses_trigger
    AFTER INSERT OR UPDATE OR DELETE ON businesses
    FOR EACH ROW EXECUTE FUNCTION audit_trigger_function();

-- Business validation trigger
CREATE OR REPLACE FUNCTION validate_business_data()
RETURNS TRIGGER AS $$
BEGIN
    -- Validate koordinat berada dalam batas Pematang Siantar
    -- Koordinat Pematang Siantar: sekitar 2.9°-3.0° LU, 99.0°-99.1° BT
    IF NEW.latitude < 2.8 OR NEW.latitude > 3.1 OR 
       NEW.longitude < 98.9 OR NEW.longitude > 99.2 THEN
        RAISE EXCEPTION 'Koordinat tidak valid untuk wilayah Pematang Siantar';
    END IF;
    
    -- Validate email unique dalam businesses
    IF EXISTS (
        SELECT 1 FROM businesses 
        WHERE email = NEW.email 
        AND id != COALESCE(NEW.id, '00000000-0000-0000-0000-000000000000'::uuid)
        AND status != 'rejected'
    ) THEN
        RAISE EXCEPTION 'Email usaha sudah terdaftar';
    END IF;
    
    -- Validate kode SLS unique
    IF EXISTS (
        SELECT 1 FROM businesses 
        WHERE kode_sls = NEW.kode_sls 
        AND id != COALESCE(NEW.id, '00000000-0000-0000-0000-000000000000'::uuid)
        AND status != 'rejected'
    ) THEN
        RAISE EXCEPTION 'Kode SLS sudah terdaftar';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER validate_business_data_trigger
    BEFORE INSERT OR UPDATE ON businesses
    FOR EACH ROW EXECUTE FUNCTION validate_business_data();

-- Auto cleanup expired sessions trigger
CREATE OR REPLACE FUNCTION auto_cleanup_sessions()
RETURNS TRIGGER AS $$
BEGIN
    -- Clean up expired sessions when new session is created
    DELETE FROM user_sessions 
    WHERE expires_at < CURRENT_TIMESTAMP 
    OR (is_active = FALSE AND created_at < CURRENT_TIMESTAMP - INTERVAL '7 days');
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER auto_cleanup_sessions_trigger
    AFTER INSERT ON user_sessions
    FOR EACH STATEMENT EXECUTE FUNCTION auto_cleanup_sessions();

-- User login tracking trigger
CREATE OR REPLACE FUNCTION track_user_login()
RETURNS TRIGGER AS $$
BEGIN
    -- Update last_login when new session is created
    UPDATE users 
    SET last_login = CURRENT_TIMESTAMP 
    WHERE id = NEW.user_id;
    
    -- Log login activity
    INSERT INTO audit_logs (
        user_id, action, metadata, ip_address, user_agent, created_at
    ) VALUES (
        NEW.user_id,
        'LOGIN'::audit_action,
        jsonb_build_object('session_id', NEW.id),
        NEW.ip_address,
        NEW.user_agent,
        CURRENT_TIMESTAMP
    );
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER track_user_login_trigger
    AFTER INSERT ON user_sessions
    FOR EACH ROW EXECUTE FUNCTION track_user_login();

-- Business verification trigger
CREATE OR REPLACE FUNCTION handle_business_verification()
RETURNS TRIGGER AS $$
BEGIN
    -- Log verification activity
    IF OLD.verified_at IS NULL AND NEW.verified_at IS NOT NULL THEN
        INSERT INTO audit_logs (
            user_id, table_name, record_id, action, 
            metadata, created_at
        ) VALUES (
            NEW.verified_by,
            'businesses',
            NEW.id,
            'VERIFY'::audit_action,
            jsonb_build_object(
                'business_name', NEW.nama_usaha,
                'verified_at', NEW.verified_at
            ),
            CURRENT_TIMESTAMP
        );
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER handle_business_verification_trigger
    AFTER UPDATE ON businesses
    FOR EACH ROW EXECUTE FUNCTION handle_business_verification();
