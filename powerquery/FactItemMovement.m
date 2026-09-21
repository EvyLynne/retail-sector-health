// ========================================================================
// FactItemMovement.m
// U.S. Retail Sector Health - Power Query source
//
// QUERY        DimItem (dw.vw_Item merged with the item-type map)
// LOADS TO     DimItem (dimension)
// SOURCE       document 02 section 6.3
// DEPENDS ON   dw.vw_Item from sql/08, and pRefMappingsPath -> reference/RefMappings.xlsx
//
// NOTE  Reads a view, never a base table. Both of its sources are local -
// NOTE  SQL Server and a file share - so it refreshes in the Service only
// NOTE  through the on-premises gateway.
//
// This folder MIRRORS the semantic model; it is not the model. Edit in
// Power BI Desktop, then paste the Advanced Editor text back here. The
// authoritative copy is pbip/RetailEconomics_Model/.
// ========================================================================

let
    Source   = Sql.Database("BRUNO\MSSQLSERVER01", "RetailEconomics"),
    ItemView = Source{[Schema = "dw", Item = "vw_Item"]}[Data],

    Wb       = Excel.Workbook(
                   File.Contents(pRefMappingsPath),
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
