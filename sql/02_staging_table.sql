/* ============================================================================
   02_staging_table.sql
   U.S. Retail Sector Health - warehouse build, script 2 of 8
   Staging table and bulk load

   WHAT IT DOES
   Creates stg.WarehouseRetailSales with every column NVARCHAR, then
   bulk loads the county CSV into it.

   PREREQUISITE
   The CSV must be at
   C:\Data\RetailEconomics\warehouse_and_retail_sales.csv, and the SQL
   Server service account must be able to read that path. If it cannot,
   use the SSMS 22 Import Flat File wizard instead - document 02
   section 5.4.

   VERIFY
   The final SELECT returns approximately 330,080 rows.

   Run the eight scripts in numeric order on a clean instance and the
   warehouse rebuilds from the source CSV with no manual step.

   Target      : SQL Server 2025, instance BRUNO\MSSQLSERVER01
   Source      : document 02 section 5.4. This file is generated from that
                 document - change the document and regenerate, do not edit here.
   ============================================================================ */

CREATE TABLE stg.WarehouseRetailSales
(
    [YEAR]              NVARCHAR(50)  NULL,
    [MONTH]             NVARCHAR(50)  NULL,
    [SUPPLIER]          NVARCHAR(255) NULL,
    [ITEM CODE]         NVARCHAR(100) NULL,
    [ITEM DESCRIPTION]  NVARCHAR(500) NULL,
    [ITEM TYPE]         NVARCHAR(100) NULL,
    [RETAIL SALES]      NVARCHAR(50)  NULL,
    [RETAIL TRANSFERS]  NVARCHAR(50)  NULL,
    [WAREHOUSE SALES]   NVARCHAR(50)  NULL
);
GO

BULK INSERT stg.WarehouseRetailSales
FROM 'C:\\Data\\RetailEconomics\\warehouse_and_retail_sales.csv'
WITH (
    FORMAT          = 'CSV',
    FIRSTROW        = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR   = '0x0a',
    CODEPAGE        = '65001',
    TABLOCK
);
GO

SELECT COUNT(*) AS StagedRows FROM stg.WarehouseRetailSales;
-- Expect approximately 330,080
