# synthea-hospital-ssrs-report (in progress)
A paginated SSRS report built on synthetic hospital data, demonstrating SQL server data extraction, data modelling and report development 

# Tools & Environment 
- SQL Server 2022
- SQL Server Management Studio
- Visual Studio (Microsoft Reporting Services Project) 
- Synthea (tool built by MIT researchers that generates fake but realistic hospital data)

## Business Questions 
1. How many encounters per department and the average length of stay?
2. Age and gender breakown for the top 10 most common diagnosis?
3. Patterns in readmissions?

## Data Source 
Synthetic patient data generated using Synthea (with Java), and exported out into CSV files. The synthetic dataset consists of 1, 176 individual patient records across 18 csv files. Four files have been selected for this report. 

1. patient.csv: master tabble containing primary identifier (patient_id) 
2. encounters.csv: hospital operational reporting
3. condition.csv: contains information on diagnosis
4. procedures: contains information on procedural activities by department

## Database & Tables 
The following tables chave been imported from Synthea (csv format) into the SQL server and used in this report 

### patients 
Contains demographic   for 1, 176 synthetic patients
![patients table](screenshots/patients-top5.png)

### encounters 
Contains all hospital visits and admissions per patient. Each row represents one encounter linked to a patient. 
![encounters table](screenshots/encounters-top5.png)

### conditions 
Contains diagnoses recorded per encounter. Linked to both patients and encounters via foreign keys. 
![conditions table](screenshots/conditions-top5.png)

## SQL queries
(refer to attached sql file) 

## How to run this project 

## Key learnings & challenges 
