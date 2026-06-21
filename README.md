# 📊 SQL Sales & Customer Analytics Project

Welcome to my **SQL Sales & Customer Analytics** repository! 🚀
This project takes the business-ready **Gold layer** data produced by my earlier [SQL Data Warehouse Project](https://github.com/Rameshsah08/SQL_Data_Warehouse_Project) and uses it to deliver actionable sales, product, and customer insights. Built as a **portfolio project** to showcase my SQL analytics and business problem-solving skills.

---

## 🏗️ Architecture

The architecture follows a simple three-stage flow, sitting on top of the **Medallion (Bronze/Silver/Gold)** warehouse from the upstream project:

1. **Source Data (Gold Layer)**: Pre-built `customers_dim`, `products_dim`, and `sales_fact` tables, produced by the upstream [SQL Data Warehouse Project](https://github.com/Rameshsah08/SQL_Data_Warehouse_Project).
2. **Analytics Data Model**: A dedicated `gold` schema in this project holding a star schema (1 fact table + 2 dimension tables) purpose-built for analytics.
3. **Business Analytics Modules**: Six SQL scripts, each answering a set of business questions using the model above.

4. <img width="896" height="1167" alt="Archicture" src="https://github.com/user-attachments/assets/4431cb02-47dd-4438-8e31-f7e698daad04" />


---

## 📂 Repository Structure

```
sql-sales-customer-analytics/
├── Documentation
  - Architecture.png                               # Architecture diagram (image)
  - Business Questions                             # List of the all questions those used in this project
  - Data Warehouse.png                             # data_warehouse Architectuure diagram
  - Project_Architcture_draw.oi.png                # Architecture diagram (editable draw.io source)
├── 1. Create table and insert data.sql            # Builds the gold schema & loads data from the warehouse
├── 2. Sales_Analysis.sql                          # Section 1 — Sales performance
├── 3. Products_Analysis.sql                       # Section 2 — Product performance
├── 4. Customer Analytics.sql                      # Section 3 — Customer behavior
├── 5. Customer Segmentation & Churn Analysis.sql  # Section 4 — Segmentation & churn
├── 6. RFM Analysis.sql                            # Section 5 — RFM scoring & segmentation
├── 7. Cohort & Retention Analysis.sql             # Section 6 — Cohort, retention & market basket
├── README.md                                      # Project overview and instructions
└── LICENSE                                        # License information for the repository
```

## 🗂️ Data Model

**Source → New Schema:** Gold layer tables from the upstream warehouse are copied into three new tables inside a dedicated `gold` schema.

| Upstream Warehouse Table | New `gold` Schema Table |
|---|---|
| `gold_dim_customers` | `gold.customers_dim` |
| `gold_dim_products` | `gold.products_dim` |
| `gold_fact_sales` | `gold.sales_fact` |

**Star schema:** `gold.sales_fact` (fact) ↔ `gold.customers_dim` / `gold.products_dim` (dimensions)

| Table | Key Columns | Description |
|---|---|---|
| `customers_dim` | `customer_key` (PK) | Customer demographics: name, country, gender, marital status, birthdate, signup date |
| `products_dim` | `product_key` (PK) | Product catalog: name, category, subcategory, cost, product line |
| `sales_fact` | `order_number`, `product_key` (FK), `customer_key` (FK) | Transaction-level sales: order/shipping/due dates, quantity, price, sales amount |

---

## 📖 Project Overview

This project demonstrates a production-style SQL analytics layer built on top of business-ready Gold layer data, covering the full analytics lifecycle — from loading warehouse output into a clean analytics schema to delivering business-ready insights for reporting and decision-making.

🔷What I Built

1. **Schema & Data Load** — Created a new `gold` analytics schema and inserted business-ready data from the upstream warehouse's Gold layer, with a duplicate-order data quality check.
2. **Star Schema Modeling** — Reused a clean fact + dimension model (`sales_fact`, `customers_dim`, `products_dim`) optimized for fast, reliable analytical queries.
3. **Business Analytics & Reporting** — Wrote SQL-based reports uncovering insights across sales performance, product performance, customer behaviour, segmentation & churn, RFM scoring, and cohort/retention to support strategic business decisions.

🎯 Skills Demonstrated:
SQL Development |
Data Modeling |
Customer Analytics |
Product Analytics |
RFM Segmentation |
Cohort & Retention Analysis |
Churn Analysis |
Sales Forecasting

---

## 🛠️ Tools & Technologies

Everything used in this project is **free and open-source!**

- **[SQL Data Warehouse Project](https://github.com/Rameshsah08/SQL_Data_Warehouse_Project):** Upstream project — source of the Gold layer data used here.
- **[MySQL Community Server](https://dev.mysql.com/downloads/mysql/):** Free, open-source relational database for hosting the analytics schema.
- **[MySQL Workbench](https://dev.mysql.com/downloads/workbench/):** Official GUI for designing, managing, and querying the MySQL database.
- **[Git & GitHub](https://github.com/):** Version control and collaboration for managing project code efficiently.
- **[Draw.IO](https://app.diagrams.net/):** Design the architecture diagram.

---

## 🚀 Project Requirements

### Building the Analytics Schema

#### Objective
Build an analytics-ready `gold` schema using **MySQL**, populated from the upstream data warehouse's Gold layer, to enable SQL-based reporting and analysis.

#### Specifications
- **Data Source**: Import `gold_dim_customers`, `gold_dim_products`, and `gold_fact_sales` from the upstream warehouse's Gold layer into new `gold.customers_dim`, `gold.products_dim`, and `gold.sales_fact` tables.
- **Schema**: Create a new, dedicated `gold` analytics schema, independent of the upstream warehouse schema.
- **Data Quality**: Validate for duplicate order numbers after loading.
- **Documentation**: Provide clear documentation of the data model for both business stakeholders and analytics teams.

---

### BI: Analytics & Reporting (Data Analysis)

#### Objective
Develop SQL-based analytics to deliver detailed insights into:
- **Sales Performance**
- **Product Performance**
- **Customer Behavior**
- **Customer Segmentation & Churn**
- **RFM (Recency, Frequency, Monetary) Scoring**
- **Cohort & Retention Trends**

These insights empower stakeholders with key business metrics, enabling strategic decision-making.

---

## 📈 Business Analytics Modules

Each module below is its own SQL script. For every one, I've outlined **why** I built it, **what** the queries actually do, and the **business value** it delivers.

### 3.1 Sales Performance Analysis — `Sales_Analysis.sql`

**Purpose:** Analyze overall business performance by tracking revenue, orders, sales trends, growth rates, anomalies, and future sales projections.

**What I Did:**
- **KPIs & Overview** — sized the dataset (total customers, products, orders) and calculated total revenue & quantity sold
- **Revenue Trends** — built the monthly sales trend and identified the highest-revenue year
- **Growth Analysis** — calculated month-over-month sales growth %, flagged the month with the highest growth, and classified each month as increasing/decreasing/stable
- **Ranking & Contribution** — computed average order value (AOV) and running (cumulative) total sales over time
- **Anomaly Detection** — used average + standard deviation bounds to flag months with unusually high or low sales
- **Forecasting** — built 3- and 6-month moving averages and used historical growth rates to project near-term sales

**Business Value:** Provides management with insights into revenue growth, sales patterns, and future business performance.

---

### 3.2 Product Performance Analysis — `Products_Analysis.sql`

**Purpose:** Evaluate product performance by identifying top-selling products, underperforming products, category contributions, seasonal trends, and product purchasing patterns.

**What I Did:**
- **Top Products** — ranked products by total revenue and by units sold (volume) to separate high-revenue products from high-demand products
- **Pareto Analysis** — applied the 80/20 rule to find the smaller set of products generating 80% of total revenue
- **Product Ranking** — ranked every product within its category and pulled out the top 3 performers per category
- **Seasonality Analysis** — compared each product's monthly sales to its own yearly average to flag Peak Season / High Season / Low Season / Normal months

**Business Value:** Helps optimize inventory, pricing strategies, product promotions, and product portfolio decisions.

> Note: market basket analysis (product affinity) is logically part of this module, but the query lives in `Cohort & Retention Analysis.sql` — see Section 3.6 below.

---

### 3.3 Customer Behavior Analysis — `Customer Analytics.sql`

**Purpose:** Understand customer behavior by measuring customer value, purchase frequency, recency, lifespan, and purchasing journeys.

**What I Did:**
- **Customer Overview** — found the top 10 customers by spend, tracked monthly active customers, and flagged customers inactive for 6+ months
- **Customer Value (CLV)** — calculated each customer's total orders, total spend, average order value, and first/last purchase dates; also identified above-average spenders and customers who purchase every year
- **Customer Lifespan** — measured the days/months/years between a customer's first and last purchase and segmented them into One-time / Short-term / Mid-term / Long-term buyers
- **Recency Analysis** — calculated days since last purchase and segmented customers into Active / At Risk / Slipping Away / Churned
- **Purchase Frequency** — calculated orders-per-month and segmented customers into Frequent / Regular / Occasional / One-time buyers
- **Average Order Value & Demographics** — calculated AOV and average customer age, and broke down revenue by age group

**Business Value:** Identifies valuable customers, purchasing patterns, and opportunities to improve customer engagement and retention.

---

### 3.4 Customer Segmentation & Retention Analysis — `Customer Segmentation & Churn Analysis.sql`

**Purpose:** Segment customers based on purchasing behavior and identify customers at risk of churn to support retention strategies.

**What I Did:**
- **VIP Customers** — segmented every customer into VIP / Regular / New based on total spend and customer lifespan
- **Top 5% Customers** — used `PERCENT_RANK()` to isolate the top 5% of customers by total spend for priority retention/marketing
- **Repeat Purchase Rate** — measured the split between one-time buyers and repeat buyers across the whole customer base
- **Churn Risk Analysis** — segmented customers into Active / Cooling Down / At Risk / High Risk / Churned based on days since their last order
- **Customer Journey Timeline** — mapped each customer's 1st through 4th purchase dates to visualize how their relationship with the business progresses

**Business Value:** Enables targeted marketing campaigns, customer retention initiatives, and efficient allocation of customer relationship resources.

---

### 3.5 RFM Analysis — `RFM Analysis.sql`

**Purpose:** Build an industry-standard customer segmentation model using Recency, Frequency, and Monetary metrics to classify customers based on their value and engagement.

**What I Did:**
- **RFM Scoring** — calculated Recency (days since last order), Frequency (distinct orders), and Monetary (total spend) per customer, then scored each on a 1–5 scale using `NTILE(5)`
- **RFM Segmentation** — combined the three scores into a single RFM score and mapped it to business segments: Champion, Loyal Customer, Potential Loyalist, At Risk, and Lost

**Business Value:** Supports personalized marketing strategies, loyalty programs, and customer retention efforts through actionable customer segments.

---

### 3.6 Cohort & Retention Analysis — `Cohort & Retention Analysis.sql`

**Purpose:** Analyze customer retention and long-term engagement by grouping customers into cohorts based on their first purchase date and tracking their behavior over time.

**What I Did:**
- **Cohort Analysis** — grouped customers into monthly cohorts by first-purchase month and tracked how many of each cohort returned in subsequent months
- **Retention Rate by Cohort** — calculated the % of each cohort still active in each period after acquisition, using `PERIOD_DIFF` to align cohorts on a common timeline
- **Cohort Revenue Analysis** — tracked how much revenue each acquisition cohort generated over its lifetime
- **Market Basket Analysis** — used a self-join on orders to find which products are frequently bought together, with a confidence score for each pair

**Business Value:** Provides insights into customer loyalty, retention performance, and long-term revenue contribution. Helps identify when customers are most likely to return, become inactive, or generate the highest lifetime value.

---

## ⚙️ Getting Started

Follow these steps to set up and run the project on your local machine:

1. **Install MySQL Community Server** from [mysql.com](https://dev.mysql.com/downloads/mysql/)
2. **Install MySQL Workbench** from [mysql.com](https://dev.mysql.com/downloads/workbench/)
3. **Build the upstream warehouse first** — clone and run the [SQL Data Warehouse Project](https://github.com/Rameshsah08/SQL_Data_Warehouse_Project) so the `warehouse` schema (`gold_dim_customers`, `gold_dim_products`, `gold_fact_sales`) exists.
4. **Clone this repository:**
   ```bash
   git clone https://github.com/Rameshsah08/SQL_Sales_Customer_Analytics_Project.git
   ```
5. **Open MySQL Workbench** and connect to your local MySQL server.
6. **Run scripts in order:**
   ```sql
   USE DataWarehouseAnalytics;

   -- Build the gold schema (quote the path — the filename contains spaces)
   SOURCE 'Create table and insert data.sql';

   -- Run any analysis module
   USE gold;
   SOURCE 'Sales_Analysis.sql';
   ```
7. **Explore the analytics** by running each module script query-by-query.

---

## 🌟 About Me

Hi there! I'm Ramesh Sah, a Computer Science student at the University for the Creative Arts, Farnham, passionate about turning raw data into meaningful insights. I'm actively building my portfolio through hands-on projects in SQL, data engineering, and analytics — with the goal of landing a job or internship in the data industry.
This project is part of my personal portfolio to demonstrate real-world SQL analytics skills to potential employers.
Feel free to check out my work and connect with me:

[![GitHub](https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/Rameshsah08)
[![Linkdln](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/feed/)
[![Gmail](https://img.shields.io/badge/Gmail-D14836?style=for-the-badge&logo=gmail&logoColor=white)](mailto:rameshk9271746@gmail.com)

---

## 🛡️ License

This project is licensed under the [MIT License](LICENSE). You are free to use, modify, and share this project with proper attribution.
