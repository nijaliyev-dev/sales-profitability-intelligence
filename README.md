# Sales Profitability Intelligence

### End-to-End Sales & Profitability Analytics | SQL Server · Python · Power BI

> **Where is the business generating revenue without generating enough profit?**

Sales growth is only part of the picture. A business can increase revenue while simultaneously giving away margin through excessive discounting, weak product economics, returns, cancellations, or poorly targeted promotions.

**Sales Profitability Intelligence** was built to investigate exactly that problem.

This project takes a transactional sales dataset through a complete analytics workflow — from data validation and reconciliation in SQL Server, through exploratory and statistical analysis in Python, to an interactive Power BI model designed for business decision-making.

The objective was not simply to report sales and profit.

It was to understand **where profit is created, where it is diluted, why that happens, and where management should focus first.**

---

## Executive Summary

The analysis covers **January 2021 – December 2025** and evaluates sales performance across time, products, categories, customers, regions, discounts, shipping, returns, cancellations, and payment status.

The headline picture initially looks strong:

| KPI                 |       Result |
| ------------------- | -----------: |
| Revenue             |   **144.2M** |
| Profit              |    **59.8M** |
| Profit Margin       |    **41.4%** |
| Completed Orders    |  **113,559** |
| Active Customers    |   **24,748** |
| Average Order Value | **1,269.79** |
| Loss-Making Orders  |    **1,229** |
| Realised Loss       |     **191K** |

However, the headline numbers hide several important profitability issues.

The strongest finding is the relationship between **discount depth and margin erosion**. Loss-making orders are heavily concentrated among deeply discounted transactions, with **97.6% of loss-making completed orders carrying discounts above 40%**.

Seasonality tells a similar story. November and December produce the highest revenue of the year, but their margins fall to roughly **30%**, compared with approximately **45–47% during typical months**.

Electronics represents the largest category-level opportunity. It contributes **33.5M in revenue**, but its margin of **32.6%** is materially below higher-margin categories such as Grocery.

The analysis also uncovered a data reliability issue that would be easy to miss in a conventional dashboard: **order-header and order-line calculations do not fully reconcile**. The difference affects approximately **8.7% of the underlying value**, so different analytical questions require different revenue bases.

The result is a project that treats **data quality, analytical consistency and business interpretation as one connected problem**, rather than treating dashboard development as the final objective.

---

# 1. Business Problem

The central business question was:

> **Where is the business creating revenue without creating enough profit?**

To answer it, the analysis was structured around three questions:

### 1. Where is profit being created or lost?

* Which categories generate the strongest margins?
* Which products generate revenue but relatively little profit?
* Which customer groups create the most value?
* Which regions perform above or below the business average?
* How significant are loss-making orders?

### 2. What is driving margin leakage?

* How does discount depth affect profitability?
* What happens during peak promotional periods?
* Which categories are most exposed to discount pressure?
* How much value is affected by returns and cancellations?
* Is shipping a meaningful profitability driver?

### 3. Can management trust the KPIs?

* Do order headers reconcile with order lines?
* Are there incomplete or inconsistent payment statuses?
* Are formulas internally consistent?
* Are missing values handled appropriately?
* Are the revenue definitions consistent across analytical layers?

This last question became particularly important because the dataset contains several issues that can materially change the interpretation of the business.

---

# 2. Analytical Approach

The project follows a complete analytics lifecycle:

```text
Raw Transactional Data
        │
        ▼
┌──────────────────────────┐
│       SQL Server         │
│                          │
│ Data Profiling           │
│ Quality Checks           │
│ Reconciliation           │
│ Clean Layer              │
│ Analytical Views         │
└────────────┬─────────────┘
             │
             ▼
┌──────────────────────────┐
│         Python           │
│                          │
│ Exploratory Analysis     │
│ Business Analysis        │
│ Statistical Analysis     │
│ Visualisation            │
│ Analytical Exports       │
└────────────┬─────────────┘
             │
             ▼
┌──────────────────────────┐
│        Power BI          │
│                          │
│ Star Schema              │
│ DAX Measures             │
│ KPI Layer                │
│ Interactive Analysis     │
└────────────┬─────────────┘
             │
             ▼
┌──────────────────────────┐
│    Business Findings     │
│                          │
│ Margin Opportunities     │
│ Revenue Leakage          │
│ Commercial Risks         │
│ Recommendations          │
└──────────────────────────┘
```

