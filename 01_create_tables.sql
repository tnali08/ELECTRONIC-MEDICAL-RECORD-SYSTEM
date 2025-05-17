-- DATABASE CREATION AND TABLES
-- For University Health Clinic EMR Project

-- Create database
DROP DATABASE IF EXISTS university_health_clinic;
CREATE DATABASE university_health_clinic;
USE university_health_clinic;

-- Patient Table
CREATE TABLE Patient (
    patient_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender CHAR(1) CHECK (gender IN ('M', 'F', 'O')),
    student_id VARCHAR(20) UNIQUE,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(15),
    emergency_contact_name VARCHAR(100),
    emergency_contact_phone VARCHAR(15),
    registration_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    active_status BOOLEAN DEFAULT TRUE
);

-- PatientAddress Table
CREATE TABLE PatientAddress (
    address_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    address_type VARCHAR(20) DEFAULT 'Primary',
    street_address VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL,
    state VARCHAR(30) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    country VARCHAR(50) DEFAULT 'United States',
    CONSTRAINT fk_address_patient FOREIGN KEY (patient_id)
        REFERENCES Patient(patient_id)
        ON DELETE CASCADE
);

-- InsuranceProvider Table
CREATE TABLE InsuranceProvider (
    provider_id INT AUTO_INCREMENT PRIMARY KEY,
    provider_name VARCHAR(100) NOT NULL,
    contact_phone VARCHAR(15),
    contact_email VARCHAR(100),
    notes TEXT
);

