# 📊 SQL Sales & Customer Analytics Project
 
Welcome to my **SQL Sales & Customer Analytics** repository! 🚀
This project takes the business-ready **Gold layer** data produced by my earlier [SQL Data Warehouse Project](https://github.com/Rameshsah08/SQL_Data_Warehouse_Project) and uses it to deliver actionable sales, product, and customer insights. Built as a **portfolio project** to showcase my SQL analytics and business problem-solving skills.
 
---
 
## 🏗️ Architecture
 
The architecture follows a simple three-stage flow, sitting on top of the **Medallion (Bronze/Silver/Gold)** warehouse from the upstream project:

<img width="1011" height="572" alt="Data Warehouse Diagram drawio (1)(1)" src="https://github.com/user-attachments/assets/8304abf6-cf02-4392-aaa6-092e5d942f25" />


1. **Source Data (Gold Layer)**: Pre-built `customers_dim`, `products_dim`, and `sales_fact` tables, produced by the upstream [SQL Data Warehouse Project](https://github.com/Rameshsah08/SQL_Data_Warehouse_Project).
2. **Analytics Data Model**: A dedicated `gold` schema in this project holding a star schema (1 fact table + 2 dimension tables) purpose-built for analytics.
3. **Business Analytics Modules**: Six SQL scripts, each answering a set of business questions using the model above.

4. <img width="1024" height="1334" alt="Archicture" src="https://github.com/user-attachments/assets/dc064a8b-d2ee-409c-b036-1d532419dd0e" />

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
- **[DrawIO](https://app.diagrams.net/):** Design the architecture diagram (`PROJECT_3.drawio`).
---
 
## 🚀 Project Requirements
 
### Building the Analytics Schema (Data Engineering)
 
#### Objective
Build an analytics-ready `gold` schema using **MySQL**, populated from the upstream data warehouse's Gold layer, to enable SQL-based reporting and analysis.
 
#### Specifications
- **Data Source**: Import `customers_dim`, `products_dim`, and `sales_fact` from the upstream warehouse's Gold layer.
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
 
## 📂 Repository Structure
 
```
sql-sales-customer-analytics/
│
├── Create table and insert data.sql            # Builds the gold schema & loads data from the warehouse
├── Sales_Analysis.sql                          # Section 1 — Sales performance
├── Products_Analysis.sql                       # Section 2 — Product performance
├── Customer Analytics.sql                      # Section 3 — Customer behavior
├── Customer Segmentation & Churn Analysis.sql   # Section 4 — Segmentation & churn
├── RFM Analysis.sql                             # Section 5 — RFM scoring & segmentation
├── Cohort & Retention Analysis.sql              # Section 6 — Cohort, retention & market basket
│
├── Archicture.png                               # Architecture diagram (image)
├── PROJECT_3.drawio                             # Architecture diagram (editable draw.io source)
├── README.md                                    # Project overview and instructions
└── LICENSE                                      # License information for the repository
```
 
---
 
## ⚙️ Getting Started
 
Follow these steps to set up and run the project on your local machine:
 
1. **Install MySQL Community Server** from [mysql.com](https://dev.mysql.com/downloads/mysql/)
2. **Install MySQL Workbench** from [mysql.com](https://dev.mysql.com/downloads/workbench/)
3. **Build the upstream warehouse first** — clone and run the [SQL Data Warehouse Project](https://github.com/Rameshsah08/SQL_Data_Warehouse_Project) so the `warehouse` schema (`gold_dim_customer`, `gold_dim_product`, `gold_fact_sales`) exists.
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
