/* =====================================================================
   SALES & PROFITABILITY INTELLIGENCE
   Part 1: Data Quality + Clean Layer (SQL Server)

   TABLES
     dbo.customers       customer master             25,000 rows
     dbo.products        product catalog              1,175 rows
     dbo.orders          ORDER ITEMS (1 row = 1 product line of an order)   397,569 rows
     dbo.sales_customer  ORDER HEADERS (1 row = 1 order)                    138,116 rows

   KEY DECISIONS (explained in the findings below)
     1. Revenue = orders with order_status = 'Completed' only.
     2. Headline KPIs (revenue, orders, AOV) come from sales_customer;
        category / product / discount analysis comes from orders (items).
        The two tables differ by ~8% (see RECONCILIATION).
     3. Currencies are NOT converted (amounts are on one common scale).
     4. Raw tables are never modified. Cleaning happens in customers_clean and views.
   ===================================================================== */

IF DB_ID('SALES_PROFITABILITY_INTELLIGENCE') IS NULL
    CREATE DATABASE SALES_PROFITABILITY_INTELLIGENCE
GO
USE SALES_PROFITABILITY_INTELLIGENCE
GO

SELECT * FROM dbo.customers
SELECT * FROM dbo.products
SELECT * FROM dbo.orders
SELECT * FROM dbo.sales_customer


/* =====================================================================
   1. ROW COUNTS AND DATA TYPES
   ===================================================================== */

-- CHECKING ROWS
SELECT 'CUSTOMERS' AS NAMES, COUNT(*) AS COUNT_ROWS FROM dbo.customers
UNION ALL
SELECT 'PRODUCTS', COUNT(*) FROM dbo.products
UNION ALL
SELECT 'ORDERS', COUNT(*) FROM dbo.orders
UNION ALL
SELECT 'SALES_CUSTOMERS', COUNT(*) FROM dbo.sales_customer

-- CHECKING DATA TYPES (all four tables)
SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME IN ('customers', 'products', 'orders', 'sales_customer')
ORDER BY TABLE_NAME, ORDINAL_POSITION;

		-- FINDING: All four tables were imported successfully. Row counts match the source CSV files
		-- (customers 25,000 / products 1,175 / order items 397,569 / order headers 138,116).
		-- Note: dbo.orders holds order ITEMS and dbo.sales_customer holds order HEADERS.


/* =====================================================================
   2. CUSTOMERS
   ===================================================================== */

-- CHECKING NULLs
	--customers
SELECT COUNT(*) - COUNT(customer_id) FROM dbo.customers

SELECT 
	SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS CUSTOMER_ID,
	SUM(CASE WHEN customer_name IS NULL THEN 1 ELSE 0 END) AS CUSTOMER_NAME,
	SUM(CASE WHEN customer_age IS NULL THEN 1 ELSE 0 END) AS CUSTOMER_AGE,
	SUM(CASE WHEN customer_segment IS NULL THEN 1 ELSE 0 END) AS CUSTOMER_SEGMENT,
	SUM(CASE WHEN gender IS NULL THEN 1 ELSE 0 END) AS CUSTOMER_GENDER,
	SUM(CASE WHEN customer_city IS NULL THEN 1 ELSE 0 END) AS CUSTOMER_CITY,
	SUM(CASE WHEN customer_state IS NULL THEN 1 ELSE 0 END) AS CUSTOMER_STATE,
	SUM(CASE WHEN customer_country IS NULL THEN 1 ELSE 0 END) AS CUSTOMER_COUNTRY,
	SUM(CASE WHEN region IS NULL THEN 1 ELSE 0 END) AS REGION,
	SUM(CASE WHEN customer_acquisition_cost IS NULL THEN 1 ELSE 0 END) AS CUSTOMER_COST
FROM dbo.customers

SELECT 
	customer_id, customer_name, gender
FROM dbo.customers
WHERE gender IS NULL

-- Raw table is NOT updated. A cleaned copy is created instead.
IF OBJECT_ID('dbo.customers_clean', 'U') IS NOT NULL DROP TABLE dbo.customers_clean;

SELECT customer_id, customer_name, customer_age,
       COALESCE(gender, 'Unknown') AS gender,
       customer_segment, customer_city, customer_state,
       customer_country, region, customer_acquisition_cost
INTO dbo.customers_clean
FROM dbo.customers;

SELECT * FROM dbo.customers_clean

		-- FINDING: Only 1 NULL value exists in the whole customers table (gender of one customer).
		-- The raw table was left untouched. A new table dbo.customers_clean was created where the
		-- missing gender is labelled 'Unknown' (we cannot know the real value, so no guess is made).
		-- All other columns have 0 NULLs.

