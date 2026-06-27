
-- =====================================================
-- JOIN VALIDATION 1 : APPOINTMENTS VS BILLING
-- REFERENCE :
-- Metadata says billing connects to appointments using Case_ID.
-- PURPOSE :
-- Validate whether appointment records and billing records
-- can be joined through Case_ID.
-- =====================================================

SELECT
    COUNT(*) AS matched_records
FROM OPENROWSET(
    BULK 'https://clevelandsynapsedata.dfs.core.windows.net/synapsefs/clean/clean_appointments/clean_appointments.parquet',
    FORMAT = 'PARQUET'
) AS a
JOIN OPENROWSET(
    BULK 'https://clevelandsynapsedata.dfs.core.windows.net/synapsefs/clean/clean_billing/clean_billing.parquet',
    FORMAT = 'PARQUET'
) AS b
ON a.Case_ID = b.Case_ID;


-- =====================================================
-- JOIN VALIDATION 2 : APPOINTMENTS VS BILLING
-- REFERENCE :
-- Secondary validation using Patient_ID because Case_ID
-- returned no matching records.
-- Metadata indicates both tables(appointments&billing) contain Patient_ID
-- PURPOSE :
-- Check whether appointments and billing records can be
-- partially linked using Patient_ID.
-- =====================================================

SELECT TOP 20
    a.Patient_ID,
    a.Case_ID AS Appointment_Case_ID,
    a.Branch_ID AS Appointment_Branch_ID,
    a.Diagnosis,
    b.Claim_ID,
    b.Case_ID AS Billing_Case_ID,
    b.Total_Bill,
    b.Insurance_Provider,
    b.Claim_Status
FROM OPENROWSET(
    BULK 'https://clevelandsynapsedata.dfs.core.windows.net/synapsefs/clean/clean_appointments/clean_appointments.parquet',
    FORMAT = 'PARQUET'
) AS a
JOIN OPENROWSET(
    BULK 'https://clevelandsynapsedata.dfs.core.windows.net/synapsefs/clean/clean_billing/clean_billing.parquet',
    FORMAT = 'PARQUET'
) AS b
ON a.Patient_ID = b.Patient_ID;


-- =====================================================
-- JOIN VALIDATION 3 : APPOINTMENTS VS PATIENTS
-- REFERENCE :
-- Metadata indicates Patient_ID is the primary key
-- connecting appointment records to patient records.
-- PURPOSE :
-- Validate whether appointments are correctly linked
-- to patient master data.
-- =====================================================

SELECT
    COUNT(*) AS matched_records
FROM OPENROWSET(
    BULK 'https://clevelandsynapsedata.dfs.core.windows.net/synapsefs/clean/clean_appointments/clean_appointments.parquet',
    FORMAT = 'PARQUET'
) AS a
JOIN OPENROWSET(
    BULK 'https://clevelandsynapsedata.dfs.core.windows.net/synapsefs/clean/clean_patients/clean_patients.parquet',
    FORMAT = 'PARQUET'
) AS p
ON a.Patient_ID = p.Patient_ID;


-- =====================================================
-- JOIN VALIDATION 3A : APPOINTMENTS VS PATIENTS
-- PURPOSE :
-- Display actual matching records between appointments
-- and patient master data using Patient_ID.
-- =====================================================

SELECT TOP 20
    a.Patient_ID,
    a.Case_ID,
    a.Branch_ID,
    a.Date_of_Consultation,
    a.Reason_for_Visit,
    a.Diagnosis,
    p.Date_of_Registration,
    p.Date_of_First_Consultation,
    p.Date_of_Latest_Consultation,
    p.Overall_Satisfaction_Rating,
    p.Total_Number_of_Visits
FROM OPENROWSET(
    BULK 'https://clevelandsynapsedata.dfs.core.windows.net/synapsefs/clean/clean_appointments/clean_appointments.parquet',
    FORMAT = 'PARQUET'
) AS a
JOIN OPENROWSET(
    BULK 'https://clevelandsynapsedata.dfs.core.windows.net/synapsefs/clean/clean_patients/clean_patients.parquet',
    FORMAT = 'PARQUET'
) AS p
ON a.Patient_ID = p.Patient_ID;



-- =====================================================
-- JOIN VALIDATION 4 : SURGERIES VS PATIENTS
-- REFERENCE :
-- Metadata indicates Patient_ID is the foreign key
-- connecting surgeries to patient records.
-- PURPOSE :
-- Validate whether surgery records are correctly linked
-- to the patient master table.
-- =====================================================

SELECT
    COUNT(*) AS matched_records
