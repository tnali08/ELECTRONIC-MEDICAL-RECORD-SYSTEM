-- SAMPLE DATA INSERTION
-- For University Health Clinic EMR Project

USE university_health_clinic;

-- Insert Facilities
INSERT INTO Facility (facility_name, location, capacity, phone, opening_hours) VALUES
('Main Campus Health Center', 'Student Union Building, 1st Floor', 50, '555-123-4567', 'Mon-Fri: 8:00 AM - 6:00 PM, Sat: 10:00 AM - 2:00 PM'),
('North Campus Clinic', 'Science Building, Room 103', 20, '555-123-8910', 'Mon-Fri: 9:00 AM - 5:00 PM'),
('Sports Medicine Facility', 'Athletics Complex, East Wing', 15, '555-123-5678', 'Mon-Fri: 7:00 AM - 7:00 PM');

-- Insert Rooms
INSERT INTO Room (facility_id, room_number, room_type, capacity, status, equipment) VALUES
(1, '101', 'Exam Room', 2, 'Available', 'Basic exam equipment'),
(1, '102', 'Exam Room', 2, 'Available', 'Basic exam equipment'),
(1, '103', 'Procedure Room', 3, 'Available', 'Advanced medical equipment, surgical lights'),
(1, '104', 'Consultation Room', 4, 'Available', 'Desk, computer, chairs'),
(1, '105', 'Vaccination Room', 2, 'Available', 'Refrigerator, basic exam equipment'),
(2, '201', 'Exam Room', 2, 'Available', 'Basic exam equipment'),
(2, '202', 'Exam Room', 2, 'Available', 'Basic exam equipment'),
(2, '203', 'Mental Health Consultation', 3, 'Available', 'Comfortable seating, privacy sound machine'),
(3, '301', 'Physical Therapy', 4, 'Available', 'Exercise equipment, treatment tables'),
(3, '302', 'Sports Injury Exam', 2, 'Available', 'Specialized sports medicine equipment');

-- Insert Providers
INSERT INTO Provider (first_name, last_name, credentials, specialty, email, phone, national_provider_id, hire_date, status) VALUES
('Robert', 'Chen', 'MD', 'Internal Medicine', 'r.chen@university.edu', '555-111-2222', 'NPI100001', '2020-06-15', 'Active'),
('Sophia', 'Williams', 'MD', 'Family Medicine', 's.williams@university.edu', '555-222-3333', 'NPI100002', '2019-08-20', 'Active'),
('Michael', 'Johnson', 'DO', 'Sports Medicine', 'm.johnson@university.edu', '555-333-4444', 'NPI100003', '2021-01-10', 'Active'),
('Emily', 'Garcia', 'NP', 'Primary Care', 'e.garcia@university.edu', '555-444-5555', 'NPI100004', '2022-03-01', 'Active'),
('David', 'Martinez', 'PA-C', 'Urgent Care', 'd.martinez@university.edu', '555-555-6666', 'NPI100005', '2021-07-15', 'Active'),
('Jessica', 'Thompson', 'PhD', 'Mental Health', 'j.thompson@university.edu', '555-666-7777', 'NPI100006', '2020-09-01', 'Active'),
('Daniel', 'Nguyen', 'MD', 'Dermatology', 'd.nguyen@university.edu', '555-777-8888', 'NPI100007', '2022-02-15', 'Active'),
('Olivia', 'Lee', 'RN', 'Nursing', 'o.lee@university.edu', '555-888-9999', 'NPI100008', '2021-04-10', 'Active');

-- Insert Patients
INSERT INTO Patient (first_name, last_name, date_of_birth, gender, student_id, email, phone, emergency_contact_name, emergency_contact_phone) VALUES
('Alex', 'Johnson', '2000-05-15', 'M', 'S10001', 'alex.j@university.edu', '555-101-1010', 'Mary Johnson', '555-102-1020'),
('Emma', 'Smith', '2001-07-22', 'F', 'S10002', 'emma.s@university.edu', '555-103-1030', 'John Smith', '555-104-1040'),
('Noah', 'Williams', '1999-03-10', 'M', 'S10003', 'noah.w@university.edu', '555-105-1050', 'Patricia Williams', '555-106-1060'),
('Olivia', 'Brown', '2002-11-30', 'F', 'S10004', 'olivia.b@university.edu', '555-107-1070', 'Robert Brown', '555-108-1080'),
('Liam', 'Miller', '2000-09-18', 'M', 'S10005', 'liam.m@university.edu', '555-109-1090', 'Jennifer Miller', '555-110-1100'),
('Ava', 'Davis', '2001-04-05', 'F', 'S10006', 'ava.d@university.edu', '555-111-1110', 'Michael Davis', '555-112-1120'),
('Ethan', 'Garcia', '1999-12-21', 'M', 'S10007', 'ethan.g@university.edu', '555-113-1130', 'Linda Garcia', '555-114-1140'),
('Sophia', 'Rodriguez', '2002-02-14', 'F', 'S10008', 'sophia.r@university.edu', '555-115-1150', 'David Rodriguez', '555-116-1160'),
('Mason', 'Wilson', '2000-08-07', 'M', 'S10009', 'mason.w@university.edu', '555-117-1170', 'Sarah Wilson', '555-118-1180'),
('Isabella', 'Taylor', '2001-01-25', 'F', 'S10010', 'isabella.t@university.edu', '555-119-1190', 'Charles Taylor', '555-120-1200');