-- CHECKING 0 / NEGATIVE
	--customers
SELECT
	SUM(CASE WHEN customer_age <= 0 THEN 1 ELSE 0 END) AS CUSTOMER_AGE,
	SUM(CASE WHEN customer_acquisition_cost <= 0 THEN 1 ELSE 0 END) AS CUSTOMER_COST
FROM dbo.customers

		-- FINDING: No zero or negative values in customer_age or customer_acquisition_cost.

-- CHECKING DUPLICATES
	--customers
SELECT customer_id,
	COUNT(customer_id) AS DUPLICATED_DATA
FROM dbo.customers
GROUP BY customer_id
HAVING COUNT(customer_id) > 1

		-- FINDING: 25,000 rows, 0 duplicated customer_id. customer_id is a valid primary key.

-- OUTLIER VALUES
	--customers
SELECT
	MIN(customer_age) AS MINIMUM_AGE,
	MAX(customer_age) AS MAXIMUM_AGE,
	AVG(1.0 * customer_age) AS AVERAGE_AGE        -- 1.0 * prevents integer truncation (45.9, not 45)
FROM dbo.customers

SELECT
	MIN(customer_acquisition_cost) AS MINIMUM_COST,
	MAX(customer_acquisition_cost) AS MAXIMUM_COST,
	AVG(1.0 * customer_acquisition_cost) AS AVERAGE_COST
FROM dbo.customers

WITH KV AS (
    SELECT 
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY customer_age) OVER () AS Q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY customer_age) OVER () AS Q3
    FROM dbo.customers
),
LIMITS AS (
    SELECT DISTINCT 
        Q1, 
        Q3,
        (Q3 - Q1) AS IQR,
        (Q1 - 1.5 * (Q3 - Q1)) AS LOW_LIMIT,
        (Q3 + 1.5 * (Q3 - Q1)) AS HIGH_LIMIT
    FROM KV
)
SELECT c.* 
FROM dbo.customers c
CROSS JOIN LIMITS s
WHERE c.customer_age < s.LOW_LIMIT OR c.customer_age > s.HIGH_LIMIT;

		-- FINDING: No outliers. Age ranges from 18 to 74 (average 45.9) and acquisition cost from
		-- 5.01 to 79.99 (average 42.16). The IQR check on age returns 0 rows.

-- CHECKING TEXTS
	--customers
SELECT customer_segment, COUNT(*) AS COUNT_ROWS FROM dbo.customers 
GROUP BY customer_segment
UNION ALL
SELECT 'SUM', COUNT(*) FROM dbo.customers

-- Leading / trailing spaces.
-- NOTE: in SQL Server  col <> LTRIM(RTRIM(col))  does NOT detect trailing spaces (they are ignored in comparisons),
-- so DATALENGTH is used instead.
SELECT COUNT(*) FROM dbo.customers WHERE DATALENGTH(customer_name)    <> DATALENGTH(LTRIM(RTRIM(customer_name)))
SELECT COUNT(*) FROM dbo.customers WHERE DATALENGTH(customer_segment) <> DATALENGTH(LTRIM(RTRIM(customer_segment)))
SELECT COUNT(*) FROM dbo.customers WHERE DATALENGTH(customer_city)    <> DATALENGTH(LTRIM(RTRIM(customer_city)))
SELECT COUNT(*) FROM dbo.customers WHERE DATALENGTH(customer_country) <> DATALENGTH(LTRIM(RTRIM(customer_country)))
SELECT COUNT(*) FROM dbo.customers WHERE DATALENGTH(customer_state)   <> DATALENGTH(LTRIM(RTRIM(customer_state)))
SELECT COUNT(*) FROM dbo.customers WHERE DATALENGTH(region)           <> DATALENGTH(LTRIM(RTRIM(region)))

-- Upper/lower-case variants (SQL Server is case-insensitive by default, so 'usa' and 'USA' would be
-- merged silently by GROUP BY). If both numbers are equal, there are no case variants.
SELECT COUNT(DISTINCT customer_country) AS CI_COUNT,
       COUNT(DISTINCT customer_country COLLATE Latin1_General_CS_AS) AS CS_COUNT
FROM dbo.customers
SELECT COUNT(DISTINCT customer_segment) AS CI_COUNT,
       COUNT(DISTINCT customer_segment COLLATE Latin1_General_CS_AS) AS CS_COUNT
FROM dbo.customers

SELECT * FROM dbo.customers_clean

		-- FINDING: Text columns are clean. Segments: Consumer 13,638 / Premium 6,301 / VIP 2,542 / Business 2,519
		-- (total 25,000). No leading or trailing spaces and no upper/lower-case variants.


