
/* =============================================================================
SECTION 6: COHORT & RETENTION ANALYSIS

Purpose:
Analyze customer retention and long-term engagement by grouping customers
into cohorts based on their first purchase date and tracking their behavior
over time.

Skills Demonstrated:
- Cohort analysis
- Retention analysis
- Customer lifecycle analysis
- Time-series analysis
- Advanced SQL aggregations
- Customer behavior analytics

Business Value:
Provides insights into customer loyalty, retention performance, and
long-term revenue contribution. Helps identify when customers are most
likely to return, become inactive, or generate the highest lifetime value.
============================================================================= */



/* =============================================================================
Q01. COHORT ANALYSIS

Business Question:
How many customers return after their first purchase month?

Purpose:
Measure customer retention over time by tracking customer activity
across monthly cohorts.

============================================================================= */
WITH first_purchase AS (
    SELECT
        customer_key,
        MIN(DATE_FORMAT(order_date, '%Y-%m')) AS cohort_month
    FROM gold.sales_fact
    WHERE order_date IS NOT NULL
    GROUP BY customer_key),
    
cohort_activity AS (
    SELECT
        f.customer_key,
        f.cohort_month,
        DATE_FORMAT(s.order_date, '%Y-%m') AS purchase_month,
        PERIOD_DIFF(DATE_FORMAT(s.order_date, '%Y%m'), DATE_FORMAT(MIN(s.order_date) OVER (PARTITION BY f.customer_key), '%Y%m')) AS month_number
    FROM first_purchase AS f
    INNER JOIN gold.sales_fact AS s 
    ON f.customer_key = s.customer_key),
    
cohort_size AS (
    SELECT
        cohort_month,
        COUNT(DISTINCT customer_key) AS total_customers
    FROM first_purchase
    GROUP BY cohort_month),
    
retention AS (
    SELECT
        cohort_month,
        month_number,
        COUNT(DISTINCT customer_key) AS returning_customers
    FROM cohort_activity
    GROUP BY cohort_month,
    month_number
)

SELECT
    r.cohort_month,
    cs.total_customers,
    r.month_number,
    r.returning_customers,
    concat(ROUND((r.returning_customers / cs.total_customers) * 100, 2), "%") AS retention_rate
FROM retention AS r
INNER JOIN cohort_size AS cs
ON r.cohort_month = cs.cohort_month
ORDER BY r.cohort_month,
r.month_number;



/* =============================================================================
Q02. RETENTION RATE BY COHORT

Business Question:
What percentage of customers return in each period after acquisition?

Purpose:
Evaluate customer retention performance by calculating retention rates
for each cohort across multiple time periods.

============================================================================= */
WITH first_purchase AS (
    SELECT
        customer_key,
        MIN(order_date) AS first_order_date
    FROM gold.sales_fact
    WHERE order_date IS NOT NULL
    GROUP BY customer_key
),

cohort_activity AS (
    SELECT
        fp.customer_key,
        DATE_FORMAT(fp.first_order_date, '%Y-%m') AS cohort_month,
        PERIOD_DIFF(
            DATE_FORMAT(sf.order_date, '%Y%m'),
            DATE_FORMAT(fp.first_order_date, '%Y%m')
        ) AS month_number
    FROM first_purchase fp
    JOIN gold.sales_fact sf
        ON fp.customer_key = sf.customer_key
),

cohort_size AS (
    SELECT
        DATE_FORMAT(first_order_date, '%Y-%m') AS cohort_month,
        COUNT(DISTINCT customer_key) AS total_customers
    FROM first_purchase
    GROUP BY cohort_month
),

retention AS (
    SELECT
        cohort_month,
        month_number,
        COUNT(DISTINCT customer_key) AS returning_customers
    FROM cohort_activity
    GROUP BY cohort_month, month_number
)

SELECT
    r.cohort_month,
    r.month_number,
    cs.total_customers,
    r.returning_customers,
    ROUND(
        100.0 * r.returning_customers / cs.total_customers,
        2
    ) AS retention_rate_pct
FROM retention r
JOIN cohort_size cs
    ON r.cohort_month = cs.cohort_month
ORDER BY
    r.cohort_month,
    r.month_number;
    
    
    
    /* =============================================================================
Q03. COHORT REVENUE ANALYSIS

Business Question:
How much revenue does each customer cohort generate over time?

Purpose:
Track the long-term revenue contribution of customer cohorts to assess
customer quality and revenue retention.

============================================================================= */
WITH first_purchase AS (
    SELECT
        customer_key,
        MIN(order_date) AS first_order_date
    FROM gold.sales_fact
    GROUP BY customer_key
),

revenue as (
SELECT
    DATE_FORMAT(fp.first_order_date, '%Y-%m') AS cohort_month,
    PERIOD_DIFF(DATE_FORMAT(sf.order_date, '%Y%m'), DATE_FORMAT(fp.first_order_date, '%Y%m')) AS month_number,
    SUM(sf.sales_amount) AS cohort_revenue
FROM first_purchase fp
JOIN gold.sales_fact sf
    ON fp.customer_key = sf.customer_key
    GROUP BY
    cohort_month,
    month_number
ORDER BY
    cohort_month,
    month_number)
    
select
case 
when cohort_month is null then "N/A"
else cohort_month
    end as cohort_month,
case 
when month_number is null then "N/A"
else month_number
   end as month_number,
cohort_revenue
from revenue;




/* =============================================================================
Q04. MARKET BASKET ANALYSIS

Business Question:
Which products are frequently purchased together?

Purpose:
Identify product combinations that commonly appear in the same order
to uncover purchasing patterns and product affinities.

Skills Demonstrated:
- Self Joins
- CTEs
- Aggregation
- Product Affinity Analysis
- Confidence Calculations
- Customer Purchase Pattern Analysis

Business Value:
Supports cross-selling and upselling opportunities, product bundling,
recommendation systems, promotional campaigns, and inventory planning
by understanding customer purchasing behavior.

============================================================================= */
WITH product_pairs AS (
    SELECT
        pa.product_name AS product_A,
        pb.product_name AS product_B,
        COUNT(DISTINCT a.order_number) AS pair_orders
    FROM sales_fact a
    JOIN sales_fact b
        ON a.order_number = b.order_number
       AND a.product_key < b.product_key
    JOIN products_dim pa
        ON a.product_key = pa.product_key
    JOIN products_dim pb
        ON b.product_key = pb.product_key
    GROUP BY pa.product_name, pb.product_name
),

product_counts AS (
    SELECT
        p.product_name,
        COUNT(DISTINCT s.order_number) AS product_orders
    FROM sales_fact s
    JOIN products_dim p
        ON s.product_key = p.product_key
    GROUP BY p.product_name
)

SELECT
    pp.product_A,
    pp.product_B,
    pp.pair_orders,
    ROUND(pp.pair_orders * 1.0 / pc.product_orders, 2) AS confidence
FROM product_pairs pp
JOIN product_counts pc
    ON pp.product_A = pc.product_name
ORDER BY confidence DESC;