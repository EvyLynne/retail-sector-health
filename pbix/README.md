# pbix/
 
The four binaries, refreshed at milestones. This is what a reviewer
double-clicks; pbip/ is what Git actually diffs. Both are deliberate.
 
| File | Contents |
|---|---|
| RetailEconomics_Model.pbix | Model and data, no report pages |
| R1_Retail_Sector_Health.pbix | Thin report, live connection |
| R2_Consumer_Stress.pbix | Thin report, live connection |
| R3_Assortment_Supplier.pbix | Thin report, live connection |
 
## Rules
- Binaries do not diff. Commit them at milestones, with a message saying
  what changed — not on every save.
- Upload through the GitHub website. GitHub Desktop handles them, but the
  website is simpler for files this size.
- The three report files carry no model. If one of them is more than a
  few megabytes, it is not thin and something has gone wrong.