-- Insert Patient Addresses
INSERT INTO PatientAddress (patient_id, address_type, street_address, city, state, postal_code) VALUES
(1, 'Primary', '123 University Ave, Apt 4', 'College Town', 'CA', '90210'),
(2, 'Primary', '456 Campus Drive', 'College Town', 'CA', '90210'),
(3, 'Primary', '789 Academic Lane', 'College Town', 'CA', '90210'),
(4, 'Primary', '101 Student Housing Complex', 'College Town', 'CA', '90210'),
(5, 'Primary', '202 College Apartments, Unit B', 'College Town', 'CA', '90210'),
(6, 'Primary', '303 Fraternity Row', 'College Town', 'CA', '90210'),
(7, 'Primary', '404 Sorority Circle', 'College Town', 'CA', '90210'),
(8, 'Primary', '505 Off-Campus Housing', 'College Town', 'CA', '90210'),
(9, 'Primary', '606 Graduate Housing', 'College Town', 'CA', '90210'),
(10, 'Primary', '707 International Student Dorm', 'College Town', 'CA', '90210');

-- Insert Insurance Providers
INSERT INTO InsuranceProvider (provider_name, contact_phone, contact_email, notes) VALUES
('University Student Health Plan', '800-111-2222', 'claims@ushp.com', 'Primary student insurance provider'),
('National Healthcare', '800-333-4444', 'service@nationalhc.com', 'Preferred provider for staff'),
('Family Health Insurance', '800-555-6666', 'claims@familyhealth.com', 'Common family plan provider'),
('State Medical Coverage', '800-777-8888', 'support@statemedical.gov', 'State subsidized healthcare'),
('International Student Coverage', '800-999-0000', 'global@isc-health.com', 'For international students');

-- Insert Patient Insurance
INSERT INTO PatientInsurance (patient_id, provider_id, policy_number, group_number, coverage_start_date, coverage_end_date, is_primary, verification_status) VALUES
(1, 1, 'USHP10001', 'GRP001', '2024-09-01', '2025-08-31', TRUE, 'Verified'),
(2, 1, 'USHP10002', 'GRP001', '2024-09-01', '2025-08-31', TRUE, 'Verified'),
(3, 2, 'NHC20001', 'FAM100', '2024-01-01', '2024-12-31', TRUE, 'Verified'),
(4, 1, 'USHP10003', 'GRP001', '2024-09-01', '2025-08-31', TRUE, 'Verified'),
(5, 3, 'FHI30001', 'STD200', '2024-01-01', '2024-12-31', TRUE, 'Verified'),
(6, 1, 'USHP10004', 'GRP001', '2024-09-01', '2025-08-31', TRUE, 'Verified'),
(7, 4, 'SMC40001', 'GOV300', '2024-01-01', '2024-12-31', TRUE, 'Verified'),
(8, 1, 'USHP10005', 'GRP001', '2024-09-01', '2025-08-31', TRUE, 'Verified'),
(9, 1, 'USHP10006', 'GRP002', '2024-09-01', '2025-08-31', TRUE, 'Verified'),
(10, 5, 'ISC50001', 'INT400', '2024-09-01', '2025-08-31', TRUE, 'Verified');

-- Insert Medical History
INSERT INTO MedicalHistory (patient_id, allergies, chronic_conditions, past_surgeries, family_history) VALUES
(1, 'Penicillin, Pollen', 'Asthma', 'None', 'Father with hypertension'),
(2, 'None', 'None', 'Appendectomy (2020)', 'Mother with diabetes'),
(3, 'Shellfish', 'Migraine', 'None', 'Grandparent with heart disease'),
(4, 'Latex', 'None', 'None', 'None significant'),
(5, 'None', 'Mild anxiety', 'None', 'Family history of depression'),
(6, 'Sulfa drugs', 'None', 'Tonsillectomy (2015)', 'None significant'),
(7, 'Peanuts', 'Eczema', 'None', 'Sibling with asthma'),
(8, 'None', 'None', 'None', 'Mother with breast cancer'),
(9, 'Amoxicillin', 'Seasonal allergies', 'None', 'Father with high cholesterol'),
(10, 'None', 'None', 'None', 'None significant');

-- Insert ICD10 Codes
INSERT INTO ICD10Codes (icd_code, description, category, is_billable) VALUES
('J02.9', 'Acute pharyngitis, unspecified', 'Respiratory', TRUE),
('J03.90', 'Acute tonsillitis, unspecified', 'Respiratory', TRUE),
('J01.90', 'Acute sinusitis, unspecified', 'Respiratory', TRUE),
('N39.0', 'Urinary tract infection, site not specified', 'Genitourinary', TRUE),
('A09', 'Infectious gastroenteritis and colitis, unspecified', 'Digestive', TRUE),
('L24.9', 'Irritant contact dermatitis, unspecified cause', 'Skin', TRUE),
('G43.909', 'Migraine, unspecified, not intractable, without status migrainosus', 'Neurological', TRUE),
('F41.9', 'Anxiety disorder, unspecified', 'Mental health', TRUE),
('M54.5', 'Low back pain', 'Musculoskeletal', TRUE),
('S93.401A', 'Sprain of ankle, unspecified, initial encounter', 'Injury', TRUE),
('Z00.00', 'Encounter for general adult medical examination without abnormal findings', 'Factors influencing health status', TRUE),
('Z00.129', 'Encounter for routine child health examination without abnormal findings', 'Factors influencing health status', TRUE);

