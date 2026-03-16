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

## SQl queries 
Refer to the attached sql file for queries for the initial preliminary analysis 

## RDL report
Refer to the attached rdl for a preview of the paginated report 
