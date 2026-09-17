/* ============================================================================
   07_indexes.sql
   U.S. Retail Sector Health - warehouse build, script 7 of 8
   Indexing

   WHAT IT DOES
   Adds the non-clustered columnstore index that serves the analytical
   scans over the fact table.

   PREREQUISITE
   Script 06 has finished. Index after loading, not before - loading
   into an indexed table is slower and fragments it.

   VERIFY
   SELECT * FROM sys.indexes WHERE object_id =
   OBJECT_ID('dw.FactItemMovement'); shows the columnstore index.

   Run the eight scripts in numeric order on a clean instance and the
   warehouse rebuilds from the source CSV with no manual step.

   Target      : SQL Server 2025, instance BRUNO\MSSQLSERVER01
   Source      : document 02 section 5.9. This file is generated from that
                 document - change the document and regenerate, do not edit here.
   ============================================================================ */

CREATE NONCLUSTERED COLUMNSTORE INDEX NCCX_FactItemMovement
    ON dw.FactItemMovement
       (DateKey, SupplierKey, ItemKey,
        RetailSales, RetailTransfers, WarehouseSales);
GO

CREATE NONCLUSTERED INDEX IX_FactItemMovement_DateKey
    ON dw.FactItemMovement (DateKey)
    INCLUDE (RetailSales, WarehouseSales);
GO
