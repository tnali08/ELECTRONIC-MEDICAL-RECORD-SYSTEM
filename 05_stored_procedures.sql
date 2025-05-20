DELIMITER //
-- Authenticate user
CREATE PROCEDURE sp_AuthenticateUser(
    IN p_username VARCHAR(50),
    IN p_password_hash VARCHAR(255)
)
BEGIN
    DECLARE v_user_id INT;
    DECLARE v_role VARCHAR(20);
    DECLARE v_status VARCHAR(20);
    
    -- Get user details
    SELECT user_id, role, status
    INTO v_user_id, v_role, v_status
    FROM User
    WHERE username = p_username AND password_hash = p_password_hash;
    
    -- Check if user exists and is active
    IF v_user_id IS NOT NULL THEN
        IF v_status = 'Active' THEN
            -- Update last login timestamp
            UPDATE User
            SET last_login = CURRENT_TIMESTAMP
            WHERE user_id = v_user_id;
            
            -- Set user context
            CALL set_current_user(v_user_id);
            
            -- Log activity
            INSERT INTO UserActivityLog (
                user_id, activity_type, entity_type, entity_id, activity_details
            ) VALUES (
                v_user_id, 'AUTHENTICATION', 'User', v_user_id, 
                'User logged in'
            );
            
            -- Return user details
            SELECT u.user_id, u.username, u.first_name, u.last_name,
                   u.email, u.role, u.provider_id, u.status,
                   CONCAT(p.first_name, ' ', p.last_name) AS provider_name,
                   p.specialty
            FROM User u
            LEFT JOIN Provider p ON u.provider_id = p.provider_id
            WHERE u.user_id = v_user_id;
        ELSE
            SELECT 'Account inactive or suspended' AS error;
        END IF;
    ELSE
        SELECT 'Invalid username or password' AS error;
    END IF;
END//

-- Get user activity log
CREATE PROCEDURE sp_GetUserActivityLog(
    IN p_user_id INT,
    IN p_start_date DATETIME,
    IN p_end_date DATETIME,
    IN p_entity_type VARCHAR(50),
    IN p_limit INT,
    IN p_offset INT
)
BEGIN
    -- Set default values if NULL is passed
    IF p_limit IS NULL THEN
        SET p_limit = 100;
    END IF;
    
    IF p_offset IS NULL THEN
        SET p_offset = 0;
    END IF;
    
    SELECT l.log_id, l.timestamp, l.activity_type, l.entity_type, l.entity_id,
           l.activity_details, l.ip_address,
           CONCAT(u.first_name, ' ', u.last_name) AS user_name, u.username
    FROM UserActivityLog l
    JOIN User u ON l.user_id = u.user_id
    WHERE (p_user_id IS NULL OR l.user_id = p_user_id)
      AND (p_start_date IS NULL OR l.timestamp >= p_start_date)
      AND (p_end_date IS NULL OR l.timestamp <= p_end_date)
      AND (p_entity_type IS NULL OR l.entity_type = p_entity_type)
    ORDER BY l.timestamp DESC
    LIMIT p_limit OFFSET p_offset;
    
    -- Get total count for pagination
    SELECT COUNT(*) AS total_count
    FROM UserActivityLog l
    WHERE (p_user_id IS NULL OR l.user_id = p_user_id)
      AND (p_start_date IS NULL OR l.timestamp >= p_start_date)
      AND (p_end_date IS NULL OR l.timestamp <= p_end_date)
      AND (p_entity_type IS NULL OR l.entity_type = p_entity_type);
END//

-- Reset delimiter
DELIMITER ;-- 05_stored_procedures.sql
-- Complete set of stored procedures for University Health Clinic EMR Project

USE university_health_clinic;

DELIMITER //

-- Set user context variable procedure
CREATE PROCEDURE set_current_user(IN p_user_id INT)
BEGIN
    SET @current_user_id = p_user_id;
END//

-- 1. Patient Management Procedures

