/* ============================================================================
   03_profiling_queries.sql
   U.S. Retail Sector Health - warehouse build, script 3 of 8
   Profile before you model

   WHAT IT DOES
   Five read-only queries that measure the defects in the staged data:
   non-numeric measures, negative values, blank item types, supplier
   name variants, and period coverage.

   PREREQUISITE
   Script 02 has loaded the staging table.

   VERIFY
   Nothing is created or changed. Read the five result sets and record
   them - document 02 section 5.5 states what each one should look
   like.

   Run the eight scripts in numeric order on a clean instance and the
   warehouse rebuilds from the source CSV with no manual step.

   Target      : SQL Server 2025, instance BRUNO\MSSQLSERVER01
   Source      : document 02 section 5.5. This file is generated from that
                 document - change the document and regenerate, do not edit here.
   ============================================================================ */

-- 1. Non-numeric values hiding in the measure columns
SELECT  SUM(CASE WHEN TRY_CONVERT(decimal(18,4), [RETAIL SALES])    IS NULL
                  AND NULLIF(LTRIM(RTRIM([RETAIL SALES])), '')      IS NOT NULL
                 THEN 1 ELSE 0 END) AS BadRetailSales,
        SUM(CASE WHEN TRY_CONVERT(decimal(18,4), [WAREHOUSE SALES]) IS NULL
                  AND NULLIF(LTRIM(RTRIM([WAREHOUSE SALES])), '')   IS NOT NULL
                 THEN 1 ELSE 0 END) AS BadWarehouseSales
FROM    stg.WarehouseRetailSales;

-- 2. Negative values: legitimate returns and transfers, NOT errors
SELECT  COUNT(*) AS NegativeRetailRows
FROM    stg.WarehouseRetailSales
WHERE   TRY_CONVERT(decimal(18,4), [RETAIL SALES]) < 0;

-- 3. Blank or missing ITEM TYPE
SELECT  COUNT(*) AS BlankItemType
FROM    stg.WarehouseRetailSales
WHERE   NULLIF(LTRIM(RTRIM([ITEM TYPE])), '') IS NULL;

-- 4. Supplier name hygiene: whitespace and casing variants
SELECT  COUNT(DISTINCT [SUPPLIER])                      AS RawSuppliers,
        COUNT(DISTINCT UPPER(LTRIM(RTRIM([SUPPLIER])))) AS NormalisedSuppliers
FROM    stg.WarehouseRetailSales;

-- 5. Period coverage and completeness
SELECT  [YEAR], COUNT(DISTINCT [MONTH]) AS MonthsPresent, COUNT(*) AS Rows
FROM    stg.WarehouseRetailSales
GROUP BY [YEAR]
ORDER BY [YEAR];
