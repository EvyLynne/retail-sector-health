// ========================================================================
// fnGetFredSeries.m
// U.S. Retail Sector Health - Power Query source
//
// QUERY        fnGetFredSeries (function)
// LOADS TO     Nothing. Invoked by FactMacro.m, once per series.
// SOURCE       document 02 section 4.2
// DEPENDS ON   Nothing. Build this first.
//
// NOTE  Web.Contents keeps a static base URL with RelativePath and Query
// NOTE  carrying everything variable. That is what lets the Service
// NOTE  refresh it without a gateway.
//
// This folder MIRRORS the semantic model; it is not the model. Edit in
// Power BI Desktop, then paste the Advanced Editor text back here. The
// authoritative copy is pbip/RetailEconomics_Model/.
// ========================================================================

let
    fnGetFredSeries = (SeriesId as text) as table =>
    let
        Source =
            Csv.Document(
                Web.Contents(
                    "https://fred.stlouisfed.org",
                    [
                        RelativePath = "graph/fredgraph.csv",
                        Query        = [ id = SeriesId ]
                    ]
                ),
                [ Delimiter = ",", Encoding = 65001, QuoteStyle = QuoteStyle.Csv ]
            ),

        Promoted = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),

        // Rename POSITIONALLY, not by name. FRED has changed the date column
        // header historically; position has been stable. This keeps the query
        // from breaking on an upstream header change.
        Renamed  = Table.RenameColumns(
                       Promoted,
                       List.Zip({
                           List.FirstN(Table.ColumnNames(Promoted), 2),
                           {"ReportDate", "Value"}
                       })
                   ),

        Typed    = Table.TransformColumnTypes(
                       Renamed,
                       {{"ReportDate", type date}, {"Value", type number}}
                   ),

        // FRED writes "." for missing observations; these become nulls above.
        NoNulls  = Table.SelectRows(Typed, each [Value] <> null),

        Tagged   = Table.AddColumn(NoNulls, "SeriesId", each SeriesId, type text),

        AddKey   = Table.AddColumn(
                       Tagged, "DateKey",
                       each Date.Year([ReportDate]) * 10000
                          + Date.Month([ReportDate]) * 100 + 1,
                       Int64.Type
                   ),

        Final    = Table.SelectColumns(
                       AddKey,
                       {"DateKey", "ReportDate", "SeriesId", "Value"}
                   )
    in
        Final
in
    fnGetFredSeries
