# 📊 Sales Profitability Intelligence

### End-to-End Data Analytics & Business Intelligence Project

**SQL Server · Python · Power BI · Business Analytics**

> **Where is the business creating revenue without creating enough profit?**

An end-to-end **Sales & Profitability Intelligence** project focused on understanding revenue performance, profitability, margin leakage, discount behaviour, product performance, customer value, regional performance, and revenue leakage.

The project transforms raw transactional data into a structured analytical workflow using **SQL Server for data quality and transformation, Python for exploratory and business analysis, Power BI for interactive decision-making, and an analytical report for business recommendations.**

**Author:** [Nijat Aliyev](https://github.com/nijaliyev-dev)
**Role:** Data Analyst
**Location:** Warsaw, Poland
**Analysis Period:** January 2021 – December 2025

---

## 🚀 Project Overview

This project demonstrates a complete data analytics lifecycle:

```text
Raw Transactional Data
        │
        ▼
┌─────────────────────┐
│     SQL Server      │
│ Data Quality Audit  │
│ Reconciliation      │
│ Clean Layer         │
│ Analytical Views    │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│       Python        │
│ EDA                 │
│ Business Analysis   │
│ Statistical Analysis│
│ Visualization       │
│ CSV Outputs         │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│      Power BI       │
│ Star Schema         │
│ DAX Measures        │
│ Interactive Dashboard│
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Analytical Report   │
│ Findings            │
│ Business Impact     │
│ Recommendations     │
└─────────────────────┘
```

The goal was not simply to calculate revenue and profit, but to answer a more important business question:

> **Where is revenue being generated without generating enough profit?**

---

# 🎯 Business Objectives

The analysis was designed around three core business questions:

1. **Where does the business make and lose money?**
2. **Which factors drive profitability and margin leakage?**
3. **How reliable are the reported KPIs?**

The analysis investigates profitability across:

* 📅 Seasonality
* 💸 Discount depth
* 📦 Product & category
* 👥 Customer segments
* 🌍 Regions
* 🚚 Shipping
* 💰 Revenue leakage
* ❌ Loss-making orders
* 📊 Data quality & KPI reliability

---

# 🛠️ Tech Stack

| Technology           | Purpose                                                           |
| -------------------- | ----------------------------------------------------------------- |
| **SQL Server**       | Data quality audit, reconciliation, cleaning and analytical views |
| **Python**           | EDA, business analysis, correlation analysis and data export      |
| **Pandas**           | Data manipulation and aggregation                                 |
| **Matplotlib**       | Data visualization                                                |
| **Seaborn**          | Correlation and analytical visualization                          |
| **Power BI**         | Interactive BI dashboard                                          |
| **DAX**              | KPI and business metric calculations                              |
| **Jupyter Notebook** | Python analysis workflow                                          |
| **Git / GitHub**     | Version control and portfolio presentation                        |

---

# 📁 Project Structure

```text
Sales-Profitability-Intelligence/
│
├── 📂 sql/
│   └── Sales_Profitability_Intelligence.sql
│
├── 📂 python/
│   └── Sales-Profitability-Intelligence.ipynb
│
├── 📂 powerbi/
│   └── SALES_PROFITABILITY_INTELLIGENCE.pbix
│
├── 📂 report/
│   └── Sales_Profitability_Intelligence_Analytical_Report.pdf
│
├── 📂 outputs/
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

> The exact repository structure may be adjusted depending on which generated analytical outputs are published.

---

# 🗄️ 1. SQL Server — Data Quality & Clean Layer

The first stage of the project was performed in **SQL Server**.

The SQL workflow was designed not only to query the data, but to establish confidence in the analytical dataset before calculating business KPIs.

### Main SQL activities

* Row-count validation
* Data type inspection
* NULL-value analysis
* Duplicate detection
* Primary-key validation
* Referential integrity checks
* Invalid-value detection
* Logical consistency checks
* Text-quality validation
* Outlier detection using IQR
* Formula integrity validation
* Header vs. order-line reconciliation
* Payment-status investigation
* Clean customer table creation
* Analytical views
* Profitability analysis
* Discount-band analysis
* Loss-order analysis

### Important data-quality findings

The dataset contains:

* **25,000 customers**
* **1,175 products**
* **397,569 order-line records**
* **138,116 order headers**

The raw tables were intentionally kept unchanged. Cleaning was performed through a separate `customers_clean` table and analytical views.

One missing gender value was converted to `Unknown` rather than attempting to infer the customer's actual gender.

The SQL analysis also identified an important reconciliation issue:

> Order-header and order-line calculations differ by approximately **8.7%**.

Therefore, headline KPIs are calculated from the order-header table, while product, category, discount and other line-level analyses use order-line data.

This distinction is explicitly preserved throughout the project rather than mixing the two revenue bases.

---

# 🐍 2. Python — Exploratory & Business Analysis

After the SQL validation and clean layer, the analysis continued in Python using **Pandas, Matplotlib and Seaborn**.

### Python workflow

```text
Load SQL outputs
      │
      ▼
Data preparation
      │
      ▼
Exploratory Data Analysis
      │
      ├── Monthly performance
      ├── Category analysis
      ├── Product analysis
      ├── Customer analysis
      ├── Regional analysis
      ├── Discount analysis
      ├── Loss analysis
      └── Correlation analysis
      │
      ▼
Business Insights
      │
      ▼
CSV analytical outputs
```

### Key analyses performed

#### 📅 Monthly & Seasonal Analysis

* Revenue by month
* Profit by month
* Profit margin by month
* Average discount
* Order volume
* Loss-making orders
* Peak-season comparison

#### 📦 Product & Category Analysis

* Revenue contribution
* Profit contribution
* Profit margin
* Product profitability
* Subcategory performance
* Pareto analysis
* High-revenue / low-profit products

#### 👥 Customer Analysis

* Revenue per customer
* Orders per customer
* Customer segment performance
* Customer concentration
* Loss-making customers

#### 🌍 Regional Analysis

* Revenue
* Profit
* Margin
* Customer base
* Shipping cost ratio

#### 💸 Discount Analysis

* Discount bands
* Margin by discount level
* Loss rate by discount level
* Discount vs. profitability
* Margin leakage estimation

#### 📉 Correlation Analysis

Correlation analysis was used to identify relationships between:

* Discount
* Product cost
* Gross sales
* Net sales
* Shipping cost
* Profit
* Profit margin

---

# 📊 3. Power BI — Interactive Business Intelligence Dashboard

The final analytical layer was developed in **Power BI**.

The model follows a **star-schema architecture** consisting of:

```text
                 dim_Date
                    │
                    │
dim_Customers ── fact_Orders ── dim_Products
                    │
                    │
              fact_OrderLines
                    │
                    ▼
              _Measures
```

### Dashboard Pages

The Power BI report contains four analytical pages:

### 1️⃣ Executive Overview

Provides a high-level view of:

* Revenue
* Profit
* Profit Margin
* Completed Orders
* Customers
* AOV
* Monthly performance
* Revenue & profit trends
* Business-level KPIs

### 2️⃣ Product & Category

Focuses on:

* Category revenue
* Category profit
* Category margin
* Subcategory performance
* Product profitability
* Revenue/profit contribution
* High-revenue / low-profit products

### 3️⃣ Customers & Regions

Analyzes:

* Customer segments
* Customer value
* Regional revenue
* Regional profitability
* Customer behaviour
* Geographic performance

### 4️⃣ Discount & Loss

Focuses on the project's most important profitability issue:

* Discount distribution
* Discount bands
* Margin erosion
* Loss-making orders
* Loss rate
* Discount vs. profitability
* Margin leakage

---

# 📈 Executive Performance

Between **2021 and 2025**, the business generated:

| KPI                    |       Result |
| ---------------------- | -----------: |
| 💰 Revenue             |   **144.2M** |
| 📈 Profit              |    **59.8M** |
| 📊 Profit Margin       |    **41.4%** |
| 🧾 Completed Orders    |  **113,559** |
| 👥 Active Customers    |   **24,748** |
| 🛒 Average Order Value | **1,269.79** |
| ❌ Loss-Making Orders   |    **1,229** |
| 📉 Total Realised Loss |     **191K** |

These headline KPIs are calculated using the completed order-header population.

---

# 🔎 Key Business Insights

## 1. Peak-season revenue does not translate into proportional profit

November and December generate the highest revenue, but profitability deteriorates significantly.

| Period         |      Revenue |  Margin | Avg. Discount |
| -------------- | -----------: | ------: | ------------: |
| Typical months | ~2.15M/month | ~46–47% |        ~11.1% |
| November       |       17.77M |   29.5% |         31.7% |
| December       |       18.91M |   29.8% |         31.6% |

November–December generated approximately **15.2M of incremental revenue** compared with typical months over the five-year period, but only around **1.1M of incremental profit**.

This means the incremental revenue was generated at approximately **7% margin**, compared with approximately **45% in typical months**.

### Business implication

The business appears to be buying seasonal revenue through aggressive discounting.

The appropriate next step is not simply to eliminate promotions, but to test:

* Targeted bundles
* Loyalty offers
* Category-specific promotions
* Controlled promotional experiments

---

# 💸 2. Discounting is the strongest margin-leakage driver

The analysis shows a clear deterioration in profitability as discount depth increases.

| Discount Band | Share of Orders |    Margin | Loss Rate |
| ------------- | --------------: | --------: | --------: |
| 0–30%         |           84.8% | **44.9%** |  **0.0%** |
| 30–50%        |           13.8% | **26.2%** |  **3.1%** |
| 50–70%        |            1.4% |  **1.8%** | **45.3%** |

A more granular analysis shows:

```text
Discount       Loss Rate

<30%           0.0%
30–40%         0.3%
40–50%         8.6%
50–60%        44.3%
60%+          59.8%
```

**1,200 of 1,229 loss-making completed orders (97.6%) were discounted above 40%.**

The direct realised loss is relatively small:

> **191K**

However, the much larger issue is **margin dilution**.

If medium- and high-discount orders had achieved the low-discount band's 44.9% margin, the estimated additional profit would be approximately:

> **5.2M**

This represents approximately **8.6% of headline profit**.

> ⚠️ This is an upper-bound scenario rather than a causal forecast, because some discounted orders may not have existed without the discount.

---

# 📦 3. Electronics is the largest margin opportunity

Electronics is the largest revenue category:

* **33.5M revenue**
* **21.4% of revenue**
* **32.6% margin**

By comparison, Grocery achieves a **54.1% margin**.

The three largest categories:

* Electronics
* Jewelry
* Home Appliances

generate approximately **47.6% of revenue**, but only **41.7% of profit**.

### Electronics opportunity

Every additional **1 percentage point of Electronics margin** represents approximately:

> **0.33M additional profit over the analysis period**

Potential actions:

* Reduce excessive discount depth
* Introduce accessory bundles
* Review low-margin subcategories
* Review high-revenue / low-profit products
* Introduce margin-based pricing guardrails

---

# 👥 4. Existing customer segmentation does not meaningfully separate value

The existing segments show surprisingly similar behaviour.

| Segment  | Customers | Orders / Customer | Revenue / Customer | Margin |
| -------- | --------: | ----------------: | -----------------: | -----: |
| Consumer |    13,508 |               4.6 |              6,387 |  42.7% |
| Premium  |     6,230 |               4.6 |              6,263 |  39.4% |
| VIP      |     2,516 |               4.6 |              6,280 |  39.5% |
| Business |     2,494 |               4.5 |              6,297 |  42.6% |

The existing labels therefore do not provide enough behavioural differentiation for effective pricing or retention strategies.

### Recommended approach

Build behavioural segmentation using:

* **RFM**
* Customer Acquisition Cost
* Customer profitability
* Retention behaviour
* Purchase frequency
* Monetary value

---

# 🌍 5. Regional performance differs mainly by margin

Revenue follows customer-base size relatively closely.

However, profitability differs:

| Region  | Revenue |    Margin |
| ------- | ------: | --------: |
| South   |   49.3M |     40.6% |
| Central |   32.8M |     40.5% |
| West    |   30.8M |     43.5% |
| East    |   24.0M |     40.0% |
| North   |   19.8M | **44.5%** |

The regional margin spread is approximately **4.5 percentage points**.

Shipping costs represent only approximately **1.5–1.9% of revenue**, making shipping a relatively minor profitability lever compared with discounting.

---

# 💧 6. Revenue Leakage

Not all booked order value becomes realised revenue.

The dataset contains approximately:

* **177.1M booked value**
* **144.2M realised revenue**
* **81.4% revenue conversion**

Approximately:

* **19.7M** is cancelled or pending
* **13.2M** is returned

Returned orders alone represent approximately:

> **9.2% of realised revenue**

An additional concern is that **11,306 Completed orders show Pending payment status**, which could potentially overstate realised revenue.

This area represents one of the largest unexplored opportunities in the dataset.

---

# 🧪 Data Quality & Reliability

One of the key goals of this project was to avoid building a dashboard on top of unvalidated data.

The SQL audit identified:

### ✅ Validated

* Primary keys
* Row counts
* Referential integrity
* Numeric ranges
* Product prices
* Product costs
* Ratings
* Formula integrity
* Text formatting
* Outliers

### ⚠️ Important Issues Identified

#### Header vs. Item Reconciliation

11,226 orders (**8.13%**) show differences between order-header and order-line calculations.

Therefore:

```text
Headline KPI Layer
        ↓
sales_customer / Order Headers

Product / Category / Discount Layer
        ↓
orders / Order Lines
```

These two revenue bases are intentionally **not added together**.

#### Payment Status

11,306 Completed orders (**10.0%**) have a Pending payment status.

This was flagged because revenue could potentially be overstated.

#### Profit Definition

Profit includes collected tax as income, meaning reported margins may be somewhat optimistic.

#### Synthetic Dataset

The underlying dataset appears synthetic.

Therefore, the project demonstrates analytical methodology and capability, while conclusions should be validated against real business data before being used for actual decisions.

---

# 💡 Business Recommendations

## 1. Introduce a 40% discount cap

Recommended control:

```text
0–30%     → Standard discount
30–40%    → Manager approval
40%+      → Automatic block / exception
```

Why?

* No loss-making orders below 30%
* Loss rate increases sharply above 40%
* 97.6% of loss-making orders are above 40%

Estimated scenario impact:

> **1.3M – 2.6M** over five years if 25–50% of estimated margin leakage is recovered.

---

## 2. Redesign November–December promotions

Replace blanket discounting with:

* Targeted bundles
* Loyalty offers
* Category-specific promotions
* Controlled A/B tests
* Margin-based promotion rules

Peak-month revenue is high, but the incremental margin is very low.

---

## 3. Protect Electronics margin

Focus on:

* Discount depth
* Bundling
* Accessory attachment
* Low-margin subcategories
* High-revenue / low-profit products

A **1 percentage-point improvement** in Electronics margin represents approximately:

> **0.33M**

over the analysis period.

---

## 4. Replace static customer segments with RFM

Build behavioural customer segments based on:

* Recency
* Frequency
* Monetary value
* Customer Acquisition Cost
* Customer profitability

This would enable more targeted:

* Retention
* Pricing
* Loyalty
* Upselling
* Cross-selling

---

## 5. Investigate revenue leakage

Priorities:

* Return reasons
* Cancellation reasons
* Pending payments
* Sales channel
* Marketing channel
* Coupon performance
* Campaign profitability

A 10% reduction in returns would protect approximately:

> **1.3M of booked value**

---

# 🧭 Recommended Implementation Roadmap

```text
PHASE 1 — CONTROL
│
├── Discount guardrails
├── KPI definitions
└── Data-quality fixes
        │
        ▼
PHASE 2 — OPTIMISE
│
├── Peak-season promotions
├── Electronics pricing
└── Product bundling
        │
        ▼
PHASE 3 — PERSONALISE
│
├── RFM segmentation
├── CAC analysis
└── Customer profitability
        │
        ▼
PHASE 4 — VALIDATE
│
├── Returns
├── Cancellations
└── Pending payments
```

---

# 📏 Success Metrics

After implementation, the following KPIs should be monitored:

* % of orders discounted above 30%
* Number of loss-making orders
* November–December margin
* Electronics margin
* Return rate
* Completed orders with Pending payment
* Revenue conversion rate
* Margin leakage

---

# ⚠️ Limitations

The analysis has several important limitations:

1. Headline KPIs use order headers, while product/category/discount analysis uses order lines.
2. Header and line totals differ by approximately 8.7%.
3. Currencies are not converted because the dataset appears to use a common monetary scale.
4. Profit includes collected tax.
5. 11,306 Completed orders have Pending payment status.
6. Delivery information is only available for Completed orders.
7. The dataset appears synthetic.
8. Seasonal discount relationships represent strong associations, not causal proof.
9. Impact estimates are scenarios rather than forecasts.

These limitations are intentionally documented rather than hidden because **data reliability is part of the analysis itself**.

---

# 🔮 Future Improvements

Potential next iterations include:

* [ ] 6–12 month revenue forecast
* [ ] Seasonal profit forecasting
* [ ] RFM customer segmentation
* [ ] CAC-to-profit analysis
* [ ] Return-reason analysis
* [ ] Cancellation analysis
* [ ] Marketing-channel profitability
* [ ] Sales-channel profitability
* [ ] Coupon & campaign profitability
* [ ] Pending-payment valuation
* [ ] Power BI data-notes page
* [ ] Executive one-page summary

---

# 📂 Deliverables

| File                                                     | Description                                               |
| -------------------------------------------------------- | --------------------------------------------------------- |
| `Sales_Profitability_Intelligence.sql`                   | SQL data audit, reconciliation and clean analytical layer |
| `Sales-Profitability-Intelligence.ipynb`                 | Python EDA and business analysis                          |
| `SALES_PROFITABILITY_INTELLIGENCE.pbix`                  | 4-page interactive Power BI dashboard                     |
| `Sales_Profitability_Intelligence_Analytical_Report.pdf` | Full analytical report and business recommendations       |

The project report documents the same end-to-end workflow and identifies the four Power BI pages as **Executive Overview, Product & Category, Customers & Regions, and Discount & Loss**.

---

# 👤 Author

## Nijat Aliyev

**Data Analyst | SQL · Python · Power BI**

Warsaw, Poland

GitHub: **[@nijaliyev-dev](https://github.com/nijaliyev-dev)**

---

## ⭐ Project Summary

**Sales Profitability Intelligence** demonstrates how raw transactional data can be transformed into actionable business intelligence through:

```text
DATA QUALITY
     ↓
SQL TRANSFORMATION
     ↓
PYTHON ANALYSIS
     ↓
BUSINESS INSIGHTS
     ↓
POWER BI DASHBOARD
     ↓
STRATEGIC RECOMMENDATIONS
```

The key lesson from the analysis is simple:

> **Revenue growth does not automatically mean profitable growth.**

The largest opportunities are not necessarily in generating more sales, but in controlling **discount depth, protecting category margins, improving customer segmentation, and reducing revenue leakage**.

---

### ⭐ If you found this project useful

Feel free to explore the repository, review the SQL workflow, inspect the Python analysis, and examine the Power BI dashboard.

**Built by Nijat Aliyev with SQL Server, Python and Power BI.**
