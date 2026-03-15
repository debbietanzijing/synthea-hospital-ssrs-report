# synthea-hospital-ssrs-report
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

### procedure 
Contains clinical procedure performed during each encounter. 
![procedures table](screenshots/procedures-top5.png)


## Data Quality Analysis 

| Check | Result | Action Taken |
|---|---|---|
| Missing admission dates | 0 | None required |
| Missing discharge dates | 0 | None required |
| Patients wth no encounters | 0 | None required |
| Encounters with no diagnosis | 42, 759 | For further review | 

![No Diagnosis Count](screenshots/no-diagnosis-by-encounter-class)

All encounters were retained with a left join on the conditions table, ensuring no encounters are excluded due to missing diagnosis. 

### Key Findings 
Wellness encounters tend to be routine preventive visits and hospice (end of life care) diagnosis are already pre- established. Inpatient and emergency encounters are flagged for further review as they should have a recorded diagnosis. 

## SQL queries

## How to run this project 

## Key learnings & challenges 



