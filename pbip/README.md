# pbip/
 
Power BI Project format — the text serialization of all four Power BI
files. This is the folder that turns a model change into a reviewable
line-by-line diff instead of an opaque binary blob.
 
| Folder | Contains |
|---|---|
| RetailEconomics_Model/ | The semantic model. TMDL lives here |
| R1_Retail_Sector_Health/ | Report definition only |
| R2_Consumer_Stress/ | Report definition only |
| R3_Assortment_Supplier/ | Report definition only |
 
## Rules
- Save every .pbip inside this folder. Saving elsewhere and copying files
  in afterwards is how commit history gets lost.
- Only RetailEconomics_Model/ contains TMDL. If a report folder ever
  grows a model, the live connection has been broken and the report is
  no longer thin.
- .pbi/localSettings.json and cache.abf are ignored. Confirm they show as
  grayed out in GitHub Desktop before the first commit.
- Search the TMDL for "key=" and for the first six characters of the
  Census key before every push. A parameter's current value can serialize
  depending on the Desktop version and settings.