The workflow deliberately separates **data preparation**, **analysis**, and **business presentation**.

This makes it possible to trace an executive KPI back to the underlying analytical logic instead of calculating everything directly inside a dashboard.

---

# 3. Technology Stack

| Technology           | Role in the project                                                           |
| -------------------- | ----------------------------------------------------------------------------- |
| **SQL Server**       | Data profiling, quality checks, reconciliation, cleaning and analytical views |
| **Python**           | Exploratory analysis, business analysis and statistical investigation         |
| **Pandas**           | Data preparation, transformation and aggregation                              |
| **Matplotlib**       | Analytical visualisation                                                      |
| **Seaborn**          | Correlation and statistical visualisation                                     |
| **Power BI**         | Interactive business intelligence and reporting                               |
| **DAX**              | KPI and business metric calculations                                          |
| **Jupyter Notebook** | Reproducible Python analysis                                                  |
| **Git / GitHub**     | Version control and project documentation                                     |

---

# 4. Repository Structure

```text
Sales-Profitability-Intelligence/
│
├── sql/
│   └── Sales_Profitability_Intelligence.sql
│
├── python/
│   └── Sales-Profitability-Intelligence.ipynb
│
├── powerbi/
│   └── SALES_PROFITABILITY_INTELLIGENCE.pbix
│
├── report/
│   └── Sales_Profitability_Intelligence_Analytical_Report.pdf
│
├── outputs/
│   ├── monthly_analysis.csv
│   ├── category_analysis.csv
│   ├── product_analysis.csv
│   ├── customer_analysis.csv
│   ├── discount_analysis.csv
│   ├── region_analysis.csv
│   └── loss_by_discount.csv
│
└── README.md
```

The repository contains the main analytical components rather than only a final dashboard.

That makes the project reviewable at several levels:

* SQL logic
* Python analysis
* BI modelling
* Business interpretation

---

# 5. SQL Server — Data Quality & Analytical Foundation

The SQL stage was designed as more than a collection of business queries.

Before calculating profitability KPIs, the underlying data was profiled and tested for structural and logical inconsistencies.

## Data quality checks

The SQL workflow covers:

* Row-count validation
* Data type inspection
* NULL-value analysis
* Duplicate detection
* Primary-key validation
* Referential integrity
* Invalid-value detection
* Range validation
* Logical consistency checks
* Text-quality validation
* Outlier detection using IQR
* Formula integrity
* Order-header vs. order-line reconciliation
* Payment-status investigation

The raw tables were not overwritten.

Instead, cleaning and analytical logic were implemented through separate structures, including a `customers_clean` table and analytical views.

This preserves the original source while keeping the analytical layer controlled and reproducible.

---

## Dataset Scale

The analysed dataset contains:

* **25,000 customers**
* **1,175 products**
* **397,569 order-line records**
* **138,116 order headers**

One missing gender value was handled explicitly as `Unknown` rather than attempting to infer information that was not present in the source data.

That approach is intentional: data cleaning should improve analytical usability without inventing information.

---

# 6. A Critical Finding: Revenue Reconciliation

One of the most important findings came from comparing order-header calculations with order-line calculations.

The two levels do not reconcile perfectly.

Approximately **8.7% of value differs between the two representations**.

This matters because using both tables interchangeably could create misleading KPIs.

The analytical architecture therefore separates the two use cases:

```text
                 HEADLINE KPIs
                       │
                       ▼
              Order Header Layer
                       │
          Revenue / Profit / Orders
                       │
                       ▼
                Executive View


               LINE-LEVEL ANALYSIS
                       │
                       ▼
                 Order Lines
                       │
        Product / Category / Discount
                       │
                       ▼
              Detailed Analysis
```

