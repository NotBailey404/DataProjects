COVID-19 Year One Analysis

Overview
This project analyzes the first year of the COVID-19 pandemic using publicly available datasets on cases, deaths, and vaccinations. The goal is to explore infection rates, mortality, and vaccination progress globally and by continent, with a focus on clear, actionable insights.

The data is stored in an MSSQL Server database, and the analysis is done primarily through SQL queries, including some advanced techniques like Common Table Expressions (CTEs) and window functions. I also created a Tableau dashboard to visualize key findings.

What’s in this repo
- SQL scripts to load, clean, and analyze COVID-19 data
- Views and queries that summarize infection rates, death counts, and vaccination progress
- A folder with the Tableau dashboard files (for interactive visualization)
- This README with project context and instructions

Why this project matters
Understanding the early pandemic trends helps us learn how COVID-19 spread and how vaccination efforts unfolded worldwide. This analysis can inform public health strategies and future responses.

Key technical highlights
- Use of CTEs for stepwise, readable query building
- Window functions to calculate rolling vaccination counts without collapsing data rows
- Joining multiple datasets (cases and vaccinations) for comprehensive analysis
- Creating reusable views to simplify repeated queries

What I learned
- How to work with large real-world datasets in SQL Server
- Writing efficient, readable queries using advanced SQL techniques
- The importance of organizing code for clarity and maintainability
- Visualizing data for better insights using Tableau

How to use this project
1. Load the SQL scripts into your MSSQL Server instance.
2. Run the provided queries or views to generate analysis results.
3. Open the Tableau dashboard files to explore the visualizations.
4. Feel free to modify or extend the analysis as needed!

Notes
- This project only covers the first year of the pandemic.
- Some data cleaning steps are omitted for simplicity.
- Queries are optimized for readability and learning, not always for performance.