-- Add a new patient
CREATE PROCEDURE sp_AddPatient(
    IN p_first_name VARCHAR(50),
    IN p_last_name VARCHAR(50),
    IN p_date_of_birth DATE,
    IN p_gender CHAR(1),
    IN p_student_id VARCHAR(20),
    IN p_email VARCHAR(100),
    IN p_phone VARCHAR(15),
    IN p_emergency_contact_name VARCHAR(100),
    IN p_emergency_contact_phone VARCHAR(15),
    IN p_street_address VARCHAR(100),
    IN p_city VARCHAR(50),
    IN p_state VARCHAR(30),
    IN p_postal_code VARCHAR(20)
)
BEGIN
    DECLARE v_patient_id INT;
    
    -- Get current user ID for audit
    SET @user_id = (SELECT @current_user_id);
    
    -- Start transaction
    START TRANSACTION;
    
    -- Insert patient record
    INSERT INTO Patient (
        first_name, last_name, date_of_birth, gender, student_id, 
        email, phone, emergency_contact_name, emergency_contact_phone,
        registration_date, active_status
    ) VALUES (
        p_first_name, p_last_name, p_date_of_birth, p_gender, p_student_id,
        p_email, p_phone, p_emergency_contact_name, p_emergency_contact_phone,
        CURRENT_TIMESTAMP, TRUE
    );
    
    -- Get the new patient ID
    SET v_patient_id = LAST_INSERT_ID();
    
    -- Insert address record
    INSERT INTO PatientAddress (
        patient_id, address_type, street_address, city, state, postal_code
    ) VALUES (
        v_patient_id, 'Primary', p_street_address, p_city, p_state, p_postal_code
    );
    
    -- Log activity
    IF @user_id IS NOT NULL THEN
        INSERT INTO UserActivityLog (
            user_id, activity_type, entity_type, entity_id, activity_details
        ) VALUES (
            @user_id, 'CREATE', 'Patient', v_patient_id, 
            CONCAT('Added new patient: ', p_first_name, ' ', p_last_name)
        );
    END IF;
    
    -- Commit transaction
    COMMIT;
    
    -- Return the new patient ID
    SELECT v_patient_id AS patient_id;
END//

-- Get patient details
CREATE PROCEDURE sp_GetPatientDetails(IN p_patient_id INT)
BEGIN
    -- Get patient demographics
    SELECT p.*, 
           pa.street_address, pa.city, pa.state, pa.postal_code,
           mh.allergies, mh.chronic_conditions, mh.past_surgeries, mh.family_history,
           ip.provider_name AS insurance_provider, 
           pi.policy_number, pi.group_number, 
           pi.coverage_start_date, pi.coverage_end_date
    FROM Patient p
    LEFT JOIN PatientAddress pa ON p.patient_id = pa.patient_id AND pa.address_type = 'Primary'
    LEFT JOIN MedicalHistory mh ON p.patient_id = mh.patient_id
    LEFT JOIN PatientInsurance pi ON p.patient_id = pi.patient_id AND pi.is_primary = TRUE
    LEFT JOIN InsuranceProvider ip ON pi.provider_id = ip.provider_id
    WHERE p.patient_id = p_patient_id;
    
    -- Get patient visit history
    SELECT v.visit_id, v.visit_date, v.visit_type, v.chief_complaint,
           f.facility_name, pr.first_name AS provider_first_name, pr.last_name AS provider_last_name,
           GROUP_CONCAT(DISTINCT icd.description SEPARATOR '; ') AS diagnoses
    FROM Visit v
    JOIN Facility f ON v.facility_id = f.facility_id
    JOIN Provider pr ON v.provider_id = pr.provider_id
    LEFT JOIN Diagnosis d ON v.visit_id = d.visit_id
    LEFT JOIN ICD10Codes icd ON d.icd_code = icd.icd_code
    WHERE v.patient_id = p_patient_id
    GROUP BY v.visit_id
    ORDER BY v.visit_date DESC;
    
    -- Get current prescriptions
    SELECT m.medication_name, p.dosage, p.frequency, p.instructions, 
           p.prescribed_at, p.status
    FROM Prescription p
    JOIN Medication m ON p.medication_id = m.medication_id
    JOIN Visit v ON p.visit_id = v.visit_id
    WHERE v.patient_id = p_patient_id AND p.status = 'Active'
    ORDER BY p.prescribed_at DESC;
END//

-- Update patient information
CREATE PROCEDURE sp_UpdatePatient(
    IN p_patient_id INT,
    IN p_email VARCHAR(100),
    IN p_phone VARCHAR(15),
    IN p_emergency_contact_name VARCHAR(100),
    IN p_emergency_contact_phone VARCHAR(15),
    IN p_street_address VARCHAR(100),
    IN p_city VARCHAR(50),
    IN p_state VARCHAR(30),
    IN p_postal_code VARCHAR(20)
)
BEGIN
    -- Get current user ID for audit
    SET @user_id = (SELECT @current_user_id);
    
    -- Start transaction
    START TRANSACTION;
    
    -- Update patient record
    UPDATE Patient
    SET email = p_email,
        phone = p_phone,
        emergency_contact_name = p_emergency_contact_name,
        emergency_contact_phone = p_emergency_contact_phone
    WHERE patient_id = p_patient_id;
    
    -- Update address record
    UPDATE PatientAddress
    SET street_address = p_street_address,
        city = p_city,
        state = p_state,
        postal_code = p_postal_code
    WHERE patient_id = p_patient_id AND address_type = 'Primary';
    
    -- Commit transaction
    COMMIT;
    
    -- Return success
    SELECT 'Patient updated successfully' AS message;