Headline KPIs are therefore calculated from the **order-header population**, while product, category, discount and other line-level analyses use the **order-line dataset**.

The two revenue bases are intentionally not combined.

This distinction is important because a dashboard can be visually correct while still being analytically inconsistent if different fact levels are mixed without a clear definition.

---

# 7. Python — Exploratory & Business Analysis

After the SQL validation layer, Python was used to explore the commercial behaviour of the dataset.

The purpose of the Python stage was not simply to reproduce SQL queries.

It was used to investigate patterns, compare groups, identify anomalies and quantify potential business opportunities before translating the results into Power BI.

## Analysis areas

### Time

* Monthly revenue
* Monthly profit
* Profit margin
* Order volume
* Average discount
* Loss-making orders
* Seasonal performance
* Peak-period comparison

### Product & Category

* Revenue contribution
* Profit contribution
* Margin
* Product profitability
* Subcategory performance
* Pareto contribution
* High-revenue / low-profit products

### Customer

* Revenue per customer
* Orders per customer
* Customer segments
* Customer concentration
* Loss-making customers

### Region

* Revenue
* Profit
* Margin
* Customer base
* Shipping cost ratio

### Discount

* Discount distribution
* Discount bands
* Margin deterioration
* Loss rate
* Discount vs. profitability

### Statistical analysis

Correlation analysis was also used to examine relationships between:

* Discount
* Product cost
* Gross sales
* Net sales
* Shipping cost
* Profit
* Profit margin

Correlation was used as an exploratory tool rather than being interpreted as proof of causality.

---

# 8. Power BI — Business Intelligence Layer

The final analytical model was implemented in Power BI using a dimensional structure designed to separate business entities from transactional facts.

The model follows a **star-schema approach** with date, customer and product dimensions connected to the transactional layer.

```text
                  dim_Date
                     │
                     │
dim_Customers ─── fact_Orders ─── dim_Products
                     │
                     │
               fact_OrderLines
                     │
                     ▼
                  _Measures
```

The Power BI layer translates the underlying analysis into an interactive environment where users can move from executive KPIs into product, customer, regional and discount-level detail.

---

# 9. Power BI Dashboard

The report is structured into four analytical pages.

## Executive Overview

The executive page focuses on the overall commercial position:

* Revenue
* Profit
* Profit Margin
* Completed Orders
* Customers
* Average Order Value
* Monthly performance
* Revenue trends
* Profit trends

The purpose is to answer:

> **Is the business growing profitably?**

---

## Product & Category

This page focuses on product economics:

* Category revenue
* Category profit
* Category margin
* Subcategory performance
* Product profitability
* Revenue contribution
* Profit contribution
* High-revenue / low-profit products

The key question is:

> **Which products and categories are actually creating economic value?**

---

## Customers & Regions

This page examines commercial performance across customer and geographic dimensions:

* Customer segments
* Customer value
* Regional revenue
* Regional profitability
* Customer behaviour
* Geographic margin differences

The focus is on identifying differences that are not visible in total-company KPIs.

---

## Discount & Loss

This page addresses the project's central profitability issue:

* Discount distribution
* Discount bands
* Margin erosion
* Loss-making orders
* Loss rate
* Discount vs. profitability
* Estimated margin leakage

The purpose is to distinguish **revenue generation from profitable revenue generation**.

---

# 10. Executive Performance

Across 2021–2025, the completed-order population generated:

| KPI                 |       Result |
| ------------------- | -----------: |
| Revenue             |   **144.2M** |
| Profit              |    **59.8M** |
| Profit Margin       |    **41.4%** |
| Completed Orders    |  **113,559** |
| Active Customers    |   **24,748** |
| Average Order Value | **1,269.79** |
| Loss-Making Orders  |    **1,229** |
| Realised Loss       |     **191K** |

These headline KPIs are based on the completed order-header population.

That definition is important because the broader dataset contains cancelled, pending and returned transactions.

---

