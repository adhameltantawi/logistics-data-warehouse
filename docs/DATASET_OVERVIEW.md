# Logistics Operations Database (2022–2024)

## Overview

This project uses the **Logistics Operations Database (2022–2024)**, a realistic logistics dataset published on Kaggle.

The dataset simulates the daily operations of a Class 8 trucking company over a three-year period (2022–2024). It was created using real industry knowledge to provide an operational database suitable for analytics, data warehousing, and data engineering projects.

Unlike simplified tutorial datasets, this dataset contains multiple related tables with realistic business relationships, making it ideal for designing ETL pipelines and dimensional data warehouses.

---

# Dataset Source

- **Source:** Kaggle
- **Dataset:** Logistics Operations Database (2022–2024)
- **Author:** Yogape Rodriguez
- **License:** MIT

---

# Dataset Statistics

| Metric | Value |
|---------|------:|
| Time Period | 2022–2024 |
| Total Tables | 14 |
| Total Records | ~361,000 |
| Geographic Scope | United States |
| Industry | Logistics & Transportation |

---

# Dataset Structure

The dataset consists of three main categories of data.

## 1. Dimension Data

These tables describe business entities.

| Table | Description |
|--------|-------------|
| drivers | Driver information |
| trucks | Fleet information |
| trailers | Trailer inventory |
| customers | Customer accounts |
| facilities | Warehouses and terminals |
| routes | Shipping routes |

---

## 2. Operational Transactions

These tables store daily operational activities.

| Table | Description |
|--------|-------------|
| loads | Shipment bookings |
| trips | Shipment execution |
| fuel_purchases | Fuel transactions |
| maintenance_records | Maintenance history |
| delivery_events | Pickup and delivery events |
| safety_incidents | Safety incidents |

---

## 3. Aggregated Metrics

These tables contain pre-calculated monthly KPIs.

| Table | Description |
|--------|-------------|
| driver_monthly_metrics | Driver performance |
| truck_utilization_metrics | Truck utilization |

---

# Business Process

The operational workflow follows this sequence:

Customer
→ Load
→ Trip
→ Delivery
→ Fuel Consumption
→ Maintenance
→ Performance Analysis

---

# Key Business Entities

The main entities represented in the dataset include:

- Drivers
- Trucks
- Trailers
- Customers
- Routes
- Facilities
- Shipments
- Trips

---

# Data Characteristics

- Multi-table relational dataset
- Fully normalized structure
- Primary and foreign key relationships
- Transactional operational data
- Historical data spanning three years
- Financial metrics
- Geographic information
- Operational KPIs
- Time-series records

---

# Data Types

The dataset contains:

- Strings
- Integers
- Decimal values
- Dates
- DateTime values
- Boolean values
- NULL values

---

# Potential Business Questions

The dataset can answer questions such as:

- Which customers generate the highest revenue?
- Which routes are the most profitable?
- How efficient is each truck?
- Which drivers have the best on-time performance?
- How much is spent on maintenance?
- What is the average fuel cost per trip?
- Which facilities experience the longest delays?
- How does truck age affect maintenance costs?

---

# Purpose in This Project

This dataset is used to build a complete Data Warehouse project, including:

- ETL Pipeline
- Staging Layer
- Data Cleansing
- Data Warehouse
- Star Schema
- Fact and Dimension Tables
- Business KPIs
- Analytical SQL Queries
- Reporting & Dashboards

The objective is to simulate a real-world logistics analytics environment similar to those used in transportation and supply chain companies.
