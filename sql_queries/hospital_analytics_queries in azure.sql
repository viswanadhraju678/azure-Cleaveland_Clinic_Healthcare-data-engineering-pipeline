-- =====================================================
-- AZURE SQL IMPORTANT QUERIES FOR HOSPITAL PROJECT
-- Tables used: Mapping_clean_*_adf
-- =====================================================


-- =====================================================
-- QUERY 1 : CLEAN TABLE RECORD COUNT SUMMARY
-- PURPOSE:
-- Validate that all cleaned tables were loaded successfully.
-- =====================================================

SELECT 'Patients' AS Table_Name, COUNT(*) AS Total_Records FROM Mapping_clean_patients_adf
UNION ALL
SELECT 'Doctors', COUNT(*) FROM Mapping_clean_doctors_adf
UNION ALL
SELECT 'Branches', COUNT(*) FROM Mapping_clean_branches_adf
UNION ALL
SELECT 'Appointments', COUNT(*) FROM Mapping_clean_appointments_adf
UNION ALL
SELECT 'Billing', COUNT(*) FROM Mapping_clean_billing_adf
UNION ALL
SELECT 'Lab Reports', COUNT(*) FROM Mapping_clean_lab_reports_adf
UNION ALL
SELECT 'Prescriptions', COUNT(*) FROM Mapping_clean_prescriptions_adf
UNION ALL
SELECT 'Surgeries', COUNT(*) FROM Mapping_clean_surgeries_adf;


-- =====================================================
-- QUERY 2 : TOP 10 DIAGNOSES
-- PURPOSE:
-- Identify the most common medical conditions.
-- =====================================================

SELECT TOP 10
    [Diagnosis],
    COUNT(*) AS Total_Cases
FROM Mapping_clean_appointments_adf
GROUP BY [Diagnosis]
ORDER BY Total_Cases DESC;


-- =====================================================
-- QUERY 3 : TOP 10 MOST ACTIVE DOCTORS
-- PURPOSE:
-- Identify doctors with the highest consultation load.
-- =====================================================

SELECT TOP 10
    [Consulted Doctor ID],
    COUNT(*) AS Total_Appointments
FROM Mapping_clean_appointments_adf
GROUP BY [Consulted Doctor ID]
ORDER BY Total_Appointments DESC;


-- =====================================================
-- QUERY 4 : BRANCH-WISE APPOINTMENT ANALYSIS
-- PURPOSE:
-- Analyze consultation volume across hospital branches.
-- =====================================================

SELECT TOP 10
    [Branch ID],
    COUNT(*) AS Total_Consultations
FROM Mapping_clean_appointments_adf
GROUP BY [Branch ID]
ORDER BY Total_Consultations DESC;


-- =====================================================
-- QUERY 5 : MONTHLY CONSULTATION TREND
-- PURPOSE:
-- Analyze patient consultation trend over time.
-- =====================================================

SELECT
    YEAR([Date of Consultation]) AS Consultation_Year,
    MONTH([Date of Consultation]) AS Consultation_Month,
    COUNT(*) AS Total_Consultations
FROM Mapping_clean_appointments_adf
GROUP BY
    YEAR([Date of Consultation]),
    MONTH([Date of Consultation])
ORDER BY
    Consultation_Year,
    Consultation_Month;


-- =====================================================
-- QUERY 6 : FOLLOW-UP REQUIREMENT ANALYSIS
-- PURPOSE:
-- Determine how many consultations required follow-up.
-- =====================================================

SELECT
    [Followup Required],
    COUNT(*) AS Total_Cases
FROM Mapping_clean_appointments_adf
GROUP BY [Followup Required]
ORDER BY [Followup Required];


-- =====================================================
-- QUERY 7 : TOP PRESCRIBED MEDICATIONS
-- PURPOSE:
-- Identify most commonly prescribed medications.
-- =====================================================

SELECT TOP 10
    [Prescribed Medication],
    COUNT(*) AS Prescription_Count
FROM Mapping_clean_appointments_adf
GROUP BY [Prescribed Medication]
ORDER BY Prescription_Count DESC;


