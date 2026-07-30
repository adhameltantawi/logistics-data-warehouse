# Logistics Data Warehouse - AI Generation Prompt

*This document contains a comprehensive "mega-prompt" designed to instruct a Large Language Model (like Claude, ChatGPT, or Gemini) to recreate this entire data warehouse project from scratch.*

---

## The Mega-Prompt

Copy and paste the text below into your AI assistant to generate the project:

```markdown
# Context & Persona
Act as a Senior Data Engineer and Data Architect. Your task is to design and build an end-to-end enterprise-grade "Logistics Data Warehouse" using Microsoft SQL Server (T-SQL). You must follow the Medallion Architecture (Bronze -> Silver -> Gold) and implement a strict Star Schema in the final layer.

# Project Overview
I have a realistic dataset for a Class 8 trucking company (years 2022-2024). The data consists of 14 CSV files (approximately 361,000 records). 
I need you to write modular, production-ready SQL scripts to ingest, cleanse, and model this data for a Business Intelligence (BI) dashboard.

# Dataset Schema Summary
The source data contains the following tables:
1. **Reference Data:** `drivers`, `trucks`, `trailers`, `customers`, `facilities`, `routes`
2. **Transactional Data:** `loads`, `trips`, `fuel_purchases`, `maintenance_records`, `delivery_events`, `safety_incidents`
3. **Analytics (Pre-aggregated):** `driver_monthly_metrics`, `truck_utilization_metrics`

# Requirements by Phase

Please generate the SQL scripts organized into the following phases. Each phase should use Stored Procedures (`CREATE PROCEDURE`) and follow idempotent design patterns (truncate and load). Separate DDL (Table Creation) from DML (Data Loading).

## Phase 1: Database Setup & Bronze Layer (Raw)
1. Create a script to initialize the database `logistics_dwh` and create three schemas: `bronze`, `silver`, `gold`.
2. Write DDL scripts to create all 14 tables in the `bronze` schema. All columns must be `NVARCHAR` and `NULLable` to prevent ingestion failures.
3. Write Stored Procedures using `BULK INSERT` to load data from local CSV paths into the `bronze` tables. Include `TRY/CATCH` blocks and log the execution time and row counts.

## Phase 2: Silver Layer (Cleansed)
1. Write DDL scripts for the 14 tables in the `silver` schema with appropriate data types (INT, DATE, DECIMAL, etc.). Add an audit column `dwh_create_date` to every table.
2. Write Stored Procedures to move data from `bronze` to `silver`. During this step, you must:
   - `TRIM()` all string columns.
   - Convert status/flag columns to `UPPER()`.
   - Handle NULLs appropriately.
   - Deduplicate rows based on their primary keys using `ROW_NUMBER()`.
   - Cast strings to correct numeric/date types, replacing invalid negative values with NULL.

## Phase 3: Gold Layer (Star Schema)
1. Design a dimensional model (Star Schema). Write DDL to create 7 Dimension tables and 5 Fact tables in the `gold` schema.
2. **Dimensions:** `dim_driver`, `dim_truck`, `dim_trailer`, `dim_customer`, `dim_facility`, `dim_route`, and a generated `dim_date` (spanning 2020-2030).
   - Use `INT IDENTITY(1,1)` for surrogate keys.
   - Retain the natural keys (e.g., `driver_id`).
   - Add derived columns (e.g., `full_name` from first and last name, `truck_age_years`).
3. **Facts:** `fact_trip`, `fact_fuel_purchase`, `fact_maintenance`, `fact_safety`, `fact_delivery`.
   - Fact tables must use the surrogate keys from the dimension tables.
   - Calculate derived metrics during the load (e.g., `total_revenue`, `total_damage_cost`).

## Phase 4: Data Quality & Testing
Generate a suite of SQL testing scripts to validate the data at each layer:
1. **Silver Tests:** Write scripts to check for NULLs in mandatory fields, ensure primary key uniqueness, and validate numeric ranges (e.g., distance > 0).
2. **Gold Tests:** Write scripts to verify referential integrity (no orphaned foreign keys in fact tables) and reconcile row counts between Silver and Gold.

## Phase 5: Documentation & Presentation
1. **README:** Write a highly professional `README.md` explaining the Medallion architecture, data flow, and engineering decisions (why stored procs, why truncate/load).
2. **ER Diagram:** Provide the code for a Mermaid.js Entity-Relationship diagram showing how the Star Schema is connected.
3. **Dashboard Presentation:** Define the 13 critical KPIs and 12 charts that a Power BI dashboard should display based on this Gold layer. Include strategic business recommendations.

# Engineering Constraints
- Use robust T-SQL syntax compatible with SQL Server 2022.
- Do not use emojis in your documentation.
- Every stored procedure must print its start time, end time, and rows affected.
- Keep the code modular. Do not give me one massive script; break it down logically by layer and table group.

Please start by providing the Database Initialization and Bronze Layer scripts.
```
