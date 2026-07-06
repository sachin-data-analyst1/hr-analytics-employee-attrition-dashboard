/* =========================================================================
   File:    attrition_analysis.sql
   Purpose: Deep-dive attrition analysis — where attrition concentrates,
            which factors drive it, and which employee segments carry the
            highest retention risk.
   Table:   employees (cleaned)
   ========================================================================= */

-- 1. Overall attrition rate
SELECT
    COUNT(*)                                                       AS total_employees,
    SUM(AttritionFlag)                                             AS attrition_count,
    ROUND(100.0 * SUM(AttritionFlag) / COUNT(*), 2)                AS attrition_rate_pct
FROM employees;

-- 2. Department-wise attrition (rate + volume)
SELECT
    Department,
    COUNT(*)                                        AS headcount,
    SUM(AttritionFlag)                              AS attrition_count,
    ROUND(100.0 * SUM(AttritionFlag) / COUNT(*), 2) AS attrition_rate_pct
FROM employees
GROUP BY Department
ORDER BY attrition_rate_pct DESC;

-- 3. Job role attrition — surfaces the highest-churn roles company-wide
SELECT
    JobRole,
    Department,
    COUNT(*)                                        AS headcount,
    SUM(AttritionFlag)                              AS attrition_count,
    ROUND(100.0 * SUM(AttritionFlag) / COUNT(*), 2) AS attrition_rate_pct
FROM employees
GROUP BY JobRole, Department
HAVING COUNT(*) >= 20   -- exclude tiny groups that would skew the rate
ORDER BY attrition_rate_pct DESC;

-- 4. Overtime impact on attrition — one of the strongest predictors
SELECT
    OverTime,
    COUNT(*)                                        AS headcount,
    SUM(AttritionFlag)                              AS attrition_count,
    ROUND(100.0 * SUM(AttritionFlag) / COUNT(*), 2) AS attrition_rate_pct
FROM employees
GROUP BY OverTime
ORDER BY attrition_rate_pct DESC;

-- 5. Salary analysis — attrition rate by income band
SELECT
    IncomeBand,
    COUNT(*)                                        AS headcount,
    ROUND(AVG(MonthlyIncome), 0)                    AS avg_income,
    SUM(AttritionFlag)                              AS attrition_count,
    ROUND(100.0 * SUM(AttritionFlag) / COUNT(*), 2) AS attrition_rate_pct
FROM employees
GROUP BY IncomeBand
ORDER BY avg_income;

-- 5b. Average income comparison: employees who left vs stayed
SELECT
    Attrition,
    COUNT(*)                     AS headcount,
    ROUND(AVG(MonthlyIncome), 0) AS avg_income
FROM employees
GROUP BY Attrition;

-- 6. Tenure analysis — attrition rate by years-at-company band
SELECT
    TenureBand,
    COUNT(*)                                        AS headcount,
    SUM(AttritionFlag)                              AS attrition_count,
    ROUND(100.0 * SUM(AttritionFlag) / COUNT(*), 2) AS attrition_rate_pct
FROM employees
GROUP BY TenureBand
ORDER BY MIN(YearsAtCompany);

-- 7. Satisfaction analysis — job satisfaction vs attrition
SELECT
    JobSatisfactionLabel,
    COUNT(*)                                        AS headcount,
    SUM(AttritionFlag)                              AS attrition_count,
    ROUND(100.0 * SUM(AttritionFlag) / COUNT(*), 2) AS attrition_rate_pct
FROM employees
GROUP BY JobSatisfactionLabel
ORDER BY attrition_rate_pct DESC;

-- 7b. Work-life balance vs attrition
SELECT
    WorkLifeBalanceLabel,
    COUNT(*)                                        AS headcount,
    SUM(AttritionFlag)                              AS attrition_count,
    ROUND(100.0 * SUM(AttritionFlag) / COUNT(*), 2) AS attrition_rate_pct
FROM employees
GROUP BY WorkLifeBalanceLabel
ORDER BY attrition_rate_pct DESC;

-- 7c. Environment satisfaction vs attrition
SELECT
    EnvironmentSatisfactionLabel,
    COUNT(*)                                        AS headcount,
    SUM(AttritionFlag)                              AS attrition_count,
    ROUND(100.0 * SUM(AttritionFlag) / COUNT(*), 2) AS attrition_rate_pct
