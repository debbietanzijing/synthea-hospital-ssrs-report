-- ====================================================================
-- Project: Synthea Hospital Data Analysis
-- Description: This SQL script performs an exploratory data analysis (EDA) on the Synthea Hospital dataset. It includes initial data exploration, data quality checks, and various aggregations to understand patient demographics, encounter characteristics, and common diagnoses.
-- Database: SyntheaHospital
-- Author: Debbie
-- Date: March 2026 

-- Environment: SQL Server Management Studio (SSMS) 
-- Datasource: Synthea v3.0 synthetic healthcare dataset, imported into SQL Server
-- ====================================================================

-- ====================================================================
-- 1. Initial Data Exploration
-- Purpose: Verify tables are imported correctly and initial look on the data structure and content.

-- Initial view on data 

SELECT COUNT (*) AS TotalPatients FROM dbo.patients
SELECT TOP 5 * FROM dbo.patients

-- Result: 1,133 patients successfully imported into the database 
-- Table contains key demographic information, along with health coverage and expenses data

SELECT COUNT (*) AS TotalEncounters FROM dbo.encounters
SELECT TOP 5 * FROM dbo.encounters

-- Result: 68, 028 encounters successfully imported into the database (dataset simulates an entire patient lifetime, resulting in multiple encounters per patient)
-- Key columns: START (admission date), STOP (discharge date), ENCOUNTERCLASS (department type)

SELECT COUNT (*) AS TotalConditions FROM dbo.conditions
SELECT TOP 5 * FROM dbo.conditions