FROM OPENROWSET(
    BULK 'https://clevelandsynapsedata.dfs.core.windows.net/synapsefs/clean/clean_surgeries/clean_surgeries.parquet',
    FORMAT = 'PARQUET'
) AS s
JOIN OPENROWSET(
    BULK 'https://clevelandsynapsedata.dfs.core.windows.net/synapsefs/clean/clean_patients/clean_patients.parquet',
    FORMAT = 'PARQUET'
) AS p
ON s.Patient_ID = p.Patient_ID;



-- =====================================================
-- JOIN VALIDATION 5 : LAB REPORTS VS PATIENTS
-- REFERENCE :
-- Metadata indicates Patient_ID connects lab reports
-- to patient master records.
-- PURPOSE :
-- Validate whether lab report records are correctly
-- linked to the patient dataset.
-- =====================================================

SELECT
    COUNT(*) AS matched_records
FROM OPENROWSET(
    BULK 'https://clevelandsynapsedata.dfs.core.windows.net/synapsefs/clean/clean_lab_reports/clean_lab_reports.parquet',
    FORMAT = 'PARQUET'
) AS l
JOIN OPENROWSET(
    BULK 'https://clevelandsynapsedata.dfs.core.windows.net/synapsefs/clean/clean_patients/clean_patients.parquet',
    FORMAT = 'PARQUET'
) AS p
ON l.Patient_ID = p.Patient_ID;


-- =====================================================
-- JOIN VALIDATION 5A : LAB REPORTS VS PATIENTS
-- PURPOSE :
-- Display actual matching records between lab reports
-- and patient master data using Patient_ID.
-- =====================================================

SELECT TOP 20
    l.Report_ID,
    l.Patient_ID,
    l.Case_ID,
    l.Branch_ID,
    l.Test_Name,
    l.Test_Date,
    l.Result,
    p.Date_of_Registration,
    p.Overall_Satisfaction_Rating,
    p.Total_Number_of_Visits
FROM OPENROWSET(
    BULK 'https://clevelandsynapsedata.dfs.core.windows.net/synapsefs/clean/clean_lab_reports/clean_lab_reports.parquet',
    FORMAT = 'PARQUET'
) AS l
JOIN OPENROWSET(
    BULK 'https://clevelandsynapsedata.dfs.core.windows.net/synapsefs/clean/clean_patients/clean_patients.parquet',
    FORMAT = 'PARQUET'
) AS p
ON l.Patient_ID = p.Patient_ID;


-- =====================================================
-- JOIN VALIDATION 6 : PRESCRIPTIONS VS DOCTORS
-- REFERENCE :
-- Metadata indicates Doctor_ID connects prescriptions
-- to doctor master records.
-- PURPOSE :
-- Validate whether prescriptions are correctly linked
-- to doctor details.
-- =====================================================

SELECT
    COUNT(*) AS matched_records
FROM OPENROWSET(
    BULK 'https://clevelandsynapsedata.dfs.core.windows.net/synapsefs/clean/clean_prescriptions/clean_prescriptions.parquet',
    FORMAT = 'PARQUET'
) AS pr
JOIN OPENROWSET(
    BULK 'https://clevelandsynapsedata.dfs.core.windows.net/synapsefs/clean/clean_doctors/clean_doctors.parquet',
    FORMAT = 'PARQUET'
) AS d
ON pr.Doctor_ID = d.Doctor_ID;



-- =====================================================
-- JOIN VALIDATION 7 : APPOINTMENTS VS BRANCHES
-- REFERENCE :
-- Metadata indicates Branch_ID connects appointment
-- records to branch master data.
-- PURPOSE :
-- Validate whether appointments are correctly linked
-- to branch information.
-- =====================================================

SELECT
    COUNT(*) AS matched_records
FROM OPENROWSET(
    BULK 'https://clevelandsynapsedata.dfs.core.windows.net/synapsefs/clean/clean_appointments/clean_appointments.parquet',
    FORMAT = 'PARQUET'
) AS a
JOIN OPENROWSET(
    BULK 'https://clevelandsynapsedata.dfs.core.windows.net/synapsefs/clean/clean_branches/clean_branches.parquet',
    FORMAT = 'PARQUET'
) AS br
ON a.Branch_ID = br.Branch_ID;

-- =====================================================
-- JOIN VALIDATION 7A : APPOINTMENTS VS BRANCHES
-- REFERENCE :
-- Metadata indicates Branch_ID connects appointments
-- to branch master data.
-- PURPOSE :
-- Display actual matching records between appointments
-- and branch information.
-- =====================================================

SELECT TOP 20
    a.Case_ID,
    a.Patient_ID,
    a.Branch_ID,
    a.Date_of_Consultation,
    a.Diagnosis,
    br.Location,
    br.OT_Available,
    br.Inhouse_Pharmacy,
    br.Inhouse_Nutritionist,
    br.Inpatient_Rooms