END//

-- Update patient medical history
CREATE PROCEDURE sp_UpdateMedicalHistory(
    IN p_patient_id INT,
    IN p_allergies TEXT,
    IN p_chronic_conditions TEXT,
    IN p_past_surgeries TEXT,
    IN p_family_history TEXT
)
BEGIN
    -- Get current user ID for audit
    SET @user_id = (SELECT @current_user_id);
    
    -- Check if medical history exists
    IF EXISTS (SELECT 1 FROM MedicalHistory WHERE patient_id = p_patient_id) THEN
        -- Update existing record
        UPDATE MedicalHistory
        SET allergies = p_allergies,
            chronic_conditions = p_chronic_conditions,
            past_surgeries = p_past_surgeries,
            family_history = p_family_history,
            last_updated = CURRENT_TIMESTAMP
        WHERE patient_id = p_patient_id;
    ELSE
        -- Insert new record
        INSERT INTO MedicalHistory (
            patient_id, allergies, chronic_conditions, past_surgeries, family_history
        ) VALUES (
            p_patient_id, p_allergies, p_chronic_conditions, p_past_surgeries, p_family_history
        );
    END IF;
    
    -- Log activity
    IF @user_id IS NOT NULL THEN
        INSERT INTO UserActivityLog (
            user_id, activity_type, entity_type, entity_id, activity_details
        ) VALUES (
            @user_id, 'UPDATE', 'MedicalHistory', p_patient_id, 
            'Updated medical history for patient'
        );
    END IF;
    
    -- Return success
    SELECT 'Medical history updated successfully' AS message;
END//

-- Add patient insurance
CREATE PROCEDURE sp_AddPatientInsurance(
    IN p_patient_id INT,
    IN p_provider_id INT,
    IN p_policy_number VARCHAR(50),
    IN p_group_number VARCHAR(50),
    IN p_coverage_start_date DATE,
    IN p_coverage_end_date DATE,
    IN p_is_primary BOOLEAN
)
BEGIN
    DECLARE v_insurance_id INT;
    
    -- Get current user ID for audit
    SET @user_id = (SELECT @current_user_id);
    
    -- If setting this as primary, update other policies to non-primary
    IF p_is_primary THEN
        UPDATE PatientInsurance
        SET is_primary = FALSE
        WHERE patient_id = p_patient_id AND is_primary = TRUE;
    END IF;
    
    -- Insert insurance record
    INSERT INTO PatientInsurance (
        patient_id, provider_id, policy_number, group_number,
        coverage_start_date, coverage_end_date, is_primary,
        verification_status, last_verified_date
    ) VALUES (
        p_patient_id, p_provider_id, p_policy_number, p_group_number,
        p_coverage_start_date, p_coverage_end_date, p_is_primary,
        'Pending', NULL
    );
    
    SET v_insurance_id = LAST_INSERT_ID();
    
    -- Log activity
    IF @user_id IS NOT NULL THEN
        INSERT INTO UserActivityLog (
            user_id, activity_type, entity_type, entity_id, activity_details
        ) VALUES (
            @user_id, 'CREATE', 'PatientInsurance', v_insurance_id, 
            CONCAT('Added insurance for patient ID ', p_patient_id)
        );
    END IF;
    
    -- Return the new insurance ID
    SELECT v_insurance_id AS insurance_id, 'Insurance added successfully' AS message;
END//

