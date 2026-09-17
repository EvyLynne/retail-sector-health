# theme/
 
One report theme per report. Power BI applies exactly one theme JSON to a
report file, and themes cannot import or inherit from one another, so each
file here is complete rather than a patch on a shared base. Do it before building the first visual, not after: a theme changes
defaults, and it does not overwrite a property already set by hand.
 
| File | Applied to |
|---|---|
| R1_Retail_Sector_Health.json | R1 — Macro Environment |
| R2_Consumer_Stress.json | R2 — Recession Resistance |
| R3_Assortment_Supplier.json | R3 — Assortment Concentration |
 
All three carry an identical palette, page background, text classes and
wildcard visual defaults, so the three reports read as one family. Each
then adds visualStyles for the visual types that report actually uses:
R1 line and combo weights, R2 the diverging matrix and stacked area,
R3 scatter bubbles and the Pareto combo.
 
| Token | Hex | Used for |
|---|---|---|
| dataColors[0] | #1F3864 | Navy — primary series, header band |
| dataColors[1] | #2E74B5 | Blue — secondary series, data bars |
| dataColors[2] | #1B9E8F | Teal — real / deflated series |
| dataColors[3] | #C8860A | Amber — markers, thresholds, warnings |
| bad / good | #C0392B / #1E7B34 | Conditional formatting extremes |
| neutral | #B3B0AD | Muted and below-reference series |
| background | #FAFAFA | Canvas |
| secondaryBackground | #FFFFFF | Visual background |
 
## Rules
- The palette above is document 15 section 3.1, verbatim. If these files
  and that table ever disagree, fix the file — the document is the spec.
- Power BI silently ignores a theme key it does not recognise. Nothing
  errors, nothing warns; the property simply keeps its default. Verify by
  looking, using the three checks in document 15 section 3.3.
- A colour set on an individual visual overrides the theme and is
  invisible to anyone reading this folder. Avoid it.
- Editing one file does not change the other two. A palette change is
  three edits, and re-running theme/gen_themes.py is the safer way to
  make it.
- The canvas is 1280 x 720 on every page of all three reports. That is a
  page setting, not a theme setting — changing it here does nothing.
 
