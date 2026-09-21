# U.S. Retail Sector Health - Power BI
 
Three Power BI reports on one shared semantic model, tracing U.S. retail
from national macro conditions to item-level physical movement.
 
## Reports
![R1 Macro Environment](assets/r1_p1_macro.png)
![R2 Recession Resistance](assets/r2_p1_stress.png)
![R3 Assortment Concentration](assets/r3_p1_assortment.png)

## Power BI Files structure
![Star schema](assets/fig_filesplit.png)
 
## Data model
![Star schema](assets/model_view.png)

## Semantic model
![PBI Semantic schema](assets/fig_modelview.png)

## Pipeline diagram
![Pipeline diagram](assets/fig_pipeline.png)
 
## Highlights
- Three ingestion patterns in one model: keyed REST API (Census MARTS),
  on-premises SQL Server (330,080 rows), and a governed Excel reference file
- One published semantic model, three live-connected thin reports
- Physical case volume reconciled against nominal dollar sales by
  deflating the national series - not by comparing levels
- PBIP source control: every DAX change is a readable line diff
 
## Data sources (not redistributed here)
- Census MARTS API: https://api.census.gov/data/timeseries/eits/marts
- FRED: https://fred.stlouisfed.org/
- Montgomery County item movement:
  https://catalog.data.gov/dataset/warehouse-and-retail-sales
 
## Repository map
| Folder | Contents |
|---|---|
| docs/ | Numbered documentation set (00, 01, 02, 12, 13, 14, 15, 20, 21, 22, 23, 25) |
| sql/ | Warehouse build scripts, run 01 through 08 in order |
| powerquery/ | M source for the API and file queries |
| dax/ | Measure catalog by display folder |
| pbip/ | Power BI Project text - the diffable source |
| pbix/ | Four binaries: model + three reports |
| reference/ | RefMappings.xlsx |
| theme/ | Report theme JSON |
| assets/ | Page and model screenshots |
 
## Limitations
Item-level data covers one Maryland county and one product category;
it is used for grain, not for national inference. Regression coefficients
are descriptive, not inferential. See docs/01 section 8.
