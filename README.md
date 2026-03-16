# synthea-hospital-ssrs-report (in progress)
A paginated SSRS report built on synthetic hospital data, demonstrating SQL server data extraction, data modelling and report development 

# Tools & Environment 
- SQL Server 2022
- SQL Server Management Studio
- Visual Studio (Microsoft Reporting Services Project) 
- Synthea (tool built by MIT researchers that generates fake but realistic hospital data)

## Business Questions 
1. How many encounters per department and the average length of stay?
2. Age breakown for the top 10 most common diagnosis?
3. Patterns in readmissions?

## Data Source 
Synthetic patient data generated using Synthea (with Java), and exported out into CSV files. The synthetic dataset consists of 1, 176 individual patient records across 18 csv files. Four files have been selected for this report. 

1. patient.csv: master tabble containing primary identifier (patient_id) 
2. encounters.csv: hospital operational reporting
3. condition.csv: contains information on diagnosis
4. procedures: contains information on procedural activities by department

## SQl queries 
Refer to the attached sql file for queries for the initial preliminary analysis 

## RDL report
Refer to the attached rdl for a preview of the paginated report 

## Key Learnings and Challenges 

### Technical challenges and resolutions 
1. SSL Certificate Trust Error:
Visual Studio rejected the local SQL Server connection due to a self- signed certificate. Resolved by appending `TrustServerCertificate = True` to the connection string. 
2. Synthea CSV Export
Synthea originally defaulted to FHIR JSON format rather than CSV. Resolved by appending --exporter.csv.export true flag to the generation command in Java
3. Column Truncation Error
Import Flat File wizard (leverages program synthesis to detect delimiters and data types) set BIRTHPLACE column to navarchar(50) and was insufficient to hold long values such as "Macau Macao Special Administrative Region of the 
People's Republic of China". Resolved by changing affected columns to nvarchar(max)
4. Data Type Inference Error
Import Flat File wizard incorrectly inferred BIRTHPLACE as `smalldatetime` and SNOMED CODE column as `int`. Resolved by manually correcting datatypes, also nothing that SNOMED codes are labels and should be stored as text

### Key learnings 
1. Data Modelling
* Identified and avoided a fan trap when combining tables in the main query-- understanding that two one- to many relationships in the same query will result in row multiplications and incorrect aggregations
2. Healthcare Data Literacy
* SNOMED CT codes uses a polyhierarchical, concept based structure that organizes medical knowledge from general to highly specific. Filters were used too exclude non- medical diagnosis.
* Missing diagnoses carries different implications depending on encounter type -- it is expected in wellness and hospice but a data quality concern in inpatient encounters
3. SQL Queries and Development
* LEFT JOIN used to retain encounters with missing diagnoses
* NULLIF prevents divide by zero errors in cost per day calculations (to account for encounters that do not require hospitalization)
