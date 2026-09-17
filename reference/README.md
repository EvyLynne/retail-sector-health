# reference/
 
Analyst-maintained inputs. One file: RefMappings.xlsx.
 
This workbook is committed on purpose, and the distinction is the whole
rule: source data stays out of Git, analyst judgement goes in.
RefMappings is the second kind. It carries the display names, groupings
and classifications that no upstream system owns.
 
## What is in the workbook
 
CategoryMap
- CategoryCode, CategoryName — transcribed from the published MARTS list
- IsAggregate — derived from the code list
- CategoryGroup, DisplayOrder — analyst judgement, openly labelled
 
ItemTypeMap
- ItemType — the source's own distinct values
- BeverageClass — analyst judgement, openly labelled
 
## Rules
- Use named tables, not sheet ranges. Power Query binds to the name; a
  range shifts the moment a row is inserted above it.
- No column here invents a fact. Every value is transcribed, derived, or
  a display choice that says so. Full provenance is document 02
  section 6.4.
- Changing a grouping changes what every report displays. Commit with a
  message that says what moved and why.