-- Result: 39, 887 conditions successfully imported into the database (not all encounters have a diagnosis recorded) 
-- Key columns: START (diagnosis date), STOP (resolution date), CODE (snomed clinical code), (DESCRIPTION (diagnosis description)

SELECT COUNT (*) AS TotalProcedures FROM dbo.procedures
SELECT TOP 5 * FROM dbo.procedures

-- Result: 145, 353 procedures successfully imported into the database
-- Key columns: START (procedure date), STOP (procedure end date), CODE (snomed clinical code), DESCRIPTION (procedure description)

-- ====================================================================

-- ====================================================================
-- 2. Data Quality Checks
-- Purpose: Identify missing or incomplete records 

SELECT COUNT(*) As MissingDischargeDates
FROM dbo.encounters 
WHERE STOP IS NULL

SELECT COUNT(*) As MissingAdmissionDates
FROM dbo.encounters 
WHERE START IS NULL

-- Result: 0 missing admission or discharge dates, indicating good data quality in terms of encounter timelines

SELECT COUNT(*) AS PatientsWithNoEncounters
FROM dbo.patients p
LEFT JOIN dbo.encounters e ON p.Id = e.PATIENT
WHERE e.PATIENT IS NULL

-- Resullt: 0 patients with no encounters, indicating all registered patients in the dataset have at least one recorded encounter

SELECT COUNT(*) AS EncountersWithNoDiagnosis
FROM dbo.encounters e
LEFT JOIN dbo.conditions c ON e.Id = c.ENCOUNTER
WHERE c.ENCOUNTER IS NULL

-- Result: 41, 759 total encounters without a diagnosis, 

SELECT 
    e.ENCOUNTERCLASS,
    COUNT(*) AS NoDiagnosisCount
FROM dbo.encounters e
LEFT JOIN dbo.conditions c ON e.Id = c.ENCOUNTER
WHERE c.ENCOUNTER IS NULL
GROUP BY e.ENCOUNTERCLASS
ORDER BY NoDiagnosisCount DESC

-- Result: Expected higher number non- diagnosis under ambulatory (30, 475), wellness (2, 504) and hospice (146) encounters that are typically for routine checkups, preventive care or end of life care and may not always have a specific diagnosis recorded.
-- To flag: inpatient (668), emergency (834) and outpatient (5, 411) encounters that should typically have a diagnosis but do not
-- Action: Further investigation needed to understand if this is a data quality issue. Left join will initially be used in the main query to retain all encounters regardless of diagnosis status

-- Testing join to see if the table works 
SELECT 
    p.FIRST,
    p.LAST,
    p.GENDER,
    e.START,
    e.STOP,
    e.ENCOUNTERCLASS,
    e.REASONDESCRIPTION
FROM dbo.patients p
INNER JOIN dbo.encounters e 
    ON p.Id = e.PATIENT
WHERE e.ENCOUNTERCLASS IS NOT NULL

-- Result: Successful join of patient and encounter tables, allowing us to link patient demographics with encounter details for downstream analysis. 
-- ====================================================================

-- ====================================================================
-- 3. Main Report Query 
-- Purpose: Primary dataset for analysis, linking patient demographics, encounter details and diagnose. Will be used as the basis for further analysis and visualizations in SSRS.

SELECT 
    p.FIRST, -- Patient first name
    p.LAST, -- Patient last name
    p.GENDER, -- Patient gender 
    DATEDIFF(year, p.BIRTHDATE, GETDATE()) AS AGE, -- Patient age at time of query execution
    e.START AS AdmissionDate, -- Patient encounter admission date
    e.STOP AS DischargeDate, -- Patient encounter discharge date
    DATEDIFF(day, e.START, e.STOP) AS LengthOfStay, -- Patient lenngth of stay in days 
    e.ENCOUNTERCLASS AS Department, -- Department type for the encounter 
    e.REASONDESCRIPTION AS ReasonForVisit, -- Reason for visit 
    c.DESCRIPTION AS Diagnosis -- Patient diagnosis description (if available, will be null if no diagnosis recorded for the encounter)
FROM dbo.patients p
INNER JOIN dbo.encounters e -- joining tables
    ON p.Id = e.PATIENT
LEFT JOIN dbo.conditions c 
    ON p.Id = c.PATIENT 
    AND e.Id = c.ENCOUNTER

-- To avoid the issue of fan trap (joining multiple one- to many relationships), procedures table will not be included in the main query but will be joined separately for any further analysis

-- ====================================================================
-- 4. Aggregation and Summary Statistics
-- Purpose: Department level summaries for report header and visualisations 

-- Average length of stay by department (encounter class)
SELECT 
    e.ENCOUNTERCLASS AS Department,
    COUNT(*) AS TotalEncounters,
    AVG(DATEDIFF(day, e.START, e.STOP)) AS AvgLengthOfStay
FROM dbo.encounters e
WHERE e.START IS NOT NULL
AND e.STOP IS NOT NULL
GROUP BY e.ENCOUNTERCLASS
ORDER BY TotalEncounters DESC

-- Results: To be expected, hospice (21), skilled nursing facilities (18) and inpatient (3) records the highest average length of stay. All other encounters do not require hospitalization.

-- Gender distribution amongst patients 
SELECT 
    GENDER,
    COUNT(*) AS TotalPatients,
    AVG(DATEDIFF(year, BIRTHDATE, GETDATE())) AS AvgAge
FROM dbo.patients
GROUP BY GENDER
-- Results: Dataset is roughly balanced at 575 females and 558 males, with an average of 42- 45 years of age

-- Top 10 most common diagnoses 
SELECT TOP 10
    c.DESCRIPTION AS Diagnosis,
    COUNT(*) AS TotalCases
FROM dbo.conditions c
GROUP BY c.DESCRIPTION
ORDER BY TotalCases DESC

-- Results: Initial exploration of the top 3 most common diagnoses was characterised by psychosocial determinants (stress and unemployment)
-- Actions: The dataset is filtred to exclude SNOMED findings and situational codes, retaining only medical diagnoses

-- Filtered top 10 most common diagnosis, filtering out non- medical diagnoses
SELECT TOP 10
    c.DESCRIPTION AS Diagnosis,
    COUNT(*) AS TotalCases
FROM dbo.conditions c
WHERE c. DESCRIPTION NOT LIKE '%finding%'
AND c.DESCRIPTION NOT LIKE '%situation%'
GROUP BY c.DESCRIPTION
ORDER BY TotalCases DESC

-- Results: Top 3 most common medical diagnosis are-- 1. Gingivitis, 2. Viral sinusitis, 3. Acute viral pharyngitis 

-- Patient readmission checks 
SELECT TOP 10
    p.FIRST,
    p.LAST,
    COUNT(e.Id) AS TotalEncounters,
    DATEDIFF(year, p.BIRTHDATE, GETDATE()) AS AGE
FROM dbo.patients p
INNER JOIN dbo.encounters e ON p.Id = e.PATIENT
GROUP BY p.FIRST, p.LAST, p.BIRTHDATE
HAVING COUNT(e.Id) > 1
ORDER BY TotalEncounters DESC

-- Results: Initial review revealed that the patient with the highest number of encounters (757) was aged 106 years old. This is clinically expected as elderly patients will naturally accumulate a higher number of healthcare interactions across their lifetime. 
-- The second highest wencounter count (735) belonged to a patient aged 55 years old, notably high for this age group and may reflect a complex chronic disease burden. 
-- Actions: Follow up with Esteban536 Ernser583 to understand the clinical context of their healthcare interactions and confirm if this is a data quality issue or a reflection of a complex medical history.

SELECT TOP 20 
    p.FIRST,
    p.LAST,
    DATEDIFF(year, p.BIRTHDATE, GETDATE()) AS AGE,
    c.DESCRIPTION AS Diagnosis,
    COUNT(*) AS DiagnosisCount
FROM dbo.patients p
INNER JOIN dbo.encounters e ON p.Id = e.PATIENT
LEFT JOIN dbo.conditions c ON p.Id = c.PATIENT
WHERE p.FIRST = 'Esteban536'
AND p.LAST = 'Ernser583'
AND c.DESCRIPTION NOT LIKE '%(finding)%'
AND c.DESCRIPTION NOT LIKE '%(situation)%'
GROUP BY p.FIRST, p.LAST, p.BIRTHDATE, c.DESCRIPTION
ORDER BY DiagnosisCount DESC

-- Results: Findings show that this patient has a high burden of chronic diseases, including late stage kidney and renal diseases.
-- This confirms that the higher encounter count is likely a reflection of a complex medical history, rather than a data quality issue

-- Department level cost analysis
SELECT 
    e.ENCOUNTERCLASS AS Department,
    COUNT(*) AS TotalEncounters,
    ROUND(SUM(e.TOTAL_CLAIM_COST) ,2) AS TotalClaimCost,
    ROUND(AVG(e.TOTAL_CLAIM_COST) ,2) AS AvgClaimCostPerEncounter,
    ROUND(AVG(e.TOTAL_CLAIM_COST / 
    NULLIF(DATEDIFF(day, e.START, e.STOP), 0)),2) AS AvgCostPerDay,
    ROUND(AVG(CAST(DATEDIFF(day, e.START, e.STOP) AS FLOAT)), 2) AS AvgLengthOfStay
        FROM dbo.encounters e
WHERE e.START IS NOT NULL
AND e.STOP IS NOT NULL
GROUP BY e.ENCOUNTERCLASS 
ORDER BY TotalClaimCost DESC

-- Results: Inpatient encounters recorded the highest average cost per day ($5107.58) despite having a lower frequency of total encounters. This is consistent with a higher intensity of care and resource utilization, also with a longer average length of stay. 
-- On the other hand, ambulatory encounters account for the highest total claim ost ($96, 823, 469.08) driven by volume rather than per- encounter cost. 
-- Interestingly, a higher average length of stay does not always correlate with higher average cost per day, as seen in hospice and skilled nursing facilities. This may reflect the nature of care provided in these settings, which may be less resource intensive despite longer stays.