# 11. Key Finding — Peak Revenue Does Not Mean Peak Profitability

November and December are by far the strongest revenue months.

They are also the months where margin deteriorates most sharply.

| Period         |        Revenue |    Margin | Average Discount |
| -------------- | -------------: | --------: | ---------------: |
| Typical months | ~2.15M / month |   ~46–47% |           ~11.1% |
| November       |     **17.77M** | **29.5%** |        **31.7%** |
| December       |     **18.91M** | **29.8%** |        **31.6%** |

Across the five-year period, November and December generated approximately **15.2M of additional revenue** compared with a typical monthly run rate.

However, that incremental revenue produced only around **1.1M of additional profit**.

The implied incremental margin is therefore roughly **7%**, compared with approximately **45% during typical months**.

### What this suggests

The issue is not that seasonal promotions are necessarily wrong.

The issue is that the business appears to be purchasing a significant amount of seasonal revenue at a much lower margin.

The commercial question should therefore shift from:

> "How much revenue did the promotion generate?"

to:

> "How much incremental profit did the promotion generate after discounting?"

### Recommended response

Rather than removing promotions completely, the business should test:

* Targeted customer offers
* Product bundles
* Category-specific promotions
* Loyalty-based incentives
* Minimum basket thresholds
* Margin-based promotion rules
* Controlled A/B testing

---

# 12. Key Finding — Discount Depth Is the Main Margin-Leakage Signal

The relationship between discount depth and profitability is particularly clear.

| Discount Band | Share of Orders |    Margin | Loss Rate |
| ------------- | --------------: | --------: | --------: |
| 0–30%         |       **84.8%** | **44.9%** |  **0.0%** |
| 30–50%        |       **13.8%** | **26.2%** |  **3.1%** |
| 50–70%        |        **1.4%** |  **1.8%** | **45.3%** |

At a more granular level:

| Discount | Loss Rate |
| -------- | --------: |
| <30%     |  **0.0%** |
| 30–40%   |  **0.3%** |
| 40–50%   |  **8.6%** |
| 50–60%   | **44.3%** |
| 60%+     | **59.8%** |

The concentration is striking:

> **1,200 of 1,229 loss-making completed orders — 97.6% — were discounted above 40%.**

The realised loss itself is relatively modest at approximately **191K**.

The larger commercial concern is the amount of **profit that may have been given away to generate revenue**.

---

# 13. Estimated Margin Leakage

If medium- and high-discount orders had achieved the same **44.9% margin** observed in the low-discount group, the theoretical additional profit would be approximately:

> **5.2M**

That represents approximately **8.6% of headline profit**.

This figure should not be interpreted as a forecast or as proof that removing discounts would automatically create 5.2M of additional profit.

It is better understood as a **scenario-based upper bound** that illustrates the economic size of the margin gap.

Some discounted transactions may not have occurred without the discount.

That distinction matters when converting analytical findings into commercial decisions.

---

# 14. Key Finding — Electronics Is the Largest Category-Level Opportunity

Electronics is the largest revenue category:

* **33.5M revenue**
* **21.4% of total revenue**
* **32.6% margin**

Grocery, by comparison, achieves approximately **54.1% margin**.

The three largest categories — Electronics, Jewelry and Home Appliances — account for approximately:

* **47.6% of revenue**
* **41.7% of profit**

This indicates a meaningful gap between **sales contribution and profit contribution**.

Electronics therefore deserves particular attention because even a relatively small margin improvement has a material financial effect.

### Sensitivity

Every additional **1 percentage point of Electronics margin** represents approximately:

> **0.33M additional profit**

over the five-year analysis period.

### Areas for investigation

* Discount depth
* Low-margin subcategories
* Product-level pricing
* Supplier cost
* Accessory attachment
* Product bundles
* High-revenue / low-profit SKUs

---

# 15. Key Finding — Existing Customer Segmentation Adds Limited Commercial Value

The existing customer segments are surprisingly similar.

