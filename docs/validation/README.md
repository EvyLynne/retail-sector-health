# docs/validation/

Step-by-step procedures for the seventeen pre-publication checks in
document 02 section 9. One procedure per check, written for someone who
has never run it: every click, every query, how to decide pass or fail,
how to record the result, and what to do if it fails.

Each procedure exists in two formats with the same content:

- `.docx` - to read and print
- `.xlsx` - the same steps, with a Pass/Fail drop-down on each tick table
  (V07, V08, V15, V16 and V17 have tick tables; the others record one result)

Results are recorded in `docs/22_Validation_Results.xlsx` and ticked in
`docs/26_Validation_Timing_Checklist.xlsx`. When to run each check is
`docs/25_Validation_Timing_Guide.docx`.

| Check | Procedure | Pass | Where it runs |
|---|---|---|---|
| 1 | V01_Staged_vs_Loaded_Rows | Model | SSMS 22, database RetailEconomics |
| 2 | V02_Sector_Month_Coverage | Model | Power BI Desktop, DAX query view, in the model file |
| 3 | V03_Aggregate_Reconciliation | Model | Power BI Desktop, DAX query view |
| 4 | V04_Census_vs_FRED_Cross_Check | Model | Power BI Desktop, DAX query view |
| 5 | V05_Referential_Integrity | Model | Power BI Desktop, DAX query view |
| 6 | V06_Date_Relationship_Integrity | Model | Power BI Desktop, DAX query view |
| 7 | V07_Measure_Unit_Consistency | Report | Power BI Desktop, the three report files |
| 8 | V08_Cases_vs_Dollars_Separation | Report | Power BI Desktop, the three report files |
| 9 | V09_Channel_Baseline_Integrity | Model | Power BI Desktop - DAX query view in the model file, then reports R1 and R2 |
| 10 | V10_Channel_Story_National_Counterpart | Model | Power BI Desktop, DAX query view; then report R1 |
| 11 | V11_Negative_Value_Handling | Model | Power BI Desktop - DAX query view, then report R1 |
| 12 | V12_Lifecycle_Columns_Current | Model | SSMS 22, database RetailEconomics |
| 13 | V13_Cohort_Census | Model | Power BI Desktop, DAX query view |
| 14 | V14_Pareto_Accumulation | Model | Power BI Desktop - DAX query view, then report R3 |
| 15 | V15_Coefficients_Carry_Their_Sample | Report | Power BI Desktop, report R2 |
| 16 | V16_Left_Censored_Cohort_Labelled | Report | Power BI Desktop, report R3 |
| 17 | V17_Report_to_Model_Binding | Report | Power BI Desktop, and File Explorer |

## Rules
- The pass criterion in each procedure is quoted from document 02 section 9.
  Change it there first, then here.
- Record results in document 22, not in these files. The Result cells in
  the .xlsx versions are for working only.
