### Insurance Analytics & Risk Intelligence

#### Project Overview

This project analyzes a sample insurance portfolio using MysQL 8.0, SQL, and Power BI to evaluate premium collection, claims exposure, customer risk, and product-level performance. The goal is to convert operational data into actionable insights for management.

Important: This is a portfolio/demo dataset. Risk scores are rule-based and illustrative, not validated underwriting or fraud models. Product-level claim-to-collected-premium ratios are indicative comparisons, not formal actuarial loss ratios.

#### Business Objectives
- Monitor written, collected, pending and failed premiums.
- Analyze claim volume, claimed amounts, approved amounts, and claim status.
- Compare insurance product categories
- Identify customers with higher claim frequency or payment issues using a transparent rule-based score.
- Present findings and recommendations through a Power BI dashboard.

#### Tools & Technologies
- MySQL 8.0 - database design, data quality checks, analytical queries, views
- SQL - business analysis, aggregation, ranking, customer risk analysis
- Power BI - KPI cards, interactive visuals, dashboard pages, data model, DAX
- Python/Jupyter Notebook - validation, business insights, recommendations, executive summary (optional supporting analysis)
- Git & GitHub - version control and portfolio publication

#### Dataset Summary

| Entity | Records |
|---|---:|
| Customers | 10 |
| Insurance Products | 4 |
| Policies | 15 |
| Premium Payments | 15 |
| Claims | 15 |
| Agents | 0 (empty source table; excluded from dashboard model) |

#### Key Portfolio Metrics

| Metric | Result |
|---|---:|
| Written Premium | ₹193,500 |
| Collected Premium | ₹166,500 |
| Premium Collection Rate | 86.05% |
| Outstanding Premium (pending + failed) | ₹27,000 |
| Total Claimed Amount | ₹1,245,000 |
| Approved Claim Amount | ₹942,000 |
| Claim Approval Rate | 73.33% |
| High-Risk Customers | 4 |
| Medium-Risk Customers | 2 |
| Low-Risk Customers | 4 |
| Customers with Multiple Claims | 5 |

#### Dashboard Pages

1. Executive Overview - portfolio-level KPIs and summary trends
2. Premium Collection Analysis - written vs collected, monthly cancellation trends, outstanding payments
3. Claims & Loss Ratio Analysis - claims status, claimed and approved amounts, product-level indicative ratios
4. Customer Risk Intelligence - customer risk segmentation, risk scores, claim frequency adn payment-risk indicators

#### SQL Analysis

SQL scripts are organized into database setup, data loading, data quality validation and business analysis:

- Database and table creation
- Sample data insertion
- Data quality checks
- Premium analysis
- Claims analysis
- Indicative claim-to-premium ratios
- Customer risk analysis
- Consolidated final business report and customer risk view

#### Rule-Based Customer Risk Score
The illustrative score uses these rules:
- More than one claim: +2
- Total claimed amount above ₹150,000: +2
- Pending premium: +1
- Failed premium: +2
- Pending claim: +1

Risk bands:
- Low: score 0-1
- Medium: score 2-3
- High: score 4+

This score is prioritization aid for review only. It should not be used for automated customer decisions without validation, governance, and fairness assessment.

#### Key Business Findings
- Premium collection is 86.05% with ₹27,000 outstanding.
- March recorded the highest monthly premium collection at ₹47,000.
- Life and Health have the largest approved-claim exposure in the sample and merit deeper profitability investigation.
- 4 customers are classified as High Risk under the illustrative scoring rules.
- 5 customers have multiple claims.
- Claims and premium data are not joined directly at row-level; each fact table is aggregated independently to avoid double-counting.

#### Recommendations
- Prioritize follow-up for pending and failed premiums; monitor collection-rate and outstanding-premium KPIs.
- Review Life and Health product economics using earned premium, incurred claims, exposure period, and reserves before drawing actuarial conclusions.
- Conduct human review of high-risk and repeat-claim customers; avoid automatic adverse decisions baseld only on the demo score.
- Monitor pending claims, rejection reasons, and turnaround time.
- Improve data capture for missing fields, settlement dates, actual payouts, claim rejection reasons, policy renewal/lapse history, and earned-premium data.

#### Repository Structure

insurance-analytics-risk-intelligence/
├── README.md
├── sql/
│   ├── 01_create_database.sql
│   ├── 02_create_tables.sql
│   ├── 03_insert_sample_data.sql
│   ├── 04_data_quality_checks.sql
│   ├── 05_premium_analysis.sql
│   ├── 06_claims_analysis.sql
│   ├── 07_loss_ratio_analysis.sql
│   ├── 08_customer_risk_analysis.sql
│   └── 09_final_business_report.sql
├── notebooks/
│   ├── 10_business_insights.ipynb
│   ├── 11_business_recommendations.ipynb
│   └── 12_executive_summary.ipynb
├── powerbi/
│   └── insurance_analytics_dashboard.pbix
├── images/
│   ├── page_1_executive_overview.png
│   ├── page_2_premium_collection.png
│   ├── page_3_claims_analysis.png
│   └── page_4_customer_risk.png
└── docs/
    └── project_notes.md

#### How to Reproduce
1. Install MySQL 8.0 or later
2. Run the SQL files in the sql/ folder in numbered order.
3. Connect Power BI Desktop to the insuarnce_analytics database (or load the exported tables/views if using an alternative setup).
4. Recreate or open the dashboard PBIX in powerbi/ once the file is included.
5. Optionally run the Jupyter notebooks in notebooks/ for insight, recommendation, and executive-summary documentation.

Credentials, personal information, and private connection strings must never be committed. This repository uses demo data.

#### Limitations
- Small demonstration dataset(10 customers, 15 policies, 15 payments, 15 claims); findings are illustrative and not statistically generalizable.
- Missing source fields include customer gender and signup date.
- No actual claim payout/settlement table is available; approved amounts should not be interpreted as paid claims.
- Formal loss-ratio analysis requires earned premium and appropriate incurred- claim/reserve data.
- The rule-based customer risk score is not a predictive model and has not been validated.
- Agent data is empty and agent-to-policy relationships are not available.

#### Project Outcomes
The project demonstrates a complete analytics workflow- from relational data modeling and SQL quality checks through KPI development, dashboard design, risk segmentation, business interpretation, and actionable recommendations.

#### Author
Sanu Mathew