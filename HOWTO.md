# How to use the Special Education Progress Monitoring Tool

This guide explains how to use the app, one step at a time.

## Contents

- [About the app](#about-the-app)
- [Words used in this guide](#words-used-in-this-guide)
- [Part 1: Individual Progress Monitoring](#part-1-individual-progress-monitoring)
- [Part 2: Class Screening](#part-2-class-screening)
  - [Step 1: Fill in the scores template](#step-1-fill-in-the-scores-template)
  - [Step 2: Fill in the cut-score template](#step-2-fill-in-the-cut-score-template)
  - [Step 3: Check the levels and colours](#step-3-check-the-levels-and-colours)
  - [Step 4: Choose what to look at](#step-4-choose-what-to-look-at)
  - [Step 5: Use the tabs](#step-5-use-the-tabs)
  - [Next steps: how the primary focus is worked out](#next-steps-how-the-primary-focus-is-worked-out)
- [Printing and saving](#printing-and-saving)
- [Sharing with other staff](#sharing-with-other-staff)
- [Accessibility tips](#accessibility-tips)
- [Troubleshooting](#troubleshooting)
- [Contact](#contact)

## About the app

The app has two parts. Each part is a tab at the top of the page.

1. **Individual Progress Monitoring.** Make a data sheet for one student, record teaching sessions, and see progress on a graph.
2. **Class Screening.** Upload screening scores for a class and the cut scores for your assessment. See who needs support, how students have grown, and suggested teaching groups.

**Important: the app does not save your data.** Your data is kept only in the files you download. Download your data before you close the browser tab.

## Words used in this guide

- **CSV file:** a simple spreadsheet file. Excel and Google Sheets can open it and save it. In Excel, choose "Save As" and pick "CSV (Comma delimited)".
- **Session:** one teaching or testing occasion with a student.
- **Assessment:** the screening test your school uses, for example the BC-ELST.
- **Measure** or **skill:** one part of an assessment, for example letter sounds.
- **Cut score:** the score where one level ends and the next level begins.
- **Level:** the group a score falls into, for example "At Risk" or "On Track". The level names come from your assessment.
- **On-track level:** the level that means a student is doing as expected. Students below this level are marked as needing support.
- **Time of year:** when the assessment was given. The app uses three short codes:
  - `BOY` means beginning of year.
  - `MOY` means middle of year.
  - `EOY` means end of year.
- **Template:** an empty file with the correct column headings, ready for you to fill in.

Short names for common early reading measures:

- `LNF`: Letter Naming Fluency
- `LSF`: Letter Sound Fluency
- `FSF`: First Sound Fluency
- `PSF`: Phoneme Segmentation Fluency
- `NWF`: Nonsense Word Fluency
- `WRF`: Word Reading Fluency
- `ORF`: Oral Reading Fluency

---

## Part 1: Individual Progress Monitoring

### See a demo first

Select **Try it with demo data**. The app loads a made-up student who is learning to wash hands. The demo uses the Task Analysis strategy, with 8 steps and 8 sessions.

- The **Graph** tab opens so you can try each graph type.
- The **Data** tab shows what a filled-in data sheet looks like.
- Select **Start over** when you are ready to begin your own data sheet.

### Start a new data sheet

1. Under **Choose a Strategy**, pick one of these: Task Analysis, Time Delay, Errorless Learning, Simultaneous Prompting, or Customized.
2. Fill in the boxes that appear. These are the objective, the task demand, the prompts, the latency, and the steps or items you are teaching.
3. Select **Create data sheet / Add a session**.
4. Open the **Data** tab. It shows your data sheet. The `Key` column lists the names of the boxes. The `Value` column lists what you typed.
5. Select **Download Data** to save the data sheet as a CSV file.

For least-to-most and most-to-least prompting, choose **Errorless Learning**.

### Record sessions

Each session is one new column in the data sheet. The app names the columns `Date.1`, `Date.2`, and so on.

There are two ways to add a session.

**Way 1: in a spreadsheet. This is usually easiest.**

1. Open the downloaded CSV file in Excel or Google Sheets.
2. Add one column for each session.
3. In each row, type how the student responded to that step or trial.
4. If you like, rename the column heading to the real date, for example `Mar 3`.
5. Save the file as CSV.
6. In the app, use **Open a saved data sheet (CSV)** to upload it.

**Way 2: in the app.**

1. In the step or trial boxes, replace the text with the student's responses for that session.
2. Select **Create data sheet / Add a session** again. Each time you select it, the app adds one session column.

### Marks to use for responses

- Type `+` when the student responded correctly without help. This is an independent response.
- For Time Delay, type `UC` for an unprompted correct response.
- Type any other mark when the student needed help or was not correct. Examples are `-`, `V` (verbal), `G` (gesture), `M` (model), `PP` (partial physical) and `FP` (full physical).
- Leave the cell empty if the step was not tried. Empty cells are not counted.

**Excel tip:** Excel may treat `+` as the start of a formula. To avoid this, type an apostrophe first, like this: `'+`. Or format the column as Text before you type.

### Make a graph

Open the **Graph** tab. These are the settings.

- **Graph type.** Choose one of six graphs.
  - **Bar graph**, **Line graph**, **Shaded line graph** and **Dot graph** show the percent of correct (independent) responses in each session.
  - **Number correct each session** shows how many responses were correct and how many were not.
  - **Every step, every session** shows each response for each step. Use it to find the steps where the student is stuck.
- **Goal (%).** The percent you want the student to reach. The graph shows it as a line.
- **Marks that count as correct (independent).** The default is `+, UC`. If you use different marks, type them here with a comma between them.
- **Show goal line.** Shows or hides the goal line.
- **Show the overall trend.** Adds a line that shows the general direction of progress. It needs at least three sessions.
- **Show numbers on the graph.** Writes the value above each point or bar.

The table under the graph gives the same information in numbers: the number correct, the number of steps recorded, and the percent correct for each session.

What the app counts:

- Rows such as Objective, Task Demand, the prompts and Latency are never counted.
- For Simultaneous Prompting, only the **Test Probe** trials are counted. The prompt trials are not counted.

To save your work:

- Select **Download graph (PNG)** to save the graph as a picture.
- Select **Download session summary** to save the table under the graph.

### Change the strategy

If you change the strategy after you have made a data sheet, the app asks you to confirm. This is because the data sheet will be cleared. Download your data first.

---

## Part 2: Class Screening

You need two CSV files.

- A **scores file.** This has your students' results.
- A **cut-score file.** This has the cut scores for your assessment. The app uses it to put each score in a level.

To see how this part works before you use your own data, select **4-level example** or **3-level example**. The demo students and the demo cut scores are made up.

### Step 1: Fill in the scores template

1. Select **Download a blank scores template**.
2. Open the file in Excel or Google Sheets.
3. Delete the example rows.
4. Type your data. Use **one row for each student for each time of year**.
5. Save the file as CSV.
6. In the app, upload it under **1. Scores**.

Here is an example. It has two students. Student A has two rows because Student A was assessed at the beginning and the middle of the year.

| Student | Grade | Class | Period | LNF | PSF | NWF | WRF | ORF |
|---|---|---|---|---|---|---|---|---|
| Student A | 1 | Div 3 | BOY | 38 | 22 | 18 | 4 | (empty) |
| Student A | 1 | Div 3 | MOY | 47 | 35 | 40 | 12 | 14 |
| Student B | 1 | Div 3 | BOY | 52 | 41 | 45 | 15 | (empty) |

Rules for each column:

- **Student** is required. You can use initials or student numbers instead of names.
- **Period** is required. Type `BOY`, `MOY` or `EOY`. The app also understands Fall, Winter and Spring, and Beginning, Middle and End.
- **Grade** is `K` or a number. You need it if your cut scores are different for each grade.
- **Class** is optional. You can also name this column Teacher or Division. It lets you look at one class at a time.
- **Measure columns** come after that. Use one column for each measure. Rename, add or delete these columns to match your assessment. For the BC-ELST, the columns are `LNF`, `LSF`, `FSF`, `PSF`, `NWF`, `WRF` and `ORF`.
- Leave a cell empty if the student was not assessed on that measure.

**To follow growth during the year, keep one file.** Add new rows to the same file for the middle of the year, and again for the end of the year. Do not start a new file each time.

### Step 2: Fill in the cut-score template

#### Choose a template

1. Under **Template to start from**, choose one of these.
   - **Blank (any assessment).** It has two example rows for you to replace.
   - **BC-ELST (British Columbia).** It has rows for Kindergarten to Grade 3 and for the measures `LNF`, `LSF`, `FSF`, `PSF`, `NWF`, `WRF` and `ORF`. This template is only for the BC-ELST, the measure used in British Columbia. If you use a different measure, start from the blank template.
2. Select **Download this cut-score template**.

The cut-score cells are empty on purpose. **Copy the numbers from the official document for your assessment.** The publisher or your ministry of education provides this document.

#### How the file is set out

The first columns are `Grade`, `Period` and `Measure`. After them, there is **one column for each level**.

- Put the levels in order, from the **lowest** level to the **highest** level.
- The **column heading** is the name of the level. The app shows it exactly as you type it.
- Each **cell** is the **lowest score** that gets that level.
- The lowest level usually starts at `0`.

**Example with four levels.** The numbers are examples only. They are not official cut scores.

| Grade | Period | Measure | Well Below | Below | At Level | Above |
|---|---|---|---|---|---|---|
| 1 | BOY | PSF | 0 | 20 | 30 | 45 |

This row means:

- A score from 0 to 19 is "Well Below".
- A score from 20 to 29 is "Below".
- A score from 30 to 44 is "At Level".
- A score of 45 or more is "Above".

**Example with three levels.** The numbers are examples only.

| Grade | Period | Measure | At Risk | Some Risk | On Track |
|---|---|---|---|---|---|
| K | MOY | LSF | 0 | 12 | 20 |

This row means:

- A score from 0 to 11 is "At Risk".
- A score from 12 to 19 is "Some Risk".
- A score of 20 or more is "On Track".

#### Change the template to fit your assessment

- **Rename the level columns.** Use the level names from your assessment.
- **Add or delete level columns.** You need one column for each level, and at least two levels. Keep them in order, lowest first.
- **Delete rows you do not need.** You can also leave them. The app ignores rows that you have not filled in.
- **Leave a cell empty** if a measure does not have that level.
- **Delete the `Period` column** if the cut scores are the same all year.
- **Delete the `Grade` column** if the cut scores are the same for every grade.
- **Use the same measure names in both files.** Capital letters, spaces and hyphens do not matter. For example, `Letter Sounds` matches `letter-sounds`. But a short name does not match a long name. For example, `LSF` does not match `Letter Sounds`.

#### If your official table shows score ranges

Some official tables show a range for each level, for example "Some Risk: 12 to 19". Type the **lowest** number of each range. In this example, type `12` in the "Some Risk" column.

#### Upload the file

1. Save the file as CSV.
2. In the app, upload it under **2. Cut scores**.

You can keep one cut-score file for each assessment and use it again every year. For example, you might have `bc-elst-cuts.csv` and `district-screener-cuts.csv`. To change to another assessment, upload the other file.

### Step 3: Check the levels and colours

After you upload both files, the app lists your levels above the tabs, in order from lowest to highest. Each level name has a colour behind it.

- Levels below the on-track level are red, orange or yellow.
- The on-track level is green.
- Levels above the on-track level are blue.
- "No level" is grey. It means the app could not find a cut score for that score.

**Check the on-track level.** The app guesses which level means "on track" from the level name. Look at the **On-track level** box in the side panel. If the guess is wrong, choose the correct level.

**Check for messages.** If some scores have no matching cut score, a yellow message appears above the tabs. It names the measures that have the problem. The usual reasons are:

- The measure name is different in the two files.
- The cut-score file has no row for that grade or that time of year.
- The scores file has no Grade column.

### Step 4: Choose what to look at

Use the boxes in the side panel, under **3. View**.

- **Time of year.** Choose beginning, middle or end of year.
- **Class / teacher.** Choose one or more classes. Leave it empty to include all classes.
- **Grade.** Choose one or more grades. Leave it empty to include all grades.
- **Students.** Choose one or more students. Leave it empty to include everyone.

**How to pick students:**

1. Select the **Students** box and choose a name. The app now shows only that student.
2. Choose more names to make a group.
3. To remove a student, select the small "x" button beside the name. With a keyboard, move to the name and press Backspace.
4. **Select all** puts every student in the box. This is useful when you want everyone except a few. Then remove the few you do not want.
5. **Clear (show everyone)** empties the box.

Every table, graph, download and printout shows only what you have chosen.

### Step 5: Use the tabs

- **Class overview.** Shows the whole class. There is one row for each student and one column for each measure. Each cell shows the score, and its colour shows the level. Select a column heading to sort by that column. For example, sort by **Skills needing support** to bring the students who need the most support to the top. A summary table above it counts the students at each level.
- **Who needs support?** Lists students at the levels you choose, on the measures you choose. For example, list every student who is "At Risk" or "Some Risk" on `PSF`. This table gives each level in words.
- **Growth.** Compares two times of year on one measure. For each student, it shows the change in score and whether the student moved up a level, moved down a level, or stayed at the same level.
- **Graphs.** Offers seven graphs. They are described in the next list.
- **Next steps.** Shows the primary focus for each student and suggests teaching groups. The next section explains how this works.

The seven graphs:

- **How many students are at each level.** For the chosen time of year, a bar for each measure shows the number of students at each level.
- **Whole-class colour chart.** A grid of every student's score on every measure. The colour of each cell shows the level. Students who need the most support are at the top.
- **Class levels across the year.** The number of students at each level at the beginning, middle and end of the year, with one small graph for each measure.
- **Each student's growth.** One line for each student across the year, for one measure. A dashed line marks the lowest on-track score.
- **Spread of class scores.** Shows how spread out the scores are at each time of year, for one measure. Each point is one student.
- **First score vs. latest score.** For one measure, an arrow for each student runs from the first score to the latest score.
- **One student's report.** One student's scores on every measure across the year. This is useful for meetings with parents or the school-based team.

On the graphs, each level has its own colour and its own marker shape. The legend under the graph names each level.

### Next steps: how the primary focus is worked out

The **Next steps** tab gives each student one **primary focus**. Students with the same primary focus and the same level are listed together as a suggested group.

The app works out the primary focus in five steps.

1. **It uses one time of year.** It uses only the time of year, class, grade and students you have chosen.
2. **It finds the skills that need support.** A skill needs support when the student is below the on-track level on that skill.
3. **It puts those skills in teaching order.** The teaching order goes from the most basic skill to the most advanced skill. The **Next steps** tab shows the order in use. The built-in order is:
   1. Letter names (`LNF`)
   2. Letter sounds (`LSF`)
   3. First sounds (`FSF`)
   4. Phonemic awareness (`PSF`)
   5. Letter-sound correspondence and decoding (`NWF`)
   6. Word reading (`WRF`)
   7. Reading accuracy
   8. Reading fluency (`ORF`)
   9. Reading comprehension
4. **It takes the first skill.** The primary focus is the **earliest** skill in the teaching order that needs support. It is not the skill with the lowest score.
5. **It makes the groups.** "Level on that skill" is the student's level on the primary-focus skill. Students with the same primary focus and the same level form one group.

**Example.** A student is "Some Risk" in phonemic awareness and "At Risk" in reading fluency. Phonemic awareness comes earlier in the teaching order. So the primary focus is phonemic awareness, even though the level in reading fluency is lower. Both skills still appear in the column named "All skills below on-track".

**Special cases:**

- A student who is on track on every skill shows "None flagged".
- A student whose scores could not be given a level shows "Unknown".
- A skill that is not in the teaching order keeps its own name. It is chosen only when no listed skill needs support.

**To change the teaching order:**

1. On the **Next steps** tab, select **Download the current teaching order to edit**.
2. Open the file. It has two columns.
   - `Measure` must match the measure name in your files.
   - `Skill` is the name the app shows.
3. Put the rows in teaching order, with the most basic skill first. Add a row for any measure that is not listed.
4. Save the file as CSV.
5. Upload it under **Use your own teaching order**.

**Please note.** The app shows where to look first. It does not tell you what to teach. The groups are a starting point for a conversation between the classroom teacher and the resource teacher. They do not replace other assessment or your professional judgement.

---

## Printing and saving

**To print what is on the screen, or save it as a PDF:**

1. Select **Print this page**. The button is at the top of the page, on the right.
2. The print window opens. The menus and buttons are left off the printout.
3. To keep a PDF, choose "Save as PDF" as the printer.

**To save or print one table:** use the three buttons above the table.

- **Copy** copies the table, so you can paste it into an email or a document.
- **Excel** saves the table as a spreadsheet.
- **Print** prints only that table.

**To save a table as a CSV file:** select the **Download** button or link under the table. The CSV file includes the level names in words.

**To save a graph as a picture:** select **Download graph (PNG)** under the graph. You can put the picture in a report or a slide.

**Long tables.** A long table shows 50 rows at a time. To print or save every row, first change **Show entries** to **All**.

Downloads and printouts use your current choices for time of year, class, grade and students.

---

## Sharing with other staff

The app has no accounts and does not store data. Anyone who has the scores file and the cut-score file can upload them and see the same information. This includes resource teachers and administrators.

Share the files in the way your school district allows for documents that contain student information.

---

## Accessibility tips

- **Colour is not the only signal.** Level names are written in words in the **Who needs support?**, **Growth** and **Next steps** tables, in the summary table, and in every CSV download. On the graphs, each level also has its own marker shape and is named in the legend.
- **If colours are hard to tell apart,** use the **Who needs support?** table or download the class overview as a CSV file. The **Class overview** table on the screen and the **Whole-class colour chart** show levels by colour only.
- **To make text larger,** use your browser's zoom. Press `Ctrl` and `+` on Windows, or `Command` and `+` on a Mac.
- **For a screen reader,** the tables are the best way to get the information in the graphs. Each graph has a matching table on another tab, and every table can be downloaded.
- **For printing in black and white,** print the tables instead of the colour graphs, or download the CSV files, which name each level.

If part of the app is hard to use, please get in touch. See [Contact](#contact).

---

## Troubleshooting

**Message: "The scores file needs a 'Student' column" or "a 'Period' column".**
The first row of the file must contain the column headings. Check that the headings are there and spelled correctly.

**Message: "The cut-score file needs at least two level columns containing numbers", or "No rows in the cut-score file have cut scores filled in yet".**
The level columns are still empty, or only the lowest level has numbers. Type the cut scores for each level.

**Every score is grey, or the message says "No levels yet".**
No cut-score file is loaded, or the measure names in the two files do not match.

**Some measures are grey.**
The cut-score file has no row for that measure, grade or time of year, or the measure name is different. The yellow message names the measures.

**The colours look the wrong way round for one measure.**
The app expects a higher score to be better. It does not support measures where a lower score is better, such as a count of errors.

**A student appears twice.**
The name is typed in two different ways, for example with an extra space or a different spelling. Make the name the same in every row.

**The wrong level is used as the on-track level.**
Choose the correct level in the **On-track level** box in the side panel.

**The file will not upload.**
Save the file as CSV. An Excel workbook (a file ending in `.xlsx`) will not work.

---

## Contact

- Email: [seulbi.lee@uwaterloo.ca](mailto:seulbi.lee@uwaterloo.ca)
- GitHub: [seul-b](https://github.com/seul-b)
- Report a problem: [open an issue on GitHub](https://github.com/seul-b/special-education-progress-monitoring/issues)
