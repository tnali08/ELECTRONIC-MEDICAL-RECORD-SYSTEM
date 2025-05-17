-- DATABASE VIEWS
-- For University Health Clinic EMR Project

USE university_health_clinic;

-- Current patient appointments view
CREATE VIEW vw_CurrentAppointments AS
SELECT 
    a.appointment_id,
    a.appointment_date,
    a.start_time,
    a.end_time,
    a.status,
    p.patient_id,
    p.first_name AS patient_first_name,
    p.last_name AS patient_last_name,
    p.phone AS patient_phone,
    pr.provider_id,
    pr.first_name AS provider_first_name,
    pr.last_name AS provider_last_name,
    r.room_number,
    f.facility_name
FROM Appointment a
JOIN Patient p ON a.patient_id = p.patient_id
JOIN Provider pr ON a.provider_id = pr.provider_id
JOIN Room r ON a.room_id = r.room_id
JOIN Facility f ON r.facility_id = f.facility_id
WHERE a.appointment_date >= CURDATE() AND a.status != 'Cancelled'
ORDER BY a.appointment_date, a.start_time;

-- Patient summary view
CREATE VIEW vw_PatientSummary AS
SELECT 
    p.patient_id,
    p.first_name,
    p.last_name,
    p.date_of_birth,
    TIMESTAMPDIFF(YEAR, p.date_of_birth, CURDATE()) AS age,
    p.gender,
    p.student_id,
    p.email,
    p.phone,
    pa.street_address,
    pa.city,
    pa.state,
    pa.postal_code,
    ip.provider_name AS insurance_provider,
    pi.policy_number,
    pi.coverage_end_date,
    MAX(v.visit_date) AS last_visit_date,
    COUNT(v.visit_id) AS total_visits
FROM Patient p
LEFT JOIN PatientAddress pa ON p.patient_id = pa.patient_id AND pa.address_type = 'Primary'
LEFT JOIN PatientInsurance pi ON p.patient_id = pi.patient_id AND pi.is_primary = TRUE
LEFT JOIN InsuranceProvider ip ON pi.provider_id = ip.provider_id
LEFT JOIN Visit v ON p.patient_id = v.patient_id
WHERE p.active_status = TRUE
GROUP BY p.patient_id;

-- Provider schedule view
CREATE VIEW vw_ProviderSchedule AS
SELECT 
    pr.provider_id,
    pr.first_name AS provider_first_name,
    pr.last_name AS provider_last_name,
    a.appointment_date,
    a.start_time,
    a.end_time,
    a.appointment_type,
    p.first_name AS patient_first_name,
    p.last_name AS patient_last_name,
    r.room_number,
    a.status
FROM Provider pr
JOIN Appointment a ON pr.provider_id = a.provider_id
JOIN Patient p ON a.patient_id = p.patient_id
JOIN Room r ON a.room_id = r.room_id
WHERE a.appointment_date >= CURDATE()
ORDER BY pr.provider_id, a.appointment_date, a.start_time;

-- Billing summary view
CREATE VIEW vw_BillingSummary AS
SELECT 
    b.billing_id,
    b.billing_date,
    b.due_date,
    b.status,
    b.total_charge,
    b.insurance_paid,
    b.patient_paid,
    b.balance_due,
    p.patient_id,
    p.first_name AS patient_first_name,
    p.last_name AS patient_last_name,
    ip.provider_name AS insurance_provider,
    v.visit_date,
    GROUP_CONCAT(DISTINCT bi.service_description SEPARATOR ', ') AS services
FROM Billing b
JOIN Visit v ON b.visit_id = v.visit_id
JOIN Patient p ON v.patient_id = p.patient_id
LEFT JOIN PatientInsurance pi ON b.insurance_id = pi.insurance_id
LEFT JOIN InsuranceProvider ip ON pi.provider_id = ip.provider_id
LEFT JOIN BillingItems bi ON b.billing_id = bi.billing_id
GROUP BY b.billing_id;

-- Supply inventory view
CREATE VIEW vw_SupplyInventory AS
SELECT 
    s.supply_id,
    s.supply_name,
    s.category,
    s.unit_of_measure,
    s.reorder_threshold,
    f.facility_id,
    f.facility_name,
    si.quantity,
    CASE 
        WHEN si.quantity <= s.reorder_threshold THEN 'Reorder'
        WHEN si.quantity <= s.reorder_threshold * 1.5 THEN 'Low'
        ELSE 'OK'
    END AS inventory_status
FROM Supply s
JOIN SupplyInventory si ON s.supply_id = si.supply_id
JOIN Facility f ON si.facility_id = f.facility_id
ORDER BY inventory_status, s.category, s.supply_name;