-- Insert Medication
INSERT INTO Medication (medication_name, generic_name, medication_class, controlled_substance_class, requires_authorization) VALUES
('Amoxicillin 500mg', 'Amoxicillin', 'Antibiotic', NULL, FALSE),
('Ibuprofen 800mg', 'Ibuprofen', 'NSAID', NULL, FALSE),
('Prednisone 20mg', 'Prednisone', 'Corticosteroid', NULL, FALSE),
('Azithromycin 250mg', 'Azithromycin', 'Antibiotic', NULL, FALSE),
('Fluticasone Nasal Spray', 'Fluticasone', 'Corticosteroid', NULL, FALSE),
('Loratadine 10mg', 'Loratadine', 'Antihistamine', NULL, FALSE),
('Sertraline 50mg', 'Sertraline', 'SSRI', NULL, FALSE),
('Cyclobenzaprine 10mg', 'Cyclobenzaprine', 'Muscle Relaxant', NULL, FALSE),
('Metronidazole 500mg', 'Metronidazole', 'Antibiotic', NULL, FALSE),
('Oseltamivir 75mg', 'Oseltamivir', 'Antiviral', NULL, FALSE),
('Alprazolam 0.5mg', 'Alprazolam', 'Benzodiazepine', 'IV', TRUE),
('Methylphenidate 10mg', 'Methylphenidate', 'Stimulant', 'II', TRUE);

-- Insert Test Types
INSERT INTO TestType (test_name, description, default_turnaround_time, specimen_required, instructions) VALUES
('Complete Blood Count', 'Measures WBC, RBC, hemoglobin, hematocrit, and platelets', 2, 'Blood', 'Fasting not required'),
('Comprehensive Metabolic Panel', 'Measures kidney and liver function, electrolytes, and blood sugar', 2, 'Blood', 'Fasting recommended for 8 hours'),
('Urinalysis', 'Screens for UTI, kidney disease, diabetes, and other conditions', 1, 'Urine', 'Clean catch mid-stream sample'),
('Rapid Strep Test', 'Detects strep throat infection', 1, 'Throat swab', 'Swab tonsils and posterior pharynx'),
('Mononucleosis Test', 'Detects infectious mononucleosis', 1, 'Blood', 'No special preparation needed'),
('COVID-19 PCR Test', 'Detects SARS-CoV-2 viral RNA', 24, 'Nasal swab', 'Insert swab into nostril and rotate'),
('Pregnancy Test', 'Detects HCG hormone', 1, 'Urine', 'First morning urine preferred'),
('Rapid Influenza Test', 'Detects influenza virus', 1, 'Nasal swab', 'Insert swab into nostril and rotate');

-- Insert Supply items
INSERT INTO Supply (supply_name, category, unit_of_measure, current_quantity, reorder_threshold, cost_per_unit) VALUES
('Examination Gloves (S)', 'PPE', 'Box', 50, 10, 8.99),
('Examination Gloves (M)', 'PPE', 'Box', 45, 10, 8.99),
('Examination Gloves (L)', 'PPE', 'Box', 40, 10, 8.99),
('Face Masks', 'PPE', 'Box', 30, 5, 12.50),
('Alcohol Swabs', 'Cleaning', 'Box', 60, 15, 3.99),
('Gauze Pads', 'Wound Care', 'Package', 40, 10, 5.50),
('Bandages', 'Wound Care', 'Box', 35, 8, 4.25),
('Syringes 5mL', 'Injection', 'Box', 25, 10, 15.75),
('Needles 22G', 'Injection', 'Box', 20, 10, 12.99),
('Rapid Strep Test Kits', 'Diagnostic', 'Box', 15, 5, 95.00),
('Pregnancy Test Kits', 'Diagnostic', 'Box', 12, 5, 45.00),
('Hand Sanitizer', 'Cleaning', 'Bottle', 30, 10, 3.99),
('Paper Exam Table Covers', 'Exam Room', 'Roll', 25, 5, 7.50),
('Thermometer Probe Covers', 'Diagnostic', 'Box', 18, 5, 10.99);

-- Insert Supply Inventory for each facility
INSERT INTO SupplyInventory (facility_id, supply_id, quantity) VALUES
(1, 1, 25), (1, 2, 20), (1, 3, 15), (1, 4, 15), (1, 5, 30), (1, 6, 20), (1, 7, 15), 
(1, 8, 10), (1, 9, 10), (1, 10, 8), (1, 11, 6), (1, 12, 15), (1, 13, 10), (1, 14, 8),
(2, 1, 15), (2, 2, 15), (2, 3, 15), (2, 4, 10), (2, 5, 20), (2, 6, 10), (2, 7, 10), 
(2, 8, 8), (2, 9, 5), (2, 10, 5), (2, 11, 4), (2, 12, 8), (2, 13, 8), (2, 14, 5),
(3, 1, 10), (3, 2, 10), (3, 3, 10), (3, 4, 5), (3, 5, 10), (3, 6, 10), (3, 7, 10), 
(3, 8, 7), (3, 9, 5), (3, 10, 2), (3, 11, 2), (3, 12, 7), (3, 13, 7), (3, 14, 5);

