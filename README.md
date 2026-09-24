# Insurance Analytics — Claims, Fraud & Customer Intelligence

An end-to-end **Insurance Analytics project** focused on analyzing customers, policies, claims, agents, complaints, fraud risk, renewals, and business performance.

The project follows a complete analytics workflow:

**CSV → Excel / Power Query → MySQL → SQL → Power BI → Business Insights → Recommendations**

> **Data Disclaimer:** The transaction-level dataset used in this project is synthetic and should not be considered confidential company data.

---

## 📌 Project Overview

Insurance companies generate large volumes of data across customers, policies, claims, agents, and complaints.

This project analyzes that data to answer important business questions such as:

* Which products generate the highest premium?
* Which products have the highest claim ratio?
* Which states have higher claim volumes?
* Which claims have high fraud-risk scores?
* Which customers are at renewal risk?
* Which agents have high premium but low renewal?
* Which providers have high claim amounts or settlement TAT?
* How are premium and claims changing month-over-month?
* Where are potential customer retention and cross-sell opportunities?

---

## 🎯 Project Objectives

* Understand and profile insurance datasets
* Clean and validate raw data
* Build a relational SQL database
* Perform business analysis using SQL
* Calculate important insurance KPIs
* Build an interactive Power BI dashboard
* Identify fraud and risk patterns
* Analyze customer retention and renewal
* Generate evidence-based business insights
* Provide actionable recommendations

---

## 🗂️ Dataset

The project works with datasets covering:

* Customers
* Policies
* Claims
* Agents
* Complaints
* Combined claims analytics

### Key Data Areas

| Area       | Examples                                        |
| ---------- | ----------------------------------------------- |
| Customer   | Customer ID, demographic information            |
| Policy     | Policy ID, product, premium, renewal status     |
| Claims     | Claim ID, claim amount, status, settlement date |
| Agents     | Agent performance and policy relationships      |
| Complaints | Complaint category, channel, resolution         |
| Fraud      | Fraud score and risk indicators                 |

---

# 🔄 Project Workflow

## Phase 1 — Data Understanding

**Tools:** Excel / CSV

* Import and inspect raw CSV files
* Record row counts and columns
* Identify IDs, dates, amounts and categories
* Understand relationships between tables
* Create a Data Dictionary

Raw CSV files are preserved separately and are never overwritten.

---

## Phase 2 — Data Cleaning

**Tools:** Excel / Power Query

Data cleaning includes:

* Correcting data types
* Removing duplicate rows and IDs
* Trimming text values
* Checking missing/null values
* Validating dates
* Validating customer, policy and agent relationships
* Validating age ranges
* Validating fraud scores
* Checking non-negative monetary values

A **Cleaning Log** is maintained with:

`Issue → Action → Rows Affected`

---

## Phase 3 — SQL Database

**Tool:** MySQL Workbench

Database:

```sql
insurance_analytics
```

Cleaned datasets are imported into MySQL and validated using queries such as:

```sql
SELECT COUNT(*) FROM customers;

SELECT *
FROM customers
LIMIT 10;
```

SQL analysis uses:

* `SELECT`
* `WHERE`
* `GROUP BY`
* `ORDER BY`
* `JOIN`
* `CASE`
* `COUNT`
* `SUM`
* `AVG`
* `DATEDIFF`
* Window Functions

---

## Phase 4 — Business Questions

Business questions are defined before creating visualizations.

### Claims

* Which claims have high amounts?
* Which claims have high TAT?
* Which claims are pending?
* Which providers have high claim amounts?

### Fraud

* Which claims have high fraud scores?
* Which providers or locations show unusual patterns?

### Customer Retention

* Which customers did not renew?
* Which products have lower renewal rates?
* Which channels have lower renewal?

### Agents

* Which agents generate high premium?
* Which agents have high premium but low renewal?
* How do complaints relate to agent performance?

### Products & Geography

* Which products generate the highest premium?
* Which states have the highest claim ratio?
* Which products have persistent high claim ratios?

---

# 📊 Phase 5 — KPI Analysis

Important KPIs include:

### Total Premium

```text
Total Premium = SUM(Premium)
```

### Total Claims

```text
Total Claims = SUM(Claim_Amount)
```

### Claim Ratio

```text
Claim Ratio =
Claim Amount ÷ Premium × 100
```

The business denominator should be documented before using the metric.

### Average Claim TAT

```text
Average Claim TAT =
Average(Settlement Date − Claim Date)
```

Calculated for valid settled claims.

### Renewal Rate

```text
Renewal Rate =
Renewed Policies ÷ Eligible Expiring Policies × 100
```

KPIs are segmented by:

* Month
* Product
* State
* Channel
* Customer Segment

---

# 📈 Phase 6 — Power BI Dashboard

**Tool:** Microsoft Power BI

### Data Model

The Power BI model connects:

```text
Customers
    ↓
Policies
    ↓
Claims

Agents
    ↓
Policies

Customers
    ↓
Complaints
```

A Date table is also added for time-based analysis.

### Dashboard Pages

The project contains **7 dashboard pages**:

1. Executive Dashboard
2. Claims Analysis
3. Fraud & Risk
4. Customer Analysis
5. Agent Performance
6. Product & Geography
7. Recommendations

---

# 🧮 DAX Measures

Example measures used in Power BI:

```DAX
[Total Premium] =
SUM(Policies[Premium])
```

```DAX
[Total Claims] =
SUM(Claims[Claim_Amount])
```

```DAX
[Approved Claims] =
SUM(Claims[Approved_Amount])
```

