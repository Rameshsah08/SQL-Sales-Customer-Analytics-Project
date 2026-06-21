
/* =============================================================================
DATA WAREHOUSE SETUP: GOLD LAYER (STAR SCHEMA MODEL)

Purpose:
This script builds the Gold layer of the data warehouse by creating
dimension and fact tables required for analytics and reporting.

What it does:
- Creates a clean schema (gold) for analytical data
- Builds dimension tables:
  • customers_dim (customer attributes and demographics)
  • products_dim (product details and hierarchy)
- Builds a fact table:
  • sales_fact (transactional sales data)
- Loads data from the warehouse staging layer into structured analytics tables
- Performs basic data quality check for duplicate order numbers

Skills Demonstrated:
- Data warehousing (Medallion / Bronze-Silver-Gold architecture)
- Star schema design (Fact + Dimension modeling)
- ETL process (Extract, Transform, Load)
- Data modeling for analytics
- Data quality validation

Business Value:
Creates a structured and optimized analytical layer that supports
reporting, dashboards, and advanced analytics such as customer
segmentation, sales performance tracking, and forecasting.
============================================================================= */


USE DataWarehouseAnalytics;

-- Create Schemas
drop schema if exists gold;
CREATE SCHEMA gold;
use gold;


-- ====================== create table  gold.dim_customers =================
drop table if exists  gold.customers_dim;
CREATE TABLE gold.customers_dim(
    customer_key int,
	customer_id int,
	customer_number varchar(100),
	customer_name varchar(50),
	customer_last_name varchar(50),
	country varchar(50),
	marital_status varchar(50),
	gender varchar(50),
	birthdate date,
	create_date date
);


-- ======================== indert data into customer_dim table from  gold layer ==========================
insert into gold.customers_dim (customer_key, customer_id, customer_number,customer_name,customer_last_name, country, marital_status, gender, birthdate, create_date)
SELECT
    customer_key,
    customer_id,
    customer_number,
    customer_name,
    customer_last_name,
    country,
    marital_status,
    gender,
    birthdate,
    create_date
FROM warehouse.gold_dim_customer;



-- ================= create table gold.products_dim ====================
drop table if exists gold.products_dim;

CREATE TABLE gold.products_dim(
	product_key int ,
	product_id int ,
	product_number varchar(50) ,
	product_name varchar(50) ,
	category_id varchar(50) ,
	category varchar(50) ,
	subcategory varchar(50) ,
	maintenance varchar(50) ,
	cost double,
	product_line varchar(50),
	start_date date 
);

-- ====================== insert data into products_dim table from gold layer ========================= 
insert into gold.products_dim (product_key, product_id, product_number, product_name, category_id, category, subcategory, maintenance, cost, product_line, start_date)
select 
product_key,
product_id, 
product_number, 
product_name, 
category_id, 
category, 
subcategory, 
maintenance, 
cost, 
product_line, 
start_date
from warehouse. gold_dim_product;



-- ============================ create table gold.sales_fact ==========================
drop table if exists gold.sales_fact;
CREATE TABLE gold.sales_fact(
	order_number varchar(50),
	product_key int,
	customer_key int,
	order_date date,
	shipping_date date,
	due_date date,
	sales_amount double,
	quantity int,
	price double
);

-- ================== insert data into sales_fact from gold layer ======================
insert into gold.sales_fact(order_number, product_key, customer_key, order_date, shipping_date, due_date, sales_amount, quantity, price)
select 
order_number, 
product_key, 
customer_key, 
order_date, 
shipping_date, 
due_date, 
sales_amount, 
quantity, 
price
from warehouse.gold_fact_sales;


-- ================== verify ============
select count(order_number) from gold.sales_fact
group by order_number
having count(order_number) >1;