/* =====================================================================
   3. PRODUCTS
   ===================================================================== */

-- NULL
	--products
SELECT COUNT(*)-COUNT(product_id) AS ID, COUNT(*)-COUNT(product_name) AS NAME, COUNT(*)-COUNT(product_category) AS CATEGORY,
       COUNT(*)-COUNT(product_subcategory) AS SUBCAT, COUNT(*)-COUNT(brand) AS BRAND, COUNT(*)-COUNT(supplier) AS SUPPLIER,
       COUNT(*)-COUNT(unit_price) AS PRICE, COUNT(*)-COUNT(product_cost) AS COST, COUNT(*)-COUNT(product_rating) AS RATING
FROM dbo.products

		-- FINDING: No NULL values in any column of the products table.

-- 0 / LOGICAL
SELECT SUM(CASE WHEN unit_price <= 0 THEN 1 ELSE 0 END) AS BAD_PRICE,
       SUM(CASE WHEN product_cost <= 0 THEN 1 ELSE 0 END) AS BAD_COST,
       SUM(CASE WHEN product_cost >= unit_price THEN 1 ELSE 0 END) AS COST_ABOVE_PRICE,
       SUM(CASE WHEN product_rating < 1 OR product_rating > 5 THEN 1 ELSE 0 END) AS BAD_RATING
FROM dbo.products

		-- FINDING: Prices, costs and ratings are valid. Product cost is always below the unit price
		-- (0 products sold at a loss by list price) and ratings stay within 1-5.

-- DUPLICATED ROWS
SELECT product_id, COUNT(*) FROM dbo.products GROUP BY product_id HAVING COUNT(*) > 1
SELECT product_name, COUNT(*) FROM dbo.products GROUP BY product_name HAVING COUNT(*) > 1

		-- FINDING: No duplicated product_id and no duplicated product_name. product_id is a valid primary key.

-- TEXT
SELECT COUNT(DISTINCT product_category) AS CATEGORIES, COUNT(DISTINCT product_subcategory) AS SUBCATS,
       COUNT(DISTINCT brand) AS BRANDS, COUNT(DISTINCT supplier) AS SUPPLIERS FROM dbo.products
SELECT COUNT(*) FROM dbo.products WHERE DATALENGTH(product_name) <> DATALENGTH(LTRIM(RTRIM(product_name)))

		-- FINDING: The catalog has 15 categories, 117 subcategories, 144 brands and 10 suppliers.
		-- No leading or trailing spaces in product names.

-- OUTLIER (IQR) products.unit_price
WITH KV AS (
  SELECT DISTINCT PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY unit_price) OVER () AS Q1,
                  PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY unit_price) OVER () AS Q3
  FROM dbo.products
)
SELECT k.Q1, k.Q3, COUNT(*) AS OUTLIER_ROWS
FROM dbo.products p CROSS JOIN KV k
WHERE p.unit_price < k.Q1 - 1.5*(k.Q3-k.Q1) OR p.unit_price > k.Q3 + 1.5*(k.Q3-k.Q1)
GROUP BY k.Q1, k.Q3

		-- FINDING: 96 products are statistical outliers by price (expensive items). They are real
		-- premium products, not errors, so they are kept.


/* =====================================================================
   4. ORDERS (ORDER ITEMS)
   ===================================================================== */

-- NULL
		--orders
SELECT COUNT(*)-COUNT(order_id) AS ORDER_ID, COUNT(*)-COUNT(product_id) AS PRODUCT_ID, COUNT(*)-COUNT(quantity) AS QTY,
       COUNT(*)-COUNT(unit_price) AS PRICE, COUNT(*)-COUNT(discount_percentage) AS DISC_PCT, COUNT(*)-COUNT(discount_amount) AS DISC_AMT,
       COUNT(*)-COUNT(gross_sales) AS GROSS, COUNT(*)-COUNT(tax_amount) AS TAX, COUNT(*)-COUNT(shipping_cost) AS SHIP,
       COUNT(*)-COUNT(net_sales) AS NET, COUNT(*)-COUNT(product_cost) AS COST, COUNT(*)-COUNT(profit) AS PROFIT
FROM dbo.orders

		-- FINDING: No NULL values in the order items table.

