
/* =============================================================================
SECTION 2: PRODUCT PERFORMANCE ANALYSIS

Purpose:
Evaluate product performance by identifying top-selling products,
underperforming products, category contributions, seasonal trends,
and product purchasing patterns.

Skills Demonstrated:
- Product analytics
- Ranking and segmentation
- Pareto (80/20) analysis
- Seasonal trend analysis
- Market basket analysis

Business Value:
Helps optimize inventory, pricing strategies, product promotions,
and product portfolio decisions.
============================================================================= */



/* =============================================================================
Q3. TOP 01 PRODUCTS BY REVENUE

Business Question:
Which products generate the most revenue?

Description:
Calculates total revenue for each product and identifies the top 10
revenue-generating products. This analysis helps determine which products
have the greatest impact on overall business performance.
============================================================================= */
select 
p.product_name,
concat("£", sum(s.sales_amount)) as total_sales
from gold.sales_fact as s
left join gold.products_dim as p
on s.product_key = p.product_key
group by p.product_name
order by total_sales desc
limit 10;



/* =============================================================================
Q02. PRODUCTS WITH THE HIGHEST SALES VOLUME

Business Question:
Which products sell the most units?

Description:
Measures product demand by calculating the total quantity sold for each
product. This analysis highlights the most frequently purchased products
and helps distinguish high-volume products from high-revenue products.
============================================================================= */
select 
p.subcategory,
p.product_name,
sum(s.quantity) as total_units_sold
from gold.sales_fact as s
left join gold.products_dim as p
on s.product_key = p.product_key
group by
 p.subcategory,
p.product_name
order by total_units_sold desc;



/* =============================================================================
Q03. PARETO ANALYSIS (80/20 RULE)

Business Question:
Which products contribute 80% of total revenue?

Description:
Calculates each product's revenue contribution and cumulative revenue
percentage to identify the products responsible for the majority of sales.
This analysis helps prioritise key products that drive business revenue.
============================================================================= */
WITH product_revenue AS (
    SELECT
        p.product_name,
        SUM(s.sales_amount) AS total_revenue
    FROM gold.sales_fact s
    JOIN gold.products_dim p
        ON s.product_key = p.product_key
    GROUP BY p.product_name
),
revenue_analysis AS (
    SELECT
        product_name,
        total_revenue,
        ROUND(
            total_revenue * 100 /
            SUM(total_revenue) OVER (),
            2
        ) AS revenue_pct,
        ROUND(
            SUM(total_revenue) OVER (
                ORDER BY total_revenue DESC
            ) * 100 /
            SUM(total_revenue) OVER (),
            2
        ) AS cumulative_pct
    FROM product_revenue
)
SELECT *
FROM revenue_analysis
WHERE cumulative_pct <= 80
ORDER BY total_revenue DESC;




/* =============================================================================
Q04. PRODUCT REVENUE RANKING WITHIN CATEGORY

Business Question:
How does each product rank against competitors within its category?

Description:
Ranks products by revenue within each category using window functions.
This analysis provides a competitive view of product performance and
identifies category leaders and underperforming products.
============================================================================= */
with product_revenue as (
select 
p.product_name,
p.category,
sum(s.sales_amount) as total_sales
from sales_fact as s
left join products_dim as p
on s.product_key = p.product_key
group by p.product_name,
p.category)

select 
product_name,
category,
total_sales,
Rank() over(partition by category order by total_sales desc) as product_rank
from product_revenue;



/* =============================================================================
Q05. TOP 3 PRODUCTS IN EACH CATEGORY

Business Question:
Which products are the best performers within each category?

Description:
Identifies the three highest-revenue products in every category based on
sales performance. This analysis highlights category leaders and supports
inventory, marketing, and product portfolio decisions.
============================================================================= */
with product_revenue as (
select 
p.product_name,
p.category,
sum(s.sales_amount) as total_sales
from sales_fact as s
left join products_dim as p
on s.product_key = p.product_key
group by p.product_name,
p.category),

ranked as (
select 
product_name,
category,
total_sales,
Rank() over(partition by category order by total_sales desc) as product_rank
from product_revenue)

select 
* from ranked
where  product_rank <= 3;



/* =============================================================================
Q06. SEASONAL PRODUCT ANALYSIS

Business Question:
Which products consistently peak during specific months of the year?

Description:
Analyzes monthly sales patterns for each product and compares monthly
performance against the product's average sales level. Products are
classified as Peak Season, High Season, Low Season, or Normal to identify
seasonal demand trends and purchasing behavior.

Business Value:
Supports demand forecasting, inventory planning, procurement decisions,
and seasonal marketing strategies by identifying predictable sales cycles.
============================================================================= */
WITH monthly_product_sales AS (
    SELECT
        p.product_name,
        p.category,
        MONTH(s.order_date)  AS month_number,
        DATE_FORMAT(s.order_date, '%M') AS month_name,
        YEAR(s.order_date) AS sale_year,
        COUNT(DISTINCT s.order_number) AS sales_count,
        ROUND(SUM(s.sales_amount), 2) AS monthly_sales
    FROM sales_fact AS s
    INNER JOIN products_dim AS p ON s.product_key = p.product_key
    WHERE s.order_date IS NOT NULL
    GROUP BY 
        p.product_key,
        p.product_name,
        p.category,
        MONTH(s.order_date),
        DATE_FORMAT(s.order_date, '%M'),
        YEAR(s.order_date)
),
avg_monthly_sales AS (
    SELECT
        product_name,
        category,
        month_number,
        month_name,
        SUM(sales_count)  AS total_orders,
        ROUND(AVG(sales_count), 0) AS avg_monthly_orders,
        ROUND(SUM(monthly_sales), 2) AS total_monthly_sales,
        ROUND(AVG(monthly_sales), 2) AS avg_sales
    FROM monthly_product_sales
    GROUP BY 
        product_name,
        category,
        month_number,
        month_name
),
overall_avg AS (
    SELECT
        product_name,
        ROUND(AVG(avg_sales), 2) AS overall_avg_sales
    FROM avg_monthly_sales
    GROUP BY product_name
)
SELECT
    a.product_name,
    a.category,
    a.month_name,
    a.month_number,
    a.total_orders,
    a.avg_monthly_orders,
    a.total_monthly_sales,
    a.avg_sales,
    o.overall_avg_sales,
    ROUND(((a.avg_sales - o.overall_avg_sales)
          / NULLIF(o.overall_avg_sales, 0)) * 100, 2) AS pct_above_avg,
    CASE
        WHEN a.avg_sales >= o.overall_avg_sales * 1.5 THEN 'Peak Season'
        WHEN a.avg_sales >= o.overall_avg_sales * 1.2 THEN 'High Season'
        WHEN a.avg_sales <= o.overall_avg_sales * 0.5 THEN 'Low Season'
        ELSE                                               'Normal'
    END AS season_flag
FROM avg_monthly_sales AS a
INNER JOIN overall_avg AS o ON a.product_name = o.product_name
ORDER BY a.product_name, a.month_number;