| Segment  | Customers | Orders / Customer | Revenue / Customer | Margin |
| -------- | --------: | ----------------: | -----------------: | -----: |
| Consumer |    13,508 |               4.6 |              6,387 |  42.7% |
| Premium  |     6,230 |               4.6 |              6,263 |  39.4% |
| VIP      |     2,516 |               4.6 |              6,280 |  39.5% |
| Business |     2,494 |               4.5 |              6,297 |  42.6% |

The similarities suggest that the existing segment labels do not provide enough behavioural separation to support sophisticated pricing or retention decisions.

For example, a customer labelled "VIP" does not appear to demonstrate dramatically different revenue or frequency behaviour from the other groups.

### Recommended next step

Replace or supplement the static segmentation with behavioural segmentation based on:

* Recency
* Frequency
* Monetary value
* Customer profitability
* Retention behaviour
* Customer acquisition cost
* Product affinity

An RFM-based framework would provide a more actionable view of customer value.

---

# 16. Key Finding — Regional Differences Are Primarily Margin Differences

Revenue broadly follows the size of the customer base, but profitability is not identical across regions.

| Region  |   Revenue |    Margin |
| ------- | --------: | --------: |
| South   | **49.3M** |     40.6% |
| Central | **32.8M** |     40.5% |
| West    | **30.8M** |     43.5% |
| East    | **24.0M** |     40.0% |
| North   | **19.8M** | **44.5%** |

The spread between the highest and lowest regional margin is approximately **4.5 percentage points**.

This is large enough to justify investigation, particularly around:

* Product mix
* Discount behaviour
* Customer composition
* Pricing
* Regional promotions

Shipping costs, however, appear to be a relatively small lever.

They account for approximately **1.5–1.9% of revenue**, making discounting and product economics considerably more important profitability drivers in this dataset.

---

# 17. Revenue Leakage

The dataset also shows a meaningful gap between booked order value and realised revenue.

Approximately:

* **177.1M** booked value
* **144.2M** realised revenue
* **81.4%** conversion to realised revenue

The difference includes approximately:

* **19.7M** in cancelled or pending value
* **13.2M** in returned value

Returns alone represent approximately:

> **9.2% of realised revenue**

This creates an additional opportunity beyond pricing and discount management.

A business can increase gross sales while still losing economic value through cancellations and returns.

---

# 18. Payment Status Requires Further Investigation

The analysis identified:

> **11,306 completed orders with Pending payment status**

This represents approximately **10% of completed orders**.

The issue is important because the revenue KPI assumes that completed orders represent realised business value, while payment status suggests that some transactions may not yet have been financially settled.

This does not automatically mean the reported revenue is incorrect.

It means that the payment-state definition should be clarified before using the KPI for financial reporting.

A production environment would ideally distinguish:

```text
Order Status
     │
     ├── Completed
     ├── Cancelled
     ├── Pending
     └── Returned
     
Payment Status
     │
     ├── Paid
     ├── Pending
     └── Failed
```

These should not be treated as interchangeable concepts.

---

# 19. Data Quality Is Part of the Business Analysis

A major principle behind this project is:

> **A dashboard is only as reliable as the definitions and data underneath it.**

The SQL audit therefore treats data quality as a first-class analytical output.

### Validated

* Primary keys
* Row counts
* Referential integrity
* Numeric ranges
* Product prices
* Product costs
* Ratings
* Formula consistency
* Text quality
* Outliers

### Issues requiring attention

#### Header / Line Reconciliation

Order-header and order-line values differ by approximately **8.7%**.

#### Payment Status

**11,306 completed orders** have pending payment status.

#### Profit Definition

Profit includes collected tax as income, which may make reported profitability more optimistic than a conventional operating-profit definition.

#### Synthetic Data

The dataset appears synthetic.

Therefore, the findings demonstrate the analytical methodology and business reasoning rather than representing actual company performance.

---

# 20. Business Recommendations

## 1. Establish Discount Guardrails

A practical starting framework would be:

```text
0–30%     → Standard commercial discount
30–40%    → Controlled / approval range
40%+      → Exception-based pricing
```

