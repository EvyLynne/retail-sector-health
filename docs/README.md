# docs/
 
The numbered document set. Everything a human reads in lifecycle sequence
lives here; nothing a system consumes does.
 
| Doc | File | What it answers |
|---|---|---|
| 00 | 00_Development_Environment_and_Source_Control_Setup_Guide.docx | Where does the work live? |
| 01 | 01_Project_Plan_Retail_Sector_Health.docx | What are we building? |
| 02 | 02_Data_Setup_and_Semantic_Model_Guide.docx | How does data get in? |
| 12 | 12_R1_Report_Mockup.html | What should R1 look like? |
| 13 | 13_R2_Report_Mockup.html | What should R2 look like? |
| 14 | 14_R3_Report_Mockup.html | What should R3 look like? |
| 15 | 15_Report_Build_Instructions.docx | How is each visual built? |
| 20 | 20_Data_Dictionary.xlsx | What is this column or measure? |
| 21 | 21_Development_Checklist.xlsx | Was this step completed? Is this step necessary?  How much is completed? |
| 22 | 22_Validation_Results.xlsx | Did the seventeen checks pass, on what date, with what numbers? |
| 23 | 23_Glossary.docx | What does this term mean here? |
| 25 | 25_Validation_Timing_Guide.docx | When do I validate, and what? |
| 26 | 26_Validation_Timing_Checklist.xlsx | Has each gate passed? What was re-validated, and when? |
| -- | validation/ | How do I actually run check N, step by step? |
 
Read 00 first. It is numbered 00 because the repository has to exist
before anything else in the project does.
 
Numbering is gapped on purpose. 05, 24 and 30 are reserved, so a
later document slots in without renumbering anything already cited.
 
## validation/

One step-by-step procedure per check, for the seventeen pre-publication
checks in document 02 section 9. V01 to V17, each in two formats with the
same content: a .docx to read and print, and an .xlsx with a Pass/Fail
drop-down on every tick table. Written for someone who has never run the
check: every click, every query, how to decide pass or fail, how to record
the result, and what to do if it fails.

The subfolder has its own README with the check-to-procedure table. Results
still go in document 22; the V files are the instructions, not the record.

## Rules
- Never renumber a delivered document. Other documents cite it by number.
- The V files in validation/ are numbered by check, not by document number.
  V07 is the procedure for check 7. They are outside the gapped numbering.
- The three .html mockups are self-contained and can be published with
  GitHub Pages with no build step.
- Documents are committed with git from the local clone. Document 00
  section 8 covers the GitHub website upload as a fallback.
 
