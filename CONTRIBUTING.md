# Contributing to retail-sector-health
 
This repository version-controls the U.S. Retail Sector Health project end to
end: documents, SQL warehouse scripts, Power Query and DAX source, the Power BI
semantic model and three reports (binary and PBIP text form), and screenshots.
Full setup detail is in `docs/00_GitHub_Development_Guide.docx`.
 
## Architecture in one line
One published semantic model; three live-connected thin reports. Measures are
edited in the model file only.
 
## How each file type enters the repo
| File type | Tool | Workflow |
|---|---|---|
| Word docs, HTML, .pbix, screenshots | GitHub website | Upload -> descriptive commit message |
| PBIP text files (`pbip/`) | Power BI Desktop + GitHub Desktop | Save into the clone -> review diff -> Commit -> Push |
| SQL / M / DAX / theme | Either | Small text files |
 
## Rules
1. Never commit the source CSV, the Census API key, or SQL backup files.
2. Save .pbip files inside the clone's `pbip/` folder. Nowhere else.
3. Measure changes go in `RetailEconomics_Model` only. If you are editing the
   same measure in two files, the architecture has been broken.
4. Re-run `sql/06_item_lifecycle.sql` after any reload of the fact table.
5. Commit messages say what changed and why, not "update".
