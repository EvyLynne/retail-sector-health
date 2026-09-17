/* ============================================================================
   05_fact_and_proc.sql
   U.S. Retail Sector Health - warehouse build, script 5 of 8
   Fact table and load procedure

   WHAT IT DOES
   Creates dw.FactItemMovement and the procedure that loads it from
   staging, converting text measures to decimal and resolving the
   dimension keys.

   PREREQUISITE
   Script 04 has populated all three dimensions.

   VERIFY
   The staged-versus-loaded reconciliation at the end of the script
   returns no unexplained gap.

   Run the eight scripts in numeric order on a clean instance and the
   warehouse rebuilds from the source CSV with no manual step.

   Target      : SQL Server 2025, instance BRUNO\MSSQLSERVER01
   Source      : document 02 section 5.7. This file is generated from that
                 document - change the document and regenerate, do not edit here.
   ============================================================================ */

CREATE TABLE dw.FactItemMovement
(
    ItemMovementKey BIGINT IDENTITY(1,1) NOT NULL,
    DateKey         INT           NOT NULL,
    SupplierKey     INT           NOT NULL,
    ItemKey         INT           NOT NULL,
    RetailSales     DECIMAL(18,4) NULL,   -- CASES
    RetailTransfers DECIMAL(18,4) NULL,   -- CASES
    WarehouseSales  DECIMAL(18,4) NULL,   -- CASES
    CONSTRAINT PK_FactItemMovement PRIMARY KEY CLUSTERED (ItemMovementKey),
    CONSTRAINT FK_FIM_Date     FOREIGN KEY (DateKey)
        REFERENCES dw.DimDate (DateKey),
    CONSTRAINT FK_FIM_Supplier FOREIGN KEY (SupplierKey)
        REFERENCES dw.DimSupplier (SupplierKey),
    CONSTRAINT FK_FIM_Item     FOREIGN KEY (ItemKey)
        REFERENCES dw.DimItem (ItemKey)
);
GO

CREATE OR ALTER PROCEDURE dw.usp_LoadFactItemMovement
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRAN;

        TRUNCATE TABLE dw.FactItemMovement;

        INSERT INTO dw.FactItemMovement
                (DateKey, SupplierKey, ItemKey,
                 RetailSales, RetailTransfers, WarehouseSales)
        SELECT  d.DateKey,
                s.SupplierKey,
                i.ItemKey,
                TRY_CONVERT(decimal(18,4), src.[RETAIL SALES]),
                TRY_CONVERT(decimal(18,4), src.[RETAIL TRANSFERS]),
                TRY_CONVERT(decimal(18,4), src.[WAREHOUSE SALES])
        FROM    stg.WarehouseRetailSales AS src
                INNER JOIN dw.DimDate AS d
                        ON d.DateKey = TRY_CONVERT(int, src.[YEAR])  * 10000
                                     + TRY_CONVERT(int, src.[MONTH]) * 100 + 1
                INNER JOIN dw.DimSupplier AS s
                        ON s.SupplierName = COALESCE(
                               NULLIF(LTRIM(RTRIM(src.[SUPPLIER])), ''),
                               'Unknown Supplier')
                INNER JOIN dw.DimItem AS i
                        ON i.ItemCode = LTRIM(RTRIM(src.[ITEM CODE]))
        WHERE   TRY_CONVERT(int, src.[YEAR])  IS NOT NULL
          AND   TRY_CONVERT(int, src.[MONTH]) BETWEEN 1 AND 12;

    COMMIT TRAN;

    -- Reconciliation: this is not optional output
    SELECT (SELECT COUNT(*) FROM stg.WarehouseRetailSales) AS StagedRows,
           (SELECT COUNT(*) FROM dw.FactItemMovement)      AS LoadedRows;
END;
GO

EXEC dw.usp_LoadFactItemMovement;
GO
