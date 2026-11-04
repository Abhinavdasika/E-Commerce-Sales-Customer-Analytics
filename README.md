# E-Commerce Sales & Customer Analytics

## Project Overview

This project analyzes the Brazilian E-Commerce Public Dataset by Olist using **MySQL 8.0**. The objective is to explore e-commerce sales, customer behavior, product performance, payment methods, customer reviews, and delivery operations through SQL queries.

The project includes data cleaning, database preparation, data quality validation, and business analysis.

## Tools & Technologies

- MySQL 8.0
- MySQL Workbench
- Python
- Pandas
- SQL

## Dataset Information

The project uses the Olist Brazilian E-Commerce Public Dataset.

| Dataset Table | Records |
|---|---:|
| Customers | 99,441 |
| Sellers | 3,095 |
| Products | 32,951 |
| Category Translation | 71 |
| Orders | 99,441 |
| Order Items | 112,650 |
| Payments | 103,886 |
| Reviews | 99,224 |
| **Total Records** | **650,759** |

## Database Structure

The project uses eight relational tables:

1. Customers
2. Sellers
3. Products
4. Category Translation
5. Orders
6. Order Items
7. Payments
8. Reviews

Primary keys, foreign keys, and indexes were created to maintain data integrity and improve query performance.

## Data Preparation & Validation

Python and Pandas were used for initial data profiling and preparation.

The following activities were performed:

- Standardized column names.
- Corrected inconsistent column naming.
- Converted date columns into appropriate datetime formats.
- Investigated missing values.
- Checked duplicate records.
- Validated primary key uniqueness.
- Checked foreign key relationships.
- Imported processed CSV files into MySQL.

### Data Quality Findings

- All eight tables were imported successfully.
- Duplicate checks returned zero for the tested customer, order, product, and seller IDs.
- Checked foreign key relationships had zero invalid references.
- Missing order dates, product attributes, and review comments were investigated.
- Nine zero-value payment records were identified and retained for investigation.
- Fourteen delivered orders had missing approval timestamps. Their payment records existed, so the original timestamps were not fabricated.

## Key Business Findings

### 1. Order Analysis

| Metric | Result |
|---|---:|
| Total Orders | 99,441 |
| Delivered Orders | 96,478 |
| Canceled Orders | 625 |
| Shipped Orders | 1,107 |
| Delivered Order Rate | 97.02% |
| Cancellation Rate | 0.63% |

The delivered order rate represents the share of all orders with delivered status, not the on-time delivery rate.

### 2. Payment Method Analysis

| Payment Method | Payment Records | Recorded Payment Value |
|---|---:|---:|
| Credit Card | 76,795 | 12,542,084.19 |
| Boleto | 19,784 | 2,869,361.27 |
| Voucher | 5,775 | 379,436.87 |
| Debit Card | 1,529 | 217,989.79 |
| Not Defined | 3 | 0.00 |

Credit cards accounted for the highest recorded payment value.

### 3. Customer Review Analysis

| Review Score | Reviews | Percentage |
|---|---:|---:|
| 1 Star | 11,424 | 11.51% |
| 2 Stars | 3,151 | 3.18% |
| 3 Stars | 8,179 | 8.24% |
| 4 Stars | 19,142 | 19.29% |
| 5 Stars | 57,328 | 57.78% |

- Total review records: 99,224
- Average review score: 4.09 / 5
- Reviews without written comments: 58,247

Most recorded reviews received a five-star rating.

### 4. Delivery Performance

| Metric | Result |
|---|---:|
| Delivered Orders with Valid Dates | 96,470 |
| Average Delivery Time | 12.50 Days |
| Minimum Delivery Time | 0 Days |
| Maximum Delivery Time | 210 Days |
| Average Days vs Estimated Date | -11.88 Days |
| Delivered After Estimate | 7,826 |
| Delivered On or Before Estimate | 88,644 |

Approximately 91.89% of delivered orders with an estimated delivery date arrived on or before the estimated date.

### 5. Seller Analysis

The highest-ranked seller in the sales analysis recorded:

- Product Sales: 229,472.63
- Total Orders: 1,132
- Items Sold: 1,156

## SQL Analysis Performed

The project includes SQL queries for:

1. Database and table validation.
2. Duplicate record checks.
3. Primary key and foreign key validation.
4. Missing value analysis.
5. Payment data quality checks.
6. Payment and order-item value reconciliation.
7. Overall business KPIs.
8. Monthly sales analysis.
9. Product category performance.
10. Customer geographical analysis.
11. Payment method analysis.
12. Customer review analysis.
13. Delivery performance analysis.
14. Top seller analysis.

## Key SQL Concepts Used

- SELECT and WHERE
- GROUP BY and ORDER BY
- Aggregate functions
- INNER JOIN and LEFT JOIN
- Subqueries
- Common Table Expressions (CTEs)
- CASE statements
- Date functions
- NULL handling
- Data validation
- Conditional aggregation

## How to Run the Project

1. Install MySQL Server 8.0 and MySQL Workbench.
2. Download the Olist dataset from its original Kaggle source.
3. Create the `ecommerce_analytics` database.
4. Import the eight CSV files into their respective tables.
5. Open `olist_ecommerce_analysis.sql` in MySQL Workbench.
6. Execute the SQL queries and review the result grids.

**Note:** The SQL analysis script assumes that the database tables have already been created and populated.

## Project Outcomes

Through this project, I gained practical experience in:

- Working with a real-world relational dataset.
- Database creation and table relationships.
- SQL data validation and quality checks.
- Writing multi-table JOIN queries.
- Performing business analysis using SQL.
- Analyzing sales, payments, customers, products, and delivery operations.

## Dataset Source

Olist Brazilian E-Commerce Public Dataset – Kaggle.

The dataset is anonymized and contains historical Brazilian e-commerce transactions. Please refer to the original dataset listing for licensing and attribution requirements.

**Note:** Raw dataset files are not included in this repository.

---

**Author:** Abhinav Dasika

**Project:** E-Commerce Sales & Customer Analytics

**Technology:** MySQL | SQL | Python | Pandas
