/* ============================================================================
   01_create_database.sql
   U.S. Retail Sector Health - warehouse build, script 1 of 8
   Database and schemas

   WHAT IT DOES
   Creates the RetailEconomics database and the stg and dw schemas.

   PREREQUISITE
   None. This is the first script. Run it against the instance, not
   against a database.

   VERIFY
   SELECT name FROM sys.schemas WHERE name IN ('stg','dw'); returns
   two rows.

   Run the eight scripts in numeric order on a clean instance and the
   warehouse rebuilds from the source CSV with no manual step.

   Target      : SQL Server 2025, instance BRUNO\MSSQLSERVER01
   Source      : document 02 section 5.3. This file is generated from that
                 document - change the document and regenerate, do not edit here.
   ============================================================================ */

CREATE DATABASE RetailEconomics;
GO
USE RetailEconomics;
GO
CREATE SCHEMA stg AUTHORIZATION dbo;   -- landing, untyped
GO
CREATE SCHEMA dw  AUTHORIZATION dbo;   -- conformed, typed
GO
