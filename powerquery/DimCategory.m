// ========================================================================
// DimCategory.m
// U.S. Retail Sector Health - Power Query source
//
// QUERY        DimCategory
// LOADS TO     DimCategory (dimension)
// SOURCE       document 02 section 6.2
// DEPENDS ON   RefMappings.xlsx in reference/
//
// NOTE  Binds to a NAMED TABLE, not a sheet range. A range shifts the
// NOTE  moment a row is inserted above it.
//
// This folder MIRRORS the semantic model; it is not the model. Edit in
// Power BI Desktop, then paste the Advanced Editor text back here. The
// authoritative copy is pbip/RetailEconomics_Model/.
// ========================================================================

let
    Source   = Excel.Workbook(
                   File.Contents("C:\Data\RetailEconomics\RefMappings.xlsx"),
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