-- 0 / MINUS
SELECT SUM(CASE WHEN quantity <= 0 THEN 1 ELSE 0 END) AS BAD_QTY,
       SUM(CASE WHEN unit_price <= 0 THEN 1 ELSE 0 END) AS BAD_PRICE,
       SUM(CASE WHEN discount_percentage < 0 OR discount_percentage > 1 THEN 1 ELSE 0 END) AS BAD_DISC,
       SUM(CASE WHEN discount_amount < 0 OR tax_amount < 0 OR shipping_cost < 0 THEN 1 ELSE 0 END) AS NEG_AMOUNTS,
       SUM(CASE WHEN profit < 0 THEN 1 ELSE 0 END) AS NEG_PROFIT_LINES
FROM dbo.orders

		-- FINDING: No invalid quantity, price, discount or negative amounts. Discount ranges from 0% to 60%.
		-- 5,426 product lines (1.36%) have negative profit. This is a business finding, not a data error:
		-- the loss comes from very high discounts (analysed later).

-- DUPLICATED ROWS
SELECT order_id, product_id, quantity, unit_price, discount_amount, net_sales, profit, COUNT(*) AS CNT
FROM dbo.orders
GROUP BY order_id, product_id, quantity, unit_price, discount_amount, net_sales, profit
HAVING COUNT(*) > 1

SELECT COUNT(*) AS DUP_PAIRS
FROM (SELECT order_id, product_id FROM dbo.orders GROUP BY order_id, product_id HAVING COUNT(*) > 1) t

		-- FINDING: 0 fully duplicated rows. However, 87 (order_id, product_id) pairs appear more than once
		-- with different values (e.g. different price or discount). They are not exact duplicates,
		-- so they are kept and mentioned as a limitation in the report.


/* =====================================================================
   5. SALES_CUSTOMER (ORDER HEADERS)
   ===================================================================== */

-- NULL
    --sales_customers
SELECT COUNT(*)-COUNT(order_id) AS ORDER_ID, COUNT(*)-COUNT(order_date) AS DATE, COUNT(*)-COUNT(order_status) AS STATUS,
       COUNT(*)-COUNT(customer_id) AS CUSTOMER_ID, COUNT(*)-COUNT(sales_channel) AS CHANNEL, COUNT(*)-COUNT(payment_method) AS PAYMENT,
       COUNT(*)-COUNT(currency) AS CURRENCY, COUNT(*)-COUNT(delivery_days) AS DELIVERY_DAYS, COUNT(*)-COUNT(customer_rating) AS RATING,
       COUNT(*)-COUNT(return_reason) AS RETURN_REASON, COUNT(*)-COUNT(campaign_name) AS CAMPAIGN, COUNT(*)-COUNT(coupon_code) AS COUPON,
       COUNT(*)-COUNT(net_sales) AS NET, COUNT(*)-COUNT(profit) AS PROFIT
FROM dbo.sales_customer

		-- FINDING: Core columns (id, date, status, customer, channel, payment, currency, sales, profit) have 0 NULLs.
		-- Expected NULLs: delivery_days and customer_rating 24,557 / return_reason 128,654 /
		-- campaign_name 83,233 / coupon_code 110,502. They are empty because the event did not happen
		-- (no return, no coupon, no campaign) and are NOT data errors.

-- REASON OF NULLs
SELECT order_status, delivery_status, COUNT(*) AS CNT, COUNT(*)-COUNT(delivery_days) AS NULL_DELIVERY
FROM dbo.sales_customer GROUP BY order_status, delivery_status

		-- FINDING: Delivery data exists ONLY for Completed orders.
		-- Cancelled (8,398) + Pending (6,697) + Returned (9,462) = 24,557 orders have no delivery_days / rating.
		-- Returned orders also carry delivery_status = 'Cancelled', so the question
		-- "does late delivery cause returns?" cannot be answered with this data (limitation).

-- 0 / NEGATIVE
SELECT SUM(CASE WHEN quantity <= 0 THEN 1 ELSE 0 END) AS BAD_QTY,
       SUM(CASE WHEN gross_sales <= 0 OR net_sales <= 0 THEN 1 ELSE 0 END) AS BAD_SALES,
       SUM(CASE WHEN delivery_days < 0 THEN 1 ELSE 0 END) AS NEG_DAYS,
       SUM(CASE WHEN customer_rating < 1 OR customer_rating > 5 THEN 1 ELSE 0 END) AS BAD_RATING
FROM dbo.sales_customer

		-- FINDING: No invalid quantity, sales, delivery days or ratings (all 0).

-- DUPLICATION
SELECT order_id, COUNT(*) FROM dbo.sales_customer GROUP BY order_id HAVING COUNT(*) > 1

		-- FINDING: 138,116 rows, 0 duplicated order_id. order_id is a valid primary key.

