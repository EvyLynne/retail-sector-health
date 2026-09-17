/* ============================================================================
   06_item_lifecycle.sql
   U.S. Retail Sector Health - warehouse build, script 6 of 8
   Item lifecycle columns

   WHAT IT DOES
   Adds FirstSeenDateKey, LastSeenDateKey, MonthsActive and CohortYear
   to dw.DimItem and populates them from the fact table.

   PREREQUISITE
   Script 05 has loaded dw.FactItemMovement.

   VERIFY
   No lifecycle column is NULL for an item that has any movement.

   WARNING
   RE-RUN THIS SCRIPT AFTER EVERY RELOAD OF THE FACT TABLE. These
   columns are derived from it and go stale silently, not loudly - the
   assortment measures in folder 08 will return wrong answers with no
   error.

   Run the eight scripts in numeric order on a clean instance and the
   warehouse rebuilds from the source CSV with no manual step.

   Target      : SQL Server 2025, instance BRUNO\MSSQLSERVER01
   Source      : document 02 section 5.8. This file is generated from that
                 document - change the document and regenerate, do not edit here.
   ============================================================================ */

ALTER TABLE dw.DimItem ADD
    FirstSeenDateKey INT      NULL,
    LastSeenDateKey  INT      NULL,
    CohortYear       SMALLINT NULL,
    MonthsActive     SMALLINT NULL;
GO

;WITH Span AS (
    SELECT  ItemKey,
            MIN(DateKey)            AS FirstKey,
            MAX(DateKey)            AS LastKey,
            COUNT(DISTINCT DateKey) AS ActiveMonths
    FROM    dw.FactItemMovement
    GROUP BY ItemKey
)
UPDATE  i
SET     i.FirstSeenDateKey = s.FirstKey,
        i.LastSeenDateKey  = s.LastKey,
        i.CohortYear       = s.FirstKey / 10000,
        i.MonthsActive     = s.ActiveMonths
FROM    dw.DimItem AS i
        INNER JOIN Span AS s ON s.ItemKey = i.ItemKey;
GO

UPDATE dw.DimItem SET MonthsActive = 0 WHERE MonthsActive IS NULL;
GO
