# Business Problem

## Context

A mid-sized organization (~1,470 employees across Sales, Research & Development, and Human
Resources) has noticed a rising number of resignations over the past few review cycles. Leadership
does not have a clear, data-driven view of **where** attrition is concentrated, **why** it's
happening, or **which currently active employees** are most likely to leave next. HR is currently
reactive — exit interviews happen after someone has already resigned, by which point the cost has
already been incurred.

## Why Attrition Matters to the Business

Employee attrition is not just an HR metric — it's a direct cost center:

- **Replacement cost.** Industry estimates put the fully-loaded cost of replacing an employee
  (recruiting, interviewing, onboarding, ramp-up productivity loss) at roughly 50%–200% of that
  employee's annual salary, depending on seniority.
- **Lost productivity and institutional knowledge.** Every departure creates a coverage gap and a
  hit to team velocity, particularly for tenured employees who exit unexpectedly.
- **Morale and manager overhead.** High-attrition teams place additional recruiting and training
  burden on managers and remaining staff.
- **Compounding risk.** As shown in this analysis, risk factors like overtime, low satisfaction,
  and stalled promotion don't act independently — they compound. A single high-risk segment
  (Sales Representatives working overtime) shows an attrition rate over 4x the company average.

Using this project's cost model (six months of salary per departure as a conservative estimate),
the 237 departures in this dataset represent an **estimated $6.9M+ in annual replacement cost** —
a number leadership can act on.

## Key Business Questions

This project answers the following questions using SQL and Power BI:

1. What is the company's overall attrition rate, and how does it break down by department and job role?
2. Does working overtime meaningfully increase attrition risk, and by how much?
3. Is there a relationship between compensation and attrition?
4. How does tenure (time at the company) relate to attrition risk?
5. Does job satisfaction, work-life balance, or environment satisfaction predict attrition?
6. Does time since last promotion correlate with an employee's likelihood of leaving?
7. Which specific employee segments carry the highest combined retention risk?
8. Which currently active employees should HR proactively check in with, based on a transparent
   risk-scoring model?

## Success Criteria

A successful outcome for this project is a reusable analytics asset that lets an HR business
partner, without writing a single query, answer "where is our attrition problem, and who should we
talk to first?" — backed by a documented, explainable SQL data pipeline underneath.