-- Search patients (modified for compatibility)
CREATE PROCEDURE sp_SearchPatients(
    IN p_search_term VARCHAR(100),
    IN p_limit INT,
    IN p_offset INT
)
BEGIN
    -- Set default values if NULL is passed
    IF p_limit IS NULL THEN
        SET p_limit = 10;
    END IF;
    
    IF p_offset IS NULL THEN
        SET p_offset = 0;
    END IF;
    
    SELECT 
        p.patient_id, p.first_name, p.last_name, p.date_of_birth,
        TIMESTAMPDIFF(YEAR, p.date_of_birth, CURDATE()) AS age,
        p.gender, p.student_id, p.email, p.phone,
        MAX(v.visit_date) AS last_visit_date
    FROM Patient p
    LEFT JOIN Visit v ON p.patient_id = v.patient_id
    WHERE 
        p.first_name LIKE CONCAT('%', p_search_term, '%') OR
        p.last_name LIKE CONCAT('%', p_search_term, '%') OR
        p.student_id LIKE CONCAT('%', p_search_term, '%') OR
        p.email LIKE CONCAT('%', p_search_term, '%') OR
        p.phone LIKE CONCAT('%', p_search_term, '%')
    GROUP BY p.patient_id
    ORDER BY p.last_name, p.first_name
    LIMIT p_limit OFFSET p_offset;
    
    -- Get total count for pagination
    SELECT COUNT(*) AS total_count
    FROM Patient
    WHERE 
        first_name LIKE CONCAT('%', p_search_term, '%') OR
        last_name LIKE CONCAT('%', p_search_term, '%') OR
        student_id LIKE CONCAT('%', p_search_term, '%') OR
        email LIKE CONCAT('%', p_search_term, '%') OR
        phone LIKE CONCAT('%', p_search_term, '%');
END//

-- 2. Appointment Procedures

-- Schedule a new appointment
CREATE PROCEDURE sp_ScheduleAppointment(
    IN p_patient_id INT,
    IN p_provider_id INT,
    IN p_room_id INT,
    IN p_appointment_date DATE,
    IN p_start_time TIME,
    IN p_end_time TIME,
    IN p_appointment_type VARCHAR(50),
    IN p_reason_for_visit TEXT
)
BEGIN
    DECLARE v_appointment_id INT;
    DECLARE v_conflict INT DEFAULT 0;
    
    -- Get current user ID for audit
    SET @user_id = (SELECT @current_user_id);
    
    -- Check for scheduling conflicts
    SELECT COUNT(*) INTO v_conflict
    FROM Appointment
    WHERE room_id = p_room_id
      AND appointment_date = p_appointment_date
      AND status != 'Cancelled'
      AND ((start_time <= p_start_time AND end_time > p_start_time)
           OR (start_time < p_end_time AND end_time >= p_end_time)
           OR (start_time >= p_start_time AND end_time <= p_end_time));
    
    IF v_conflict > 0 THEN
        SELECT 'Room scheduling conflict' AS error;
    ELSE
        -- Also check provider availability
        SELECT COUNT(*) INTO v_conflict
        FROM Appointment
        WHERE provider_id = p_provider_id
          AND appointment_date = p_appointment_date
          AND status != 'Cancelled'
          AND ((start_time <= p_start_time AND end_time > p_start_time)
               OR (start_time < p_end_time AND end_time >= p_end_time)
               OR (start_time >= p_start_time AND end_time <= p_end_time));
        
        IF v_conflict > 0 THEN
            SELECT 'Provider scheduling conflict' AS error;
        ELSE
            -- Insert appointment
            INSERT INTO Appointment (
                patient_id, provider_id, room_id, appointment_date, start_time, end_time,
                appointment_type, status, reason_for_visit, created_at, last_updated
            ) VALUES (
                p_patient_id, p_provider_id, p_room_id, p_appointment_date, p_start_time, p_end_time,
                p_appointment_type, 'Scheduled', p_reason_for_visit, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
            );
            
            SET v_appointment_id = LAST_INSERT_ID();
            
            -- Log activity
            IF @user_id IS NOT NULL THEN
                INSERT INTO UserActivityLog (
                    user_id, activity_type, entity_type, entity_id, activity_details
                ) VALUES (
                    @user_id, 'CREATE', 'Appointment', v_appointment_id, 
                    CONCAT('Scheduled appointment for patient ID ', p_patient_id, 
                           ' with provider ID ', p_provider_id,
                           ' on ', p_appointment_date, ' at ', p_start_time)
                );
            END IF;
            
            SELECT v_appointment_id AS appointment_id, 'Appointment scheduled successfully' AS message;
        END IF;
    END IF;
END//

-- Get provider's schedule
CREATE PROCEDURE sp_GetProviderSchedule(
    IN p_provider_id INT,
    IN p_date DATE
)
BEGIN
    SELECT a.appointment_id, a.appointment_date, a.start_time, a.end_time, 
           a.appointment_type, a.status, a.reason_for_visit,
           p.patient_id, p.first_name AS patient_first_name, p.last_name AS patient_last_name,
           r.room_number, f.facility_name
    FROM Appointment a
    JOIN Patient p ON a.patient_id = p.patient_id
    JOIN Room r ON a.room_id = r.room_id
    JOIN Facility f ON r.facility_id = f.facility_id
    WHERE a.provider_id = p_provider_id
      AND a.appointment_date = p_date
    ORDER BY a.start_time;
