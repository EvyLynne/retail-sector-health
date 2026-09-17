// ========================================================================
// FactItemMovement.m
// U.S. Retail Sector Health - Power Query source
//
// QUERY        FactItemMovement and the SQL Server dimensions
// LOADS TO     FactItemMovement, DimItem, DimSupplier, DimDate
// SOURCE       document 02 section 7.1
// DEPENDS ON   The warehouse built by sql/01 through sql/08
//
// NOTE  Reads dw.vw_ItemMovement, never a base table. This is the only
// NOTE  source that requires the on-premises gateway to refresh in the
// NOTE  Service.
//
// This folder MIRRORS the semantic model; it is not the model. Edit in
// Power BI Desktop, then paste the Advanced Editor text back here. The
// authoritative copy is pbip/RetailEconomics_Model/.
// ========================================================================

let
    Source   = Sql.Database("BRUNO\MSSQLSERVER01", "RetailEconomics"),
    ItemView = Source{[Schema = "dw", Item = "vw_Item"]}[Data],

    Wb       = Excel.Workbook(
                   File.Contents("C:\Data\RetailEconomics\RefMappings.xlsx"),
                   null, true
               ),
    TypeMap  = Wb{[Item = "tbl_ItemTypeMap", Kind = "Table"]}[Data],

    Joined   = Table.NestedJoin(
                   ItemView, {"ItemType"},
                   TypeMap,  {"ItemType"},
                   "map", JoinKind.LeftOuter
               ),

    Expanded = Table.ExpandTableColumn(
                   Joined, "map",
                   {"BeverageClass"},
                   {"BeverageClass"}
               ),

    // Unmatched types become "Unmapped" rather than blank, so they are
    // visible on a slicer instead of silently disappearing from it.
    Filled   = Table.ReplaceValue(
                   Expanded, null, "Unmapped",
                   Replacer.ReplaceValue,
                   {"BeverageClass"}
               )
in
    Filled
