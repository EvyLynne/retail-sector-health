/* ============================================================================
   08_presentation_views.sql
   U.S. Retail Sector Health - warehouse build, script 8 of 8
   Presentation views

   WHAT IT DOES
   Creates dw.vw_ItemMovement, the single object Power BI reads. Power
   BI never reads a base table.

   PREREQUISITE
   Scripts 01 to 07 have all run.

   VERIFY
   SELECT TOP 10 * FROM dw.vw_ItemMovement; returns rows with resolved
   dimension attributes.

   Run the eight scripts in numeric order on a clean instance and the
   warehouse rebuilds from the source CSV with no manual step.

   Target      : SQL Server 2025, instance BRUNO\MSSQLSERVER01
   Source      : document 02 section 5.10. This file is generated from that
                 document - change the document and regenerate, do not edit here.
   ============================================================================ */

CREATE OR ALTER VIEW dw.vw_ItemMovement
AS
SELECT  f.DateKey,
        f.SupplierKey,
        f.ItemKey,
        f.RetailSales,
        f.RetailTransfers,
        f.WarehouseSales,
        f.RetailSales + f.WarehouseSales AS TotalMovement
FROM    dw.FactItemMovement AS f;
GO

CREATE OR ALTER VIEW dw.vw_Item
AS
SELECT  ItemKey, ItemCode, ItemDescription, ItemType,
        FirstSeenDateKey, LastSeenDateKey, CohortYear, MonthsActive
FROM    dw.DimItem;
GO
