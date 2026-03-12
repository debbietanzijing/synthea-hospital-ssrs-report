# synthea-hospital-ssrs-report
A paginated SSRS report built on synthetic hospital data, demonstrating SQL server data extraction, data modelling and report development 

# Tools & Environment 
- SQL Server 2022
- SQL Server Management Studio
- Visual Studio (Microsoft Reporting Services Project) 
- Synthea (tool built by MIT researchers that generates fake but realistic hospital data)

# Data Source 
Synthetic patient data generated using Synthea (with Java), and exported out into CSV files. The synthetic dataset consists of 1, 176 individual patient records across 18 csv files. Four files have been selected for this report. 

1. patient.csv: master tabble containing primary identifier (patient_id) 
2. encounters.csv: hospital operational reporting
3. condition.csv: contains information on diagnosis
4. procedures: contains information on procedural activities by department



