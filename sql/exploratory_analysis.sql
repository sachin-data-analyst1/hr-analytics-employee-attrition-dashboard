/* =========================================================================
   File:    exploratory_analysis.sql
   Purpose: General exploratory data analysis (EDA) of the workforce —
            headcount, demographics, distributions — before diving into
            attrition-specific analysis.
   Table:   employees (cleaned)
   ========================================================================= */

-- 1. Total headcount and overall attrition split
SELECT
    COUNT(*)                                            AS total_employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END)  AS employees_left,
    SUM(CASE WHEN Attrition = 'No'  THEN 1 ELSE 0 END)  AS active_employees
FROM employees;

-- 2. Headcount by department
SELECT Department, COUNT(*) AS headcount,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct_of_workforce
FROM employees
GROUP BY Department
ORDER BY headcount DESC;

-- 3. Headcount by job role
SELECT JobRole, Department, COUNT(*) AS headcount
FROM employees
GROUP BY JobRole, Department
ORDER BY headcount DESC;

-- 4. Age distribution
SELECT AgeBand, COUNT(*) AS headcount
FROM employees
GROUP BY AgeBand
ORDER BY MIN(Age);

-- 5. Gender split overall and by department
SELECT Department, Gender, COUNT(*) AS headcount
FROM employees
GROUP BY Department, Gender
ORDER BY Department, Gender;

-- 6. Education level distribution
SELECT EducationLabel, COUNT(*) AS headcount,
       ROUND(AVG(MonthlyIncome), 0) AS avg_income
FROM employees
GROUP BY EducationLabel
ORDER BY headcount DESC;

-- 7. Marital status distribution
SELECT MaritalStatus, COUNT(*) AS headcount
FROM employees
GROUP BY MaritalStatus
ORDER BY headcount DESC;

-- 8. Tenure distribution (how mature is the workforce?)
SELECT TenureBand, COUNT(*) AS headcount,
       ROUND(AVG(MonthlyIncome), 0) AS avg_income
FROM employees
GROUP BY TenureBand
ORDER BY MIN(YearsAtCompany);

-- 9. Monthly income summary statistics overall and by department
SELECT
    Department,
    COUNT(*)                    AS headcount,
    ROUND(AVG(MonthlyIncome),0) AS avg_income,
    MIN(MonthlyIncome)          AS min_income,
    MAX(MonthlyIncome)          AS max_income
FROM employees
GROUP BY Department
ORDER BY avg_income DESC;

-- 10. Overtime prevalence across the workforce
SELECT OverTime, COUNT(*) AS headcount,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct_of_workforce
FROM employees
GROUP BY OverTime;

-- 11. Business travel frequency distribution
SELECT BusinessTravel, COUNT(*) AS headcount
FROM employees
GROUP BY BusinessTravel
ORDER BY headcount DESC;

-- 12. Job satisfaction distribution across the workforce
SELECT JobSatisfactionLabel, COUNT(*) AS headcount
FROM employees
GROUP BY JobSatisfactionLabel
ORDER BY MIN(JobSatisfaction);

-- 13. Work-life balance distribution
SELECT WorkLifeBalanceLabel, COUNT(*) AS headcount
FROM employees
GROUP BY WorkLifeBalanceLabel
ORDER BY MIN(WorkLifeBalance);

-- 14. Performance rating distribution (sanity check for rating inflation)
SELECT PerformanceRatingLabel, COUNT(*) AS headcount
FROM employees
GROUP BY PerformanceRatingLabel;

-- 15. Correlation check: does income scale with tenure, as expected?
SELECT TenureBand, ROUND(AVG(MonthlyIncome), 0) AS avg_income
FROM employees
GROUP BY TenureBand
ORDER BY MIN(YearsAtCompany);
