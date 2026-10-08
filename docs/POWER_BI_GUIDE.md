# Power BI Dashboard — Connection & Setup Guide

## Overview

The Gold layer Star Schema is designed to plug directly into Power BI. This guide walks you through connecting Power BI Desktop to `logistics_dwh` and building the first dashboard.

---

## Prerequisites

- **Power BI Desktop** — [Download free](https://powerbi.microsoft.com/desktop/)
- **SQL Server connector** — bundled with Power BI Desktop (no extra install)
- The Gold layer must be loaded: `EXEC gold.load_gold;`

---

## Step 1 — Connect Power BI to SQL Server

1. Open **Power BI Desktop**
2. Click **Home → Get Data → SQL Server**
3. Enter your server details:

| Field | Value |
|---|---|
| **Server** | `.` or `localhost` (or your server name) |
| **Database** | `logistics_dwh` |
| **Data Connectivity mode** | `Import` (recommended for <1M rows) |

4. Click **OK → Connect**

---

## Step 2 — Import the Gold Layer Tables

In the Navigator, select these tables (tick all):

**Dimension Tables:**
- `gold.dim_driver`
- `gold.dim_truck`
- `gold.dim_trailer`
- `gold.dim_customer`
- `gold.dim_facility`
- `gold.dim_route`
- `gold.dim_date`

**Fact Tables:**
- `gold.fact_trip`
- `gold.fact_fuel_purchase`
- `gold.fact_maintenance`
- `gold.fact_safety`
- `gold.fact_delivery`

**KPI Views (optional — pre-aggregated for faster reports):**
- `gold.vw_driver_performance`
- `gold.vw_route_profitability`
- `gold.vw_fleet_utilization`
- `gold.vw_fuel_efficiency`

Click **Load**.

---

## Step 3 — Define Relationships (Model View)

Power BI should auto-detect most relationships. Verify these in **Model View**:

| From (Fact) | From Column | To (Dimension) | To Column |
|---|---|---|---|
| `fact_trip` | `driver_key` | `dim_driver` | `driver_key` |
| `fact_trip` | `truck_key` | `dim_truck` | `truck_key` |
| `fact_trip` | `trailer_key` | `dim_trailer` | `trailer_key` |
| `fact_trip` | `customer_key` | `dim_customer` | `customer_key` |
| `fact_trip` | `route_key` | `dim_route` | `route_key` |
| `fact_trip` | `dispatch_date_key` | `dim_date` | `date_key` |
| `fact_fuel_purchase` | `driver_key` | `dim_driver` | `driver_key` |
| `fact_fuel_purchase` | `truck_key` | `dim_truck` | `truck_key` |
| `fact_fuel_purchase` | `purchase_date_key` | `dim_date` | `date_key` |
| `fact_maintenance` | `truck_key` | `dim_truck` | `truck_key` |
| `fact_maintenance` | `maintenance_date_key` | `dim_date` | `date_key` |
| `fact_safety` | `driver_key` | `dim_driver` | `driver_key` |
| `fact_safety` | `truck_key` | `dim_truck` | `truck_key` |
| `fact_safety` | `incident_date_key` | `dim_date` | `date_key` |
| `fact_delivery` | `facility_key` | `dim_facility` | `facility_key` |
| `fact_delivery` | `delivery_date_key` | `dim_date` | `date_key` |

---

## Step 4 — Suggested Dashboard Pages

### Page 1 — Executive Overview
| Visual | Fields |
|---|---|
| KPI Card | `SUM(fact_trip[total_revenue])` |
| KPI Card | `COUNT(fact_trip[trip_key])` |
| KPI Card | `AVERAGE(fact_trip[average_mpg])` |
| KPI Card | On-time % from `vw_driver_performance` |
| Line chart | Revenue over time (`dim_date[year_month]` × `total_revenue`) |
| Bar chart | Top 10 routes by revenue (`dim_route[lane_description]`) |

### Page 2 — Driver Performance
| Visual | Fields |
|---|---|
| Table | `vw_driver_performance` — all columns |
| Scatter | X: `total_miles`, Y: `on_time_delivery_pct`, Size: `total_revenue` |
| Bar | `total_safety_incidents` per driver |

### Page 3 — Fleet & Maintenance
| Visual | Fields |
|---|---|
| Bar | Maintenance cost by truck age bracket (`dim_truck[truck_age_years]`) |
| Line | Monthly downtime hours (`dim_date[year_month]`) |
| Table | `vw_fleet_utilization` — Truck, Month, Miles, Revenue |

### Page 4 — Fuel Efficiency
| Visual | Fields |
|---|---|
| Line | Average MPG over time |
| Bar | MPG by truck make |
| Scatter | X: `truck_age_years`, Y: `actual_mpg` |

---

## Useful DAX Measures

Add these to a `_Measures` table in Power BI:

```dax
Total Revenue = SUM(fact_trip[total_revenue])

On-Time % = 
DIVIDE(
    COUNTROWS(FILTER(fact_delivery, fact_delivery[on_time_flag] = "Y")),
    COUNTROWS(fact_delivery),
    0
) * 100

Avg MPG = AVERAGE(fact_trip[average_mpg])

Fuel Cost Per Mile = 
DIVIDE(SUM(fact_fuel_purchase[total_cost]), SUM(fact_trip[actual_distance_miles]))

Prev Month Revenue = 
CALCULATE(
    [Total Revenue],
    DATEADD(dim_date[full_date], -1, MONTH)
)

Revenue MoM % = 
DIVIDE([Total Revenue] - [Prev Month Revenue], [Prev Month Revenue]) * 100
```

---

## Refresh Schedule

Once published to Power BI Service, configure a **scheduled refresh** via:
> Power BI Service → Dataset → Settings → Scheduled Refresh

Set frequency to **Daily** or after each pipeline run (`EXEC gold.load_gold`).
