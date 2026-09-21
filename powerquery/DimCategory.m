// ========================================================================
// DimCategory.m
// U.S. Retail Sector Health - Power Query source
//
// QUERY        DimCategory
// LOADS TO     DimCategory (dimension)
// SOURCE       document 02 section 6.2
// DEPENDS ON   Parameter pRefMappingsPath -> reference/RefMappings.xlsx
//
// NOTE  Binds to a NAMED TABLE, not a sheet range. A range shifts the
// NOTE  moment a row is inserted above it. The workbook location comes
// NOTE  from pRefMappingsPath, set to its UNC path - document 02 section
// NOTE  6.1.
//
// This folder MIRRORS the semantic model; it is not the model. Edit in
// Power BI Desktop, then paste the Advanced Editor text back here. The
// authoritative copy is pbip/RetailEconomics_Model/.
// ========================================================================

let
    Source   = Excel.Workbook(
                   File.Contents(pRefMappingsPath),
                   null, true
               ),

    Tbl      = Source{[Item = "tbl_CategoryMap", Kind = "Table"]}[Data],

    Typed    = Table.TransformColumnTypes(
                   Tbl,
                   {
                       {"CategoryCode",  type text},
                       {"CategoryName",  type text},
                       {"CategoryGroup", type text},
                       {"DisplayOrder",  Int64.Type},
                       {"IsAggregate",   type logical}
                   }
               ),

    Trimmed  = Table.TransformColumns(
                   Typed,
                   {{"CategoryCode", Text.Trim, type text},
                    {"CategoryName", Text.Trim, type text}}
               ),

    NoBlanks = Table.SelectRows(
                   Trimmed,
                   each [CategoryCode] <> null and [CategoryCode] <> ""
               )
in
    NoBlanks
