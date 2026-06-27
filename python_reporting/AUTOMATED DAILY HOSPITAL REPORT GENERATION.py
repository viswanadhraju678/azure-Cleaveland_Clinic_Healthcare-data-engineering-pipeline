# =====================================================
# AUTOMATED DAILY HOSPITAL REPORT GENERATION
# PURPOSE:
# Connect to Azure Synapse Serverless SQL Pool,
# run daily analytics queries, and generate Excel reports.
# =====================================================

import os
from datetime import datetime
import pandas as pd
import pyodbc

# =====================================================
# CONNECTION DETAILS
# =====================================================

server = "syn-clevelandclinic-project-ondemand.sql.azuresynapse.net"
database = "clevelandclinic_synapse_db"
username = "sqladminuser"
password = "Viswa@2541"

connection_string = (
    "DRIVER={ODBC Driver 18 for SQL Server};"
    f"SERVER={server};"
    f"DATABASE={database};"
    f"UID={username};"
    f"PWD={password};"
    "Encrypt=yes;"
    "TrustServerCertificate=no;"
    "Connection Timeout=30;"
)

# =====================================================
# OUTPUT FOLDER
# =====================================================

base_folder = os.path.join(os.path.expanduser("~"), "Desktop", "Azure_Hospital_Report")
reports_folder = os.path.join(base_folder, "reports")
os.makedirs(reports_folder, exist_ok=True)

today = datetime.now().strftime("%Y-%m-%d")

patient_visits_file = os.path.join(reports_folder, f"Daily_Patient_Visits_Report_{today}.xlsx")
revenue_file = os.path.join(reports_folder, f"Daily_Revenue_Report_{today}.xlsx")
diagnosis_file = os.path.join(reports_folder, f"Daily_Common_Diagnoses_Report_{today}.xlsx")

# =====================================================
# DAILY SQL REPORT QUERIES
# =====================================================

patient_visits_query = """
-- =====================================================
-- REPORT QUERY 1 : DAILY PATIENT VISITS
-- PURPOSE :
-- Count how many patient consultations happened each day.
-- =====================================================

SELECT
    Date_of_Consultation AS report_date,
    COUNT(*) AS daily_patient_visits
FROM OPENROWSET(
    BULK 'clean/clean_appointments/clean_appointments.parquet',
    DATA_SOURCE = 'ClevelandDataSource',
    FORMAT = 'PARQUET'
) AS a
GROUP BY Date_of_Consultation
ORDER BY report_date;
"""

revenue_query = """
-- =====================================================
-- REPORT QUERY 2 : DAILY REVENUE REPORT
-- PURPOSE :
-- Estimate daily revenue using available matching Patient_ID
-- records between appointments and billing.
-- =====================================================

SELECT
    a.Date_of_Consultation AS report_date,
    COUNT(DISTINCT a.Patient_ID) AS billed_patients,
    SUM(b.Total_Bill) AS daily_revenue,
    AVG(b.Total_Bill) AS avg_bill_amount
FROM OPENROWSET(
    BULK 'clean/clean_appointments/clean_appointments.parquet',
    DATA_SOURCE = 'ClevelandDataSource',
    FORMAT = 'PARQUET'
) AS a
JOIN OPENROWSET(
    BULK 'clean/clean_billing/clean_billing.parquet',
    DATA_SOURCE = 'ClevelandDataSource',
    FORMAT = 'PARQUET'
) AS b
ON a.Patient_ID = b.Patient_ID
GROUP BY a.Date_of_Consultation
ORDER BY report_date;
"""

diagnosis_query = """
-- =====================================================
-- REPORT QUERY 3 : DAILY COMMON DIAGNOSES
-- PURPOSE :
-- Count diagnosis frequency for each consultation date.
-- =====================================================

SELECT
    Date_of_Consultation AS report_date,
    Diagnosis,
    COUNT(*) AS diagnosis_count
FROM OPENROWSET(
    BULK 'clean/clean_appointments/clean_appointments.parquet',
    DATA_SOURCE = 'ClevelandDataSource',
    FORMAT = 'PARQUET'
) AS a
GROUP BY
    Date_of_Consultation,
    Diagnosis
ORDER BY
    report_date,
    diagnosis_count DESC;
"""

# =====================================================
# GENERATE SEPARATE EXCEL REPORTS
# =====================================================

try:
    print("Connecting to Azure Synapse...")
    conn = pyodbc.connect(connection_string)

    print("Running daily patient visits query...")
    patient_visits_df = pd.read_sql(patient_visits_query, conn)

    print("Running daily revenue query...")
    revenue_df = pd.read_sql(revenue_query, conn)

    print("Running daily common diagnoses query...")
    diagnosis_df = pd.read_sql(diagnosis_query, conn)

    print("Creating Excel reports...")

    patient_visits_df.to_excel(patient_visits_file, index=False)
    revenue_df.to_excel(revenue_file, index=False)
    diagnosis_df.to_excel(diagnosis_file, index=False)

    conn.close()

    print("Reports generated successfully!")
    print(f"Saved: {patient_visits_file}")
    print(f"Saved: {revenue_file}")
    print(f"Saved: {diagnosis_file}")

except Exception as e:
    print("Report generation failed.")
    print(str(e))