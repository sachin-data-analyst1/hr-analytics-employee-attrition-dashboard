/* =========================================================================
   File:    data_cleaning.sql
   Purpose: Clean, validate, and enrich employees_raw -> employees
   Notes:   Written for PostgreSQL/MySQL syntax. Swap CASE logic as needed
            for SQL Server (works as-is in T-SQL too).
   ========================================================================= */

/* -------------------------------------------------------------------------
   STEP 1: DATA VALIDATION CHECKS
   Run these first — they should all return 0 rows on a clean load.
   ------------------------------------------------------------------------- */

-- 1a. Check for duplicate Employee IDs
SELECT EmployeeNumber, COUNT(*) AS cnt
FROM employees_raw
GROUP BY EmployeeNumber
HAVING COUNT(*) > 1;

-- 1b. Check for NULLs in any critical business field
SELECT *
FROM employees_raw
WHERE Age IS NULL
   OR Attrition IS NULL
   OR Department IS NULL
   OR JobRole IS NULL
   OR MonthlyIncome IS NULL
   OR YearsAtCompany IS NULL;

-- 1c. Check for out-of-range ordinal scale values (should all be 1-4, Education 1-5)
SELECT * FROM employees_raw
WHERE JobSatisfaction NOT BETWEEN 1 AND 4
   OR EnvironmentSatisfaction NOT BETWEEN 1 AND 4
   OR RelationshipSatisfaction NOT BETWEEN 1 AND 4
   OR JobInvolvement NOT BETWEEN 1 AND 4
   OR WorkLifeBalance NOT BETWEEN 1 AND 4
   OR PerformanceRating NOT BETWEEN 1 AND 4
   OR Education NOT BETWEEN 1 AND 5;

-- 1d. Check Attrition only contains expected values
SELECT DISTINCT Attrition FROM employees_raw
WHERE Attrition NOT IN ('Yes', 'No');

-- 1e. Confirm the three "constant" columns really are constant before dropping them
SELECT DISTINCT EmployeeCount, Over18, StandardHours FROM employees_raw;


/* -------------------------------------------------------------------------
   STEP 2: BUILD THE CLEANED / ENRICHED ANALYTICS TABLE
   - Drops zero-variance columns (EmployeeCount, Over18, StandardHours)
   - Decodes ordinal survey scales into readable labels
   - Builds banding/segmentation fields used across the dashboard
   - Builds a transparent, rule-based Retention Risk Score
   ------------------------------------------------------------------------- */

