-- INDEXES FOR PERFORMANCE OPTIMIZATION
-- For University Health Clinic EMR Project

USE university_health_clinic;

-- Patient table indexes
CREATE INDEX idx_patient_name ON Patient(last_name, first_name);
CREATE INDEX idx_patient_dob ON Patient(date_of_birth);
CREATE INDEX idx_patient_student_id ON Patient(student_id);

-- Appointment indexes
CREATE INDEX idx_appointment_date ON Appointment(appointment_date);
CREATE INDEX idx_appointment_provider ON Appointment(provider_id, appointment_date);
CREATE INDEX idx_appointment_status ON Appointment(status, appointment_date);

-- Visit indexes
CREATE INDEX idx_visit_date ON Visit(visit_date);
CREATE INDEX idx_visit_patient ON Visit(patient_id, visit_date);
CREATE INDEX idx_visit_provider ON Visit(provider_id, visit_date);

-- Diagnosis indexes
CREATE INDEX idx_diagnosis_icd ON Diagnosis(icd_code);
CREATE INDEX idx_diagnosis_date ON Diagnosis(diagnosis_date);

-- Prescription indexes
CREATE INDEX idx_prescription_medication ON Prescription(medication_id);
CREATE INDEX idx_prescription_date ON Prescription(prescribed_at);

-- Billing indexes
CREATE INDEX idx_billing_date ON Billing(billing_date);
CREATE INDEX idx_billing_status ON Billing(status);

-- Search optimization indexes
CREATE INDEX idx_provider_specialty ON Provider(specialty);
CREATE INDEX idx_lab_test_status ON LabTest(status);