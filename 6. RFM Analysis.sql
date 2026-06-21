
/* =============================================================================
SECTION 5: RFM ANALYSIS

Purpose:
Build an industry-standard customer segmentation model using
Recency, Frequency, and Monetary metrics to classify customers
based on their value and engagement.

Skills Demonstrated:
- Advanced customer analytics
- Scoring methodologies
- Customer segmentation frameworks
- Data-driven decision making

Business Value:
Supports personalized marketing strategies, loyalty programs,
and customer retention efforts through actionable customer segments.
============================================================================= */


/* =============================================================================
Q01. RFM ANALYSIS (SCORING MODEL)

Business Question:
How can customers be ranked based on value and engagement?

Description:
Calculates Recency, Frequency, and Monetary (RFM) values for each customer
and assigns scores using NTILE segmentation. These scores are combined into
a single RFM score to rank customers based on overall value.

Purpose:
Transforms raw customer transaction data into a structured scoring model
for customer valuation and prioritization.

============================================================================= */

with RFM_analysis as (
select 
concat(c.customer_name, " ", c.customer_last_name) as full_name,
datediff((select max(order_date) from gold.sales_fact), max(s.order_date)) as recency_days,
count(distinct s.order_number) as frequency,
sum(s.sales_amount) as monetary,
-- Recency: lower days = better = higher score
        NTILE(5) OVER (ORDER BY concat(c.customer_name, " ", c.customer_last_name) ASC)  AS r_score,
        -- Frequency: higher orders = better = higher score
        NTILE(5) OVER (ORDER BY count(distinct s.order_number) DESC)    AS f_score,
        -- Monetary: higher spend = better = higher score
        NTILE(5) OVER (ORDER BY sum(s.sales_amount) DESC)     AS m_score
from gold.sales_fact as s
inner join gold.customers_dim as c
on s.customer_key = c.customer_key
group by c.customer_key,
c.customer_name,
c.customer_last_name),

rfm_combined as (
select 
full_name,
recency_days,
frequency,
monetary,
r_score,
f_score,
m_score,
(r_score + f_score + m_score) as rfm_score
from RFM_analysis)

select 
full_name,
recency_days,
frequency,
monetary,
r_score,
f_score,
m_score,
rfm_score,
CASE
        WHEN rfm_score >= 13 THEN 'Champion'
        WHEN rfm_score >= 10 THEN 'Loyal Customer'
        WHEN rfm_score >= 7  THEN 'Potential Loyalist'
        WHEN rfm_score >= 4  THEN 'At Risk'
        ELSE                      'Lost'
    END AS rfm_segment
from rfm_combined
ORDER BY rfm_score DESC;



/* =============================================================================
Q02. RFM CUSTOMER SEGMENTATION

Business Question:
How can customers be grouped into meaningful behavioral segments?

Description:
Uses RFM scores (Recency, Frequency, Monetary) to classify customers into
behavioral segments such as Champions, Loyal Customers, Potential Loyalists,
At Risk, and Lost Customers based on purchase behavior patterns.

Difference from Q31:
Q31 focuses on scoring customers numerically, while Q32 translates those
scores into actionable business segments.

============================================================================= */

with RFM_analysis as (
select 
concat(c.customer_name, " ", c.customer_last_name) as full_name,
datediff((select max(order_date) from gold.sales_fact), max(s.order_date)) as recency_days,
count(distinct s.order_number) as frequency,
sum(s.sales_amount) as monetary,
-- Recency: lower days = better = higher score
        NTILE(5) OVER (ORDER BY concat(c.customer_name, " ", c.customer_last_name) ASC)  AS r_score,
        -- Frequency: higher orders = better = higher score
        NTILE(5) OVER (ORDER BY count(distinct s.order_number) DESC)    AS f_score,
        -- Monetary: higher spend = better = higher score
        NTILE(5) OVER (ORDER BY sum(s.sales_amount) DESC)     AS m_score
from gold.sales_fact as s
inner join gold.customers_dim as c
on s.customer_key = c.customer_key
group by c.customer_key,
c.customer_name,
c.customer_last_name),

rfm_combined as (
select 
full_name,
recency_days,
frequency,
monetary,
r_score,
f_score,
m_score,
(r_score + f_score + m_score) as rfm_score
from RFM_analysis)

select 
full_name,
recency_days,
frequency,
monetary,
r_score,
f_score,
m_score,
rfm_score,
CASE 
        -- Champions: high on all three
        WHEN r_score = 5 AND f_score = 5 AND m_score = 5 THEN 'Champion'
        -- Loyal: high frequency and monetary
        WHEN f_score >= 4 AND m_score >= 4 THEN 'Loyal Customer'
        -- Potential Loyalist: recent but not frequent yet
        WHEN r_score >= 4 AND f_score < 4 THEN 'Potential Loyalist'
        -- At Risk: used to buy a lot but not recently
        WHEN r_score <= 2 AND f_score >= 3 AND m_score >= 3  THEN 'At Risk'
        ELSE 'Lost Customer'
    END AS customer_segment
FROM rfm_combined
ORDER BY rfm_score DESC;