-- Insert Appointments and associated data
-- First appointment and visit with diagnosis, prescription, lab test, and billing
INSERT INTO Appointment (patient_id, provider_id, room_id, appointment_date, start_time, end_time, 
                        appointment_type, status, reason_for_visit) VALUES
(1, 1, 1, '2025-02-15', '09:00:00', '09:30:00', 'Regular Check-up', 'Completed', 'Sore throat, fever');

INSERT INTO Visit (appointment_id, patient_id, provider_id, facility_id, visit_date, check_in_time, 
                   check_out_time, visit_type, visit_reason, chief_complaint) VALUES
(1, 1, 1, 1, '2025-02-15', '2025-02-15 08:45:00', '2025-02-15 09:35:00', 'Sick Visit', 
'Sore throat, fever for 2 days', 'Sore throat, difficulty swallowing');

INSERT INTO Vitals (visit_id, temperature, blood_pressure_systolic, blood_pressure_diastolic, 
                   pulse_rate, respiratory_rate, height, weight, bmi, oxygen_saturation, 
                   pain_level, recorded_by) VALUES
(1, 100.8, 118, 75, 88, 16, 175.3, 70.5, 22.9, 98, 6, 8);

INSERT INTO Diagnosis (visit_id, icd_code, diagnosis_notes, diagnosed_by) VALUES
(1, 'J02.9', 'Acute pharyngitis likely viral in origin', 1);

INSERT INTO Prescription (visit_id, medication_id, dosage, frequency, duration, quantity, 
                         refills, instructions, prescribed_by) VALUES
(1, 2, '800mg', 'Every 8 hours as needed', '7 days', 21, 0, 
'Take with food for pain and fever', 1);

INSERT INTO LabTest (visit_id, test_type_id, ordered_by, status, priority) VALUES
(1, 4, 1, 'Completed', 'Routine');

INSERT INTO TestResult (test_id, result_value, reference_range, abnormal_flag, resulted_by) VALUES
(1, 'Positive', 'Negative', 'A', 8);

INSERT INTO SupplyUsage (visit_id, supply_id, quantity_used, used_by) VALUES
(1, 10, 1, 8), -- Used 1 Rapid Strep Test Kit
(1, 5, 2, 8);  -- Used 2 Alcohol Swabs

INSERT INTO Billing (visit_id, insurance_id, total_charge, insurance_paid, patient_paid, 
                    billing_date, due_date, status) VALUES
(1, 1, 175.00, 140.00, 35.00, '2025-02-15', '2025-03-15', 'Paid');

INSERT INTO BillingItems (billing_id, service_code, service_description, charge_amount, quantity) VALUES
(1, 'OV-SICK', 'Sick Visit - Level 2', 100.00, 1),
(1, 'LAB-RST', 'Rapid Strep Test', 45.00, 1),
(1, 'MED-CONS', 'Medication Consultation', 30.00, 1);

INSERT INTO Payment (billing_id, payment_date, payment_amount, payment_method, payment_reference) VALUES
(1, '2025-02-15', 35.00, 'Credit Card', 'TXN12345');

-- Second appointment and visit
INSERT INTO Appointment (patient_id, provider_id, room_id, appointment_date, start_time, end_time, 
                        appointment_type, status, reason_for_visit) VALUES
(2, 2, 2, '2025-02-16', '10:00:00', '10:30:00', 'Annual Physical', 'Completed', 'Routine check-up');

INSERT INTO Visit (appointment_id, patient_id, provider_id, facility_id, visit_date, check_in_time, 
                   check_out_time, visit_type, visit_reason, chief_complaint) VALUES
(2, 2, 2, 1, '2025-02-16', '2025-02-16 09:45:00', '2025-02-16 10:40:00', 'Wellness Visit', 
'Annual physical examination', 'No complaints');

INSERT INTO Vitals (visit_id, temperature, blood_pressure_systolic, blood_pressure_diastolic, 
                   pulse_rate, respiratory_rate, height, weight, bmi, oxygen_saturation, 
                   pain_level, recorded_by) VALUES
(2, 98.6, 110, 70, 72, 14, 162.5, 55.0, 20.8, 99, 0, 8);

INSERT INTO Diagnosis (visit_id, icd_code, diagnosis_notes, diagnosed_by) VALUES
(2, 'Z00.00', 'Routine adult health check-up, no issues identified', 2);

INSERT INTO LabTest (visit_id, test_type_id, ordered_by, status, priority) VALUES
(2, 1, 2, 'Completed', 'Routine'),
(2, 2, 2, 'Completed', 'Routine');

