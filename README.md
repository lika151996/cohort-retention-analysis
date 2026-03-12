# cohort-retention-analysis
Cohort retention analysis comparing Organic and Promo acquisition channels using SQL and Google Sheets.

Project Overview

This project analyzes user retention across two acquisition channels: Organic and Promo.
The goal of the analysis was to evaluate the quality of users acquired through different channels and understand which channel delivers more stable long-term engagement.

The analysis focuses on user retention during the first 6 months after registration.

Business Problem

1. The objective of this analysis was to evaluate the quality of users acquired through different acquisition channels and measure their retention over time.

The key business question was:

1. Which acquisition channel delivers more stable long-term user engagement?

2. Understanding this helps companies decide where to allocate marketing resources and which acquisition strategies generate more valuable users.

Dataset

The dataset contained:

1. Users table:

- user_id

- registration_date

- acquisition_channel

2.Events table:

- user_id

- event_date

- activity events

These tables were used to measure user activity and retention over time.

Tools Used:

- PostgreSQL

- CTE (Common Table Expressions)

- JOIN operations

- Date transformations

- Cohort analysis logic

- Google Sheets

- Pivot Tables

- Conditional Formatting

- Slicers

- Data Visualization (charts)

- Analytical Approach

The analysis was conducted in several steps:

1. Data Cleaning

2. Standardized date formats using SQL.

3. Data Preparation

4. Joined user and event tables using appropriate JOIN logic.

5. Calculated the cohort_month based on user registration date.

6. Cohort Calculation

7. Calculated month_offset (number of months since registration).

8. Built a cohort retention table showing active users per cohort and month.

9. Retention Calculation

10. Calculated Retention Rate (%) relative to cohort size

11. Month 0 = 100% baseline.

12. Data Visualization

13. Exported results to Google Sheets.

14. Built Pivot Tables to analyze retention by cohort and acquisition channel.

15. Created charts and retention curves.

Key Insights

The analysis revealed several important patterns:

• Organic users demonstrate higher and more stable retention over time compared to Promo users.

• Promo users experience a significant drop in retention after months 2–3.

• After 5 months:

Organic retention remains around 56%

Promo retention drops to approximately 9%

• Organic acquisition appears to generate higher-quality long-term engagement.

Business Interpretation

The analysis suggests that while Promo campaigns may generate short-term spikes in user acquisition, Organic traffic provides more sustainable long-term engagement.

However, evaluating acquisition channels purely based on retention is not sufficient for strategic decisions.

A complete evaluation would require additional financial metrics such as: Customer Acquisition Cost (CAC),  Lifetime Value (LTV), Return on Investment (ROI), These metrics were not available in the dataset.