-- =====================================================
-- QUERY 8 : INSURANCE CLAIM STATUS ANALYSIS
-- PURPOSE:
-- Analyze approved, rejected and pending insurance claims.
-- =====================================================

SELECT
    [Claim Status],
    COUNT(*) AS Total_Claims,
    SUM([Total Bill]) AS Total_Claim_Amount,
    AVG([Total Bill]) AS Average_Claim_Amount
FROM Mapping_clean_billing_adf
GROUP BY [Claim Status]
ORDER BY Total_Claims DESC;


-- =====================================================
-- QUERY 9 : TOP LAB TESTS
-- PURPOSE:
-- Identify most frequently requested lab tests.
-- =====================================================

SELECT
    [Test Name],
    COUNT(*) AS Total_Tests
FROM Mapping_clean_lab_reports_adf
GROUP BY [Test Name]
ORDER BY Total_Tests DESC;


-- =====================================================
-- QUERY 10 : SURGERY OUTCOME ANALYSIS
-- PURPOSE:
-- Analyze surgical outcomes.
-- =====================================================

SELECT
    [Surgery Outcome],
    COUNT(*) AS Total_Surgeries
FROM Mapping_clean_surgeries_adf
GROUP BY [Surgery Outcome]
ORDER BY Total_Surgeries DESC;


-- =====================================================
-- QUERY 11 : AVERAGE RECOVERY BY SURGERY TYPE
-- PURPOSE:
-- Analyze average surgery duration and recovery period.
-- =====================================================

SELECT
    [Surgery Type],
    AVG([Surgery Duration (hours)]) AS Avg_Surgery_Duration_Hours,
    AVG([Recovery Period (days)]) AS Avg_Recovery_Days,
    COUNT(*) AS Total_Surgeries
FROM Mapping_clean_surgeries_adf
GROUP BY [Surgery Type]
ORDER BY Avg_Recovery_Days DESC;


-- =====================================================
-- QUERY 12 : PATIENT VISIT FREQUENCY ANALYSIS
-- PURPOSE:
-- Analyze overall patient engagement.
-- =====================================================

SELECT
    AVG(TRY_CAST([Total Number of Visits] AS FLOAT)) AS Avg_Visits,
    MAX(TRY_CAST([Total Number of Visits] AS INT)) AS Max_Visits,
    MIN(TRY_CAST([Total Number of Visits] AS INT)) AS Min_Visits,
    COUNT(*) AS Total_Patients
FROM Mapping_clean_patients_adf;


-- =====================================================
-- QUERY 13 : PATIENT SATISFACTION ANALYSIS
-- PURPOSE:
-- Analyze distribution of patient satisfaction ratings.
-- =====================================================

SELECT
    [Overall Satisfaction Rating],
    COUNT(*) AS Patient_Count
FROM Mapping_clean_patients_adf
GROUP BY [Overall Satisfaction Rating]
ORDER BY [Overall Satisfaction Rating];


-- =====================================================
-- QUERY 14 : BRANCH FACILITY ANALYSIS
-- PURPOSE:
-- Analyze hospital branch infrastructure availability.
-- =====================================================

SELECT
    COUNT(*) AS Total_Branches,
    SUM(CASE WHEN [OT_Available] = 1 THEN 1 ELSE 0 END) AS Branches_With_OT,
    SUM(CASE WHEN [Inhouse Pharmacy] = 1 THEN 1 ELSE 0 END) AS Branches_With_Pharmacy,
    SUM(CASE WHEN [Inhouse Nutritionist] = 1 THEN 1 ELSE 0 END) AS Branches_With_Nutritionist,
    AVG([Inpatient Rooms]) AS Avg_Inpatient_Rooms
FROM Mapping_clean_branches_adf;


-- =====================================================
-- QUERY 15 : JOIN VALIDATION SUMMARY
-- PURPOSE:
-- Validate relationships between clean Azure SQL tables.
-- =====================================================

SELECT
    'Appointments ↔ Patients using Patient ID' AS Relationship_Name,
    COUNT(*) AS Matched_Records