The objective is not to eliminate discounting.

It is to prevent discounts from becoming an uncontrolled substitute for pricing strategy.

The data shows that:

* Loss rate is effectively zero below 30%
* Loss rates rise sharply beyond 40%
* 97.6% of loss-making orders are discounted above 40%

A scenario analysis suggests that recovering only **25–50% of the estimated margin leakage** could represent approximately:

> **1.3M–2.6M**

over the five-year period.

---

## 2. Redesign Peak-Season Promotions

November and December should be treated as a profitability-management problem rather than simply a sales-growth opportunity.

Recommended tests:

* Customer-specific promotions
* Product bundles
* Minimum basket thresholds
* Loyalty incentives
* Category-level discount rules
* Margin-based campaign approval
* Promotion-level ROI measurement

The KPI for a campaign should be **incremental profit**, not only incremental revenue.

---

## 3. Protect Electronics Margin

Because Electronics is the largest revenue category, small margin improvements can have meaningful financial impact.

Priority actions:

* Review discount distribution
* Identify low-margin subcategories
* Review supplier economics
* Analyse high-revenue / low-profit products
* Increase accessory attachment
* Test bundles instead of pure price reductions

A **1 percentage-point improvement** in Electronics margin corresponds to approximately **0.33M** of additional profit over the analysis period.

---

## 4. Move From Static Segments to Behavioural Segmentation

The current customer labels do not sufficiently distinguish economic value.

A stronger segmentation framework should combine:

* RFM
* Customer profitability
* Retention
* Acquisition cost
* Purchase frequency
* Product affinity

This would allow the business to differentiate between:

* High-value / high-margin customers
* High-revenue / low-margin customers
* High-potential customers
* At-risk customers
* Discount-dependent customers

---

## 5. Investigate Revenue Leakage

The next analytical layer should explain why booked value does not become realised revenue.

Priority dimensions:

* Return reason
* Cancellation reason
* Payment status
* Sales channel
* Marketing channel
* Coupon usage
* Campaign
* Product
* Customer segment

A **10% reduction in returns** would protect approximately:

> **1.3M of booked value**

based on the current dataset.

---

# 21. Recommended Implementation Roadmap

```text
PHASE 1 — CONTROL
│
├── Define KPI ownership
├── Establish discount guardrails
├── Resolve payment-status ambiguity
└── Standardise revenue definitions
        │
        ▼
PHASE 2 — OPTIMISE
│
├── Redesign peak-season promotions
├── Improve Electronics margin
├── Review low-margin products
└── Test bundles and targeted offers
        │
        ▼
PHASE 3 — PERSONALISE
│
├── RFM segmentation
├── Customer profitability
├── Retention analysis
└── CAC-to-profit analysis
        │
        ▼
PHASE 4 — REDUCE LEAKAGE
│
├── Return analysis
├── Cancellation analysis
├── Payment reconciliation
└── Campaign profitability
```

---

# 22. Success Metrics

The effectiveness of the recommendations should be monitored through a focused KPI framework.

### Pricing & Margin

* % of orders discounted above 30%
* % of orders discounted above 40%
* Average discount
* Loss-making order rate
* Profit margin
* Electronics margin

### Seasonal Performance

* November margin
* December margin
* Incremental profit from promotions
* Promotion ROI

### Revenue Quality

* Revenue conversion rate
* Return rate
* Cancellation rate
* Pending-payment rate

### Customer Economics

* Revenue per customer
* Profit per customer
* Customer retention
* Customer profitability by segment

The purpose is to move from **descriptive reporting** to ongoing commercial performance management.

---

# 23. Limitations

The analysis intentionally documents its limitations.

### Revenue definitions

Headline KPIs are calculated from order headers, while product, category and discount analysis is performed at line level.

### Reconciliation

Header and line values differ by approximately 8.7%.

### Currency

The dataset appears to use a common monetary scale, so no currency conversion was applied.

### Profit definition

Profit includes collected tax as income. This may overstate profitability compared with a stricter operating-profit definition.