-- PatientInsurance Table
CREATE TABLE PatientInsurance (
    insurance_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    provider_id INT NOT NULL,
    policy_number VARCHAR(50) NOT NULL,
    group_number VARCHAR(50),
    coverage_start_date DATE NOT NULL,
    coverage_end_date DATE,
    is_primary BOOLEAN DEFAULT TRUE,
    verification_status VARCHAR(20) DEFAULT 'Pending',
    last_verified_date DATE,
    CONSTRAINT fk_insurance_patient FOREIGN KEY (patient_id)
        REFERENCES Patient(patient_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_insurance_provider FOREIGN KEY (provider_id)
        REFERENCES InsuranceProvider(provider_id)
        ON DELETE RESTRICT
);

-- MedicalHistory Table
CREATE TABLE MedicalHistory (
    history_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    allergies TEXT,
    chronic_conditions TEXT,
    past_surgeries TEXT,
    family_history TEXT,
    last_updated DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_history_patient FOREIGN KEY (patient_id)
        REFERENCES Patient(patient_id)
        ON DELETE CASCADE
);

-- Provider Table
CREATE TABLE Provider (
    provider_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    credentials VARCHAR(50) NOT NULL,
    specialty VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(15),
    national_provider_id VARCHAR(20) UNIQUE,
    hire_date DATE,
    status VARCHAR(20) DEFAULT 'Active'
);

-- Facility Table
CREATE TABLE Facility (
    facility_id INT AUTO_INCREMENT PRIMARY KEY,
    facility_name VARCHAR(100) NOT NULL,
    location VARCHAR(100) NOT NULL,
    capacity INT,
    phone VARCHAR(15),
    opening_hours VARCHAR(100),
    notes TEXT
);

-- Room Table
CREATE TABLE Room (
    room_id INT AUTO_INCREMENT PRIMARY KEY,
    facility_id INT NOT NULL,
    room_number VARCHAR(20) NOT NULL,
    room_type VARCHAR(50) NOT NULL,
    capacity INT DEFAULT 1,
    status VARCHAR(20) DEFAULT 'Available',
    equipment TEXT,
    notes TEXT,
    CONSTRAINT fk_room_facility FOREIGN KEY (facility_id)
        REFERENCES Facility(facility_id)
        ON DELETE RESTRICT,
    CONSTRAINT uc_facility_room UNIQUE (facility_id, room_number)
);

-- Appointment Table
CREATE TABLE Appointment (
    appointment_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    provider_id INT NOT NULL,
    room_id INT,
    appointment_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    appointment_type VARCHAR(50) NOT NULL,
    status VARCHAR(20) DEFAULT 'Scheduled',
    reason_for_visit TEXT,
    notes TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    last_updated DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_appointment_patient FOREIGN KEY (patient_id)
        REFERENCES Patient(patient_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_appointment_provider FOREIGN KEY (provider_id)
        REFERENCES Provider(provider_id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_appointment_room FOREIGN KEY (room_id)
        REFERENCES Room(room_id)
        ON DELETE SET NULL
);

-- Visit Table
CREATE TABLE Visit (
    visit_id INT AUTO_INCREMENT PRIMARY KEY,
    appointment_id INT,
    patient_id INT NOT NULL,
    provider_id INT NOT NULL,
    facility_id INT NOT NULL,
    visit_date DATE NOT NULL,
    check_in_time DATETIME NOT NULL,
    check_out_time DATETIME,
    visit_type VARCHAR(50) NOT NULL,
    visit_reason TEXT,
    chief_complaint TEXT,
    CONSTRAINT fk_visit_appointment FOREIGN KEY (appointment_id)
        REFERENCES Appointment(appointment_id)
        ON DELETE SET NULL,
    CONSTRAINT fk_visit_patient FOREIGN KEY (patient_id)
        REFERENCES Patient(patient_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_visit_provider FOREIGN KEY (provider_id)
        REFERENCES Provider(provider_id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_visit_facility FOREIGN KEY (facility_id)
        REFERENCES Facility(facility_id)
        ON DELETE RESTRICT
);

-- Vitals Table
CREATE TABLE Vitals (
    vitals_id INT AUTO_INCREMENT PRIMARY KEY,
    visit_id INT NOT NULL,
    temperature DECIMAL(4,1),
    blood_pressure_systolic INT,
    blood_pressure_diastolic INT,
    pulse_rate INT,
    respiratory_rate INT,
    height DECIMAL(5,2),
    weight DECIMAL(5,2),
    bmi DECIMAL(4,2),
    oxygen_saturation INT,
    pain_level INT CHECK (pain_level BETWEEN 0 AND 10),
    recorded_by INT,
    recorded_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_vitals_visit FOREIGN KEY (visit_id)
        REFERENCES Visit(visit_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_vitals_provider FOREIGN KEY (recorded_by)
        REFERENCES Provider(provider_id)
        ON DELETE SET NULL
);

-- ICD10Codes Table (for standardized diagnosis codes)
CREATE TABLE ICD10Codes (
    icd_code VARCHAR(10) PRIMARY KEY,
    description VARCHAR(255) NOT NULL,
    category VARCHAR(100),
    is_billable BOOLEAN DEFAULT TRUE
);

-- Diagnosis Table
CREATE TABLE Diagnosis (
    diagnosis_id INT AUTO_INCREMENT PRIMARY KEY,
    visit_id INT NOT NULL,
    icd_code VARCHAR(10) NOT NULL,
    diagnosis_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    diagnosis_notes TEXT,
    diagnosed_by INT NOT NULL,
    CONSTRAINT fk_diagnosis_visit FOREIGN KEY (visit_id)
        REFERENCES Visit(visit_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_diagnosis_icd FOREIGN KEY (icd_code)
        REFERENCES ICD10Codes(icd_code)
        ON DELETE RESTRICT,
    CONSTRAINT fk_diagnosis_provider FOREIGN KEY (diagnosed_by)
        REFERENCES Provider(provider_id)
        ON DELETE RESTRICT
);

-- Medication Table
CREATE TABLE Medication (
    medication_id INT AUTO_INCREMENT PRIMARY KEY,
    medication_name VARCHAR(100) NOT NULL,
    generic_name VARCHAR(100),
    medication_class VARCHAR(100),
    controlled_substance_class VARCHAR(10),
    requires_authorization BOOLEAN DEFAULT FALSE,
    notes TEXT
);

-- Prescription Table
CREATE TABLE Prescription (
    prescription_id INT AUTO_INCREMENT PRIMARY KEY,
    visit_id INT NOT NULL,
    medication_id INT NOT NULL,
    dosage VARCHAR(50) NOT NULL,
    frequency VARCHAR(50) NOT NULL,
    duration VARCHAR(50),
    quantity INT NOT NULL,
    refills INT DEFAULT 0,
    instructions TEXT,
    prescribed_by INT NOT NULL,
    prescribed_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'Active',
    CONSTRAINT fk_prescription_visit FOREIGN KEY (visit_id)
        REFERENCES Visit(visit_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_prescription_medication FOREIGN KEY (medication_id)
        REFERENCES Medication(medication_id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_prescription_provider FOREIGN KEY (prescribed_by)
        REFERENCES Provider(provider_id)
        ON DELETE RESTRICT
);

-- TestType Table
CREATE TABLE TestType (
    test_type_id INT AUTO_INCREMENT PRIMARY KEY,
    test_name VARCHAR(100) NOT NULL,
    description TEXT,
    default_turnaround_time INT, -- in hours
    specimen_required VARCHAR(50),
    instructions TEXT
);

-- LabTest Table
CREATE TABLE LabTest (
    test_id INT AUTO_INCREMENT PRIMARY KEY,
    visit_id INT NOT NULL,
    test_type_id INT NOT NULL,
    ordered_by INT NOT NULL,
    ordered_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'Ordered',
    priority VARCHAR(20) DEFAULT 'Routine',
    notes TEXT,
    CONSTRAINT fk_test_visit FOREIGN KEY (visit_id)
        REFERENCES Visit(visit_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_test_type FOREIGN KEY (test_type_id)
        REFERENCES TestType(test_type_id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_test_provider FOREIGN KEY (ordered_by)
        REFERENCES Provider(provider_id)
        ON DELETE RESTRICT
);

-- TestResult Table
CREATE TABLE TestResult (
    result_id INT AUTO_INCREMENT PRIMARY KEY,
    test_id INT NOT NULL,
    result_value TEXT NOT NULL,
    reference_range VARCHAR(100),
    abnormal_flag CHAR(1),
    resulted_by INT,
    result_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    notes TEXT,
    CONSTRAINT fk_result_test FOREIGN KEY (test_id)
        REFERENCES LabTest(test_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_result_provider FOREIGN KEY (resulted_by)
        REFERENCES Provider(provider_id)
        ON DELETE SET NULL
);

-- Supply Table
CREATE TABLE Supply (
    supply_id INT AUTO_INCREMENT PRIMARY KEY,
    supply_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    unit_of_measure VARCHAR(20) NOT NULL,
    current_quantity INT NOT NULL DEFAULT 0,
    reorder_threshold INT NOT NULL,
    cost_per_unit DECIMAL(10,2),
    last_ordered_date DATE,
    notes TEXT
);

-- SupplyInventory Table
CREATE TABLE SupplyInventory (
    inventory_id INT AUTO_INCREMENT PRIMARY KEY,
    facility_id INT NOT NULL,
    supply_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 0,
    last_updated DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_inventory_facility FOREIGN KEY (facility_id)
        REFERENCES Facility(facility_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_inventory_supply FOREIGN KEY (supply_id)
        REFERENCES Supply(supply_id)
        ON DELETE CASCADE,
    CONSTRAINT uc_facility_supply UNIQUE (facility_id, supply_id)
);

-- SupplyUsage Table
CREATE TABLE SupplyUsage (
    usage_id INT AUTO_INCREMENT PRIMARY KEY,
    visit_id INT NOT NULL,
    supply_id INT NOT NULL,
    quantity_used INT NOT NULL,
    used_by INT,
    usage_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    notes TEXT,
    CONSTRAINT fk_usage_visit FOREIGN KEY (visit_id)
        REFERENCES Visit(visit_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_usage_supply FOREIGN KEY (supply_id)
        REFERENCES Supply(supply_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_usage_provider FOREIGN KEY (used_by)
        REFERENCES Provider(provider_id)
        ON DELETE SET NULL
);

-- Billing Table
CREATE TABLE Billing (
    billing_id INT AUTO_INCREMENT PRIMARY KEY,
    visit_id INT NOT NULL,
    insurance_id INT,
    total_charge DECIMAL(10,2) NOT NULL,
    insurance_paid DECIMAL(10,2) DEFAULT 0.00,
    patient_paid DECIMAL(10,2) DEFAULT 0.00,
    balance_due DECIMAL(10,2) GENERATED ALWAYS AS (total_charge - insurance_paid - patient_paid) STORED,
    billing_date DATE NOT NULL,
    due_date DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'Pending',
    billing_notes TEXT,
    CONSTRAINT fk_billing_visit FOREIGN KEY (visit_id)
        REFERENCES Visit(visit_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_billing_insurance FOREIGN KEY (insurance_id)
        REFERENCES PatientInsurance(insurance_id)
        ON DELETE SET NULL
);

-- BillingItems Table
CREATE TABLE BillingItems (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    billing_id INT NOT NULL,
    service_code VARCHAR(20) NOT NULL,
    service_description VARCHAR(255) NOT NULL,
    charge_amount DECIMAL(10,2) NOT NULL,
    quantity INT DEFAULT 1,
    total_amount DECIMAL(10,2) GENERATED ALWAYS AS (charge_amount * quantity) STORED,
    CONSTRAINT fk_item_billing FOREIGN KEY (billing_id)
        REFERENCES Billing(billing_id)
        ON DELETE CASCADE
);

-- Payment Table
CREATE TABLE Payment (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    billing_id INT NOT NULL,
    payment_date DATE NOT NULL,
    payment_amount DECIMAL(10,2) NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    payment_reference VARCHAR(100),
    notes TEXT,
    CONSTRAINT fk_payment_billing FOREIGN KEY (billing_id)
        REFERENCES Billing(billing_id)
        ON DELETE CASCADE
);

-- Audit trail for patient record changes
CREATE TABLE PatientAudit (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    action_type VARCHAR(10) NOT NULL,
    field_changed VARCHAR(50) NOT NULL,
    old_value TEXT,
    new_value TEXT,
    changed_by VARCHAR(100) NOT NULL,
    change_timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_audit_patient FOREIGN KEY (patient_id)
        REFERENCES Patient(patient_id)
        ON DELETE CASCADE
);