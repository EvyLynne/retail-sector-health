// ========================================================================
// FactMacro.m
// U.S. Retail Sector Health - Power Query source
//
// QUERY        FactMacro
// LOADS TO     FactMacro (fact table)
// SOURCE       document 02 section 4.3
// DEPENDS ON   fnGetFredSeries.m
//
// This folder MIRRORS the semantic model; it is not the model. Edit in
// Power BI Desktop, then paste the Advanced Editor text back here. The
// authoritative copy is pbip/RetailEconomics_Model/.
// ========================================================================

let
    SeriesList = {
        "CPIAUCSL", "RSAFS", "RRSFS", "MRTSSM452USS",
        "FEDFUNDS", "UMCSENT", "UNRATE", "PSAVERT", "DSPIC96"
    },

    AsTable  = Table.FromList(SeriesList, Splitter.SplitByNothing(), {"SeriesId"}),

    Invoked  = Table.AddColumn(AsTable, "Data", each fnGetFredSeries([SeriesId])),

    Expanded = Table.ExpandTableColumn(
                   Invoked, "Data",
                   {"DateKey", "ReportDate", "Value"},
                   {"DateKey", "ReportDate", "Value"}
               ),

    Typed    = Table.TransformColumnTypes(
                   Expanded,
                   {
                       {"DateKey",    Int64.Type},
                       {"ReportDate", type date},
                       {"Value",      type number}
                   }
               ),

    // Restrict to the analysis window so the macro tier aligns with Tier 3.
    Windowed = Table.SelectRows(Typed, each [ReportDate] >= #date(2017, 1, 1))
in
    Windowed
