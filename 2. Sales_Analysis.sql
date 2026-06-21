
/* =============================================================================
SECTION 1: SALES PERFORMANCE ANALYSIS

Purpose:
Analyze overall business performance by tracking revenue, orders, sales trends,
growth rates, anomalies, and future sales projections.

Skills Demonstrated:
- Aggregations and KPI calculations
- Time-series analysis
- Window functions
- Trend analysis
- Business performance reporting

Business Value:
Provides management with insights into revenue growth, sales patterns,
and future business performance.
============================================================================= */


/* =============================================================================
Q1. DATABASE OVERVIEW

Business Question:
How many customers, products, and orders exist in the database?

Description:
Provides a high-level overview of the business by measuring the size of
the customer base, product catalog, and sales transactions. This serves
as a foundation for understanding the scale of the dataset and business
operations.
============================================================================= */

-- customers table
select count(customer_key) as total_customers
from customers_dim;

-- products table
select count(product_key) as total_products
from gold.products_dim;

-- sales table
select count(order_number) as total_orders
from gold.sales_fact;



/* =============================================================================
Q2. TOTAL SALES & QUANTITY SOLD

Business Question:
What are the total sales and total quantity sold?

Description:
Calculates overall revenue and units sold across all transactions to
measure business performance and provide key baseline performance metrics.
============================================================================= */
select 
sum(quantity) as total_quantity,
concat("£", sum(sales_amount)) as total_sales
from gold.sales_fact;



/* =============================================================================
Q3. MONTHLY SALES TREND

Business Question:
How do sales perform over time?

Description:
Aggregates sales revenue by month and year to identify revenue trends,
seasonality, and changes in business performance over time.
============================================================================= */
select 
year(order_date) as order_year,
month(order_date) as order_month,
sum(sales_amount) as total_sales
from sales_fact
where order_date is not null
group by 
year(order_date),
month(order_date)
order by 
order_year,
order_month;



/* =============================================================================
Q4. HIGHEST REVENUE YEAR

Business Question:
Which year generated the highest revenue?

Description:
Compares annual sales performance to identify the most successful year
and evaluate long-term business growth trends.
============================================================================= */
select 
year(order_date) as order_year,
sum(sales_amount) as total_revenue
from sales_fact
where order_date is not null
group by 
year(order_date)
order by total_revenue desc;



/* =============================================================================
Q5. AVERAGE ORDER VALUE (AOV)

Business Question:
How much revenue does an average order generate?

Description:
Measures the average value of customer transactions by dividing total
revenue by the number of unique orders. This KPI helps evaluate customer
spending behavior and sales efficiency.
============================================================================= */
select 
round(sum(sales_amount)/count( distinct order_number), 2) as average_order_value
from sales_fact;



/* =============================================================================
Q6. HIGHEST MONTHLY SALES GROWTH

Business Question:
Which month experienced the highest sales growth?

Description:
Calculates month-over-month sales growth and identifies the period with
the strongest revenue increase, helping uncover successful business
events, campaigns, or seasonal demand spikes.
============================================================================= */
WITH monthly_sales AS (
    SELECT
        DATE_FORMAT(order_date, '%Y-%m') AS sales_month,
        SUM(sales_amount) AS total_sales
    FROM gold.sales_fact
    WHERE order_date IS NOT NULL
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
),
monthly_growth AS (
    SELECT
        sales_month,
        total_sales,
        LAG(total_sales) OVER (ORDER BY sales_month) AS previous_month_sales,
        concat(ROUND(
            (total_sales - LAG(total_sales) OVER (ORDER BY sales_month))
            / LAG(total_sales) OVER (ORDER BY sales_month) * 100,
            2
        ), "%") AS growth_rate
    FROM monthly_sales
)
SELECT
    sales_month,
    total_sales,
    previous_month_sales,
    growth_rate
FROM monthly_growth
WHERE previous_month_sales IS NOT NULL
ORDER BY growth_rate DESC
LIMIT 1;




/* =============================================================================
Q7. REVENUE BY AGE GROUP

Business Question:
Which age groups contribute the most revenue?

Description:
Segments customers into age groups and measures their revenue contribution
to identify the most valuable customer demographics and support targeted
marketing strategies.
============================================================================= */
SELECT
    CASE 
        WHEN TIMESTAMPDIFF(YEAR, c.birthdate, d.max_date) < 20 THEN 'Under 20'
        WHEN TIMESTAMPDIFF(YEAR, c.birthdate, d.max_date) BETWEEN 20 AND 29 THEN '20-29'
        WHEN TIMESTAMPDIFF(YEAR, c.birthdate, d.max_date) BETWEEN 30 AND 39 THEN '30-39'
        WHEN TIMESTAMPDIFF(YEAR, c.birthdate, d.max_date) BETWEEN 40 AND 49 THEN '40-49'
        ELSE '50+'
    END AS age_group,
    SUM(s.sales_amount) AS total_revenue