INSERT INTO TestResult (test_id, result_value, reference_range, abnormal_flag, resulted_by) VALUES
(2, 'WBC: 7.5, RBC: 4.8, Hgb: 14.2, Hct: 42%, Plt: 250', 'WBC: 4.5-11.0, RBC: 4.2-5.4, Hgb: 12.0-15.0, Hct: 36-45%, Plt: 150-450', 'N', 8),
(3, 'Glucose: 85, BUN: 15, Cr: 0.8, Na: 140, K: 4.0, Cl: 102, CO2: 24', 'Glucose: 70-99, BUN: 7-20, Cr: 0.6-1.2, Na: 136-145, K: 3.5-5.0, Cl: 98-107, CO2: 23-29', 'N', 8);

INSERT INTO Billing (visit_id, insurance_id, total_charge, insurance_paid, patient_paid, 
                    billing_date, due_date, status) VALUES
(2, 2, 250.00, 250.00, 0.00, '2025-02-16', '2025-03-16', 'Paid');

INSERT INTO BillingItems (billing_id, service_code, service_description, charge_amount, quantity) VALUES
(2, 'OV-WEL', 'Wellness Visit', 150.00, 1),
(2, 'LAB-CBC', 'Complete Blood Count', 50.00, 1),
(2, 'LAB-CMP', 'Comprehensive Metabolic Panel', 50.00, 1);

INSERT INTO Payment (billing_id, payment_date, payment_amount, payment_method, payment_reference) VALUES
(2, '2025-02-16', 250.00, 'Insurance', 'INS98765');

-- Third appointment and visit for mental health
INSERT INTO Appointment (patient_id, provider_id, room_id, appointment_date, start_time, end_time, 
                        appointment_type, status, reason_for_visit) VALUES
(5, 6, 8, '2025-02-17', '13:00:00', '14:00:00', 'Mental Health', 'Completed', 'Anxiety symptoms');

INSERT INTO Visit (appointment_id, patient_id, provider_id, facility_id, visit_date, check_in_time, 
                   check_out_time, visit_type, visit_reason, chief_complaint) VALUES
(3, 5, 6, 2, '2025-02-17', '2025-02-17 12:45:00', '2025-02-17 14:10:00', 'Mental Health', 
'Increased anxiety symptoms', 'Anxiety, trouble sleeping, exam stress');

INSERT INTO Vitals (visit_id, temperature, blood_pressure_systolic, blood_pressure_diastolic, 
                   pulse_rate, respiratory_rate, height, weight, bmi, oxygen_saturation, 
                   pain_level, recorded_by) VALUES
(3, 98.9, 125, 80, 85, 16, 180.0, 75.5, 23.3, 98, 0, 8);

INSERT INTO Diagnosis (visit_id, icd_code, diagnosis_notes, diagnosed_by) VALUES
(3, 'F41.9', 'Anxiety disorder, likely related to academic stress', 6);

INSERT INTO Prescription (visit_id, medication_id, dosage, frequency, duration, quantity, 
                         refills, instructions, prescribed_by) VALUES
(3, 7, '50mg', 'Once daily in the morning', '30 days', 30, 2, 
'Take with food. May cause drowsiness initially.', 6);

INSERT INTO Billing (visit_id, insurance_id, total_charge, insurance_paid, patient_paid, 
                    billing_date, due_date, status) VALUES
(3, 5, 200.00, 160.00, 40.00, '2025-02-17', '2025-03-17', 'Paid');

INSERT INTO BillingItems (billing_id, service_code, service_description, charge_amount, quantity) VALUES
(3, 'MH-CONS', 'Mental Health Consultation', 200.00, 1);

INSERT INTO Payment (billing_id, payment_date, payment_amount, payment_method, payment_reference) VALUES
(3, '2025-02-17', 40.00, 'Credit Card', 'TXN23456');

-- Fourth appointment for sports injury
INSERT INTO Appointment (patient_id, provider_id, room_id, appointment_date, start_time, end_time, 
                        appointment_type, status, reason_for_visit) VALUES
(3, 3, 10, '2025-02-18', '15:00:00', '15:30:00', 'Injury Assessment', 'Completed', 'Ankle sprain during basketball');

INSERT INTO Visit (appointment_id, patient_id, provider_id, facility_id, visit_date, check_in_time, 
                   check_out_time, visit_type, visit_reason, chief_complaint) VALUES
(4, 3, 3, 3, '2025-02-18', '2025-02-18 14:45:00', '2025-02-18 15:40:00', 'Injury', 
'Ankle injury during intramural basketball', 'Right ankle pain, swelling after inversion injury');

INSERT INTO Vitals (visit_id, temperature, blood_pressure_systolic, blood_pressure_diastolic, 
                   pulse_rate, respiratory_rate, height, weight, bmi, oxygen_saturation, 
                   pain_level, recorded_by) VALUES
(4, 98.7, 122, 78, 80, 16, 188.0, 82.3, 23.3, 99, 7, 8);

INSERT INTO Diagnosis (visit_id, icd_code, diagnosis_notes, diagnosed_by) VALUES
(4, 'S93.401A', 'Grade 2 ankle sprain, right side', 3);

INSERT INTO Prescription (visit_id, medication_id, dosage, frequency, duration, quantity, 
                         refills, instructions, prescribed_by) VALUES
(4, 2, '600mg', 'Every 6 hours as needed', '10 days', 40, 0, 
'Take with food for pain and swelling', 3);