-- Patient visit history view
CREATE VIEW vw_PatientVisitHistory AS
SELECT 
    v.visit_id,
    v.visit_date,
    v.check_in_time,
    v.check_out_time,
    v.visit_type,
    v.chief_complaint,
    p.patient_id,
    p.first_name AS patient_first_name,
    p.last_name AS patient_last_name,
    pr.provider_id,
    pr.first_name AS provider_first_name,
    pr.last_name AS provider_last_name,
    f.facility_name,
    GROUP_CONCAT(DISTINCT d.icd_code) AS diagnosis_codes,
    GROUP_CONCAT(DISTINCT icd.description SEPARATOR '; ') AS diagnoses,
    COUNT(DISTINCT px.prescription_id) AS prescriptions_count,
    COUNT(DISTINCT lt.test_id) AS lab_tests_count
FROM Visit v
JOIN Patient p ON v.patient_id = p.patient_id
JOIN Provider pr ON v.provider_id = pr.provider_id
JOIN Facility f ON v.facility_id = f.facility_id
LEFT JOIN Diagnosis d ON v.visit_id = d.visit_id
LEFT JOIN ICD10Codes icd ON d.icd_code = icd.icd_code
LEFT JOIN Prescription px ON v.visit_id = px.visit_id
LEFT JOIN LabTest lt ON v.visit_id = lt.visit_id
GROUP BY v.visit_id
ORDER BY v.visit_date DESC;

-- Provider productivity view
CREATE VIEW vw_ProviderProductivity AS
SELECT 
    pr.provider_id,
    pr.first_name,
    pr.last_name,
    pr.specialty,
    COUNT(DISTINCT v.visit_id) AS total_visits,
    COUNT(DISTINCT v.patient_id) AS unique_patients,
    COUNT(DISTINCT d.diagnosis_id) AS diagnoses_made,
    COUNT(DISTINCT px.prescription_id) AS prescriptions_written,
    COUNT(DISTINCT lt.test_id) AS tests_ordered,
    AVG(TIMESTAMPDIFF(MINUTE, v.check_in_time, v.check_out_time)) AS avg_visit_duration_minutes
FROM Provider pr
LEFT JOIN Visit v ON pr.provider_id = v.provider_id AND v.visit_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
LEFT JOIN Diagnosis d ON v.visit_id = d.visit_id
LEFT JOIN Prescription px ON v.visit_id = px.visit_id
LEFT JOIN LabTest lt ON v.visit_id = lt.visit_id
GROUP BY pr.provider_id
ORDER BY total_visits DESC;

-- Outstanding balances view
CREATE VIEW vw_OutstandingBalances AS
SELECT 
    p.patient_id,
    p.first_name,
    p.last_name,
    p.email,
    p.phone,
    COUNT(b.billing_id) AS open_invoices,
    SUM(b.balance_due) AS total_balance,
    MIN(b.billing_date) AS oldest_invoice_date,
    DATEDIFF(CURDATE(), MIN(b.billing_date)) AS days_outstanding
FROM Patient p
JOIN Visit v ON p.patient_id = v.patient_id
JOIN Billing b ON v.visit_id = b.visit_id
WHERE b.balance_due > 0
GROUP BY p.patient_id
ORDER BY days_outstanding DESC;

-- Medication usage view
CREATE VIEW vw_MedicationUsage AS
SELECT 
    m.medication_id,
    m.medication_name,
    m.medication_class,
    COUNT(px.prescription_id) AS times_prescribed,
    COUNT(DISTINCT v.patient_id) AS unique_patients,
    MIN(px.prescribed_at) AS first_prescribed,
    MAX(px.prescribed_at) AS last_prescribed
FROM Medication m
LEFT JOIN Prescription px ON m.medication_id = px.medication_id
LEFT JOIN Visit v ON px.visit_id = v.visit_id
GROUP BY m.medication_id
ORDER BY times_prescribed DESC;

-- Test results view with abnormal flags
CREATE VIEW vw_TestResults AS
SELECT 
    lt.test_id,
    tt.test_name,
    tr.result_value,
    tr.reference_range,
    tr.abnormal_flag,
    tr.result_date,
    lt.ordered_at,
    TIMESTAMPDIFF(HOUR, lt.ordered_at, tr.result_date) AS turnaround_hours,
    p.patient_id,
    p.first_name AS patient_first_name,
    p.last_name AS patient_last_name,
    op.first_name AS ordered_by_first_name,
    op.last_name AS ordered_by_last_name,
    rp.first_name AS resulted_by_first_name,
    rp.last_name AS resulted_by_last_name
FROM LabTest lt
JOIN TestType tt ON lt.test_type_id = tt.test_type_id
JOIN TestResult tr ON lt.test_id = tr.test_id
JOIN Visit v ON lt.visit_id = v.visit_id
JOIN Patient p ON v.patient_id = p.patient_id
JOIN Provider op ON lt.ordered_by = op.provider_id
LEFT JOIN Provider rp ON tr.resulted_by = rp.provider_id
ORDER BY tr.result_date DESC;