FROM OPENROWSET(
    BULK 'https://clevelandsynapsedata.dfs.core.windows.net/synapsefs/clean/clean_appointments/clean_appointments.parquet',
    FORMAT = 'PARQUET'
) AS a
JOIN OPENROWSET(
    BULK 'https://clevelandsynapsedata.dfs.core.windows.net/synapsefs/clean/clean_branches/clean_branches.parquet',
    FORMAT = 'PARQUET'
) AS br
ON a.Branch_ID = br.Branch_ID;


-- =====================================================
-- QUERY 1 : TOP 10 DIAGNOSES ACROSS ALL CONSULTATIONS
-- PURPOSE :
-- Identify the most common medical conditions diagnosed
-- across all patient consultations.
-- =====================================================

SELECT TOP 10
    a.Diagnosis,
    COUNT(*) AS total_cases
FROM OPENROWSET(
    BULK 'https://clevelandsynapsedata.dfs.core.windows.net/synapsefs/clean/clean_appointments/clean_appointments.parquet',
    FORMAT = 'PARQUET'
) AS a
GROUP BY a.Diagnosis
ORDER BY total_cases DESC;


-- =====================================================
-- QUERY 2 : BRANCH-WISE REVENUE ANALYSIS
-- PURPOSE :
-- Join appointments and billing using Case_ID to calculate
-- total consultations, revenue generated, and average bill
-- amount for each hospital branch.
-- =====================================================

SELECT
    a.Branch_ID,
    COUNT(DISTINCT a.Case_ID) AS total_appointments,
    SUM(b.Total_Bill) AS total_revenue,
    AVG(b.Total_Bill) AS avg_bill
FROM OPENROWSET(
    BULK 'https://clevelandsynapsedata.dfs.core.windows.net/synapsefs/clean/clean_appointments/clean_appointments.parquet',
    FORMAT = 'PARQUET'
) AS a
JOIN OPENROWSET(
    BULK 'https://clevelandsynapsedata.dfs.core.windows.net/synapsefs/clean/clean_billing/clean_billing.parquet',
    FORMAT = 'PARQUET'
) AS b
ON a.Case_ID = b.Case_ID
GROUP BY a.Branch_ID
ORDER BY total_revenue DESC;


-- =====================================================
-- QUERY 3 : MONTHLY CONSULTATION TREND ANALYSIS
-- PURPOSE :
-- Analyze how consultation volume changes over time.
-- This helps identify seasonal patterns and patient
-- demand across the hospital network.
-- =====================================================

SELECT
    YEAR(Date_of_Consultation) AS consultation_year,
    MONTH(Date_of_Consultation) AS consultation_month,
    COUNT(*) AS total_consultations
FROM OPENROWSET(
    BULK 'https://clevelandsynapsedata.dfs.core.windows.net/synapsefs/clean/clean_appointments/clean_appointments.parquet',
    FORMAT = 'PARQUET'
) AS a
GROUP BY
    YEAR(Date_of_Consultation),
    MONTH(Date_of_Consultation)
ORDER BY
    consultation_year,
    consultation_month;



    -- =====================================================
-- QUERY 4 : FOLLOW-UP REQUIREMENT ANALYSIS
-- PURPOSE :
-- Determine how many consultations required
-- additional follow-up appointments.
-- =====================================================

SELECT
    Followup_Required,
    COUNT(*) AS total_patients
FROM OPENROWSET(
    BULK 'https://clevelandsynapsedata.dfs.core.windows.net/synapsefs/clean/clean_appointments/clean_appointments.parquet',
    FORMAT = 'PARQUET'
) AS a
GROUP BY Followup_Required
ORDER BY Followup_Required;




-- =====================================================
-- QUERY 5 : TOP PRESCRIBED MEDICATIONS
-- PURPOSE :
-- Identify the medications most frequently prescribed
-- across all patient consultations.
-- =====================================================
SELECT
    Prescribed_Medication,
    COUNT(*) AS prescription_count
FROM OPENROWSET(
    BULK 'https://clevelandsynapsedata.dfs.core.windows.net/synapsefs/clean/clean_appointments/clean_appointments.parquet',
    FORMAT = 'PARQUET'
) AS a
GROUP BY Prescribed_Medication
ORDER BY prescription_count DESC;


-- =====================================================
-- QUERY 6 : SURGERY OUTCOME ANALYSIS
-- PURPOSE :
-- Analyze the distribution of surgery outcomes across
-- all surgical procedures.
-- =====================================================

SELECT
    Surgery_Outcome,
    COUNT(*) AS total_surgeries
FROM OPENROWSET(
    BULK 'https://clevelandsynapsedata.dfs.core.windows.net/synapsefs/clean/clean_surgeries/clean_surgeries.parquet',
    FORMAT = 'PARQUET'
) AS s
GROUP BY Surgery_Outcome
ORDER BY total_surgeries DESC;

