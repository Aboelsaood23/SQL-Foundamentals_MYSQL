# 🗄️ MySQL Sales Ecosystem: From DDL to Stored Procedures
### Comprehensive Database Engineering & Business Logic

## 📖 Project Overview
This project serves as a deep dive into the **MySQL** ecosystem, focusing on the end-to-end creation and management of a relational database. It simulates a retail environment—`sales_database`—consisting of interconnected tables for customers, products, stores, and transactions.

The core strength of this project lies in its **procedural logic**, demonstrating how to automate business calculations using Stored Procedures and custom Functions.

## 🛠️ Relational Data Model
The database is built on a four-table schema designed for referential integrity:
* **Customers:** Demographic tracking (Name, Gender, City).
* **Products:** Inventory catalog categorized by type (Electronics, Clothing, etc.) with decimal pricing precision.
* **Stores:** Geographic distribution across different US regions (East Coast, Midwest, Far West).
* **Sales:** The central fact table linking all entities through foreign keys to track units sold and total transaction amounts.


## 🚀 Technical Highlights & MySQL Statements
This script implements a wide array of MySQL features:

### 1. Data Definition & Manipulation (DDL/DML)
* **Schema Evolution:** Extensive use of `ALTER TABLE` and `MODIFY COLUMN` to refine data types (e.g., adjusting `decimal` precision for financial accuracy).
* **Data Ingestion:** Batch `INSERT` statements for hundreds of realistic records across all tables.

### 2. Advanced Business Logic
The project goes beyond simple queries to include reusable programming blocks:
* **Stored Procedures with Parameters:** * `sum_total_by_state`: Aggregates sales based on a specific input state.
    * `sum_total_by_state_2parameters`: Utilizes both `IN` and `OUT` parameters to fetch product pricing into variables.
* **Custom Functions:** * `total_sales_by_produt`: A deterministic function that returns the total revenue for a specific product name.
* **Control Structures:** Implementation of `DELIMITER` changes and `DECLARE` statements to handle complex procedural blocks.

### 3. Reporting & Aggregation
* **Joins & Having:** Multi-table joins combined with `GROUP BY` and `HAVING` clauses to filter aggregated results for specific business regions.
* **Financial Calculations:** Use of aggregate functions like `SUM()` and `COUNT()` to generate high-level performance metrics.

## 📂 Repository Contents
```text
├── SQL_FOUNDAMENTALS.sql   # Master script containing Schema, Data, and Procedures
└── README.md                # Project documentation
