# 📊 SQL Analytics Suite: Sales & User Behavior
### Google BigQuery | Advanced SQL Development

## 📖 Project Overview
This repository contains a professional SQL-based sales analysis project executed in **Google BigQuery**. The project is built on a relational database schema consisting of three core entities: **Users**, **Products**, and **Orders**.

The primary objective of this project was to implement and demonstrate advanced SQL techniques for business intelligence, moving beyond simple queries into complex analytical patterns like **Window Functions**, **Common Table Expressions (CTEs)**, and **Multi-table Joins**.

## 🛠️ The Data Schema
The project is structured around a classic E-commerce/Retail relational model:
* **Users Table:** Contains customer demographics and account creation metadata.
* **Products Table:** Inventory data including categories, pricing, and stock levels.
* **Orders Table:** Transactional records linking users to products with timestamps and volume.



## 🚀 SQL Techniques Implemented
To extract meaningful business insights, I utilized the following advanced BigQuery features:

### 1. Advanced Analytical Joins
* Integrated all three tables to create a "Master Sales View."
* Utilized **INNER** and **LEFT JOINS** to analyze user-product affinity and identify "orphan" products that haven't sold.

### 2. Window Functions (Analytical Power)
* **Ranking:** Used `ROW_NUMBER()` and `DENSE_RANK()` to identify the top 3 best-selling products per category.
* **Running Totals:** Implemented `SUM(amount) OVER(ORDER BY date)` to track cumulative revenue growth over time.
* **Moving Averages:** Created a 7-day rolling average for sales volume to smooth out daily fluctuations.

### 3. Common Table Expressions (CTEs)
* Used the `WITH` clause to create modular, readable code.
* Structured multi-step transformations where raw data is first cleaned, then aggregated, and finally filtered in a single execution block.

### 4. Strategic Business Queries
* **Cohort Analysis:** Grouping users by their sign up month to track retention.
* **Product Performance:** Identifying high-value categories vs. high-volume categories.


## 📂 Repository Contents
```text
├── SQL_Scripts/
│   ├── Sales_Schema_Query.sql             # Script to create the 3-table schema
│   ├── Uploaded_Sales_Dataset_Query.sql   # General analysis and joins
└── README.md
