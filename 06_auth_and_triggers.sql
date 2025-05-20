-- AUTHENTICATION AND TRIGGERS
-- For University Health Clinic EMR Project

USE university_health_clinic;

-- USER AUTHENTICATION SYSTEM

-- Create users table if not already created
CREATE TABLE IF NOT EXISTS Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    provider_id INT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    last_login DATETIME NULL,
    active BOOLEAN DEFAULT TRUE,
    CONSTRAINT fk_user_provider FOREIGN KEY (provider_id)
        REFERENCES Provider(provider_id)
        ON DELETE SET NULL
);

-- Create roles table if not already created
CREATE TABLE IF NOT EXISTS Roles (
    role_id INT AUTO_INCREMENT PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT
);

-- Create user_roles junction table if not already created
CREATE TABLE IF NOT EXISTS UserRoles (
    user_id INT NOT NULL,
    role_id INT NOT NULL,
    granted_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    granted_by INT,
    PRIMARY KEY (user_id, role_id),
    CONSTRAINT fk_userrole_user FOREIGN KEY (user_id)
        REFERENCES Users(user_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_userrole_role FOREIGN KEY (role_id)
        REFERENCES Roles(role_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_userrole_granter FOREIGN KEY (granted_by)
        REFERENCES Users(user_id)
        ON DELETE SET NULL
);

-- Create permissions table if not already created
CREATE TABLE IF NOT EXISTS Permissions (
    permission_id INT AUTO_INCREMENT PRIMARY KEY,
    permission_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT
);

-- Create role_permissions junction table if not already created
CREATE TABLE IF NOT EXISTS RolePermissions (
    role_id INT NOT NULL,
    permission_id INT NOT NULL,
    PRIMARY KEY (role_id, permission_id),
    CONSTRAINT fk_roleperm_role FOREIGN KEY (role_id)
        REFERENCES Roles(role_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_roleperm_permission FOREIGN KEY (permission_id)
        REFERENCES Permissions(permission_id)
        ON DELETE CASCADE
);

-- Create session management table if not already created
CREATE TABLE IF NOT EXISTS UserSessions (
    session_id VARCHAR(64) PRIMARY KEY,
    user_id INT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    expires_at DATETIME NOT NULL,
    ip_address VARCHAR(45),
    user_agent TEXT,
    CONSTRAINT fk_session_user FOREIGN KEY (user_id)
        REFERENCES Users(user_id)
        ON DELETE CASCADE
);

-- Create user activity log if not already created
CREATE TABLE IF NOT EXISTS UserActivityLog (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    activity_type VARCHAR(50) NOT NULL,
    entity_type VARCHAR(50),
    entity_id INT,
    activity_details TEXT,
    ip_address VARCHAR(45),
    activity_timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_activitylog_user FOREIGN KEY (user_id)
        REFERENCES Users(user_id)
        ON DELETE SET NULL
);

-- Insert default roles if they don't exist
INSERT IGNORE INTO Roles (role_name, description) VALUES
('Administrator', 'System administrator with full access to all functions'),
('Doctor', 'Medical provider with access to clinical functions'),
('Nurse', 'Nursing staff with limited clinical access'),
('Receptionist', 'Front desk staff for scheduling and check-in'),
('Billing', 'Billing department staff for financial operations');

-- Insert default permissions if they don't exist
INSERT IGNORE INTO Permissions (permission_name, description) VALUES
('patient:view', 'View patient information'),
('patient:add', 'Add new patients'),
('patient:edit', 'Edit patient information'),
('appointment:view', 'View appointments'),
('appointment:schedule', 'Schedule appointments'),
('appointment:cancel', 'Cancel appointments'),
('visit:record', 'Record patient visits'),
('diagnosis:add', 'Add diagnoses'),
('prescription:add', 'Add prescriptions'),
('labtest:order', 'Order lab tests'),
('billing:view', 'View billing information'),
('billing:add', 'Create billing records'),
('billing:process', 'Process payments'),
('report:run', 'Run system reports'),
('user:manage', 'Manage system users');

-- Assign permissions to roles if not already assigned
-- Administrator permissions (all)
INSERT IGNORE INTO RolePermissions 
SELECT (SELECT role_id FROM Roles WHERE role_name = 'Administrator'), permission_id 
FROM Permissions;

-- Doctor permissions
INSERT IGNORE INTO RolePermissions 
SELECT (SELECT role_id FROM Roles WHERE role_name = 'Doctor'), permission_id 
FROM Permissions 
WHERE permission_name IN (
    'patient:view', 'patient:edit', 'appointment:view', 'appointment:schedule', 
    'appointment:cancel', 'visit:record', 'diagnosis:add', 'prescription:add', 
    'labtest:order', 'report:run'
);

-- Nurse permissions
INSERT IGNORE INTO RolePermissions 
SELECT (SELECT role_id FROM Roles WHERE role_name = 'Nurse'), permission_id 
FROM Permissions 
WHERE permission_name IN (
    'patient:view', 'appointment:view', 'visit:record', 'labtest:order'
);

-- Receptionist permissions
INSERT IGNORE INTO RolePermissions 
SELECT (SELECT role_id FROM Roles WHERE role_name = 'Receptionist'), permission_id 
FROM Permissions 
WHERE permission_name IN (
    'patient:view', 'patient:add', 'patient:edit', 'appointment:view', 
    'appointment:schedule', 'appointment:cancel'
);

-- Billing permissions
INSERT IGNORE INTO RolePermissions 
SELECT (SELECT role_id FROM Roles WHERE role_name = 'Billing'), permission_id 
FROM Permissions 
WHERE permission_name IN (
    'patient:view', 'billing:view', 'billing:add', 'billing:process', 'report:run'
);

-- Create admin user if it doesn't exist
INSERT IGNORE INTO Users (username, password_hash, email, provider_id) VALUES
('admin', SHA2('password', 256), 'admin@clinic.edu', NULL);

-- Assign admin role to admin user if not already assigned
INSERT IGNORE INTO UserRoles (user_id, role_id, granted_by)
SELECT 
    (SELECT user_id FROM Users WHERE username = 'admin'),
    (SELECT role_id FROM Roles WHERE role_name = 'Administrator'),
    (SELECT user_id FROM Users WHERE username = 'admin')
WHERE NOT EXISTS (
    SELECT 1 FROM UserRoles 
    WHERE user_id = (SELECT user_id FROM Users WHERE username = 'admin')
    AND role_id = (SELECT role_id FROM Roles WHERE role_name = 'Administrator')
);

-- Create sample users if they don't exist
INSERT IGNORE INTO Users (username, password_hash, email, provider_id) VALUES
('dr.chen', SHA2('password', 256), 'r.chen@university.edu', 1),
('dr.williams', SHA2('password', 256), 's.williams@university.edu', 2),
('nurse.lee', SHA2('password', 256), 'o.lee@university.edu', 8),
('receptionist', SHA2('password', 256), 'reception@clinic.edu', NULL),
('billing', SHA2('password', 256), 'billing@clinic.edu', NULL);

-- Assign roles to sample users if not already assigned
INSERT IGNORE INTO UserRoles (user_id, role_id, granted_by)
SELECT 
    (SELECT user_id FROM Users WHERE username = 'dr.chen'),
    (SELECT role_id FROM Roles WHERE role_name = 'Doctor'),
    (SELECT user_id FROM Users WHERE username = 'admin')
WHERE NOT EXISTS (
    SELECT 1 FROM UserRoles 
    WHERE user_id = (SELECT user_id FROM Users WHERE username = 'dr.chen')
    AND role_id = (SELECT role_id FROM Roles WHERE role_name = 'Doctor')
);

INSERT IGNORE INTO UserRoles (user_id, role_id, granted_by)
SELECT 
    (SELECT user_id FROM Users WHERE username = 'dr.williams'),
    (SELECT role_id FROM Roles WHERE role_name = 'Doctor'),
    (SELECT user_id FROM Users WHERE username = 'admin')
WHERE NOT EXISTS (
    SELECT 1 FROM UserRoles 
    WHERE user_id = (SELECT user_id FROM Users WHERE username = 'dr.williams')
    AND role_id = (SELECT role_id FROM Roles WHERE role_name = 'Doctor')
);

INSERT IGNORE INTO UserRoles (user_id, role_id, granted_by)
SELECT 
    (SELECT user_id FROM Users WHERE username = 'nurse.lee'),
    (SELECT role_id FROM Roles WHERE role_name = 'Nurse'),
    (SELECT user_id FROM Users WHERE username = 'admin')
WHERE NOT EXISTS (
    SELECT 1 FROM UserRoles 
    WHERE user_id = (SELECT user_id FROM Users WHERE username = 'nurse.lee')
    AND role_id = (SELECT role_id FROM Roles WHERE role_name = 'Nurse')
);

INSERT IGNORE INTO UserRoles (user_id, role_id, granted_by)
SELECT 
    (SELECT user_id FROM Users WHERE username = 'receptionist'),
    (SELECT role_id FROM Roles WHERE role_name = 'Receptionist'),
    (SELECT user_id FROM Users WHERE username = 'admin')
WHERE NOT EXISTS (
    SELECT 1 FROM UserRoles 
    WHERE user_id = (SELECT user_id FROM Users WHERE username = 'receptionist')
    AND role_id = (SELECT role_id FROM Roles WHERE role_name = 'Receptionist')
);

INSERT IGNORE INTO UserRoles (user_id, role_id, granted_by)
SELECT 
    (SELECT user_id FROM Users WHERE username = 'billing'),
    (SELECT role_id FROM Roles WHERE role_name = 'Billing'),
    (SELECT user_id FROM Users WHERE username = 'admin')
WHERE NOT EXISTS (
    SELECT 1 FROM UserRoles 
    WHERE user_id = (SELECT user_id FROM Users WHERE username = 'billing')
    AND role_id = (SELECT role_id FROM Roles WHERE role_name = 'Billing')
);

-- AUDIT TRAIL SETUP

-- Create additional audit tables if needed

-- Create PatientInsuranceAudit table if not exists
CREATE TABLE IF NOT EXISTS PatientInsuranceAudit (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    insurance_id INT NOT NULL,
    action_type ENUM('INSERT', 'UPDATE', 'DELETE') NOT NULL,
    field_changed VARCHAR(50),
    old_value TEXT,
    new_value TEXT,
    changed_by INT,
    change_timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_insuranceaudit_insurance FOREIGN KEY (insurance_id)
        REFERENCES PatientInsurance(insurance_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_insuranceaudit_user FOREIGN KEY (changed_by)
        REFERENCES Users(user_id)
        ON DELETE SET NULL
);

-- Create MedicalHistoryAudit table if not exists
CREATE TABLE IF NOT EXISTS MedicalHistoryAudit (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    history_id INT NOT NULL,
    action_type ENUM('INSERT', 'UPDATE', 'DELETE') NOT NULL,
    field_changed VARCHAR(50),
    old_value TEXT,
    new_value TEXT,
    changed_by INT,
    change_timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_historyaudit_history FOREIGN KEY (history_id)
        REFERENCES MedicalHistory(history_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_historyaudit_user FOREIGN KEY (changed_by)
        REFERENCES Users(user_id)
        ON DELETE SET NULL
);

-- Create audit trigger for PatientInsurance
DELIMITER //

CREATE TRIGGER IF NOT EXISTS tr_patient_insurance_update AFTER UPDATE ON PatientInsurance
FOR EACH ROW
BEGIN
    -- Get current user ID for audit
    SET @user_id = (SELECT @current_user_id);
    
    IF OLD.policy_number != NEW.policy_number THEN
        INSERT INTO PatientInsuranceAudit (
            insurance_id, action_type, field_changed, old_value, new_value, changed_by
        ) VALUES (
            NEW.insurance_id, 'UPDATE', 'policy_number', OLD.policy_number, NEW.policy_number, @user_id
        );
    END IF;
    
    IF OLD.coverage_start_date != NEW.coverage_start_date THEN
        INSERT INTO PatientInsuranceAudit (
            insurance_id, action_type, field_changed, old_value, new_value, changed_by
        ) VALUES (
            NEW.insurance_id, 'UPDATE', 'coverage_start_date', 
            DATE_FORMAT(OLD.coverage_start_date, '%Y-%m-%d'), 
            DATE_FORMAT(NEW.coverage_start_date, '%Y-%m-%d'), 
            @user_id
        );
    END IF;
    
    IF OLD.coverage_end_date != NEW.coverage_end_date THEN
        INSERT INTO PatientInsuranceAudit (
            insurance_id, action_type, field_changed, old_value, new_value, changed_by
        ) VALUES (
            NEW.insurance_id, 'UPDATE', 'coverage_end_date', 
            DATE_FORMAT(OLD.coverage_end_date, '%Y-%m-%d'), 
            DATE_FORMAT(NEW.coverage_end_date, '%Y-%m-%d'), 
            @user_id
        );
    END IF;
    
    IF OLD.verification_status != NEW.verification_status THEN
        INSERT INTO PatientInsuranceAudit (
            insurance_id, action_type, field_changed, old_value, new_value, changed_by
        ) VALUES (
            NEW.insurance_id, 'UPDATE', 'verification_status', 
            OLD.verification_status, NEW.verification_status, @user_id
        );
    END IF;
    
    -- Log activity
    INSERT INTO UserActivityLog (
        user_id, activity_type, entity_type, entity_id, activity_details
    ) VALUES (
        @user_id, 'UPDATE', 'PatientInsurance', NEW.insurance_id, 
        CONCAT('Updated insurance information for patient ID ', NEW.patient_id)
    );
END//

CREATE TRIGGER IF NOT EXISTS tr_medical_history_update AFTER UPDATE ON MedicalHistory
FOR EACH ROW
BEGIN
    -- Get current user ID for audit
    SET @user_id = (SELECT @current_user_id);
    
    IF OLD.allergies != NEW.allergies THEN
        INSERT INTO MedicalHistoryAudit (
            history_id, action_type, field_changed, old_value, new_value, changed_by
        ) VALUES (
            NEW.history_id, 'UPDATE', 'allergies', OLD.allergies, NEW.allergies, @user_id
        );
    END IF;
    
    IF OLD.chronic_conditions != NEW.chronic_conditions THEN
        INSERT INTO MedicalHistoryAudit (
            history_id, action_type, field_changed, old_value, new_value, changed_by
        ) VALUES (
            NEW.history_id, 'UPDATE', 'chronic_conditions', 
            OLD.chronic_conditions, NEW.chronic_conditions, @user_id
        );
    END IF;
    
    IF OLD.past_surgeries != NEW.past_surgeries THEN
        INSERT INTO MedicalHistoryAudit (
            history_id, action_type, field_changed, old_value, new_value, changed_by
        ) VALUES (
            NEW.history_id, 'UPDATE', 'past_surgeries', 
            OLD.past_surgeries, NEW.past_surgeries, @user_id
        );
    END IF;
    
    IF OLD.family_history != NEW.family_history THEN
        INSERT INTO MedicalHistoryAudit (
            history_id, action_type, field_changed, old_value, new_value, changed_by
        ) VALUES (
            NEW.history_id, 'UPDATE', 'family_history', 
            OLD.family_history, NEW.family_history, @user_id
        );
    END IF;
    
    -- Log activity
    INSERT INTO UserActivityLog (
        user_id, activity_type, entity_type, entity_id, activity_details
    ) VALUES (
        @user_id, 'UPDATE', 'MedicalHistory', NEW.history_id, 
        CONCAT('Updated medical history for patient ID ', NEW.patient_id)
    );
END//

DELIMITER ;