-- TEXT
SELECT order_status, COUNT(*) AS CNT FROM dbo.sales_customer GROUP BY order_status
SELECT currency, COUNT(*) AS CNT FROM dbo.sales_customer GROUP BY currency
SELECT payment_status, COUNT(*) AS CNT FROM dbo.sales_customer GROUP BY payment_status
SELECT sales_channel, COUNT(*) AS CNT FROM dbo.sales_customer GROUP BY sales_channel
SELECT payment_method, COUNT(*) AS CNT FROM dbo.sales_customer GROUP BY payment_method
SELECT delivery_status, COUNT(*) AS CNT FROM dbo.sales_customer GROUP BY delivery_status
SELECT marketing_channel, COUNT(*) AS CNT FROM dbo.sales_customer GROUP BY marketing_channel

		-- FINDING: No spelling variants in categorical columns.
		-- order_status: Completed 113,559 / Returned 9,462 / Cancelled 8,398 / Pending 6,697.
		-- 7 currencies: USD, GBP, EUR, CAD, AUD, INR, AED.
		-- delivery_status: On Time 86,916 / Delayed 16,886 / Early 9,757 / Cancelled 24,557.

-- OUTLIER (IQR)  net_sales
WITH KV AS (
  SELECT DISTINCT PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY net_sales) OVER () AS Q1,
                  PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY net_sales) OVER () AS Q3
  FROM dbo.sales_customer
)
SELECT k.Q1, k.Q3, COUNT(*) AS OUTLIER_ROWS
FROM dbo.sales_customer s CROSS JOIN KV k
WHERE s.net_sales < k.Q1 - 1.5*(k.Q3-k.Q1) OR s.net_sales > k.Q3 + 1.5*(k.Q3-k.Q1)
GROUP BY k.Q1, k.Q3

-- OUTLIER (IQR)  profit
WITH KV AS (
  SELECT DISTINCT PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY profit) OVER () AS Q1,
                  PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY profit) OVER () AS Q3
  FROM dbo.sales_customer
)
SELECT k.Q1, k.Q3, COUNT(*) AS OUTLIER_ROWS
FROM dbo.sales_customer s CROSS JOIN KV k
WHERE s.profit < k.Q1 - 1.5*(k.Q3-k.Q1) OR s.profit > k.Q3 + 1.5*(k.Q3-k.Q1)
GROUP BY k.Q1, k.Q3

-- OUTLIER (IQR)  quantity
WITH KV AS (
  SELECT DISTINCT PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY quantity) OVER () AS Q1,
                  PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY quantity) OVER () AS Q3
  FROM dbo.sales_customer
)
SELECT k.Q1, k.Q3, COUNT(*) AS OUTLIER_ROWS
FROM dbo.sales_customer s CROSS JOIN KV k
WHERE s.quantity < k.Q1 - 1.5*(k.Q3-k.Q1) OR s.quantity > k.Q3 + 1.5*(k.Q3-k.Q1)
GROUP BY k.Q1, k.Q3

		-- FINDING: Statistical outliers exist: net_sales 6,435 / profit 6,514 / quantity 1,197 orders.
		-- They are real values (quantity goes up to 24, price varies by product), not errors,
		-- so they are NOT removed.


/* =====================================================================
   6. RELATION QUALITY (orphan records)
   ===================================================================== */
	--customer
SELECT customer_id, COUNT(*) AS cnt
FROM dbo.customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

SELECT DISTINCT s.customer_id FROM dbo.sales_customer s
LEFT JOIN dbo.customers c
ON c.customer_id = s.customer_id
WHERE c.customer_id IS NULL

SELECT DISTINCT s.order_id FROM dbo.sales_customer s
LEFT JOIN dbo.orders o
ON o.order_id = s.order_id
WHERE o.order_id IS NULL

SELECT DISTINCT o.order_id FROM dbo.orders o
LEFT JOIN dbo.sales_customer s
ON o.order_id = s.order_id
WHERE s.order_id IS NULL

SELECT DISTINCT o.product_id FROM dbo.orders o
LEFT JOIN dbo.products p
ON o.product_id = p.product_id
WHERE p.product_id IS NULL

-- Customers who never placed an order
SELECT COUNT(*) AS CUSTOMERS_WITHOUT_ORDERS
FROM dbo.customers c
LEFT JOIN dbo.sales_customer s ON s.customer_id = c.customer_id
WHERE s.customer_id IS NULL

		-- FINDING: No orphan records in any direction (order headers <-> customers, order headers <-> items,
		-- items <-> products). All joins are safe.
		-- 89 of the 25,000 customers never placed an order (24,911 ordering customers); they are kept
		-- by using LEFT JOIN in the customer summary.