```DAX
[Total Policies] =
DISTINCTCOUNT(Policies[Policy_ID])
```

```DAX
[Total Customers] =
DISTINCTCOUNT(Customers[Customer_ID])
```

```DAX
[Total Claims Count] =
DISTINCTCOUNT(Claims[Claim_ID])
```

```DAX
[Renewed Policies] =
CALCULATE(
    [Total Policies],
    Policies[Renewal_Status] = "Renewed"
)
```

```DAX
[Renewal Rate] =
DIVIDE(
    [Renewed Policies],
    [Total Policies]
)
```

---

# 🔍 Phase 7 — Business Insights

Insights follow the structure:

```text
Finding → Evidence → Business Meaning
```

Only actual numbers from the final dataset/dashboard should be used.

The project avoids claiming causation where the analysis only demonstrates an association or pattern.

---

# 💡 Phase 8 — Recommendations

Potential recommendation areas include:

### Claims

Monitor high-TAT branches/providers and ageing claims.

### Fraud

Prioritize high-risk claims for investigation.

> A fraud score is a risk indicator, not proof of fraud.

### Customer Retention

Target high-value customers before policy renewal.

### Agent Performance

Evaluate agents using:

* Premium
* Renewal
* Complaints

rather than sales alone.

### Products

Review products showing persistent high claim ratios.

Each recommendation should have:

```text
Owner → KPI → Review Frequency
```

---

# 📝 Phase 9 — Project Report

The final report structure:

1. Title
2. Executive Summary
3. Business Context
4. Problem Statement
5. Objectives
6. Dataset
7. Data Cleaning
8. SQL Analysis
9. Power BI Dashboard
10. Insights
11. Recommendations
12. Limitations
13. Future Scope
14. Conclusion

Screenshots should include:

* Raw data
* Data cleaning
* SQL queries/results
* Data model
* Power BI dashboards

---

# 🎤 Phase 10 — Interview Preparation

The project can be explained in approximately **60–90 seconds** using:

```text
Problem
   ↓
Data
   ↓
Cleaning
   ↓
SQL
   ↓
Power BI
   ↓
Findings
   ↓
Recommendations
```

The interview explanation should use actual final dashboard numbers rather than memorized or fabricated results.

---

# 🗃️ Suggested Repository Structure

```text
insurance-analytics/
│
├── README.md
│
├── 01_Raw_Data/
│   ├── customers.csv
│   ├── policies.csv
│   ├── claims.csv
│   ├── agents.csv
│   └── complaints.csv
│
├── 02_Cleaned_Data/
│   ├── customers_cleaned.csv
│   ├── policies_cleaned.csv
│   ├── claims_cleaned.csv
│   ├── agents_cleaned.csv
│   └── complaints_cleaned.csv
│
├── 03_Data_Dictionary/
│   └── data_dictionary.xlsx
│
├── 04_Cleaning/
│   └── cleaning_log.xlsx
│
├── 05_SQL/
│   ├── 01_database_setup.sql
│   ├── 02_basic_analysis.sql
│   ├── 03_intermediate_analysis.sql
│   └── 04_advanced_analysis.sql
│
├── 06_Excel_Analysis/
│   └── insurance_analysis.xlsx
│
├── 07_PowerBI/
│   └── insurance_analytics_dashboard.pbix
│
├── 08_Screenshots/
│   ├── executive_dashboard.png
│   ├── claims_dashboard.png
│   ├── fraud_dashboard.png
│   ├── customer_dashboard.png
│   └── recommendations.png
│
├── 09_Report/
│   └── insurance_analytics_report.pdf
│
└── 10_Presentation/
    └── insurance_analytics_presentation.pptx
```

---

# 🛠️ Tools & Technologies

* **Excel**
* **Power Query**
* **MySQL**
* **SQL**
* **Power BI**
* **DAX**
* **Data Analytics**
* **Data Visualization**

---

# 📌 Key Skills Demonstrated

* Data Cleaning & Validation
* Exploratory Data Analysis
* SQL Querying
* Relational Data Modeling
* KPI Development
* Business Analysis
* Power BI Dashboard Development
* DAX
* Fraud Risk Analysis
* Customer Retention Analysis
* Data Storytelling
* Business Recommendations

---

# ⚠️ Data & Analysis Disclaimer

This project uses synthetic transaction-level insurance data.

The analysis is intended for **educational, portfolio, and demonstration purposes**. It does not represent confidential information from an actual insurance company.

Fraud scores should be treated as **risk indicators for investigation**, not as proof of fraudulent activity.

---

# ✅ Project Completion Checklist

* [ ] Raw CSVs preserved
* [ ] Cleaned data created separately
* [ ] Cleaning log completed
* [ ] SQL database created
* [ ] SQL scripts saved
* [ ] Business questions analyzed
* [ ] SQL results validated
* [ ] Power BI relationships tested
* [ ] DAX measures created
* [ ] 7 dashboard pages completed
* [ ] Screenshots captured
* [ ] Insights based on actual numbers
* [ ] Recommendations linked to insights
* [ ] Final report completed
* [ ] Synthetic-data disclosure included
* [ ] 60–90 second interview explanation prepared

---

## 👨‍💻 Author

**Vishal kumar**

---

## ⭐ Project Summary

This project demonstrates an end-to-end approach to converting raw insurance data into **validated datasets, SQL analysis, KPIs, interactive Power BI dashboards, business insights, and actionable recommendations**.

**CSV → Cleaning → SQL → Analysis → Power BI → Insights → Recommendations**