### Payment status

11,306 completed orders have pending payment status and require further investigation.

### Delivery information

Delivery-related analysis is limited because delivery information is available only for completed orders.

### Synthetic dataset

The source data appears synthetic. Findings should therefore be interpreted as analytical demonstrations rather than real-world company results.

### Causality

Discount and margin relationships are strong associations in this dataset, but they should not be treated as causal evidence without controlled experimentation.

### Impact estimates

Margin-recovery figures are scenario estimates, not forecasts.

These limitations are documented because **analytical credibility depends not only on the findings, but also on clearly defining what the data can and cannot prove.**

---

# 24. Future Development

Several extensions would make the analytical system more decision-oriented.

### Forecasting

* Revenue forecasting
* Profit forecasting
* Seasonal forecasting
* Category-level forecasting

### Customer Intelligence

* RFM segmentation
* Customer Lifetime Value
* Customer Acquisition Cost
* Churn / retention analysis
* Customer profitability

### Commercial Analytics

* Campaign profitability
* Coupon effectiveness
* Sales-channel profitability
* Marketing-channel profitability
* Price elasticity analysis

### Revenue Quality

* Return-reason analysis
* Cancellation analysis
* Payment reconciliation
* Pending-payment valuation

### BI Improvements

* Executive one-page summary
* Data definitions page
* KPI dictionary
* Automated refresh architecture
* Exception monitoring

---

# 25. Deliverables

| Deliverable                                              | Purpose                                                       |
| -------------------------------------------------------- | ------------------------------------------------------------- |
| `Sales_Profitability_Intelligence.sql`                   | SQL data audit, reconciliation, cleaning and analytical layer |
| `Sales-Profitability-Intelligence.ipynb`                 | Python EDA, business analysis and analytical outputs          |
| `SALES_PROFITABILITY_INTELLIGENCE.pbix`                  | Interactive four-page Power BI dashboard                      |
| `Sales_Profitability_Intelligence_Analytical_Report.pdf` | Detailed findings, interpretation and recommendations         |

The Power BI report contains:

1. **Executive Overview**
2. **Product & Category**
3. **Customers & Regions**
4. **Discount & Loss**

---

# 26. What This Project Demonstrates

This project demonstrates the complete workflow expected from a modern Data Analyst:

```text
Understand the business problem
             ↓
Profile the data
             ↓
Validate the numbers
             ↓
Build a reliable analytical layer
             ↓
Explore the data
             ↓
Identify business drivers
             ↓
Quantify opportunities
             ↓
Model the data for BI
             ↓
Build decision-oriented dashboards
             ↓
Translate findings into actions
```

The most important part of the project is not the dashboard itself.

It is the reasoning that connects:

**raw data → validated metrics → business finding → financial impact → recommended action.**

---

# 27. Final Takeaway

The analysis highlights a simple but important distinction:

> **Revenue growth is not the same as profitable growth.**

The business generates strong headline revenue and profit, but the analysis reveals several areas where additional revenue is being purchased at disproportionately low margins.

The largest opportunities are concentrated around:

* **Discount depth**
* **Peak-season promotions**
* **Electronics margin**
* **Customer segmentation**
* **Returns and cancellations**
* **Payment-status reconciliation**
* **Revenue-definition consistency**

The most important finding is therefore not that the business needs to sell more.

It is that the business needs to become more selective about **which revenue it chooses to buy**.

A strong commercial strategy should optimise for:

> **Revenue quality → Margin → Incremental Profit → Sustainable Growth**

rather than revenue alone.

---

# About the Author

## Nijat Aliyev

**Data Analyst | SQL · Python · Power BI**

Warsaw, Poland

GitHub: **@nijaliyev-dev**

This project was built as an end-to-end demonstration of analytical thinking, SQL development, Python-based investigation, Power BI modelling and business-oriented decision support.

---

## Project

**Sales Profitability Intelligence**

**Analysis Period:** January 2021 – December 2025

**Primary Question:**

> **Where is the business creating revenue without creating enough profit?**