/* =====================================================================
   7. NEGATIVE PROFIT
   ===================================================================== */
	-- sales_customer
SELECT COUNT(profit) FROM dbo.sales_customer
WHERE profit < 0
SELECT profit FROM dbo.sales_customer
WHERE profit < 0
SELECT COUNT(*) AS negative_orders,
       SUM(profit) AS total_loss,
       MIN(profit) AS worst_loss,
       AVG(profit) AS avg_loss,
       100.0 * COUNT(*) / (SELECT COUNT(*) FROM dbo.sales_customer) AS pct_of_orders
FROM dbo.sales_customer
WHERE profit < 0;

SELECT COUNT(*) AS invalid_quantity
FROM dbo.sales_customer
WHERE quantity <= 0;

SELECT COUNT(*) AS invalid_discount
FROM dbo.sales_customer
WHERE discount_amount < 0

SELECT order_status, COUNT(*) AS cnt, SUM(profit) AS loss
FROM dbo.sales_customer
WHERE profit < 0
GROUP BY order_status;

SELECT
  CASE WHEN 100.0*discount_amount/gross_sales < 30 THEN '1) 0-30%'
       WHEN 100.0*discount_amount/gross_sales < 40 THEN '2) 30-40%'
       WHEN 100.0*discount_amount/gross_sales < 50 THEN '3) 40-50%'
       WHEN 100.0*discount_amount/gross_sales < 60 THEN '4) 50-60%'
       ELSE '5) 60%+' END AS discount_band,
  COUNT(*) AS orders_count,
  SUM(CASE WHEN profit < 0 THEN 1 ELSE 0 END) AS negative_orders,
  100.0 * SUM(CASE WHEN profit < 0 THEN 1 ELSE 0 END) / COUNT(*) AS negative_pct
FROM dbo.sales_customer
WHERE order_status = 'Completed'
GROUP BY CASE WHEN 100.0*discount_amount/gross_sales < 30 THEN '1) 0-30%'
              WHEN 100.0*discount_amount/gross_sales < 40 THEN '2) 30-40%'
              WHEN 100.0*discount_amount/gross_sales < 50 THEN '3) 40-50%'
              WHEN 100.0*discount_amount/gross_sales < 60 THEN '4) 50-60%'
              ELSE '5) 60%+' END
ORDER BY discount_band;

		-- FINDING: Over-discounting is directly killing profitability.
		-- 1,296 orders (0.94%) have negative profit, a total loss of about -201K (worst single order -1,281.59).
		-- Status split: 1,229 are Completed (about -191K, roughly 0.3% of total profit) and 67 are Pending.
		-- Root cause: excessive discounts, averaging 51.7% on losing orders versus 17.0% on profitable ones.
		-- Loss rate by discount band (Completed orders):
		--   0-30%   -> 0 losing orders (0%)         <- the safe zone
		--   30-40%  -> 29 losing orders (0.3%)
		--   40-50%  -> 461 losing orders (8.6%)
		--   50-60%  -> 675 losing orders (44.3%)
		--   60%+    -> 64 losing orders (59.8%)
		-- RECOMMENDATION: cap discounts at about 40%.


/* =====================================================================
   8. CROSS-TABLE CHECKS (reconciliation, formulas, currency)
   ===================================================================== */

-- 1) MATCHING ORDER HEADERS WITH ORDER ITEMS
WITH IT AS (SELECT order_id, SUM(net_sales) AS ITEM_NET FROM dbo.orders GROUP BY order_id)
SELECT COUNT(*) AS TOTAL_ORDERS,
       SUM(CASE WHEN ABS(s.net_sales - t.ITEM_NET) > 1 THEN 1 ELSE 0 END) AS MISMATCH,
       ROUND(SUM(s.net_sales),0) AS HEADER_NET, ROUND(SUM(t.ITEM_NET),0) AS ITEMS_NET
FROM dbo.sales_customer s JOIN IT t ON s.order_id = t.order_id

		-- FINDING: Order headers and order items do NOT reconcile. 11,226 of 138,116 orders (8.13%) have a
		-- different net_sales; the header is always the smaller one. Totals: headers about 177.1M vs
		-- items about 192.4M. The gap is systematic (about 7-8% in every order status).
		-- DECISION: headline KPIs (revenue, orders, AOV) are taken from sales_customer;
		-- category / product / discount analysis is taken from orders (items).
		-- Category totals are therefore about 8.7% higher than the headline revenue - this is stated in the report.

