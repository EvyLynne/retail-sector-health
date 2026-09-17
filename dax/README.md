# dax/
 
The measure catalog, one file per display folder, mirroring the folder
structure inside the semantic model. 79 measures in total.
 
| File | Display folder in the model |
|---|---|
| 01_macro.dax | 01 Macro |
| 02_sector.dax | 02 Sector |
| 03_micro.dax | 03 Micro |
| 04_cross_tier.dax | 04 Cross-Tier |
| 05_channel.dax | 05 Channel |
| 06_elasticity.dax | 06 Elasticity |
| 07_rotation.dax | 07 Rotation |
| 08_assortment.dax | 08 Assortment |
| 09_supplier.dax | 09 Supplier |
| 10_seasonality.dax | 10 Seasonality |
 
Every definition, with its format string and its description, is also in
docs/20_Data_Dictionary.xlsx on the Measures tab.
 
## Rules
- Measures live in the semantic model only. A measure added inside a thin
  report exists in that one report, which is the divergence the shared
  model exists to prevent.
- This folder is a readable mirror. Where it disagrees with the model,
  the model is right and this folder is stale.
- Leave a blank line between measures so a diff stays legible.
