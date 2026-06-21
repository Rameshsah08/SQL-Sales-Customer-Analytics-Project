/* =============================================================================
SECTION 4: CUSTOMER SEGMENTATION & CHURN ANALYSIS

Purpose:
Segment customers based on purchasing behavior and identify
customers at risk of churn to support retention strategies.

Skills Demonstrated:
- Customer segmentation
- Business rule implementation
- Churn analysis
- Customer retention metrics
- Strategic customer profiling

Business Value:
Enables targeted marketing campaigns, customer retention initiatives,
and efficient allocation of customer relationship resources.
============================================================================= */


/* =============================================================================
Q01. CUSTOMER SEGMENTATION (VIP / REGULAR / NEW)

Business Question:
How can customers be grouped based on value and behavior?

Description:
Segments customers based on total spending and purchase history to classify
them into VIP, Regular, or New customers. This helps identify high-value
customers and distinguish them from low-engagement customers.

============================================================================= */

with customer_segmentation as (
select 
concat(c.customer_name, " ", c.customer_last_name) as customer_full_name,
round(sum(s.sales_amount), 2) as total_spend,
count(s.order_number) as total_order,
MIN(DATE_FORMAT(s.order_date, '%Y-%m-%d')) AS first_purchase_date,
MAX(DATE_FORMAT(s.order_date, '%Y-%m-%d')) AS last_purchase_date,
datediff(MAX(DATE_FORMAT(s.order_date, '%Y-%m-%d')), MIN(DATE_FORMAT(s.order_date, '%Y-%m-%d'))) as lifespan_days
from sales_fact as s
inner join customers_dim as c
on s.customer_key = c.customer_key
group by 
c.customer_key,
c.customer_name,
c.customer_last_name)

select 
customer_full_name,
total_spend,
total_order,
first_purchase_date,
last_purchase_date,
lifespan_days,
case 
when total_spend >= 10000 then "Vip"
when total_spend >= 1000 and lifespan_days > 180 then "Regular"
else "New"
end as customer_segment
from customer_segmentation
order by total_spend desc;




/* =============================================================================
Q02. TOP 5% HIGH-VALUE CUSTOMERS

Business Question:
Which customers contribute the most revenue?

Description:
Ranks customers using percentile ranking based on total spending and
identifies the top 5% highest-value customers for retention and marketing
prioritization.

============================================================================= */

with customer_spending as (
select 
concat(c.customer_name, " ", c.customer_last_name) as full_name,
round(sum(s.sales_amount), 2) as total_spend,
count(distinct s.order_number) as total_order
from sales_fact as s
inner join customers_dim as c
on s.customer_key = c.customer_key
group by c.customer_key,
c.customer_name,
c.customer_last_name),

percentile_ranking as (
select 
full_name,
total_spend,
total_order,
round(percent_rank() over(order by total_spend desc), 5) as pct_rank
from  customer_spending)

select 
full_name,
total_spend,
total_order,
pct_rank
from percentile_ranking
where pct_rank <= 0.05
order by total_spend desc;




/* =============================================================================
Q03. REPEAT PURCHASE RATE

Business Question:
How many customers make repeat purchases?

Description:
Calculates the proportion of customers who have made more than one order
compared to total customers, along with one-time vs repeat buyer distribution.

============================================================================= */

WITH customer_orders AS (
    SELECT 
        c.customer_key,
        COUNT(DISTINCT s.order_number) AS total_orders
    FROM sales_fact AS s
    INNER JOIN customers_dim AS c ON c.customer_key = s.customer_key
    GROUP BY c.customer_key
)
SELECT
    COUNT(customer_key) AS total_customers,
    SUM(total_orders) AS total_orders,
    SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END) AS repeat_customers,
    SUM(CASE WHEN total_orders = 1 THEN 1 ELSE 0 END)  AS one_time_customers,
    concat(ROUND(SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END) / COUNT(customer_key) * 100, 2), "%") AS repeat_purchase_rate,
    concat(ROUND(SUM(CASE WHEN total_orders = 1 THEN 1 ELSE 0 END) / COUNT(customer_key) * 100, 2), "%") AS one_time_purchase_rate
FROM customer_orders;




/* =============================================================================
Q04. CHURN RISK ANALYSIS

Business Question:
Which customers are at risk of stopping purchases?

Description:
Measures customer inactivity based on time since last purchase and segments
customers into Active, Cooling Down, At Risk, High Risk, and Churned groups.
This helps identify customers who are likely to stop purchasing.

============================================================================= */

with customers_risk as (
select 
concat(customer_name, " ", customer_last_name) as full_name,
max(s.order_date) as last_purchase_date,
(select max(order_date) from gold.sales_fact) as cur_date,
datediff((select max(order_date) from gold.sales_fact), max(s.order_date)) as days_since_purchase,
count(distinct s.order_number) as total_order,
sum(s.sales_amount) as total_spend
from customers_dim as c
inner join sales_fact as s
on s.customer_key = c.customer_key
group by 
c.customer_key,
c.customer_name,
c.customer_last_name)

select 
full_name,
last_purchase_date,
cur_date,
days_since_purchase,
total_order,
total_spend,
CASE
WHEN days_since_purchase <= 30  THEN 'Active'
WHEN days_since_purchase <= 60  THEN 'Cooling Down'
WHEN days_since_purchase <= 90  THEN 'At Risk'
WHEN days_since_purchase <= 180 THEN 'High Risk'
ELSE                                 'Churned'
    END AS churn_status
from customers_risk
order by days_since_purchase;



/* =============================================================================
Q05. CUSTOMER JOURNEY TIMELINE

Business Question:
What does the customer purchase journey look like over time?

Description:
Tracks the sequence of purchases per customer using row numbering and
pivots the first few transactions (1st to 4th purchase) to visualize
customer lifecycle progression.

============================================================================= */

WITH journey_timeline AS (
    SELECT 
        c.customer_key,
        CONCAT(c.customer_name, " ", c.customer_last_name) AS customer_full_name,
        s.order_date,
        ROW_NUMBER() OVER (PARTITION BY c.customer_key ORDER BY s.order_date) AS purchase_number
    FROM customers_dim c
    INNER JOIN sales_fact s
        ON c.customer_key = s.customer_key
    WHERE s.order_date IS NOT NULL
)

SELECT 
    customer_key,
    customer_full_name,
    MAX(CASE WHEN purchase_number = 1 THEN order_date END) AS first_purchase,
    MAX(CASE WHEN purchase_number = 2 THEN order_date END) AS second_purchase,
    MAX(CASE WHEN purchase_number = 3 THEN order_date END) AS third_purchase,
    MAX(CASE WHEN purchase_number = 4 THEN order_date END) AS fourth_purchase
FROM journey_timeline
GROUP BY 
    customer_key,
    customer_full_name
ORDER BY 
    customer_key;