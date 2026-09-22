// ========================================================================
// FactSectorSales.m
// U.S. Retail Sector Health - Power Query source
//
// QUERY        FactSectorSales
// LOADS TO     FactSectorSales (fact table)
// SOURCE       document 02 section 3.5
// DEPENDS ON   Parameters pCensusKey, pStartPeriod
//
// NOTE  pCensusKey is referenced as a parameter and never inlined. Search
// NOTE  the PBIP text for "key=" before the first push - document 00
// NOTE  section 12.
//
// VERIFIED 2026-09-22 against the live endpoint: 21 category codes
// discovered, 2,940 rows, 140 months per code, 2015-01 through 2026-08.
//
// This folder MIRRORS the semantic model; it is not the model. Edit in
// Power BI Desktop, then paste the Advanced Editor text back here. The
// authoritative copy is pbip/RetailEconomics_Model/.
// ========================================================================

let
    // Parameters: pCensusKey, pStartPeriod

    Fields =
        "cell_value,category_code,data_type_code,seasonally_adj,time_slot_name",

    Key = Text.Trim(pCensusKey),

    // ------------------------------------------------------------------
    // Shared caller. This endpoint answers with an EMPTY body - not an HTTP
    // error - for a comma-separated category_code list and for any code it
    // does not publish. Json.Document on an empty body raises
    // "DataFormat.Error: We reached the end of the buffer", so every response
    // is inspected before it is parsed and unusable ones return null.
    // ------------------------------------------------------------------
    Call = (q as record) as nullable list =>
        let
            Response =
                Binary.Buffer(
                    Web.Contents(
                        "https://api.census.gov",
                        [
                            RelativePath = "data/timeseries/eits/marts",
                            Query = q,
                            ManualStatusHandling = {204, 400, 401, 403, 404, 429, 500, 502, 503}
                        ]
                    )
                ),
            Body   = Text.Trim(Text.FromBinary(Response)),
            Parsed = if Text.StartsWith(Body, "[") then Json.Document(Body) else null
        in
            if Parsed = null or List.Count(Parsed) < 2 then null else Parsed,

    // The API echoes predicate columns - data_type_code and seasonally_adj on
    // every call, category_code on the history calls - so the header carries
    // repeats. Suffix them; Cleaned keeps only what the model needs.
    ToTable = (parsed as list) as table =>
        let
            RawHeader = List.First(parsed),
            Header =
                List.Accumulate(
                    RawHeader,
                    {},
                    (seen, col) =>
                        seen
                      & { if List.Contains(seen, col)
                          then col & "_echo" & Text.From(List.Count(seen))
                          else col }
                )
        in
            Table.FromRows(List.Skip(parsed, 1), Header),

    // ------------------------------------------------------------------
    // 1. DISCOVERY - one recent month, no category_code predicate, so the
    //    response names every code the advance survey currently publishes.
    //    cell_value must be in get: the API rejects a predicate-only get with
    //    "missing required variable/predicate: cell_value". Advance estimates
    //    lag by weeks, so recent months are tried until one returns data.
    // ------------------------------------------------------------------
    MonthText = (offset as number) as text =>
        Date.ToText(Date.AddMonths(Date.From(DateTime.FixedLocalNow()), - offset), "yyyy-MM"),

    Discovery =
        List.First(
            List.RemoveNulls(
                List.Transform(
                    {1, 2, 3, 4, 5},
                    each Call(
                        [
                            get            = Fields,
                            #"for"         = "us:*",
                            time           = MonthText(_),
                            data_type_code = "SM",
                            seasonally_adj = "yes",
                            key            = Key
                        ]
                    )
                )
            ),
            null
        ),

    PublishedCodes =
        if Discovery = null then
            error Error.Record(
                "Census.DiscoveryFailed",
                "No category codes returned for any of the last five months. Check pCensusKey and the api.census.gov credential."
            )
        else
            List.Sort(
                List.Distinct(
                    List.Transform(
                        Table.Column(
                            Table.SelectRows(
                                ToTable(Discovery),
                                each [data_type_code] = "SM"
                            ),
                            "category_code"
                        ),
                        Text.From
                    )
                )
            ),

    // ------------------------------------------------------------------
    // 2. HISTORY - one request per discovered code over the open-ended
    //    range. A code returning nothing is skipped rather than fatal.
    // ------------------------------------------------------------------
    GetOne = (cat as text) as nullable table =>
        let
            Parsed =
                Call(
                    [
                        get            = Fields,
                        #"for"         = "us:*",
                        time           = "from " & Text.Trim(pStartPeriod),
                        category_code  = cat,
                        data_type_code = "SM",
                        seasonally_adj = "yes",
                        key            = Key
                    ]
                )
        in
            if Parsed = null then null else ToTable(Parsed),

    Returned = List.RemoveNulls(List.Transform(PublishedCodes, GetOne)),

    AsTable =
        if List.Count(Returned) = 0 then
            error Error.Record(
                "Census.NoData",
                "Codes were discovered but every history request came back empty."
            )
        else
            Table.Combine(Returned),

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