-- 2) MATCHING WITH FORMULAS
SELECT SUM(CASE WHEN ABS(net_sales - (gross_sales - discount_amount + tax_amount + shipping_cost)) > 0.02 THEN 1 ELSE 0 END) AS NET_FAIL,
       SUM(CASE WHEN ABS(profit - (net_sales - product_cost - shipping_cost)) > 0.02 THEN 1 ELSE 0 END) AS PROFIT_FAIL
FROM dbo.sales_customer

		-- FINDING: Both formulas hold for 100% of orders (0 failures):
		--   net_sales = gross_sales - discount_amount + tax_amount + shipping_cost
		--   profit    = net_sales - product_cost - shipping_cost
		-- NOTE: because net_sales includes tax, the profit figure also counts collected TAX as income
		-- (profit = gross - discount + tax - cost). This makes margins slightly optimistic and is
		-- stated as a limitation in the report.

-- 3) CURRENCY
SELECT currency, COUNT(*) AS ORDERS_CNT, ROUND(AVG(net_sales),0) AS AVG_NET FROM dbo.sales_customer GROUP BY currency

		-- FINDING: 7 currencies exist, but the average order value is similar in every currency (about 1,238-1,384).
		-- INR or AED orders are NOT about 80x or 3.7x larger than USD ones, so the amounts are not in real
		-- local currencies - they are on a common scale.
		-- DECISION: no currency conversion; amounts are summed directly and this is noted in the report.

-- 4) REVENUE RULE (which statuses count as a sale)
SELECT order_status, payment_status, COUNT(*) AS ORDERS_CNT, ROUND(AVG(net_sales),0) AS AVG_NET
FROM dbo.sales_customer
GROUP BY order_status, payment_status
ORDER BY order_status, payment_status

SELECT
  ROUND(SUM(CASE WHEN order_status = 'Completed' THEN net_sales END), 0) AS REVENUE_COMPLETED_ONLY,
  ROUND(SUM(CASE WHEN order_status IN ('Completed','Returned') THEN net_sales END), 0) AS REVENUE_INCL_RETURNED,
  ROUND(SUM(net_sales), 0) AS REVENUE_ALL_STATUSES
FROM dbo.sales_customer

		-- FINDING: Cancelled orders always have payment 'Failed' and Returned orders always 'Refunded'.
		-- 11,306 Completed orders show payment_status 'Pending' (data inconsistency, noted in the report).
		-- Revenue by rule: Completed only about 144.2M / incl. Returned about 157.4M / all statuses about 177.1M.
		-- DECISION: Revenue = order_status 'Completed' only.


/* =====================================================================
   9. CLEAN LAYER (views)
   ===================================================================== */

-- 1) ORDER LEVEL (all statuses kept; filter is applied in each query)
CREATE OR ALTER VIEW dbo.vw_orders_clean AS
SELECT s.*,
       YEAR(x.d)                                AS order_year,
       DATEPART(QUARTER, x.d)                   AS order_quarter,
       MONTH(x.d)                               AS order_month_num,
       DATEFROMPARTS(YEAR(x.d), MONTH(x.d), 1)  AS order_month,
       ((DATEPART(WEEKDAY, x.d) + @@DATEFIRST - 2) % 7) + 1 AS order_weekday,   -- 1 = Monday ... 7 = Sunday
       DATEPART(HOUR, CAST(s.order_time AS time)) AS order_hour,
       c.customer_acquisition_cost,
       CASE WHEN s.order_status = 'Completed' THEN 1 ELSE 0 END AS is_completed,
       CASE WHEN s.profit < 0 THEN 1 ELSE 0 END                 AS is_loss_order,
       100.0 * s.discount_amount / NULLIF(s.gross_sales, 0)     AS discount_pct,
       CASE WHEN 100.0*s.discount_amount/NULLIF(s.gross_sales,0) < 30 THEN '1) 0-30%'
            WHEN 100.0*s.discount_amount/NULLIF(s.gross_sales,0) < 40 THEN '2) 30-40%'
            WHEN 100.0*s.discount_amount/NULLIF(s.gross_sales,0) < 50 THEN '3) 40-50%'
            WHEN 100.0*s.discount_amount/NULLIF(s.gross_sales,0) < 60 THEN '4) 50-60%'
            ELSE '5) 60%+' END                                  AS discount_band
FROM dbo.sales_customer s
CROSS APPLY (SELECT CAST(s.order_date AS date) AS d) x
LEFT JOIN dbo.customers_clean c ON s.customer_id = c.customer_id
GO