FROM gold.sales_fact s
JOIN gold.customers_dim c
    ON s.customer_key = c.customer_key
CROSS JOIN (
    SELECT MAX(order_date) AS max_date
    FROM gold.sales_fact
) d
GROUP BY age_group
ORDER BY total_revenue DESC;



/* =============================================================================
Q8. RUNNING TOTAL SALES

Business Question:
How does cumulative revenue grow over time?

Description:
Calculates cumulative sales revenue across consecutive months to visualize
business growth and track overall revenue progression.
============================================================================= */

WITH monthly_sales AS (
    SELECT
        DATE_FORMAT(order_date, '%Y-%m') AS sales_month,
        SUM(sales_amount) AS total_sales
    FROM sales_fact
    WHERE order_date IS NOT NULL
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
)
SELECT
    sales_month,
    total_sales,
    SUM(total_sales) OVER (
        ORDER BY sales_month
    ) AS running_total_sales
FROM monthly_sales
ORDER BY sales_month;




/* =============================================================================
Q9. MONTH-OVER-MONTH SALES GROWTH

Business Question:
How much do sales increase or decrease each month?

Description:
Measures the percentage change in sales between consecutive months to
evaluate growth trends, business momentum, and performance fluctuations.
============================================================================= */

WITH monthly_sales AS (
    SELECT
        DATE_FORMAT(order_date, '%Y-%m') AS sales_month,
        SUM(sales_amount) AS monthly_sales,
        lag(SUM(sales_amount)) over(order by  DATE_FORMAT(order_date, '%Y-%m')) as previous_sales
    FROM sales_fact
    WHERE order_date IS NOT NULL
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
)
select 
sales_month,
monthly_sales,
 previous_sales,
 ROUND(
    CASE 
        WHEN previous_sales IS NULL OR previous_sales = 0 THEN NULL
        ELSE ((monthly_sales - previous_sales) / previous_sales) * 100
    END, 2) AS sales_growth
from  monthly_sales ;




/* =============================================================================
Q10. MONTHLY SALES COMPARISON

Business Question:
How does each month's performance compare to the previous month?

Description:
Compares monthly sales against the previous month and classifies trends
as increasing, decreasing, or stable, providing a simple view of revenue
movement over time.
============================================================================= */

WITH monthly_sales AS (
    SELECT
        DATE_FORMAT(order_date, '%Y-%m') AS sales_month,
        SUM(sales_amount) AS monthly_sales,
        lag(SUM(sales_amount)) over(order by  DATE_FORMAT(order_date, '%Y-%m')) as previous_sales
    FROM sales_fact
    WHERE order_date IS NOT NULL
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
)
select 
sales_month,
monthly_sales,
 previous_sales,
 ROUND(
    CASE 
        WHEN previous_sales IS NULL OR previous_sales = 0 THEN NULL
        ELSE ((monthly_sales - previous_sales) / previous_sales) * 100
    END, 2) AS sales_growth,
    
    case when monthly_sales > previous_sales then "sales increase"
    when monthly_sales < previous_sales then "sales decrease"
    else "No previous data"
    end as sales_trend
from  monthly_sales;



/* =============================================================================
Q11. SALES ANOMALY DETECTION

Business Question:
Which months had unusually high or low sales?

Description:
Uses average sales and standard deviation to identify months whose sales
performance significantly deviates from normal business activity. This
analysis helps detect exceptional events, unexpected demand spikes, or
potential business issues.
============================================================================= */

