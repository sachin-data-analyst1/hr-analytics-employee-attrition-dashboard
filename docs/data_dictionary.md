# Data Dictionary

**Source dataset:** IBM HR Analytics Employee Attrition & Performance
**Records:** 1,470 employees | **Original fields:** 35 | **Cleaned/enriched fields:** 46
**File:** `data/HR_Employee_Attrition_cleaned.csv` (analysis-ready) · `data/HR_Employee_Attrition_raw.csv` (untouched source)

This is a widely-used, publicly available HR dataset (fictional employee records created for
analytics education and benchmarking — not real personal data). Its recognizability is intentional
for a portfolio project: it lets reviewers sanity-check your numbers against known benchmarks.

## Core Fields (from source data)

| Field | Type | Description |
|---|---|---|
| EmployeeID | Integer | Unique employee identifier (renamed from `EmployeeNumber`) |
| Age | Integer | Employee age in years |
| Gender | Text | Male / Female |
| MaritalStatus | Text | Single / Married / Divorced |
| Department | Text | Sales / Research & Development / Human Resources |
| JobRole | Text | Specific job title (9 distinct roles) |
| JobLevel | Integer | Seniority level, 1 (entry) to 5 (executive) |
| Education | Integer | 1=Below College, 2=College, 3=Bachelor, 4=Master, 5=Doctor |
| EducationField | Text | Field of study |
| BusinessTravel | Text | Non-Travel / Travel_Rarely / Travel_Frequently |
| DistanceFromHome | Integer | Commute distance in miles |
| MonthlyIncome | Integer | Monthly salary in USD |
| DailyRate / HourlyRate / MonthlyRate | Integer | Additional compensation reference rates from source system |
| PercentSalaryHike | Integer | Most recent salary increase, % |
| StockOptionLevel | Integer | 0 (none) to 3 (highest) |
| OverTime | Text | Yes / No — whether the employee regularly works overtime |
| NumCompaniesWorked | Integer | Number of employers prior to this one |
| TotalWorkingYears | Integer | Total years of professional experience |
| TrainingTimesLastYear | Integer | Number of trainings attended in the last year |
| YearsAtCompany | Integer | Tenure at this company |
| YearsInCurrentRole | Integer | Years in current position |
| YearsSinceLastPromotion | Integer | Years since last promotion |
| YearsWithCurrManager | Integer | Years reporting to current manager |
| JobSatisfaction | Integer | 1=Low, 2=Medium, 3=High, 4=Very High |
| EnvironmentSatisfaction | Integer | Same 1-4 scale, satisfaction with work environment |
| RelationshipSatisfaction | Integer | Same 1-4 scale, satisfaction with workplace relationships |
| JobInvolvement | Integer | Same 1-4 scale, engagement/involvement in role |
| WorkLifeBalance | Integer | 1=Bad, 2=Good, 3=Better, 4=Best |
| PerformanceRating | Integer | 1=Low, 2=Good, 3=Excellent, 4=Outstanding |
| Attrition | Text | Yes / No — whether the employee has left the company |

**Dropped from source (zero-variance, no analytical value):** `EmployeeCount` (always 1),
`Over18` (always "Y"), `StandardHours` (always 80).

## Derived / Enriched Fields (added in `sql/data_cleaning.sql`)

| Field | Description |
|---|---|
| AgeBand | <25, 25-34, 35-44, 45-54, 55+ |
| TenureBand | 0 (New Hire), 1-2 yrs, 3-5 yrs, 6-10 yrs, 10+ yrs |
| IncomeBand | <3K, 3K-6K, 6K-10K, 10K-15K, 15K+ (monthly USD) |
| PromotionGapBand | 0-1 yrs, 2-3 yrs, 4-6 yrs, 7+ yrs since last promotion |
| EducationLabel, JobSatisfactionLabel, EnvironmentSatisfactionLabel, RelationshipSatisfactionLabel, JobInvolvementLabel, WorkLifeBalanceLabel, PerformanceRatingLabel | Decoded text labels for each 1-5/1-4 ordinal scale, for dashboard readability |
| AttritionFlag | 1 = Yes, 0 = No — numeric version of Attrition for aggregation |
| RetentionRiskScore | 0-12 point transparent, rule-based score (see below) |
| RetentionRiskTier | Low Risk / Medium Risk / High Risk, derived from RetentionRiskScore |

## Retention Risk Score — Methodology

This project intentionally uses a **transparent, explainable rule-based score** rather than a
black-box ML model, because the primary audience is HR business partners who need to understand
*why* someone is flagged, not just that they are. Points are awarded as follows:

| Risk Factor | Points |
|---|---|
| Works overtime | +2 |
| Job satisfaction = Low | +2 |
| Job satisfaction = Medium | +1 |
| Work-life balance = Bad | +2 |
| Monthly income < $3,500 | +2 |
| 5+ years since last promotion | +1 |
| Tenure ≤ 1 year | +1 |
| Travels frequently for business | +1 |
| Environment satisfaction = Low | +1 |

**Tiers:** 0-2 = Low Risk · 3-5 = Medium Risk · 6+ = High Risk

This score was validated against actual attrition outcomes in the dataset: employees in the
**High Risk** tier have a **65.3%** actual attrition rate, versus **5.6%** for **Low Risk** —
confirming the scoring logic tracks real-world departure behavior well despite its simplicity.
