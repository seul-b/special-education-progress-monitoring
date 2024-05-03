---
title: 'Special Education Progress Monitoring (SEPM): A Shiny app for data collection in special education classroom'
tags:
  - R
  - shinyapp
  - education
  - special education
authors:
  - name: Seulbi Lee
    orcid: 0000-0001-8290-8087
    equal-contrib: true
    affiliation: 1
affiliations:
 - name: University of Oregon, USA
   index: 1
date: 3 May 2024
bibliography: paper.bib

---

# Summary
"Special Education Progress Monitoring" (SEPM) is a Shiny app intended to support special education professionals with interactive data collection and graphing functions. Special education professionals, including teachers, paraprofessionals, and related service providers, will be able to input details and corresponding data for each step for a student to complete through systematic instructional strategies. Available strategies include task analysis, time delay, least-to-most and most-to-least prompt hierarchies, and simultaneous prompting, as well as their customized instruction or assessment data. 

# Overview
The "Special Education Progress Monitoring" (SEPM) app is designed specifically for special education professionals, providing a user-friendly platform to track and analyze student progress efficiently. Built on the Shiny framework, this app offers interactive features tailored to the needs of teachers, paraprofessionals, and related service providers in the field of special education.

SEPM aims to streamline the process of data collection and analysis, focusing on evidence-based teaching practices and effective data management. By incorporating systematic instructional strategies, the app empowers educators to create tailored instructional plans for students while facilitating progress monitoring and data-driven decision-making.

# Information for Users
Step 1: Access the main page and locate the hyperlink titled "Systematic Instructional Procedures Guide". This link provides comprehensive information including definitions, descriptions, and examples of the instructional strategies along with resources for special education professionals based on @Brown:2016.

Step 2: Below the hyperlink, users can either upload a properly formatted .csv file or select an instructional strategy to begin a new datasheet. Available instructional strategies include task analysis, time delay, least-to-most or most-to-least prompt hierarchies, simultaneous prompting, or a customized assessment template.

Step 3: Upon selecting a strategy, the app will present text fields or drop-down menus for inputting objectives, task demands, prompts determined, latency, steps or items, and delay schedules. Users can fill in these details to create a list of instructional plans for a student.

Step 4: Once the instructional plans are created, users can click on the 'Generate Template' button to generate a datasheet. This datasheet will display key components and values, indicating the strategies chosen by professionals and student data starting from the third column (Figure 1).

Step 5: Users have the option to download the resulting datasheet onto their local device by clicking the 'Download Data' button located at the top of the page. Additionally, the app automatically generates a graph based on the number of '+' (correct/independent responses) from the datasheet.

Step 6: For progress monitoring, the app counts only '+' and 'CA' (Correct Anticipated) for time delay [@Hughes:2002] , generating a graph to track progress. It's important for users to note that the app may not generate baseline data properly when included in the datasheet.


# Figures

Figures can be included like this:
![Caption for example figure.\label{fig:example}](figure.png)
and referenced from text using \autoref{fig:example}.

Figure sizes can be customized by adding an optional second parameter:
![Caption for example figure.](figure.png){ width=20% }

# Acknowledgements


# References