-- =====================================================
-- QUERY 7 : AVERAGE RECOVERY TIME BY SURGERY TYPE
-- PURPOSE :
-- Calculate the average recovery period and surgery
-- duration for each surgery type.
-- =====================================================

SELECT
    Surgery_Type,
    AVG(Recovery_Period_days) AS avg_recovery_days,
    AVG(Surgery_Duration_hours) AS avg_surgery_duration_hours,
    COUNT(*) AS total_surgeries
FROM OPENROWSET(
    BULK 'https://clevelandsynapsedata.dfs.core.windows.net/synapsefs/clean/clean_surgeries/clean_surgeries.parquet',
    FORMAT = 'PARQUET'
) AS s
GROUP BY Surgery_Type
ORDER BY avg_recovery_days DESC;


-- =====================================================
-- QUERY 8 : INSURANCE CLAIM STATUS ANALYSIS
-- PURPOSE :
-- Analyze approval, rejection and pending rates
-- of insurance claims.
-- =====================================================

SELECT
    Claim_Status,
    COUNT(*) AS total_claims,
    SUM(Total_Bill) AS total_claim_amount,
    AVG(Total_Bill) AS avg_claim_amount
FROM OPENROWSET(
    BULK 'https://clevelandsynapsedata.dfs.core.windows.net/synapsefs/clean/clean_billing/clean_billing.parquet',
    FORMAT = 'PARQUET'
) AS b
GROUP BY Claim_Status
ORDER BY total_claims DESC;


-- =====================================================
-- QUERY 9 : TOP LAB TESTS ANALYSIS
-- PURPOSE :
-- Identify the most frequently requested laboratory
-- tests across all patient records.
-- =====================================================

SELECT
    Test_Name,
    COUNT(*) AS total_tests
FROM OPENROWSET(
    BULK 'https://clevelandsynapsedata.dfs.core.windows.net/synapsefs/clean/clean_lab_reports/clean_lab_reports.parquet',
    FORMAT = 'PARQUET'
) AS l
GROUP BY Test_Name
ORDER BY total_tests DESC;

-- =====================================================
-- QUERY 10 : BRANCH FACILITY ANALYSIS
-- PURPOSE :
-- Analyze hospital infrastructure and facility
-- availability across branches.
-- =====================================================

SELECT
    COUNT(*) AS total_branches,
    SUM(CASE WHEN OT_Available = 1 THEN 1 ELSE 0 END) AS branches_with_OT,
    SUM(CASE WHEN Inhouse_Pharmacy = 1 THEN 1 ELSE 0 END) AS branches_with_pharmacy,
    SUM(CASE WHEN Inhouse_Nutritionist = 1 THEN 1 ELSE 0 END) AS branches_with_nutritionist,
    AVG(Inpatient_Rooms) AS avg_inpatient_rooms
FROM OPENROWSET(
    BULK 'https://clevelandsynapsedata.dfs.core.windows.net/synapsefs/clean/clean_branches/clean_branches.parquet',
    FORMAT = 'PARQUET'
) AS br;


-- =====================================================
-- QUERY 11 : PATIENT VISIT FREQUENCY ANALYSIS
-- PURPOSE :
-- Analyze patient engagement by examining the
-- distribution of total hospital visits.
-- =====================================================

-- =====================================================
-- QUERY 11 : PATIENT VISIT FREQUENCY ANALYSIS
-- PURPOSE :
-- Analyze patient engagement by converting visit count
-- from text format into numeric format.
-- =====================================================

SELECT
    AVG(TRY_CAST(Total_Number_of_Visits AS FLOAT)) AS avg_visits,
    MAX(TRY_CAST(Total_Number_of_Visits AS INT)) AS max_visits,
    MIN(TRY_CAST(Total_Number_of_Visits AS INT)) AS min_visits,
    COUNT(*) AS total_patients
FROM OPENROWSET(
    BULK 'https://clevelandsynapsedata.dfs.core.windows.net/synapsefs/clean/clean_patients/clean_patients.parquet',
    FORMAT = 'PARQUET'
) AS p;


-- =====================================================
-- QUERY 12 : PATIENT SATISFACTION ANALYSIS
-- PURPOSE :
-- Analyze overall patient satisfaction ratings.
-- =====================================================

SELECT
    Overall_Satisfaction_Rating,
    COUNT(*) AS patient_count
FROM OPENROWSET(
    BULK 'https://clevelandsynapsedata.dfs.core.windows.net/synapsefs/clean/clean_patients/clean_patients.parquet',
    FORMAT = 'PARQUET'
) AS p
GROUP BY Overall_Satisfaction_Rating
ORDER BY Overall_Satisfaction_Rating;