FROM Mapping_clean_appointments_adf a
JOIN Mapping_clean_patients_adf p
    ON a.[Patient ID] = p.[Patient ID]

UNION ALL

SELECT
    'Appointments ↔ Doctors using Consulted Doctor ID',
    COUNT(*)
FROM Mapping_clean_appointments_adf a
JOIN Mapping_clean_doctors_adf d
    ON a.[Consulted Doctor ID] = d.[Doctor ID]

UNION ALL

SELECT
    'Appointments ↔ Billing using Case ID',
    COUNT(*)
FROM Mapping_clean_appointments_adf a
JOIN Mapping_clean_billing_adf b
    ON a.[Case ID] = b.[Case ID]

UNION ALL

SELECT
    'Appointments ↔ Billing using Patient ID',
    COUNT(*)
FROM Mapping_clean_appointments_adf a
JOIN Mapping_clean_billing_adf b
    ON a.[Patient ID] = b.[Patient ID]

UNION ALL

SELECT
    'Appointments ↔ Branches using Branch ID',
    COUNT(*)
FROM Mapping_clean_appointments_adf a
JOIN Mapping_clean_branches_adf br
    ON a.[Branch ID] = br.[Branch ID]

UNION ALL

SELECT
    'Lab Reports ↔ Patients using Patient ID',
    COUNT(*)
FROM Mapping_clean_lab_reports_adf l
JOIN Mapping_clean_patients_adf p
    ON l.[Patient ID] = p.[Patient ID]

UNION ALL

SELECT
    'Prescriptions ↔ Doctors using Doctor ID',
    COUNT(*)
FROM Mapping_clean_prescriptions_adf pr
JOIN Mapping_clean_doctors_adf d
    ON pr.[Doctor ID] = d.[Doctor ID]

UNION ALL

SELECT
    'Surgeries ↔ Patients using Patient ID',
    COUNT(*)
FROM Mapping_clean_surgeries_adf s
JOIN Mapping_clean_patients_adf p
    ON s.[Patient ID] = p.[Patient ID];


-- =====================================================
-- QUERY 16 : APPOINTMENTS VS BRANCH DETAILS
-- PURPOSE:
-- Join appointments with branch data to analyze
-- consultations by branch location.
-- =====================================================

SELECT TOP 20
    a.[Branch ID],
    br.[Location],
    COUNT(*) AS Total_Consultations
FROM Mapping_clean_appointments_adf a
JOIN Mapping_clean_branches_adf br
    ON a.[Branch ID] = br.[Branch ID]
GROUP BY
    a.[Branch ID],
    br.[Location]
ORDER BY Total_Consultations DESC;


-- =====================================================
-- QUERY 17 : APPOINTMENTS VS BILLING USING PATIENT ID
-- PURPOSE:
-- Analyze diagnosis-level revenue where Patient ID matches.
-- =====================================================

SELECT
    a.[Diagnosis],
    COUNT(*) AS Matched_Cases,
    SUM(b.[Total Bill]) AS Total_Revenue,
    AVG(b.[Total Bill]) AS Avg_Bill
FROM Mapping_clean_appointments_adf a
JOIN Mapping_clean_billing_adf b
    ON a.[Patient ID] = b.[Patient ID]
GROUP BY a.[Diagnosis]
ORDER BY Total_Revenue DESC;


-- =====================================================
-- QUERY 18 : DATA QUALITY CHECK - MISSING KEY VALUES
-- PURPOSE:
-- Check missing key identifiers in clean appointment table.
-- =====================================================

SELECT
    SUM(CASE WHEN [Patient ID] IS NULL THEN 1 ELSE 0 END) AS Missing_Patient_IDs,
    SUM(CASE WHEN [Case ID] IS NULL THEN 1 ELSE 0 END) AS Missing_Case_IDs,
    SUM(CASE WHEN [Branch ID] IS NULL THEN 1 ELSE 0 END) AS Missing_Branch_IDs,
    SUM(CASE WHEN [Consulted Doctor ID] IS NULL THEN 1 ELSE 0 END) AS Missing_Consulted_Doctor_IDs
FROM Mapping_clean_appointments_adf;