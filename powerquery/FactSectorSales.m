// ========================================================================
// FactSectorSales.m
// U.S. Retail Sector Health - Power Query source
//
// QUERY        FactSectorSales
// LOADS TO     FactSectorSales (fact table)
// SOURCE       document 02 section 3.5
// DEPENDS ON   Parameters pCensusKey, pStartPeriod, pEndPeriod
//
// NOTE  pCensusKey is referenced as a parameter and never inlined. Search
// NOTE  the PBIP text for "key=" before the first push - document 00
// NOTE  section 12.
//
// This folder MIRRORS the semantic model; it is not the model. Edit in
// Power BI Desktop, then paste the Advanced Editor text back here. The
// authoritative copy is pbip/RetailEconomics_Model/.
// ========================================================================

let
    // Parameters: pCensusKey, pStartPeriod, pEndPeriod

    Fields =
        "cell_value,category_code,data_type_code,seasonally_adj,time_slot_name",

    CategoryList =
        "44X72,44000,441,442,443,444,445,4453,446,447,448,"
      & "451,452,4522,452311,453,454,4541,722",

    Source =
        Json.Document(
            Web.Contents(
                "https://api.census.gov",
                [
                    RelativePath = "data/timeseries/eits/marts",
                    Query =
                    [
                        get            = Fields,
                        #"for"         = "us:*",
                        time           = "from " & pStartPeriod & " to " & pEndPeriod,
                        category_code  = CategoryList,
                        data_type_code = "SM",
                        seasonally_adj = "yes",
                        key            = pCensusKey
                    ]
                ]
            )
        ),

    AsTable = Table.FromRows(List.Skip(Source, 1), List.First(Source)),

    // time_slot_name arrives as "July 2026"; normalise to a month start.
    AddDate = Table.AddColumn(
                  AsTable, "ReportDate",
                  each Date.StartOfMonth(Date.From([time_slot_name])),
                  type date
              ),

    AddKey  = Table.AddColumn(
                  AddDate, "DateKey",
                  each Date.Year([ReportDate]) * 10000
                     + Date.Month([ReportDate]) * 100 + 1,
                  Int64.Type
              ),

    Typed   = Table.TransformColumnTypes(
                  AddKey,
                  {
                      {"cell_value",    Int64.Type},
                      {"category_code", type text}
                  }
              ),

    // cell_value under data_type_code "SM" is MILLIONS OF DOLLARS.
    Renamed = Table.RenameColumns(Typed, {{"cell_value", "SalesMillionsUSD"}}),

    Cleaned = Table.SelectColumns(
                  Renamed,
                  {"DateKey", "ReportDate", "category_code", "SalesMillionsUSD"}
              ),

    NoNulls = Table.SelectRows(Cleaned, each [SalesMillionsUSD] <> null)
in
    NoNulls
