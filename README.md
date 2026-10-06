# Loan Default Risk Analysis Project Report

[![Data Source: Analyst Builder](https://shields.io)](https://analystbuilder.com)
[![Tools: SQL | Excel | Power BI](https://shields.io)](#tools-used)

An end-to-end data analytics project that cleans, structures, and visualizes financial loan metrics to uncover the key drivers behind **loan defaults**. The analysis transitions from raw data processing using **SQL** and **Excel** to advanced data modeling and interactive visualization in **Power BI**.

---

## Table of Contents
- [Project Overview & Key Metrics](#-project-overview--key-metrics)
- [Tools Used](#tools-used)
- [Data Pipeline & Workflow](#data-pipeline--workflow)
  - [Phase 1: Data Cleaning & SQL Querying](#phase-1-data-cleaning--sql-querying)
  - [Phase 2: Excel Prototyping](#phase-2-excel-prototyping)
  - [Phase 3: Power BI Data Modeling & Visualization](#phase-3-power-bi-data-modeling--visualizations)
- [Project Architecture & Repositories](#project-architecture--repositories)
- [Key Insights & Statistical Findings](#-key-insights--statistical-findings)
- [Executive Risk Mitigations & Recommendations](#executive-risk-mitigations--recommendations)

---

## Project Overview & Key Metrics

This project identifies high-risk loan profiles by evaluating critical borrower parameters such as credit score tiers, Debt-to-Income (DTI) ratios, interest rates, and existing monthly obligations. 

### Core KPIs Discovered:
* **Total Loan Count:** 601
* **Loans Defaulted:** 146
* **Overall Default Rate:** 24.29%
* **Total Loan Amount:** \$13.31M
* **Total Loan Amount in Default:** \$3.30M

---

## Tools Used
* **SQL (MySQL):** Database hosting, advanced statistical filtering, variables correlation logic, data conditional bucketing.
* **Microsoft Excel:** Initial data scrubbing, structure verification, and query extraction testing.
* **Power BI Desktop:** DAX engineering, custom data modeling, dashboard deployment, and interactive slicing.

---

## Data Pipeline & Workflow

### Phase 1: Data Cleaning & SQL Querying
1. Raw dataset obtained from the **[Analyst Builder Projects Section](https://analystbuilder.com)**.
2. Cleaned and formatted missing schema fields inside **MySQL**.
3. Formulated precise custom SQL scripts to logically bucket features (e.g., Credit Score Tiers, DTI Ranges, Interest Rates).
4. Constructed a dedicated relational query mapping out **Correlation Coefficients** across financial variables to see what triggers defaults, exposing a distinct profile pattern:
   * **Positive correlation** targets: `interest_rate` (+0.20) and `dti_ratio` (+0.19).
   * **Negative correlation** target: `credit_score` (-0.29).

### Phase 2: Excel Prototyping
1. Connected the localized MySQL database server queries directly into Microsoft Excel.
2. Formed standalone quick-view reporting charts using the initial bucketing scripts to establish an analytical baseline.

#### Excel Dashboard Mockup
![Excel Dashboard Visualizations](https://github.com)
*Figure 1: Initial analysis charts detailing Employment Status, Correlation Analysis, Loan Purpose, DTI Ratio, Credit Score pie charts, and Interest Rate distributions.*

### Phase 3: Power BI Data Modeling & Visualizations
1. Raw source tables were imported into **Power BI Desktop** directly from the underlying MySQL database.
2. Created operational Business Performance Metrics utilizing custom **DAX Measures**:
   ```dax
   Default Rate = DIVIDE([Loans Defaulted], [Total Loan Count], 0)
   ```
   ```dax
   Total Loan Amount in Default = CALCULATE(SUM(Loans[loan_amount]), Loans[loan_status] == "Default")
   ```
3. Formed custom **Calculated Columns** via DAX expressions to securely stratify numeric data intervals:
   * `Credit Score Tiers`
   * `Existing Monthly Debt Ranges`
   * `Interest Rate Ranges`
   * `DTI Ranges`
4. Generated conditional indexing sort-order map columns for each bucketing array to ensure the charts maintain an ordered sequence rather than sorting alphabetically.
5. Rendered a fully interactive analytical UI built with dynamic slicers filtering by **Credit Score Tiers** and **Credit Term Lengths**.

#### Power BI Dashboard Mockup
![Power BI Interactive Dashboard](https://github.com/deepika-analyst/loan_default_risk_analysis/blob/main/Screenshot%20(322).png)
*Figure 2: Final Power BI UI design displaying executive KPIs, Correlation charts, DTI vs. Default Rate scatters, and multi-tier filters.*

---

## Project Architecture & Repositories

```text
├── sql_queries/
│   ├── data_cleaning.sql        # Database initialization & field updates
│   ├── bucket_segmentation.sql  # SQL scripts for data bucketing
│   └── correlation_analysis.sql # Advanced query extracting mathematical variables relationship
├── excel/
│   └── Correlation Analysis.xlsx # Initial SQL queried charts workbook (971e485 SHA Commit)
├── power_bi/
│   └── Loan_Default_Risk_Analysis.pbix            # Complete Power BI workspace file
└── README.md
```
* Access the direct source workbook commit files here: **[GitHub Commit Workspace Directory](https://github.com)**

---

## 📈 Key Insights & Statistical Findings

* **The Credit Score Impact:** Borrowers with credit scores **below 580** exhibit the highest density of default records, showing a powerful negative correlation factor of **-0.29**.
* **Interest Rate Leverage:** Loan risk profiles increase proportionally with higher interest rates. The default concentration maximizes decisively within the **14-15% and above** range brackets.
* **DTI Ratio Strain:** A clear positive trend exists between high Debt-to-Income indicators and default rates, heavily intensifying once a borrower's DTI ratio crosses past the **60-79% tier limit**.

---

## Executive Risk Mitigations & Recommendations

Based on the statistical correlations and empirical visual findings within the active dashboards, the following structural adjustments are recommended for the credit underwriting team to lower the 24.29% portfolio default rate:

1. **Implement Automated Credit Threshold Caps:** 
   Establish an automatic risk-flagging policy inside the underwriting engine for any loan application showing a credit score **below 580**. Applicants in this bracket account for a disproportionately high chunk of total defaulted funds.
2. **Cap Debt-to-Income (DTI) Allowances:** 
   Strictly restrict loan approval or require mandatory secondary collateral evaluations once an applicant's DTI ratio crosses the **60% boundary marker**, as this segment shows exponential default acceleration.
3. **Restructure High Interest Rate Underwriting Strategy:** 
   Review pricing structures for high-interest offerings. Because the default concentration maximizes within the **14-15% and above range**, these higher yields are currently offset by massive capital losses (\$3.30M total default capital). High-interest pricing guidelines should incorporate tighter down-payment requirements.