END//

-- Get appointments by date range
CREATE PROCEDURE sp_GetAppointmentsByDateRange(
    IN p_start_date DATE,
    IN p_end_date DATE,
    IN p_provider_id INT,
    IN p_facility_id INT
)
BEGIN
    SELECT a.appointment_id, a.appointment_date, a.start_time, a.end_time, 
           a.appointment_type, a.status, a.reason_for_visit,
           pt.patient_id, pt.first_name AS patient_first_name, pt.last_name AS patient_last_name,
           pr.provider_id, pr.first_name AS provider_first_name, pr.last_name AS provider_last_name,
           r.room_number, f.facility_name
    FROM Appointment a
    JOIN Patient pt ON a.patient_id = pt.patient_id
    JOIN Provider pr ON a.provider_id = pr.provider_id
    JOIN Room r ON a.room_id = r.room_id
    JOIN Facility f ON r.facility_id = f.facility_id
    WHERE a.appointment_date BETWEEN p_start_date AND p_end_date
      AND (p_provider_id IS NULL OR a.provider_id = p_provider_id)
      AND (p_facility_id IS NULL OR f.facility_id = p_facility_id)
    ORDER BY a.appointment_date, a.start_time;
END//

-- Cancel an appointment
CREATE PROCEDURE sp_CancelAppointment(
    IN p_appointment_id INT,
    IN p_cancellation_reason TEXT
)
BEGIN
    -- Get current user ID for audit
    SET @user_id = (SELECT @current_user_id);
    
    UPDATE Appointment
    SET status = 'Cancelled',
        notes = CONCAT(IFNULL(notes, ''), ' Cancellation reason: ', p_cancellation_reason),
        last_updated = CURRENT_TIMESTAMP
    WHERE appointment_id = p_appointment_id;
    
    -- Log activity
    IF @user_id IS NOT NULL THEN
        INSERT INTO UserActivityLog (
            user_id, activity_type, entity_type, entity_id, activity_details
        ) VALUES (
            @user_id, 'UPDATE', 'Appointment', p_appointment_id, 
            CONCAT('Cancelled appointment. Reason: ', p_cancellation_reason)
        );
    END IF;
    
    SELECT 'Appointment cancelled successfully' AS message;
END//

-- Reschedule an appointment
CREATE PROCEDURE sp_RescheduleAppointment(
    IN p_appointment_id INT,
    IN p_new_date DATE,
    IN p_new_start_time TIME,
    IN p_new_end_time TIME,
    IN p_new_room_id INT,
    IN p_reschedule_reason TEXT
)
BEGIN
    DECLARE v_conflict INT DEFAULT 0;
    DECLARE v_provider_id INT;
    
    -- Get current user ID for audit
    SET @user_id = (SELECT @current_user_id);
    
    -- Get provider ID from the appointment
    SELECT provider_id INTO v_provider_id
    FROM Appointment
    WHERE appointment_id = p_appointment_id;
    
    -- Check for scheduling conflicts
    SELECT COUNT(*) INTO v_conflict
    FROM Appointment
    WHERE room_id = p_new_room_id
      AND appointment_date = p_new_date
      AND appointment_id != p_appointment_id
      AND status != 'Cancelled'
      AND ((start_time <= p_new_start_time AND end_time > p_new_start_time)
           OR (start_time < p_new_end_time AND end_time >= p_new_end_time)
           OR (start_time >= p_new_start_time AND end_time <= p_new_end_time));
    
    IF v_conflict > 0 THEN
        SELECT 'Room scheduling conflict' AS error;
    ELSE
        -- Also check provider availability
        SELECT COUNT(*) INTO v_conflict
        FROM Appointment
        WHERE provider_id = v_provider_id
          AND appointment_date = p_new_date
          AND appointment_id != p_appointment_id
          AND status != 'Cancelled'
          AND ((start_time <= p_new_start_time AND end_time > p_new_start_time)
               OR (start_time < p_new_end_time AND end_time >= p_new_end_time)
               OR (start_time >= p_new_start_time AND end_time <= p_new_end_time));
        
        IF v_conflict > 0 THEN
            SELECT 'Provider scheduling conflict' AS error;
        ELSE
            -- Update appointment
            UPDATE Appointment
            SET appointment_date = p_new_date,
                start_time = p_new_start_time,
                end_time = p_new_end_time,
                room_id = p_new_room_id,
                status = 'Rescheduled',
                notes = CONCAT(IFNULL(notes, ''), ' Rescheduled reason: ', p_reschedule_reason),
                last_updated = CURRENT_TIMESTAMP
            WHERE appointment_id = p_appointment_id;
            
            -- Log activity
            IF @user_id IS NOT NULL THEN
                INSERT INTO UserActivityLog (
                    user_id, activity_type, entity_type, entity_id, activity_details
                ) VALUES (
                    @user_id, 'UPDATE', 'Appointment', p_appointment_id, 
                    CONCAT('Rescheduled appointment to ', p_new_date, ' at ', p_new_start_time)
                );
            END IF;
            
            SELECT 'Appointment rescheduled successfully' AS message;
        END IF;
    END IF;
