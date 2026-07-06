# Business Insights & Recommendations

All figures below are computed directly from `sql/attrition_analysis.sql` and
`sql/kpi_queries.sql` run against the cleaned dataset (1,470 employees, 237 departures,
16.12% overall attrition rate).

## Key Findings

### 1. Overtime is the single strongest attrition driver in the dataset
Employees who work overtime leave at **30.5%**, nearly **3x** the rate of employees who don't
(**10.4%**). Overtime affects 28.3% of the workforce — a meaningful share of the org is carrying
elevated risk.

### 2. Attrition concentrates heavily in Sales, and specifically Sales Representatives
- **Sales** has the highest departmental attrition rate at **20.6%**, followed by **Human
  Resources** (19.1%) and **Research & Development** (13.8%, the largest and most stable department).
- At the role level, **Sales Representatives churn at 39.8%** — by far the highest of any role —
  followed by Laboratory Technicians (23.9%) and HR staff (23.1%). Meanwhile Research Directors
  (2.5%) and Managers (4.9%) are the most stable roles, unsurprising given their seniority and pay.

### 3. Compensation matters, but mostly at the low end
Employees earning under **$3,000/month** leave at **28.6%**, more than double the rate of anyone
earning above $6,000/month (12–13%), and nearly **8x** the rate of top earners ($15K+: 3.8%).
Employees who left earned **$4,787/month on average versus $6,833 for those who stayed** — a 30%
gap. Beyond the lowest income band, however, the relationship flattens — pay alone doesn't explain
attrition once someone clears a basic compensation threshold.

### 4. Tenure risk is front-loaded: the first two years are the danger zone
- **New hires (0 years): 36.4% attrition**
- **1-2 years: 28.9% attrition**
- **3-5 years: 13.8%** — a sharp drop-off
- **10+ years: 8.1%** — the most stable segment

This is a classic early-tenure risk curve: once an employee clears roughly two years, retention
odds improve substantially.

### 5. Job satisfaction and work-life balance matter, but less than overtime and tenure alone
- Low job satisfaction correlates with 22.8% attrition vs. 11.3% for "Very High" satisfaction —
  meaningful, but a smaller gap than overtime's effect.
- Bad work-life balance shows the largest single jump in this category: **31.3% attrition**, nearly
  double every other work-life balance tier (14–18%).
- Frequent business travel nearly triples attrition versus no travel (24.9% vs. 8.0%).

### 6. Risk factors compound — this is the most actionable finding
Attrition isn't driven by any single factor in isolation; it compounds when factors stack:
- Overtime **and** low job satisfaction together: **35.7%** attrition (n=84)
- Sales Representatives specifically who work overtime: **66.7%** attrition (n=24) — two-thirds of
  this exact segment leaves
- New hires (≤2 years) working overtime: **47.8%** attrition (n=90)

This is why the project builds a **combined Retention Risk Score** rather than relying on any one
metric: employees flagged **High Risk** (score ≥6) show a **65.3% actual attrition rate**, versus
just **5.6%** for **Low Risk** employees — a 12x spread that a single-variable view would miss entirely.

### 7. Demographic patterns worth noting
- **Single employees churn at 25.5%**, more than double married (12.5%) or divorced (10.1%)
  employees — plausibly reflecting fewer geographic/financial ties keeping them in place.
- **Under-25 employees churn at 39.2%**, the highest of any age band, consistent with early-career
  job-hopping and the tenure-risk pattern above.
- Gender shows only a modest gap (Male 17.0% vs. Female 14.8%) — not a primary driver here.

## Business Recommendations

1. **Audit overtime practices in high-churn roles first.** Sales Representatives working overtime
   lose two-thirds of that population — this is the single highest-leverage segment in the entire
   dataset. Investigate whether overtime here reflects understaffing, unrealistic quotas, or poor
   territory design, and consider workload redistribution or targeted overtime pay premiums.

2. **Build a structured 0-24 month onboarding and check-in program.** With attrition at 28-36% in
   an employee's first two years, front-loaded retention investment (mentorship, 30/60/90-day
   check-ins, early career-path conversations) will have outsized ROI compared to later-tenure
   interventions.

3. **Review the compensation floor, not the whole scale.** Since attrition risk is concentrated
   below the $3,000/month threshold rather than scaling smoothly with pay, a targeted minimum-pay
   adjustment for the lowest band is likely more cost-effective than an across-the-board raise.

4. **Use the Retention Risk Score for proactive HR outreach, not just historical reporting.**
   The dashboard's drill-through table (Page 4) surfaces currently active employees already
   scoring "High Risk" — HR should treat this as a standing outreach list, prioritized by risk
   score, rather than waiting for a resignation letter.

5. **Re-examine business travel policy for frequent travelers.** A near-3x attrition gap for
   frequent travelers suggests either travel fatigue or that frequent-travel roles are
   under-compensated for the lifestyle cost — worth a targeted employee survey.

6. **Treat single, under-25 employees as a distinct retention cohort**, not because of who they
   are, but because they cluster with the other real risk factors above (early tenure, entry-level
   pay). Retention programs aimed at "new to career" employees broadly will capture this group
   without singling out demographics directly.

## Suggested Next Metrics to Track Going Forward

- Time-to-fill and cost-per-hire by role, to validate the $6.9M cost estimate against actuals
- Exit interview theme tagging, cross-referenced against this risk score to validate/refine it
- Manager-level attrition rates (via `YearsWithCurrManager`) to spot manager-specific retention issues
- Promotion velocity by department, to check whether the "years since promotion" risk factor is a
  policy issue or role-specific ceiling