FROM employees
GROUP BY EnvironmentSatisfactionLabel
ORDER BY attrition_rate_pct DESC;

-- 8. Promotion analysis — does time since last promotion drive attrition?
SELECT
    PromotionGapBand,
    COUNT(*)                                        AS headcount,
    SUM(AttritionFlag)                              AS attrition_count,
    ROUND(100.0 * SUM(AttritionFlag) / COUNT(*), 2) AS attrition_rate_pct
FROM employees
GROUP BY PromotionGapBand
ORDER BY MIN(YearsSinceLastPromotion);

-- 9. Business travel impact on attrition
SELECT
    BusinessTravel,
    COUNT(*)                                        AS headcount,
    SUM(AttritionFlag)                              AS attrition_count,
    ROUND(100.0 * SUM(AttritionFlag) / COUNT(*), 2) AS attrition_rate_pct
FROM employees
GROUP BY BusinessTravel
ORDER BY attrition_rate_pct DESC;

-- 10. Age band attrition — early-career risk check
SELECT
    AgeBand,
    COUNT(*)                                        AS headcount,
    SUM(AttritionFlag)                              AS attrition_count,
    ROUND(100.0 * SUM(AttritionFlag) / COUNT(*), 2) AS attrition_rate_pct
FROM employees
GROUP BY AgeBand
ORDER BY MIN(Age);

-- 11. Marital status vs attrition
SELECT
    MaritalStatus,
    COUNT(*)                                        AS headcount,
    SUM(AttritionFlag)                              AS attrition_count,
    ROUND(100.0 * SUM(AttritionFlag) / COUNT(*), 2) AS attrition_rate_pct
FROM employees
GROUP BY MaritalStatus
ORDER BY attrition_rate_pct DESC;

-- 12. TOP RETENTION RISK SEGMENTS — multi-factor intersection analysis
--     Combines the two strongest single-factor drivers (overtime + low
--     satisfaction) to show how risk compounds when factors stack.
SELECT
    CASE WHEN OverTime = 'Yes' THEN 'Overtime' ELSE 'No Overtime' END       AS overtime_group,
    JobSatisfactionLabel,
    COUNT(*)                                        AS headcount,
    SUM(AttritionFlag)                              AS attrition_count,
    ROUND(100.0 * SUM(AttritionFlag) / COUNT(*), 2) AS attrition_rate_pct
FROM employees
GROUP BY overtime_group, JobSatisfactionLabel
HAVING COUNT(*) >= 15
ORDER BY attrition_rate_pct DESC;

-- 12b. Retention risk tier summary (built in data_cleaning.sql)
SELECT
    RetentionRiskTier,
    COUNT(*)                                        AS headcount,
    SUM(AttritionFlag)                              AS attrition_count,
    ROUND(100.0 * SUM(AttritionFlag) / COUNT(*), 2) AS attrition_rate_pct
FROM employees
GROUP BY RetentionRiskTier
ORDER BY attrition_rate_pct DESC;

-- 13. Highest-risk named segment: new hires (<=1 yr) working overtime
SELECT
    COUNT(*)                                        AS headcount,
    SUM(AttritionFlag)                              AS attrition_count,
    ROUND(100.0 * SUM(AttritionFlag) / COUNT(*), 2) AS attrition_rate_pct
FROM employees
WHERE TenureBand IN ('0 (New Hire)', '1-2 yrs')
  AND OverTime = 'Yes';

-- 14. Highest-risk named segment: Sales Representatives working overtime
SELECT
    COUNT(*)                                        AS headcount,
    SUM(AttritionFlag)                              AS attrition_count,
    ROUND(100.0 * SUM(AttritionFlag) / COUNT(*), 2) AS attrition_rate_pct
FROM employees
WHERE JobRole = 'Sales Representative'
  AND OverTime = 'Yes';

-- 15. Ranked list of individual at-risk active employees for HR outreach
--     (Active employees only, sorted by highest risk score first)
SELECT
    EmployeeID, Department, JobRole, MonthlyIncome, OverTime,
    JobSatisfactionLabel, WorkLifeBalanceLabel, YearsAtCompany,
    YearsSinceLastPromotion, RetentionRiskScore, RetentionRiskTier
FROM employees
WHERE Attrition = 'No'
  AND RetentionRiskTier = 'High Risk'
ORDER BY RetentionRiskScore DESC, MonthlyIncome ASC
LIMIT 25;