END//

-- Get available rooms for appointment
CREATE PROCEDURE sp_GetAvailableRooms(
    IN p_facility_id INT,
    IN p_date DATE,
    IN p_start_time TIME,
    IN p_end_time TIME,
    IN p_room_type VARCHAR(50)
)
BEGIN
    -- Set default values if NULL is passed
    IF p_room_type IS NULL THEN
        SET p_room_type = NULL;
    END IF;
    
    SELECT r.room_id, r.room_number, r.room_type, r.capacity, f.facility_name
    FROM Room r
    JOIN Facility f ON r.facility_id = f.facility_id
    WHERE r.facility_id = p_facility_id
      AND r.status = 'Available'
      AND (p_room_type IS NULL OR r.room_type = p_room_type)
      AND NOT EXISTS (
          SELECT 1
          FROM Appointment a
          WHERE a.room_id = r.room_id
            AND a.appointment_date = p_date
            AND a.status NOT IN ('Cancelled', 'Completed')
            AND ((a.start_time <= p_start_time AND a.end_time > p_start_time)
                 OR (a.start_time < p_end_time AND a.end_time >= p_end_time)
                 OR (a.start_time >= p_start_time AND a.end_time <= p_end_time))
      )
    ORDER BY r.room_number;
END//

-- 3. Clinical Procedures

-- Record a visit
CREATE PROCEDURE sp_RecordVisit(
    IN p_appointment_id INT,
    IN p_patient_id INT,
    IN p_provider_id INT,
    IN p_facility_id INT,
    IN p_visit_type VARCHAR(50),
    IN p_chief_complaint TEXT
)
BEGIN
    DECLARE v_visit_id INT;
    
    -- Get current user ID for audit
    SET @user_id = (SELECT @current_user_id);
    
    -- Start transaction
    START TRANSACTION;
    
    -- Insert visit record
    INSERT INTO Visit (
        appointment_id, patient_id, provider_id, facility_id, visit_date,
        check_in_time, visit_type, chief_complaint
    ) VALUES (
        p_appointment_id, p_patient_id, p_provider_id, p_facility_id, CURDATE(),
        CURRENT_TIMESTAMP, p_visit_type, p_chief_complaint
    );
    
    SET v_visit_id = LAST_INSERT_ID();
    
    -- Update appointment status if provided
    IF p_appointment_id IS NOT NULL THEN
        UPDATE Appointment
        SET status = 'In Progress',
            last_updated = CURRENT_TIMESTAMP
        WHERE appointment_id = p_appointment_id;
    END IF;
    
    -- Log activity
    IF @user_id IS NOT NULL THEN
        INSERT INTO UserActivityLog (
            user_id, activity_type, entity_type, entity_id, activity_details
        ) VALUES (
            @user_id, 'CREATE', 'Visit', v_visit_id, 
            CONCAT('Recorded visit for patient ID ', p_patient_id, 
                   ' with provider ID ', p_provider_id)
        );
    END IF;
    
    -- Commit transaction
    COMMIT;
    
    SELECT v_visit_id AS visit_id, 'Visit recorded successfully' AS message;
END//

