# powerquery/
 
The M source behind every query in the semantic model, extracted so it
is readable and diffable outside Power BI Desktop.
 
| File | Query |
|---|---|
| fnGetFredSeries.m | Reusable function — one FRED series per call |
| FactMacro.m | Invokes the function per series, then appends |
| FactSectorSales.m | Census MARTS, Web.Contents with a Query record |
| DimCategory.m | The RefMappings.xlsx named table |
 
## Rules
- This folder mirrors the model; it is not the model. Edit in Power BI
  Desktop, then paste the Advanced Editor text back here. The
  authoritative copy is pbip/RetailEconomics_Model/.
- pCensusKey is referenced as a parameter and never appears as a literal
  in any file here. Check that before every commit, not after.
- Web.Contents keeps its base URL static, with RelativePath and Query
  carrying everything variable. That is precisely what lets the Power BI
  Service refresh these two sources without a gateway.