INSERT INTO SupplyUsage (visit_id, supply_id, quantity_used, used_by) VALUES
(4, 6, 4, 3), -- Used 4 Gauze Pads
(4, 7, 1, 3); -- Used 1 Bandage

INSERT INTO Billing (visit_id, insurance_id, total_charge, insurance_paid, patient_paid, 
                    billing_date, due_date, status) VALUES
(4, 3, 150.00, 120.00, 30.00, '2025-02-18', '2025-03-18', 'Paid');

INSERT INTO BillingItems (billing_id, service_code, service_description, charge_amount, quantity) VALUES
(4, 'INJ-EVAL', 'Injury Evaluation', 120.00, 1),
(4, 'WRAP-ANK', 'Ankle Wrapping', 30.00, 1);

INSERT INTO Payment (billing_id, payment_date, payment_amount, payment_method, payment_reference) VALUES
(4, '2025-02-18', 30.00, 'Credit Card', 'TXN34567');

-- Fifth appointment for follow-up visit
INSERT INTO Appointment (patient_id, provider_id, room_id, appointment_date, start_time, end_time, 
                        appointment_type, status, reason_for_visit) VALUES
(1, 1, 1, '2025-02-25', '11:00:00', '11:30:00', 'Follow-up', 'Completed', 'Follow-up for pharyngitis');

INSERT INTO Visit (appointment_id, patient_id, provider_id, facility_id, visit_date, check_in_time, 
                   check_out_time, visit_type, visit_reason, chief_complaint) VALUES
(5, 1, 1, 1, '2025-02-25', '2025-02-25 10:45:00', '2025-02-25 11:25:00', 'Follow-up', 
'Follow-up for pharyngitis', 'Feeling better, mild residual soreness');

INSERT INTO Vitals (visit_id, temperature, blood_pressure_systolic, blood_pressure_diastolic, 
                   pulse_rate, respiratory_rate, height, weight, bmi, oxygen_saturation, 
                   pain_level, recorded_by) VALUES
(5, 98.9, 120, 76, 72, 14, 175.3, 70.5, 22.9, 99, 2, 8);

INSERT INTO Diagnosis (visit_id, icd_code, diagnosis_notes, diagnosed_by) VALUES
(5, 'J02.9', 'Resolving pharyngitis', 1);

INSERT INTO Billing (visit_id, insurance_id, total_charge, insurance_paid, patient_paid, 
                    billing_date, due_date, status) VALUES
(5, 1, 75.00, 60.00, 15.00, '2025-02-25', '2025-03-25', 'Paid');

INSERT INTO BillingItems (billing_id, service_code, service_description, charge_amount, quantity) VALUES
(5, 'FU-VISIT', 'Follow-up Visit', 75.00, 1);

INSERT INTO Payment (billing_id, payment_date, payment_amount, payment_method, payment_reference) VALUES
(5, '2025-02-25', 15.00, 'Credit Card', 'TXN45678');

-- Sixth appointment for skin condition
INSERT INTO Appointment (patient_id, provider_id, room_id, appointment_date, start_time, end_time, 
                        appointment_type, status, reason_for_visit) VALUES
(7, 7, 1, '2025-02-19', '14:00:00', '14:30:00', 'Dermatology', 'Completed', 'Skin rash on arms');

INSERT INTO Visit (appointment_id, patient_id, provider_id, facility_id, visit_date, check_in_time, 
                   check_out_time, visit_type, visit_reason, chief_complaint) VALUES
(6, 7, 7, 1, '2025-02-19', '2025-02-19 13:45:00', '2025-02-19 14:35:00', 'Specialty', 
'Skin rash evaluation', 'Itchy rash on forearms for 1 week');

INSERT INTO Vitals (visit_id, temperature, blood_pressure_systolic, blood_pressure_diastolic, 
                   pulse_rate, respiratory_rate, height, weight, bmi, oxygen_saturation, 
                   pain_level, recorded_by) VALUES
(6, 98.4, 118, 74, 76, 16, 177.8, 68.0, 21.5, 99, 1, 8);

INSERT INTO Diagnosis (visit_id, icd_code, diagnosis_notes, diagnosed_by) VALUES
(6, 'L24.9', 'Contact dermatitis, likely due to new laundry detergent', 7);

INSERT INTO Prescription (visit_id, medication_id, dosage, frequency, duration, quantity, 
                         refills, instructions, prescribed_by) VALUES
(6, 3, '20mg', 'Once daily for 3 days, then 10mg daily for 4 days', '7 days', 7, 0, 
'Take with food in the morning', 7);

INSERT INTO Billing (visit_id, insurance_id, total_charge, insurance_paid, patient_paid, 
                    billing_date, due_date, status) VALUES
(6, 4, 150.00, 120.00, 30.00, '2025-02-19', '2025-03-19', 'Paid');

INSERT INTO BillingItems (billing_id, service_code, service_description, charge_amount, quantity) VALUES
(6, 'DERM-CONS', 'Dermatology Consultation', 150.00, 1);

INSERT INTO Payment (billing_id, payment_date, payment_amount, payment_method, payment_reference) VALUES
(6, '2025-02-19', 30.00, 'Credit Card', 'TXN56789');