-- Record vital signs
CREATE PROCEDURE sp_RecordVitals(
    IN p_visit_id INT,
    IN p_temperature DECIMAL(4,1),
    IN p_blood_pressure_systolic INT,
    IN p_blood_pressure_diastolic INT,
    IN p_pulse_rate INT,
    IN p_respiratory_rate INT,
    IN p_height DECIMAL(5,2),
    IN p_weight DECIMAL(5,2),
    IN p_oxygen_saturation INT,
    IN p_pain_level INT,
    IN p_recorded_by INT
)
BEGIN
    DECLARE v_bmi DECIMAL(4,2);
    
    -- Calculate BMI if height and weight are provided
    IF p_height IS NOT NULL AND p_weight IS NOT NULL AND p_height > 0 THEN
        SET v_bmi = p_weight / ((p_height / 100) * (p_height / 100));
    END IF;
    
    -- Insert vitals record
    INSERT INTO Vitals (
        visit_id, temperature, blood_pressure_systolic, blood_pressure_diastolic,
        pulse_rate, respiratory_rate, height, weight, bmi, oxygen_saturation,
        pain_level, recorded_by, recorded_at
    ) VALUES (
        p_visit_id, p_temperature, p_blood_pressure_systolic, p_blood_pressure_diastolic,
        p_pulse_rate, p_respiratory_rate, p_height, p_weight, v_bmi, p_oxygen_saturation,
        p_pain_level, p_recorded_by, CURRENT_TIMESTAMP
    );
    
    -- Log activity
    IF (SELECT @current_user_id) IS NOT NULL THEN
        INSERT INTO UserActivityLog (
            user_id, activity_type, entity_type, entity_id, activity_details
        ) VALUES (
            (SELECT @current_user_id), 'CREATE', 'Vitals', LAST_INSERT_ID(), 
            CONCAT('Recorded vitals for visit ID ', p_visit_id)
        );
    END IF;
    
    SELECT 'Vitals recorded successfully' AS message;
END//

-- Record diagnosis
CREATE PROCEDURE sp_RecordDiagnosis(
    IN p_visit_id INT,
    IN p_icd_code VARCHAR(10),
    IN p_diagnosis_notes TEXT,
    IN p_diagnosed_by INT
)
BEGIN
    DECLARE v_diagnosis_id INT;
    
    -- Insert diagnosis
    INSERT INTO Diagnosis (
        visit_id, icd_code, diagnosis_notes, diagnosed_by, diagnosis_date
    ) VALUES (
        p_visit_id, p_icd_code, p_diagnosis_notes, p_diagnosed_by, CURRENT_TIMESTAMP
    );
    
    SET v_diagnosis_id = LAST_INSERT_ID();
    
    -- Get diagnosis description for logging
    SET @diagnosis_desc = (SELECT description FROM ICD10Codes WHERE icd_code = p_icd_code);
    
    -- Log activity
    IF (SELECT @current_user_id) IS NOT NULL THEN
        INSERT INTO UserActivityLog (
            user_id, activity_type, entity_type, entity_id, activity_details
        ) VALUES (
            (SELECT @current_user_id), 'CREATE', 'Diagnosis', v_diagnosis_id, 
            CONCAT('Recorded diagnosis: ', @diagnosis_desc, ' for visit ID ', p_visit_id)
        );
    END IF;
    
    SELECT v_diagnosis_id AS diagnosis_id, 'Diagnosis recorded successfully' AS message;
END//

-- Prescribe medication
CREATE PROCEDURE sp_PrescribeMedication(
    IN p_visit_id INT,
    IN p_medication_id INT,
    IN p_dosage VARCHAR(50),
    IN p_frequency VARCHAR(50),
    IN p_duration VARCHAR(50),
    IN p_quantity INT,
    IN p_refills INT,
    IN p_instructions TEXT,
    IN p_prescribed_by INT
)
BEGIN
    DECLARE v_prescription_id INT;
    DECLARE v_requires_auth BOOLEAN;
    DECLARE v_patient_id INT;
    
    -- Get medication authorization requirement
    SELECT requires_authorization INTO v_requires_auth
    FROM Medication
    WHERE medication_id = p_medication_id;
    
    -- Get patient ID for logging
    SELECT patient_id INTO v_patient_id
    FROM Visit
    WHERE visit_id = p_visit_id;
    
    -- Check if medication requires authorization and handle accordingly
    IF v_requires_auth THEN
        -- In a real system, you might implement an authorization workflow here
        -- For now, we'll just log the requirement and proceed
        IF (SELECT @current_user_id) IS NOT NULL THEN
            INSERT INTO UserActivityLog (
                user_id, activity_type, entity_type, entity_id, activity_details
            ) VALUES (
                (SELECT @current_user_id), 'WARNING', 'Medication', p_medication_id, 
                CONCAT('Medication requires authorization: ', p_medication_id, ' for visit ID ', p_visit_id)
            );
        END IF;
    END IF;
    
    -- Insert prescription
    INSERT INTO Prescription (
        visit_id, medication_id, dosage, frequency, duration, quantity,
        refills, instructions, prescribed_by, prescribed_at, status
    ) VALUES (
        p_visit_id, p_medication_id, p_dosage, p_frequency, p_duration, p_quantity,
        p_refills, p_instructions, p_prescribed_by, CURRENT_TIMESTAMP, 'Active'
    );
    
    SET v_prescription_id = LAST_INSERT_ID();
    
    -- Get medication name for logging
    SET @medication_name = (SELECT medication_name FROM Medication WHERE medication_id = p_medication_id);
    
    -- Log activity
    IF (SELECT @current_user_id) IS NOT NULL THEN
        INSERT INTO UserActivityLog (
            user_id, activity_type, entity_type, entity_id, activity_details
        ) VALUES (
            (SELECT @current_user_id), 'CREATE', 'Prescription', v_prescription_id, 
            CONCAT('Prescribed ', @medication_name, ' for patient ID ', v_patient_id)
        );
    END IF;
    
    SELECT v_prescription_id AS prescription_id, 'Medication prescribed successfully' AS message;