INSERT INTO employees
SELECT
    EmployeeNumber                                                     AS EmployeeID,
    Age,
    CASE
        WHEN Age < 25 THEN '<25'
        WHEN Age BETWEEN 25 AND 34 THEN '25-34'
        WHEN Age BETWEEN 35 AND 44 THEN '35-44'
        WHEN Age BETWEEN 45 AND 54 THEN '45-54'
        ELSE '55+'
    END                                                                 AS AgeBand,
    Gender,
    MaritalStatus,
    Department,
    JobRole,
    JobLevel,
    Education,
    CASE Education
        WHEN 1 THEN 'Below College' WHEN 2 THEN 'College'
        WHEN 3 THEN 'Bachelor'      WHEN 4 THEN 'Master'
        WHEN 5 THEN 'Doctor'
    END                                                                 AS EducationLabel,
    EducationField,
    BusinessTravel,
    DistanceFromHome,
    MonthlyIncome,
    CASE
        WHEN MonthlyIncome < 3000  THEN '<3K'
        WHEN MonthlyIncome < 6000  THEN '3K-6K'
        WHEN MonthlyIncome < 10000 THEN '6K-10K'
        WHEN MonthlyIncome < 15000 THEN '10K-15K'
        ELSE '15K+'
    END                                                                 AS IncomeBand,
    DailyRate,
    HourlyRate,
    MonthlyRate,
    PercentSalaryHike,
    StockOptionLevel,
    OverTime,
    NumCompaniesWorked,
    TotalWorkingYears,
    TrainingTimesLastYear,
    YearsAtCompany,
    CASE
        WHEN YearsAtCompany = 0                       THEN '0 (New Hire)'
        WHEN YearsAtCompany BETWEEN 1 AND 2            THEN '1-2 yrs'
        WHEN YearsAtCompany BETWEEN 3 AND 5            THEN '3-5 yrs'
        WHEN YearsAtCompany BETWEEN 6 AND 10           THEN '6-10 yrs'
        ELSE '10+ yrs'
    END                                                                 AS TenureBand,
    YearsInCurrentRole,
    YearsSinceLastPromotion,
    CASE
        WHEN YearsSinceLastPromotion <= 1 THEN '0-1 yrs'
        WHEN YearsSinceLastPromotion <= 3 THEN '2-3 yrs'
        WHEN YearsSinceLastPromotion <= 6 THEN '4-6 yrs'
        ELSE '7+ yrs'
    END                                                                 AS PromotionGapBand,
    YearsWithCurrManager,
    JobSatisfaction,
    CASE JobSatisfaction
        WHEN 1 THEN 'Low' WHEN 2 THEN 'Medium' WHEN 3 THEN 'High' WHEN 4 THEN 'Very High'
    END                                                                 AS JobSatisfactionLabel,
    EnvironmentSatisfaction,
    CASE EnvironmentSatisfaction
        WHEN 1 THEN 'Low' WHEN 2 THEN 'Medium' WHEN 3 THEN 'High' WHEN 4 THEN 'Very High'
    END                                                                 AS EnvironmentSatisfactionLabel,
    RelationshipSatisfaction,
    CASE RelationshipSatisfaction
        WHEN 1 THEN 'Low' WHEN 2 THEN 'Medium' WHEN 3 THEN 'High' WHEN 4 THEN 'Very High'
    END                                                                 AS RelationshipSatisfactionLabel,
    JobInvolvement,
    CASE JobInvolvement
        WHEN 1 THEN 'Low' WHEN 2 THEN 'Medium' WHEN 3 THEN 'High' WHEN 4 THEN 'Very High'
    END                                                                 AS JobInvolvementLabel,
    WorkLifeBalance,
    CASE WorkLifeBalance
        WHEN 1 THEN 'Bad' WHEN 2 THEN 'Good' WHEN 3 THEN 'Better' WHEN 4 THEN 'Best'
    END                                                                 AS WorkLifeBalanceLabel,
    PerformanceRating,
    CASE PerformanceRating
        WHEN 1 THEN 'Low' WHEN 2 THEN 'Good' WHEN 3 THEN 'Excellent' WHEN 4 THEN 'Outstanding'
    END                                                                 AS PerformanceRatingLabel,

    -- Transparent, explainable retention risk score (0-12 scale, higher = riskier)
    ( CASE WHEN OverTime = 'Yes' THEN 2 ELSE 0 END
    + CASE WHEN JobSatisfaction = 1 THEN 2 WHEN JobSatisfaction = 2 THEN 1 ELSE 0 END
    + CASE WHEN WorkLifeBalance = 1 THEN 2 ELSE 0 END
    + CASE WHEN MonthlyIncome < 3500 THEN 2 ELSE 0 END
    + CASE WHEN YearsSinceLastPromotion >= 5 THEN 1 ELSE 0 END
    + CASE WHEN YearsAtCompany <= 1 THEN 1 ELSE 0 END
    + CASE WHEN BusinessTravel = 'Travel_Frequently' THEN 1 ELSE 0 END
    + CASE WHEN EnvironmentSatisfaction = 1 THEN 1 ELSE 0 END
    )                                                                   AS RetentionRiskScore,

    CASE
        WHEN ( CASE WHEN OverTime = 'Yes' THEN 2 ELSE 0 END
             + CASE WHEN JobSatisfaction = 1 THEN 2 WHEN JobSatisfaction = 2 THEN 1 ELSE 0 END
             + CASE WHEN WorkLifeBalance = 1 THEN 2 ELSE 0 END
             + CASE WHEN MonthlyIncome < 3500 THEN 2 ELSE 0 END
             + CASE WHEN YearsSinceLastPromotion >= 5 THEN 1 ELSE 0 END
             + CASE WHEN YearsAtCompany <= 1 THEN 1 ELSE 0 END
             + CASE WHEN BusinessTravel = 'Travel_Frequently' THEN 1 ELSE 0 END
             + CASE WHEN EnvironmentSatisfaction = 1 THEN 1 ELSE 0 END ) >= 6 THEN 'High Risk'
        WHEN ( CASE WHEN OverTime = 'Yes' THEN 2 ELSE 0 END
             + CASE WHEN JobSatisfaction = 1 THEN 2 WHEN JobSatisfaction = 2 THEN 1 ELSE 0 END
             + CASE WHEN WorkLifeBalance = 1 THEN 2 ELSE 0 END
             + CASE WHEN MonthlyIncome < 3500 THEN 2 ELSE 0 END
             + CASE WHEN YearsSinceLastPromotion >= 5 THEN 1 ELSE 0 END
             + CASE WHEN YearsAtCompany <= 1 THEN 1 ELSE 0 END
             + CASE WHEN BusinessTravel = 'Travel_Frequently' THEN 1 ELSE 0 END
             + CASE WHEN EnvironmentSatisfaction = 1 THEN 1 ELSE 0 END ) >= 3 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END                                                                 AS RetentionRiskTier,

    Attrition,
    CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END                       AS AttritionFlag
FROM employees_raw;


/* -------------------------------------------------------------------------
   STEP 3: POST-LOAD VALIDATION
   ------------------------------------------------------------------------- */

-- Row counts should match between raw and cleaned tables
SELECT
    (SELECT COUNT(*) FROM employees_raw) AS raw_count,
    (SELECT COUNT(*) FROM employees)      AS cleaned_count;

-- Spot-check that no analytical field is unexpectedly NULL after transformation
SELECT COUNT(*) AS null_check_failures
FROM employees
WHERE AgeBand IS NULL OR IncomeBand IS NULL OR TenureBand IS NULL
   OR JobSatisfactionLabel IS NULL OR RetentionRiskTier IS NULL;