-- Seventh appointment for UTI
INSERT INTO Appointment (patient_id, provider_id, room_id, appointment_date, start_time, end_time, 
                        appointment_type, status, reason_for_visit) VALUES
(4, 4, 6, '2025-02-20', '11:00:00', '11:30:00', 'Urgent Care', 'Completed', 'Urinary symptoms');

INSERT INTO Visit (appointment_id, patient_id, provider_id, facility_id, visit_date, check_in_time, 
                   check_out_time, visit_type, visit_reason, chief_complaint) VALUES
(7, 4, 4, 2, '2025-02-20', '2025-02-20 10:45:00', '2025-02-20 11:40:00', 'Urgent', 
'Urinary frequency and pain', 'Painful urination, urgency, and frequency for 2 days');

INSERT INTO Vitals (visit_id, temperature, blood_pressure_systolic, blood_pressure_diastolic, 
                   pulse_rate, respiratory_rate, height, weight, bmi, oxygen_saturation, 
                   pain_level, recorded_by) VALUES
(7, 99.1, 124, 78, 88, 18, 165.1, 58.5, 21.5, 98, 4, 8);

INSERT INTO Diagnosis (visit_id, icd_code, diagnosis_notes, diagnosed_by) VALUES
(7, 'N39.0', 'Urinary tract infection, uncomplicated', 4);

INSERT INTO Prescription (visit_id, medication_id, dosage, frequency, duration, quantity, 
                         refills, instructions, prescribed_by) VALUES
(7, 1, '500mg', 'Every 8 hours', '7 days', 21, 0, 
'Take until complete. Drink plenty of water.', 4);

INSERT INTO LabTest (visit_id, test_type_id, ordered_by, status, priority) VALUES
(7, 3, 4, 'Completed', 'Urgent');

INSERT INTO TestResult (test_id, result_value, reference_range, abnormal_flag, resulted_by) VALUES
(4, 'Positive for leukocyte esterase, nitrites, and bacterial cells. 20-50 WBCs/hpf.', 'Negative for all', 'A', 8);

INSERT INTO Billing (visit_id, insurance_id, total_charge, insurance_paid, patient_paid, 
                    billing_date, due_date, status) VALUES
(7, 1, 195.00, 155.00, 40.00, '2025-02-20', '2025-03-20', 'Paid');

INSERT INTO BillingItems (billing_id, service_code, service_description, charge_amount, quantity) VALUES
(7, 'URG-VISIT', 'Urgent Care Visit', 150.00, 1),
(7, 'LAB-UA', 'Urinalysis', 45.00, 1);

INSERT INTO Payment (billing_id, payment_date, payment_amount, payment_method, payment_reference) VALUES
(7, '2025-02-20', 40.00, 'Credit Card', 'TXN67890');

-- Eighth appointment for migraine
INSERT INTO Appointment (patient_id, provider_id, room_id, appointment_date, start_time, end_time, 
                        appointment_type, status, reason_for_visit) VALUES
(3, 2, 2, '2025-02-22', '09:30:00', '10:00:00', 'Sick Visit', 'Completed', 'Severe headache');

INSERT INTO Visit (appointment_id, patient_id, provider_id, facility_id, visit_date, check_in_time, 
                   check_out_time, visit_type, visit_reason, chief_complaint) VALUES
(8, 3, 2, 1, '2025-02-22', '2025-02-22 09:15:00', '2025-02-22 10:10:00', 'Urgent', 
'Severe headache with visual changes', 'Throbbing headache, nausea, light sensitivity for 6 hours');

INSERT INTO Vitals (visit_id, temperature, blood_pressure_systolic, blood_pressure_diastolic, 
                   pulse_rate, respiratory_rate, height, weight, bmi, oxygen_saturation, 
                   pain_level, recorded_by) VALUES
(8, 98.2, 130, 85, 90, 18, 188.0, 82.5, 23.3, 99, 8, 8);

INSERT INTO Diagnosis (visit_id, icd_code, diagnosis_notes, diagnosed_by) VALUES
(8, 'G43.909', 'Acute migraine without aura', 2);

INSERT INTO Prescription (visit_id, medication_id, dosage, frequency, duration, quantity, 
                         refills, instructions, prescribed_by) VALUES
(8, 8, '10mg', 'Every 8 hours as needed for 24 hours only', '1 day', 3, 0, 
'Take only when in a quiet, dark room. Do not drive or operate machinery.', 2);

INSERT INTO Billing (visit_id, insurance_id, total_charge, insurance_paid, patient_paid, 
                    billing_date, due_date, status) VALUES
(8, 2, 125.00, 100.00, 25.00, '2025-02-22', '2025-03-22', 'Paid');

INSERT INTO BillingItems (billing_id, service_code, service_description, charge_amount, quantity) VALUES
(8, 'URG-SICK', 'Urgent Sick Visit', 125.00, 1);

INSERT INTO Payment (billing_id, payment_date, payment_amount, payment_method, payment_reference) VALUES
(8, '2025-02-22', 25.00, 'Credit Card', 'TXN78901');

-- Ninth appointment for gastrointestinal issue
INSERT INTO Appointment (patient_id, provider_id, room_id, appointment_date, start_time, end_time, 
                        appointment_type, status, reason_for_visit) VALUES