WITH monthly_sales AS (
    SELECT
        DATE_FORMAT(s.order_date, '%Y-%m') AS sales_month,
        YEAR(s.order_date) AS sale_year,
        MONTH(s.order_date) AS month_number,
        DATE_FORMAT(s.order_date, '%M') AS month_name,
        COUNT(DISTINCT s.order_number) AS total_orders,
        ROUND(SUM(s.sales_amount), 2)  AS total_sales
    FROM sales_fact AS s
    WHERE s.order_date IS NOT NULL
    GROUP BY
        DATE_FORMAT(s.order_date, '%Y-%m'),
        YEAR(s.order_date),
        MONTH(s.order_date),
        DATE_FORMAT(s.order_date, '%M')
),
sales_stats AS (
    SELECT
        ROUND(AVG(total_sales), 2) AS avg_sales,
        ROUND(STDDEV(total_sales), 2) AS stddev_sales,
        ROUND(AVG(total_sales) + (2 * STDDEV(total_sales)), 2) AS upper_bound,
        ROUND(AVG(total_sales) - (2 * STDDEV(total_sales)), 2) AS lower_bound
    FROM monthly_sales
)
SELECT
    m.sales_month,
    m.sale_year,
    m.month_name,
    m.total_orders,
    m.total_sales,
    s.avg_sales,
    s.stddev_sales,
    s.upper_bound,
    s.lower_bound,
    ROUND(m.total_sales - s.avg_sales, 2) AS deviation_from_avg,
    ROUND(((m.total_sales - s.avg_sales) 
          / NULLIF(s.avg_sales, 0)) * 100, 2) AS pct_deviation,
    CASE
        WHEN m.total_sales > s.upper_bound  THEN 'Unusually High'
        WHEN m.total_sales < s.lower_bound  THEN 'Unusually Low'
        ELSE 'Normal'
    END AS anomaly_flag
FROM monthly_sales AS m
CROSS JOIN sales_stats AS s
ORDER BY m.sales_month;



/* =============================================================================
Q12. SALES FORECASTING

Business Question:
What are the expected future sales based on historical trends?

Description:
Uses moving averages and historical growth rates to estimate future sales
performance and evaluate business growth trends. This analysis supports
planning, budgeting, and forecasting activities.
============================================================================= */
WITH monthly_sales AS (
    SELECT
        DATE_FORMAT(s.order_date, '%Y-%m') AS sales_month,
        YEAR(s.order_date) AS sale_year,
        MONTH(s.order_date) AS month_number,
        DATE_FORMAT(s.order_date, '%M') AS month_name,
        COUNT(DISTINCT s.order_number) AS total_orders,
        ROUND(SUM(s.sales_amount), 2) AS total_sales
    FROM sales_fact AS s
    WHERE s.order_date IS NOT NULL
    GROUP BY
        DATE_FORMAT(s.order_date, '%Y-%m'),
        YEAR(s.order_date),
        MONTH(s.order_date),
        DATE_FORMAT(s.order_date, '%M')
),
moving_avg AS (
    SELECT
        sales_month,
        sale_year,
        month_name,
        total_orders,
        total_sales,
        LAG(total_sales, 1) OVER 
            (ORDER BY sales_month) AS prev_month_sales,
        ROUND(AVG(total_sales) OVER (
            ORDER BY sales_month
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS moving_avg_3months,
        ROUND(AVG(total_sales) OVER (
            ORDER BY sales_month
            ROWS BETWEEN 5 PRECEDING AND CURRENT ROW), 2) AS moving_avg_6months
    FROM monthly_sales
),
growth_rate AS (
    SELECT
        sales_month,
        sale_year,
        month_name,
        total_orders,
        total_sales,
        prev_month_sales,
        moving_avg_3months,
        moving_avg_6months,
        ROUND(((total_sales - prev_month_sales) / NULLIF(prev_month_sales, 0)) * 100, 2) AS mom_growth_rate
    FROM moving_avg
),
avg_growth AS (
    SELECT
        ROUND(AVG(mom_growth_rate), 2) AS avg_growth_rate
    FROM growth_rate
    WHERE mom_growth_rate IS NOT NULL
)
SELECT
    g.sales_month,
    g.month_name,
    g.total_orders,
    g.total_sales,
    g.prev_month_sales,
    g.moving_avg_3months,
    g.moving_avg_6months,
    g.mom_growth_rate,
    a.avg_growth_rate,
    ROUND(g.moving_avg_3months * (1 + (a.avg_growth_rate / 100)), 2) AS forecast_moving_avg,
    ROUND(g.total_sales * (1 + (a.avg_growth_rate / 100)), 2) AS forecast_growth_rate,
    CASE
        WHEN g.mom_growth_rate > 0  THEN 'Growing'
        WHEN g.mom_growth_rate < 0  THEN 'Declining'
        ELSE 'Stable'
    END AS sales_trend
FROM growth_rate AS g
CROSS JOIN avg_growth AS a
ORDER BY g.sales_month;    
    
    
    
    
