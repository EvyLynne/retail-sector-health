# sql/
 
The warehouse build. Run 01 through 08 in numeric order against a clean
SQL Server 2025 instance and the RetailEconomics database rebuilds
from the source CSV with no manual step anywhere in the sequence.
 
| Script | What it does |
|---|---|
| 01_create_database.sql | RetailEconomics, plus the stg and dw schemas |
| 02_staging_table.sql | stg.WarehouseRetailSales and the BULK INSERT |
| 03_profiling_queries.sql | Row counts, nulls, defects — read the output |
| 04_dimensions.sql | dw.DimDate, dw.DimItem, dw.DimSupplier |
| 05_fact_and_proc.sql | dw.FactItemMovement and its load procedure |
| 06_item_lifecycle.sql | FirstSeen, LastSeen, MonthsActive, CohortYear |
| 07_indexes.sql | Clustered and non-clustered indexes |
| 08_presentation_views.sql | dw.vw_ItemMovement — what Power BI reads |
 
## Rules
- The numbering is an instruction, not a filing convention. This is the
  only folder in the repository where that is true.
- Re-run 06 after any reload of the fact table. The lifecycle columns
  are derived, and they go stale silently rather than loudly.
- These files contain schema only — no rows, no backups, no .bak, .mdf
  or .ldf files. .gitignore blocks those, but the rule comes first.
- Power BI reads the view created in 08. It never reads a base table.