END//

-- Complete visit
CREATE PROCEDURE sp_CompleteVisit(
    IN p_visit_id INT,
    IN p_visit_notes TEXT,
    IN p_follow_up_required BOOLEAN,
    IN p_follow_up_notes TEXT
)
BEGIN
    DECLARE v_appointment_id INT;
    
    -- Get appointment ID if exists
    SELECT appointment_id INTO v_appointment_id
    FROM Visit
    WHERE visit_id = p_visit_id;
    
    -- Update visit record
    UPDATE Visit
    SET visit_notes = p_visit_notes,
        follow_up_required = p_follow_up_required,
        follow_up_notes = p_follow_up_notes,
        check_out_time = CURRENT_TIMESTAMP
    WHERE visit_id = p_visit_id;
    
    -- Update appointment status if exists
    IF v_appointment_id IS NOT NULL THEN
        UPDATE Appointment
        SET status = 'Completed',
            last_updated = CURRENT_TIMESTAMP
        WHERE appointment_id = v_appointment_id;
    END IF;
    
    -- Log activity
    IF (SELECT @current_user_id) IS NOT NULL THEN
        INSERT INTO UserActivityLog (
            user_id, activity_type, entity_type, entity_id, activity_details
        ) VALUES (
            (SELECT @current_user_id), 'UPDATE', 'Visit', p_visit_id, 
            'Completed visit'
        );
    END IF;
    
    SELECT 'Visit completed successfully' AS message;
END//

-- 4. Billing Procedures

-- Create invoice for visit
CREATE PROCEDURE sp_CreateInvoice(
    IN p_visit_id INT,
    IN p_billing_code_id INT,
    IN p_total_amount DECIMAL(10,2),
    IN p_created_by INT
)
BEGIN
    DECLARE v_invoice_id INT;
    DECLARE v_patient_id INT;
    DECLARE v_insurance_id INT;
    
    -- Get patient and insurance information
    SELECT v.patient_id, pi.insurance_id
    INTO v_patient_id, v_insurance_id
    FROM Visit v
    LEFT JOIN Patient p ON v.patient_id = p.patient_id
    LEFT JOIN PatientInsurance pi ON p.patient_id = pi.patient_id AND pi.is_primary = TRUE
    WHERE v.visit_id = p_visit_id;
    
    -- Insert invoice record
    INSERT INTO Invoice (
        visit_id, patient_id, insurance_id, billing_code_id,
        total_amount, remaining_amount, created_by, created_at,
        status
    ) VALUES (
        p_visit_id, v_patient_id, v_insurance_id, p_billing_code_id,
        p_total_amount, p_total_amount, p_created_by, CURRENT_TIMESTAMP,
        'Pending'
    );
    
    SET v_invoice_id = LAST_INSERT_ID();
    
    -- Log activity
    IF (SELECT @current_user_id) IS NOT NULL THEN
        INSERT INTO UserActivityLog (
            user_id, activity_type, entity_type, entity_id, activity_details
        ) VALUES (
            (SELECT @current_user_id), 'CREATE', 'Invoice', v_invoice_id, 
            CONCAT('Created invoice for visit ID ', p_visit_id, ' amount: ', p_total_amount)
        );
    END IF;
    
    SELECT v_invoice_id AS invoice_id, 'Invoice created successfully' AS message;
END//