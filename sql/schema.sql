/* =========================================================================
   HR ANALYTICS: EMPLOYEE ATTRITION & WORKFORCE INSIGHTS
   File:        schema.sql
   Purpose:     Defines the database schema used for this project.
   Source Data: IBM HR Analytics Employee Attrition & Performance dataset
                (1,470 employees, 35 original attributes)
   Compatible with: PostgreSQL / MySQL 8+ / SQL Server (minor type tweaks noted)
   ========================================================================= */

-- Drop tables if re-running the script during development
DROP TABLE IF EXISTS employees_raw;
DROP TABLE IF EXISTS employees;

/* -------------------------------------------------------------------------
   1. STAGING TABLE — mirrors the raw source file exactly (no transformations)
      This preserves an untouched copy of the source data for auditability.
   ------------------------------------------------------------------------- */
CREATE TABLE employees_raw (
    Age                         INT,
    Attrition                   VARCHAR(3),
    BusinessTravel              VARCHAR(30),
    DailyRate                   INT,
    Department                  VARCHAR(50),
    DistanceFromHome            INT,
    Education                   INT,          -- 1-5 ordinal scale
    EducationField              VARCHAR(50),
    EmployeeCount                INT,          -- constant = 1 (dropped downstream)
    EmployeeNumber              INT PRIMARY KEY,
    EnvironmentSatisfaction     INT,          -- 1-4 ordinal scale
    Gender                      VARCHAR(10),
    HourlyRate                  INT,
    JobInvolvement              INT,          -- 1-4 ordinal scale
    JobLevel                    INT,
    JobRole                     VARCHAR(50),
    JobSatisfaction             INT,          -- 1-4 ordinal scale
    MaritalStatus               VARCHAR(20),
    MonthlyIncome                INT,
    MonthlyRate                  INT,
    NumCompaniesWorked          INT,
    Over18                       CHAR(1),      -- constant = 'Y' (dropped downstream)
    OverTime                     VARCHAR(3),
    PercentSalaryHike           INT,
    PerformanceRating           INT,          -- 1-4 ordinal scale
    RelationshipSatisfaction    INT,          -- 1-4 ordinal scale
    StandardHours                INT,          -- constant = 80 (dropped downstream)
    StockOptionLevel             INT,
    TotalWorkingYears            INT,
    TrainingTimesLastYear       INT,
    WorkLifeBalance              INT,          -- 1-4 ordinal scale
    YearsAtCompany                INT,
    YearsInCurrentRole           INT,
    YearsSinceLastPromotion      INT,
    YearsWithCurrManager         INT
);

/* -------------------------------------------------------------------------
   2. ANALYTICS TABLE — cleaned & enriched table used for all downstream
      SQL analysis and as the Power BI data source.
      Built by running data_cleaning.sql against employees_raw.
   ------------------------------------------------------------------------- */
CREATE TABLE employees (
    EmployeeID                     INT PRIMARY KEY,     -- renamed from EmployeeNumber
    Age                             INT,
    AgeBand                         VARCHAR(10),
    Gender                          VARCHAR(10),
    MaritalStatus                   VARCHAR(20),
    Department                      VARCHAR(50),
    JobRole                         VARCHAR(50),
    JobLevel                        INT,
    Education                       INT,
    EducationLabel                  VARCHAR(20),
    EducationField                  VARCHAR(50),
    BusinessTravel                  VARCHAR(30),
    DistanceFromHome                INT,
    MonthlyIncome                   INT,
    IncomeBand                      VARCHAR(10),
    DailyRate                       INT,
    HourlyRate                      INT,
    MonthlyRate                     INT,
    PercentSalaryHike               INT,
    StockOptionLevel                INT,
    OverTime                        VARCHAR(3),
    NumCompaniesWorked              INT,
    TotalWorkingYears               INT,
    TrainingTimesLastYear           INT,
    YearsAtCompany                  INT,
    TenureBand                      VARCHAR(15),
    YearsInCurrentRole              INT,
    YearsSinceLastPromotion         INT,
    PromotionGapBand                VARCHAR(10),
    YearsWithCurrManager            INT,
    JobSatisfaction                 INT,
    JobSatisfactionLabel            VARCHAR(15),
    EnvironmentSatisfaction         INT,
    EnvironmentSatisfactionLabel    VARCHAR(15),
    RelationshipSatisfaction        INT,
    RelationshipSatisfactionLabel   VARCHAR(15),
    JobInvolvement                  INT,
    JobInvolvementLabel             VARCHAR(15),
    WorkLifeBalance                  INT,
    WorkLifeBalanceLabel            VARCHAR(10),
    PerformanceRating               INT,
    PerformanceRatingLabel          VARCHAR(15),
    RetentionRiskScore              INT,
    RetentionRiskTier               VARCHAR(15),
    Attrition                       VARCHAR(3),
    AttritionFlag                   INT           -- 1 = Yes, 0 = No (for aggregations)
);

-- Helpful indexes for the query patterns used throughout this project
CREATE INDEX idx_employees_department   ON employees (Department);
CREATE INDEX idx_employees_jobrole      ON employees (JobRole);
CREATE INDEX idx_employees_attrition    ON employees (Attrition);
CREATE INDEX idx_employees_overtime     ON employees (OverTime);
CREATE INDEX idx_employees_risktier     ON employees (RetentionRiskTier);
