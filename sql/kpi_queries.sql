/* =========================================================================
   File:    kpi_queries.sql
   Purpose: Single-source-of-truth KPI queries. These mirror exactly what
            is built as DAX measures in Power BI, so SQL and dashboard
            numbers always reconcile.
   Table:   employees (cleaned)
   ========================================================================= */

-- KPI 1: Total Employees (all-time, includes both active and departed)
SELECT COUNT(*) AS total_employees FROM employees;

-- KPI 2: Active Employees (current headcount)
SELECT COUNT(*) AS active_employees FROM employees WHERE Attrition = 'No';

-- KPI 3: Employees Who Left
SELECT COUNT(*) AS employees_left FROM employees WHERE Attrition = 'Yes';

-- KPI 4: Overall Attrition Rate (%)
SELECT ROUND(100.0 * SUM(AttritionFlag) / COUNT(*), 2) AS attrition_rate_pct
FROM employees;

-- KPI 5: Average Monthly Income (active employees)
SELECT ROUND(AVG(MonthlyIncome), 0) AS avg_monthly_income
FROM employees WHERE Attrition = 'No';

-- KPI 6: Average Tenure (Years at Company), active employees
SELECT ROUND(AVG(YearsAtCompany), 2) AS avg_tenure_years
FROM employees WHERE Attrition = 'No';

-- KPI 7: Average Job Satisfaction Score (1-4 scale), active employees
SELECT ROUND(AVG(JobSatisfaction), 2) AS avg_job_satisfaction
FROM employees WHERE Attrition = 'No';

-- KPI 8: Overtime Percentage (share of workforce working overtime)
SELECT ROUND(100.0 * SUM(CASE WHEN OverTime = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS overtime_pct
FROM employees;

-- KPI 9: Department-wise Attrition Rate (%) — feeds the department bar chart
SELECT
    Department,
    COUNT(*)                                        AS headcount,
    ROUND(100.0 * SUM(AttritionFlag) / COUNT(*), 2) AS attrition_rate_pct
FROM employees
GROUP BY Department
ORDER BY attrition_rate_pct DESC;

-- KPI 10: Average Monthly Salary Hike (%) — a proxy for compensation growth
SELECT ROUND(AVG(PercentSalaryHike), 2) AS avg_salary_hike_pct
FROM employees WHERE Attrition = 'No';

-- KPI 11: Average Years Since Last Promotion (active employees)
SELECT ROUND(AVG(YearsSinceLastPromotion), 2) AS avg_years_since_promotion
FROM employees WHERE Attrition = 'No';

-- KPI 12: High-Risk Employee Count (active employees flagged High Risk)
SELECT COUNT(*) AS high_risk_active_employees
FROM employees
WHERE Attrition = 'No' AND RetentionRiskTier = 'High Risk';

-- KPI 13: High-Risk Employees as % of Active Workforce
SELECT
    ROUND(100.0 *
        SUM(CASE WHEN RetentionRiskTier = 'High Risk' THEN 1 ELSE 0 END)
        / COUNT(*), 2) AS pct_active_workforce_high_risk
FROM employees
WHERE Attrition = 'No';

-- KPI 14: Estimated Annual Attrition-Related Cost (illustrative)
--         Formula: attrition_count * avg_monthly_income_of_leavers * 6 months
--         (Industry rule-of-thumb: replacing an employee typically costs
--          50 to 200 percent of annual salary. Six months of salary is
--          used here as a conservative mid-point covering recruiting,
--          onboarding, and lost productivity during ramp-up.)
SELECT
    SUM(AttritionFlag)                                       AS employees_lost,
    ROUND(AVG(CASE WHEN Attrition = 'Yes' THEN MonthlyIncome END), 0) AS avg_income_of_leavers,
    ROUND(SUM(AttritionFlag) *
          (SELECT AVG(MonthlyIncome) FROM employees WHERE Attrition = 'Yes') * 6, 0)
                                                                AS estimated_annual_attrition_cost
FROM employees;

-- KPI 15: Gender Diversity Ratio
SELECT
    Gender,
    COUNT(*)                                                 AS headcount,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1)       AS pct_of_workforce
FROM employees
GROUP BY Gender;

-- ---------------------------------------------------------------------
-- Executive summary — all headline KPIs in a single row (for KPI cards)
-- ---------------------------------------------------------------------
SELECT
    COUNT(*)                                                                   AS total_employees,
    SUM(CASE WHEN Attrition = 'No' THEN 1 ELSE 0 END)                          AS active_employees,
    SUM(AttritionFlag)                                                         AS employees_left,
    ROUND(100.0 * SUM(AttritionFlag) / COUNT(*), 2)                            AS attrition_rate_pct,
    ROUND(AVG(CASE WHEN Attrition = 'No' THEN MonthlyIncome END), 0)           AS avg_monthly_income,
    ROUND(AVG(CASE WHEN Attrition = 'No' THEN YearsAtCompany END), 2)          AS avg_tenure_years,
    ROUND(AVG(CASE WHEN Attrition = 'No' THEN JobSatisfaction END), 2)         AS avg_job_satisfaction,
    ROUND(100.0 * SUM(CASE WHEN OverTime = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS overtime_pct
FROM employees;
