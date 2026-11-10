# Special Education Progress Monitoring Tool

A free web app for teachers and other special education professionals. It helps you collect data on a student's learning, see the data as graphs, and plan what to teach next.

**Open the app:** [Special Education Progress Monitoring Tool on shinyapps.io](https://seul-b.shinyapps.io/special-education-progress-monitoring/)

You do not need to install anything or create an account.

## What the app does

The app has two parts.

1. **Individual Progress Monitoring.** Make a data sheet for one student. Record how the student responds in each teaching session. See progress toward a goal on a graph. The data sheets support task analysis, time delay, errorless learning (least-to-most and most-to-least prompting), simultaneous prompting, and a custom sheet of your own.
2. **Class Screening.** Upload screening scores for a class from any assessment, together with the cut scores for that assessment. See which students need support, how students have grown during the year, and suggested teaching groups.

## Guides

- [How to use the app (HOWTO.md)](HOWTO.md): step-by-step instructions for both parts, including how to fill in the templates and enter cut scores.
- [Systematic Instructional Procedures Guide (Google Doc)](https://docs.google.com/document/d/1EyBuzxEux3LoUZa1_0awVCVPttpzxEzZapCnFGKjIVA/edit?usp=sharing): background on each teaching strategy, with example data sheets.

## Before you start

Please read these four points.

1. **Your data is not saved in the app.** Download your data before you close the browser tab. You can upload the file again later to continue.
2. **Keep the same strategy.** When you upload a saved data sheet, choose the same teaching strategy that the sheet was made with.
3. **Keep the layout of the data sheet.** Do not delete or rename the `Key` and `Value` columns or the rows. Add one column for each session. You may rename a session column to the real date.
4. **Use made-up names if you prefer.** Initials or student numbers work as well as full names. Follow your school district's rules for files that contain student information.

## Try it with demo data

Each part of the app has a demo button, so you can explore before you enter real data.

- In **Individual Progress Monitoring**, select **Try it with demo data**.
- In **Class Screening**, select **4-level example** or **3-level example**.

All demo students and demo cut scores are made up.

## Accessibility

- All levels are named in words as well as shown in colour. The **Who needs support?** table and every CSV download include the level name, so colour is never the only way to get the information.
- Every table can be copied, saved as a spreadsheet, or printed. Every graph can be saved as a picture.
- The **Print this page** button makes a clean printout without menus. You can also save it as a PDF.
- The app works with browser zoom. Use `Ctrl` and `+` (Windows) or `Command` and `+` (Mac) to make everything larger.
- The app is in English.

If something in the app is hard to use with your assistive technology, please [email Seulbi Lee](mailto:seulbi.lee@uwaterloo.ca). Your feedback helps improve the app.

## Run the app on your own computer

This section is for people who use R. Teachers using the web app can skip it.

1. Install [R](https://cran.r-project.org/).
2. In R, install the packages the app needs:

   ```r
   install.packages(c("shiny", "shinythemes", "dplyr", "tidyr", "tibble", "ggplot2", "DT"))
   ```

3. Download this repository, then run:

   ```r
   shiny::runApp("path/to/special-education-progress-monitoring")
   ```

### Files in this repository

- `ui.R`: the layout of the app (what you see).
- `server.R`: the logic of the app (what happens when you select something).
- `global.R`: shared settings, templates, demo data and contact details.
- `HOWTO.md`: the user guide.

## Contact

- Email: [seulbi.lee@uwaterloo.ca](mailto:seulbi.lee@uwaterloo.ca)
- GitHub: [seul-b](https://github.com/seul-b)
- Report a problem: [open an issue on GitHub](https://github.com/seul-b/special-education-progress-monitoring/issues)
