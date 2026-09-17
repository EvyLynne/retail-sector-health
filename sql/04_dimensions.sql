/* ============================================================================
   04_dimensions.sql
   U.S. Retail Sector Health - warehouse build, script 4 of 8
   Dimensions

   WHAT IT DOES
   Creates and populates dw.DimSupplier, dw.DimItem and dw.DimDate.
   DimDate is MONTHLY, one row per month, shared by all three tiers.

   PREREQUISITE
   Scripts 01 to 02 have run. Read the script 03 output first - the
   cleansing choices here follow from it.

   VERIFY
   Each dimension has rows and no duplicate business key.

   Run the eight scripts in numeric order on a clean instance and the
   warehouse rebuilds from the source CSV with no manual step.

   Target      : SQL Server 2025, instance BRUNO\MSSQLSERVER01
   Source      : document 02 section 5.6. This file is generated from that
                 document - change the document and regenerate, do not edit here.
   ============================================================================ */

/* ---------- Supplier ---------- */
CREATE TABLE dw.DimSupplier
(
    SupplierKey  INT IDENTITY(1,1) NOT NULL,
    SupplierName NVARCHAR(255)     NOT NULL,
    CONSTRAINT PK_DimSupplier PRIMARY KEY CLUSTERED (SupplierKey),
    CONSTRAINT UQ_DimSupplier_Name UNIQUE (SupplierName)
);
GO

INSERT INTO dw.DimSupplier (SupplierName)
SELECT DISTINCT
       COALESCE(NULLIF(LTRIM(RTRIM([SUPPLIER])), ''), 'Unknown Supplier')
FROM   stg.WarehouseRetailSales;
GO

/* ---------- Item ---------- */
CREATE TABLE dw.DimItem
(
    ItemKey         INT IDENTITY(1,1) NOT NULL,
    ItemCode        NVARCHAR(100)     NOT NULL,
    ItemDescription NVARCHAR(500)     NULL,
    ItemType        NVARCHAR(100)     NOT NULL,
    CONSTRAINT PK_DimItem PRIMARY KEY CLUSTERED (ItemKey),
    CONSTRAINT UQ_DimItem_Code UNIQUE (ItemCode)
);
GO

INSERT INTO dw.DimItem (ItemCode, ItemDescription, ItemType)
SELECT  LTRIM(RTRIM([ITEM CODE])),
        MAX(LTRIM(RTRIM([ITEM DESCRIPTION]))),
        COALESCE(NULLIF(LTRIM(RTRIM(MAX([ITEM TYPE]))), ''), 'Unclassified')
FROM    stg.WarehouseRetailSales
WHERE   NULLIF(LTRIM(RTRIM([ITEM CODE])), '') IS NOT NULL
GROUP BY LTRIM(RTRIM([ITEM CODE]));
GO

/* ---------- Date: MONTHLY, shared by all three tiers ---------- */
CREATE TABLE dw.DimDate
(
    DateKey     INT         NOT NULL,   -- YYYYMM01
    [Date]      DATE        NOT NULL,
    [Year]      SMALLINT    NOT NULL,
    [Quarter]   TINYINT     NOT NULL,
    QuarterName CHAR(7)     NOT NULL,
    MonthNumber TINYINT     NOT NULL,
    MonthName   VARCHAR(12) NOT NULL,
    MonthYear   CHAR(8)     NOT NULL,
    CONSTRAINT PK_DimDate PRIMARY KEY CLUSTERED (DateKey)
);
GO

;WITH Months AS (
    SELECT CAST('2015-01-01' AS DATE) AS d
    UNION ALL
    SELECT DATEADD(MONTH, 1, d) FROM Months WHERE d < '2030-12-01'
)
INSERT INTO dw.DimDate
        (DateKey, [Date], [Year], [Quarter], QuarterName,
         MonthNumber, MonthName, MonthYear)
SELECT  YEAR(d) * 10000 + MONTH(d) * 100 + 1,
        d, YEAR(d), DATEPART(QUARTER, d),
        CAST(YEAR(d) AS CHAR(4)) + ' Q' + CAST(DATEPART(QUARTER, d) AS CHAR(1)),
        MONTH(d), DATENAME(MONTH, d),
        LEFT(DATENAME(MONTH, d), 3) + ' ' + CAST(YEAR(d) AS CHAR(4))
FROM    Months
OPTION (MAXRECURSION 0);
GO