(9, 5, 6, '2025-02-24', '13:30:00', '14:00:00', 'Urgent Care', 'Completed', 'Stomach pain and diarrhea');

INSERT INTO Visit (appointment_id, patient_id, provider_id, facility_id, visit_date, check_in_time, 
                   check_out_time, visit_type, visit_reason, chief_complaint) VALUES
(9, 9, 5, 2, '2025-02-24', '2025-02-24 13:15:00', '2025-02-24 14:05:00', 'Urgent', 
'Abdominal pain and diarrhea', 'Cramping abdominal pain and watery diarrhea for 24 hours');

INSERT INTO Vitals (visit_id, temperature, blood_pressure_systolic, blood_pressure_diastolic, 
                   pulse_rate, respiratory_rate, height, weight, bmi, oxygen_saturation, 
                   pain_level, recorded_by) VALUES
(9, 99.2, 110, 70, 92, 18, 182.9, 79.4, 23.7, 98, 5, 8);

INSERT INTO Diagnosis (visit_id, icd_code, diagnosis_notes, diagnosed_by) VALUES
(9, 'A09', 'Acute gastroenteritis, likely viral', 5);

INSERT INTO Prescription (visit_id, medication_id, dosage, frequency, duration, quantity, 
                         refills, instructions, prescribed_by) VALUES
(9, 2, '400mg', 'Every 6 hours as needed for pain', '3 days', 12, 0, 
'Take with food. Maintain hydration with clear fluids.', 5);

INSERT INTO Billing (visit_id, insurance_id, total_charge, insurance_paid, patient_paid, 
                    billing_date, due_date, status) VALUES
(9, 1, 125.00, 100.00, 25.00, '2025-02-24', '2025-03-24', 'Paid');

INSERT INTO BillingItems (billing_id, service_code, service_description, charge_amount, quantity) VALUES
(9, 'URG-SICK', 'Urgent Sick Visit', 125.00, 1);

INSERT INTO Payment (billing_id, payment_date, payment_amount, payment_method, payment_reference) VALUES
(9, '2025-02-24', 25.00, 'Credit Card', 'TXN89012');

-- Tenth appointment for annual physical
INSERT INTO Appointment (patient_id, provider_id, room_id, appointment_date, start_time, end_time, 
                        appointment_type, status, reason_for_visit) VALUES
(10, 2, 2, '2025-02-26', '11:00:00', '12:00:00', 'Annual Physical', 'Completed', 'Yearly check-up');

INSERT INTO Visit (appointment_id, patient_id, provider_id, facility_id, visit_date, check_in_time, 
                   check_out_time, visit_type, visit_reason, chief_complaint) VALUES
(10, 10, 2, 1, '2025-02-26', '2025-02-26 10:45:00', '2025-02-26 12:15:00', 'Wellness Visit', 
'Annual physical examination', 'No complaints, routine check-up');

INSERT INTO Vitals (visit_id, temperature, blood_pressure_systolic, blood_pressure_diastolic, 
                   pulse_rate, respiratory_rate, height, weight, bmi, oxygen_saturation, 
                   pain_level, recorded_by) VALUES
(10, 98.6, 115, 75, 68, 14, 160.0, 54.0, 21.1, 99, 0, 8);

INSERT INTO Diagnosis (visit_id, icd_code, diagnosis_notes, diagnosed_by) VALUES
(10, 'Z00.00', 'Routine adult health examination without abnormal findings', 2);

INSERT INTO LabTest (visit_id, test_type_id, ordered_by, status, priority) VALUES
(10, 1, 2, 'Completed', 'Routine'),
(10, 2, 2, 'Completed', 'Routine');

INSERT INTO TestResult (test_id, result_value, reference_range, abnormal_flag, resulted_by) VALUES
(5, 'WBC: 6.8, RBC: 4.5, Hgb: 13.5, Hct: 40.5%, Plt: 265', 'WBC: 4.5-11.0, RBC: 4.2-5.4, Hgb: 12.0-15.0, Hct: 36-45%, Plt: 150-450', 'N', 8),
(6, 'Glucose: 82, BUN: 14, Cr: 0.7, Na: 138, K: 4.1, Cl: 101, CO2: 25', 'Glucose: 70-99, BUN: 7-20, Cr: 0.6-1.2, Na: 136-145, K: 3.5-5.0, Cl: 98-107, CO2: 23-29', 'N', 8);

INSERT INTO Billing (visit_id, insurance_id, total_charge, insurance_paid, patient_paid, 
                    billing_date, due_date, status) VALUES
(10, 5, 250.00, 250.00, 0.00, '2025-02-26', '2025-03-26', 'Paid');

INSERT INTO BillingItems (billing_id, service_code, service_description, charge_amount, quantity) VALUES
(10, 'OV-WEL', 'Wellness Visit', 150.00, 1),
(10, 'LAB-CBC', 'Complete Blood Count', 50.00, 1),
(10, 'LAB-CMP', 'Comprehensive Metabolic Panel', 50.00, 1);

INSERT INTO Payment (billing_id, payment_date, payment_amount, payment_method, payment_reference) VALUES
(10, '2025-02-26', 250.00, 'Insurance', 'INS90123');