-- 2) PRODUCT LEVEL (category, brand, discount analysis)
CREATE OR ALTER VIEW dbo.vw_sales_detail AS
SELECT oi.order_id, oi.product_id, oi.quantity, oi.unit_price, oi.discount_percentage, oi.discount_amount,
       oi.gross_sales, oi.tax_amount, oi.shipping_cost, oi.net_sales, oi.product_cost, oi.profit,
       CASE WHEN oi.profit < 0 THEN 1 ELSE 0 END AS is_loss_line,
       CASE WHEN oi.discount_percentage = 0     THEN '1) 0%'
            WHEN oi.discount_percentage <= 0.10 THEN '2) 0-10%'
            WHEN oi.discount_percentage <= 0.20 THEN '3) 10-20%'
            WHEN oi.discount_percentage <= 0.30 THEN '4) 20-30%'
            WHEN oi.discount_percentage <= 0.40 THEN '5) 30-40%'
            ELSE '6) 40%+' END AS discount_band,
       p.product_name, p.product_category, p.product_subcategory, p.brand, p.supplier,
       s.order_date, s.order_status, s.customer_id, s.region, s.customer_country, s.sales_channel
FROM dbo.orders oi
JOIN dbo.products p       ON oi.product_id = p.product_id
JOIN dbo.sales_customer s ON oi.order_id   = s.order_id
GO

-- 3) CUSTOMER SUMMARY (Completed orders only; customers without orders are kept)
CREATE OR ALTER VIEW dbo.vw_customer_summary AS
SELECT c.customer_id, c.customer_segment, c.customer_country, c.customer_acquisition_cost,
       COUNT(s.order_id)             AS orders,
       COALESCE(SUM(s.net_sales), 0) AS revenue,
       COALESCE(SUM(s.profit), 0)    AS profit,
       MIN(s.order_date)             AS first_order,
       MAX(s.order_date)             AS last_order
FROM dbo.customers_clean c
LEFT JOIN dbo.sales_customer s ON s.customer_id = c.customer_id AND s.order_status = 'Completed'
GROUP BY c.customer_id, c.customer_segment, c.customer_country, c.customer_acquisition_cost
GO

-- 4) MONTHLY SUMMARY (for forecasting in Python)
CREATE OR ALTER VIEW dbo.vw_monthly_summary AS
SELECT order_month, SUM(net_sales) AS revenue, SUM(profit) AS profit, COUNT(*) AS orders
FROM dbo.vw_orders_clean
WHERE is_completed = 1
GROUP BY order_month
GO

-- VIEW CHECKS
SELECT 'vw_orders_clean' AS VIEW_NAME, COUNT(*) AS ROWS_CNT FROM dbo.vw_orders_clean
UNION ALL SELECT 'vw_sales_detail',     COUNT(*) FROM dbo.vw_sales_detail
UNION ALL SELECT 'vw_customer_summary', COUNT(*) FROM dbo.vw_customer_summary
UNION ALL SELECT 'vw_monthly_summary',  COUNT(*) FROM dbo.vw_monthly_summary

-- QUICK KPI TEST
SELECT ROUND(SUM(net_sales),0) AS REVENUE, ROUND(SUM(profit),0) AS PROFIT,
       ROUND(100.0*SUM(profit)/SUM(net_sales),2) AS MARGIN_PCT, COUNT(*) AS ORDERS_CNT
FROM dbo.vw_orders_clean WHERE is_completed = 1

		-- FINDING: The clean layer is ready. Row counts: vw_orders_clean 138,116 / vw_sales_detail 397,569 /
		-- vw_customer_summary 25,000 / vw_monthly_summary 60 (no rows lost or duplicated by the joins).
		-- Headline KPIs (Completed only): revenue about 144.2M, profit about 59.8M, margin 41.44%,
		-- 113,559 orders.


/* =====================================================================
   SUMMARY OF DATA QUALITY FINDINGS (for the README / report)
   ---------------------------------------------------------------------
   1. Structure: 4 tables imported correctly; no orphan records; all primary keys unique.
   2. Cleanliness: no zero/negative values, no text issues, 1 NULL gender (labelled 'Unknown' in customers_clean).
   3. Expected NULLs: delivery/rating (24,557), return reason (128,654), campaign (83,233), coupon (110,502).
   4. Outliers (net_sales, profit, quantity, price) are real values and are kept.
   5. Negative profit: 1,296 orders (0.94%), about -201K, caused by discounts above ~40%.
   6. LIMITATIONS:
        - Order headers vs items differ by ~8% (11,226 orders).
        - Currencies are on a common scale (no conversion).
        - Profit includes tax as income.
        - Delivery data exists only for Completed orders, so delay -> return cannot be measured.
        - 87 repeated (order, product) pairs with different values.
        - 11,306 Completed orders have payment status 'Pending'.
   ===================================================================== */
