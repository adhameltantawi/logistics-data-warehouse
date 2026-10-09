# 📖 Logistics Data Warehouse — Gold Layer Data Catalog

> **Audience:** Data Analysts, BI Developers, Report Builders  
> **Database:** `logistics_dwh` | **Schema:** `gold`  
> **Updated:** 2026-10-09

This catalog describes every table and view available to analysts in the Gold layer. It covers column definitions, data types, business meaning, and example usage.

---

## How to Query

Connect to SQL Server and run:
```sql
USE logistics_dwh;
SELECT * FROM gold.dim_driver;          -- dimension example
SELECT * FROM gold.fact_trip;           -- fact example
SELECT * FROM gold.vw_driver_performance; -- pre-built KPI view
```

---

## 🗓️ Dimension Tables

Dimension tables describe **who, what, where** — the business entities. They change slowly and are small in row count.

---

### `gold.dim_driver`

One row per driver **per SCD2 version**. When a driver's `home_terminal`, `employment_status`, `cdl_class`, or `years_experience` changes, a new row is inserted and the old row is expired.

| Column | Type | Description |
|---|---|---|
| `driver_key` | INT (PK) | Surrogate key — use this for all JOINs to fact tables |
| `driver_id` | NVARCHAR(20) | Natural key from source — consistent across all SCD2 versions |
| `first_name` | NVARCHAR(50) | Driver first name (trimmed) |
| `last_name` | NVARCHAR(50) | Driver last name (trimmed) |
| `full_name` | NVARCHAR(101) | `first_name + ' ' + last_name` — ready for display |
| `hire_date` | DATE | Date the driver was hired |
| `termination_date` | DATE | Date driver left (NULL if still active) |
| `license_number` | NVARCHAR(50) | CDL license number |
| `license_state` | NCHAR(2) | State that issued the CDL (upper-cased) |
| `date_of_birth` | DATE | Driver date of birth |
| `home_terminal` | NVARCHAR(50) | Home terminal / dispatch location ⭐ *SCD2 tracked* |
| `employment_status` | NVARCHAR(50) | `Active` \| `Inactive` \| `Terminated` \| `On Leave` ⭐ *SCD2 tracked* |
| `cdl_class` | NCHAR(1) | CDL class: `A`, `B`, or `C` ⭐ *SCD2 tracked* |
| `years_experience` | INT | Years of CDL driving experience ⭐ *SCD2 tracked* |
| `effective_start_date` | DATE | Date this SCD2 version became active |
| `effective_end_date` | DATE | Date this version was superseded (NULL = current row) |
| `is_current` | BIT | **1 = current active row**; 0 = historical version |
| `dwh_create_date` | DATETIME2 | Warehouse load timestamp |

> 💡 **Analyst Tip:** Always filter `WHERE is_current = 1` to get today's driver attributes. Use SCD2 history for point-in-time reporting.

---

### `gold.dim_truck`

One row per fleet truck unit. Enriched with computed `truck_age_years`.

| Column | Type | Description |
|---|---|---|
| `truck_key` | INT (PK) | Surrogate key |
| `truck_id` | NVARCHAR(20) | Natural key from fleet system |
| `unit_number` | INT | Internal unit/fleet number |
| `make` | NVARCHAR(50) | Truck manufacturer (e.g. Freightliner, Kenworth) |
| `model_year` | INT | Year of manufacture |
| `vin` | NVARCHAR(25) | Vehicle Identification Number |
| `acquisition_date` | DATE | Date the company acquired this truck |
| `acquisition_mileage` | INT | Odometer reading at acquisition |
| `fuel_type` | NVARCHAR(50) | Fuel type (Diesel, CNG, etc.) |
| `tank_capacity_gallons` | INT | Fuel tank capacity in gallons |
| `status` | NVARCHAR(50) | Current status: `Active`, `Maintenance`, `Retired` |
| `home_terminal` | NVARCHAR(50) | Home depot/terminal |
| `truck_age_years` | INT | **Derived:** `YEAR(GETDATE()) − model_year` — recomputed on every Gold load |

---

### `gold.dim_trailer`

One row per trailer in the fleet.

| Column | Type | Description |
|---|---|---|
| `trailer_key` | INT (PK) | Surrogate key |
| `trailer_id` | NVARCHAR(20) | Natural key |
| `trailer_number` | INT | Internal trailer number |
| `trailer_type` | NVARCHAR(50) | Type: `Dry Van`, `Reefer`, `Flatbed`, etc. |
| `length_feet` | INT | Trailer length in feet (typically 48 or 53) |
| `model_year` | INT | Year of manufacture |
| `vin` | NVARCHAR(25) | VIN |
| `acquisition_date` | DATE | Date acquired |
| `status` | NVARCHAR(50) | `Active`, `Maintenance`, `Retired` |
| `current_location` | NVARCHAR(50) | Last known location/terminal |

---

### `gold.dim_customer`

One row per customer account.

| Column | Type | Description |
|---|---|---|
| `customer_key` | INT (PK) | Surrogate key |
| `customer_id` | NVARCHAR(20) | Natural key |
| `customer_name` | NVARCHAR(100) | Business name |
| `customer_type` | NVARCHAR(50) | Account type: `Shipper`, `Broker`, `3PL`, etc. |
| `credit_terms_days` | INT | Payment terms in days (e.g. 30, 45, 60) |
| `primary_freight_type` | NVARCHAR(50) | Main freight category |
| `account_status` | NVARCHAR(50) | `Active`, `Inactive`, `Suspended` |
| `contract_start_date` | DATE | Date the customer relationship began |
| `annual_revenue_potential` | INT | Contracted max annual revenue in USD |

---

### `gold.dim_facility`

One row per terminal, warehouse, or distribution centre.

| Column | Type | Description |
|---|---|---|
| `facility_key` | INT (PK) | Surrogate key |
| `facility_id` | NVARCHAR(20) | Natural key |
| `facility_name` | NVARCHAR(100) | Full facility name |
| `facility_type` | NVARCHAR(50) | `Terminal`, `Warehouse`, `Distribution Center` |
| `city` | NVARCHAR(50) | City |
| `state` | NCHAR(2) | State abbreviation (upper-cased) |
| `latitude` | FLOAT | Geographic latitude (for mapping) |
| `longitude` | FLOAT | Geographic longitude (for mapping) |
| `dock_doors` | INT | Number of loading dock doors |
| `operating_hours` | NVARCHAR(50) | Operating schedule (e.g. `24/7`, `06:00-22:00`) |

---

### `gold.dim_route`

One row per origin → destination lane.

| Column | Type | Description |
|---|---|---|
| `route_key` | INT (PK) | Surrogate key |
| `route_id` | NVARCHAR(20) | Natural key |
| `origin_city` | NVARCHAR(50) | Departure city |
| `origin_state` | NCHAR(2) | Departure state |
| `destination_city` | NVARCHAR(50) | Arrival city |
| `destination_state` | NCHAR(2) | Arrival state |
| `typical_distance_miles` | INT | Standard lane distance in miles |
| `base_rate_per_mile` | DECIMAL(10,2) | Base freight rate (USD/mile, excluding surcharges) |
| `fuel_surcharge_rate` | DECIMAL(10,2) | Fuel surcharge rate (USD/mile) |
| `typical_transit_days` | INT | Expected transit time in days |
| `lane_description` | NVARCHAR(120) | **Derived:** `"Chicago, IL → Dallas, TX"` — ready for display |

---

### `gold.dim_date`

One row per calendar day from **2020-01-01 to 2030-12-31**.

| Column | Type | Description |
|---|---|---|
| `date_key` | INT (PK) | Date in `YYYYMMDD` format — FK target for all fact tables |
| `full_date` | DATE | The actual date |
| `year` | INT | Calendar year |
| `quarter` | INT | Quarter (1–4) |
| `month` | INT | Month number (1–12) |
| `month_name` | NVARCHAR(10) | Month name (e.g. `January`) |
| `week` | INT | ISO week number |
| `day_of_month` | INT | Day number within the month |
| `day_of_week` | INT | Day number (1=Sunday, 7=Saturday) |
| `day_name` | NVARCHAR(10) | Day name (e.g. `Monday`) |
| `is_weekend` | BIT | `1` = Saturday or Sunday |
| `is_holiday` | BIT | `1` = US Federal Holiday |
| `holiday_name` | NVARCHAR(50) | Holiday name (e.g. `Christmas Day`), NULL if not a holiday |
| `year_month` | NVARCHAR(7) | Format `yyyy-MM` — useful for monthly grouping in BI tools |

---

## 📊 Fact Tables

Fact tables store **measurable business events**. They are large, row-oriented, and linked to dimensions via surrogate keys.

---

### `gold.fact_trip`

**Grain:** One completed trip. This is the central fact table.

| Column | Type | Description |
|---|---|---|
| `trip_key` | INT (PK) | Surrogate key |
| `driver_key` | INT (FK) | → `dim_driver.driver_key` |
| `truck_key` | INT (FK) | → `dim_truck.truck_key` |
| `trailer_key` | INT (FK) | → `dim_trailer.trailer_key` |
| `customer_key` | INT (FK) | → `dim_customer.customer_key` |
| `route_key` | INT (FK) | → `dim_route.route_key` |
| `dispatch_date_key` | INT (FK) | → `dim_date.date_key` |
| `trip_id` | NVARCHAR(20) | Natural key — traceability back to Silver |
| `load_id` | NVARCHAR(20) | Associated load/shipment natural key |
| `actual_distance_miles` | INT | Miles actually driven (may differ from route distance) |
| `actual_duration_hours` | FLOAT | Total trip duration in hours |
| `fuel_gallons_used` | FLOAT | Total fuel consumed (gallons) |
| `average_mpg` | FLOAT | Fuel economy achieved (miles per gallon) |
| `idle_time_hours` | FLOAT | Engine-on, truck-stationary hours |
| `revenue` | DECIMAL(18,3) | Base freight revenue (USD) |
| `fuel_surcharge` | DECIMAL(18,3) | Fuel surcharge amount (USD) |
| `accessorial_charges` | INT | Additional charges (USD) |
| `total_revenue` | DECIMAL(18,3) | **Derived:** `revenue + fuel_surcharge + accessorial_charges` |
| `weight_lbs` | INT | Shipment weight in pounds |
| `pieces` | INT | Number of pieces/pallets |
| `load_type` | NVARCHAR(20) | `Full Truckload`, `LTL`, etc. |
| `load_status` | NVARCHAR(20) | `Delivered`, `In Transit`, `Pending` |
| `trip_status` | NVARCHAR(15) | `Completed`, `Cancelled`, etc. |

---

### `gold.fact_fuel_purchase`

**Grain:** One fuel stop / transaction.

| Column | Type | Description |
|---|---|---|
| `fuel_purchase_key` | INT (PK) | Surrogate key |
| `driver_key` | INT (FK) | → `dim_driver.driver_key` |
| `truck_key` | INT (FK) | → `dim_truck.truck_key` |
| `purchase_date_key` | INT (FK) | → `dim_date.date_key` |
| `fuel_purchase_id` | NVARCHAR(20) | Natural key |
| `trip_id` | NVARCHAR(20) | Associated trip natural key |
| `gallons` | FLOAT | Gallons purchased |
| `price_per_gallon` | DECIMAL(10,3) | Pump price (USD/gallon) |
| `total_cost` | DECIMAL(18,3) | **Derived:** `gallons × price_per_gallon` |
| `location_city` | NVARCHAR(20) | Fuel stop city |
| `location_state` | NCHAR(2) | Fuel stop state |
| `fuel_card_number` | NVARCHAR(20) | Fleet fuel card used |

---

### `gold.fact_maintenance`

**Grain:** One maintenance service event per truck.

| Column | Type | Description |
|---|---|---|
| `maintenance_key` | INT (PK) | Surrogate key |
| `truck_key` | INT (FK) | → `dim_truck.truck_key` |
| `maintenance_date_key` | INT (FK) | → `dim_date.date_key` |
| `maintenance_id` | NVARCHAR(20) | Natural key |
| `odometer_reading` | INT | Odometer reading at time of service |
| `labor_hours` | FLOAT | Hours of mechanic labour |
| `labor_cost` | DECIMAL(18,3) | Labour cost (USD) |
| `parts_cost` | DECIMAL(18,3) | Parts cost (USD) |
| `total_cost` | DECIMAL(18,3) | **Derived:** `labor_cost + parts_cost` |
| `downtime_hours` | FLOAT | Hours truck was unavailable |
| `maintenance_type` | NVARCHAR(20) | `Preventive`, `Corrective`, `Emergency` |
| `facility_location` | NVARCHAR(20) | Service facility name/location |
| `service_description` | NVARCHAR(50) | Brief description of work done |

---

### `gold.fact_safety`

**Grain:** One safety incident (accident, violation, or near-miss).

| Column | Type | Description |
|---|---|---|
| `safety_key` | INT (PK) | Surrogate key |
| `driver_key` | INT (FK) | → `dim_driver.driver_key` |
| `truck_key` | INT (FK) | → `dim_truck.truck_key` |
| `incident_date_key` | INT (FK) | → `dim_date.date_key` |
| `incident_id` | NVARCHAR(20) | Natural key |
| `trip_id` | NVARCHAR(20) | Associated trip natural key |
| `vehicle_damage_cost` | DECIMAL(18,3) | Cost to repair the truck (USD) |
| `cargo_damage_cost` | DECIMAL(18,3) | Cost of damaged freight (USD) |
| `claim_amount` | DECIMAL(18,3) | Insurance claim filed (USD) |
| `total_damage_cost` | DECIMAL(18,3) | **Derived:** `vehicle_damage_cost + cargo_damage_cost` |
| `incident_type` | NVARCHAR(50) | `Accident`, `Moving Violation`, `Cargo Damage`, etc. |
| `location_city` | NVARCHAR(20) | Location where incident occurred |
| `location_state` | NCHAR(2) | State of incident |
| `at_fault_flag` | NVARCHAR(5) | `Y` / `N` — was the driver at fault? |
| `injury_flag` | NVARCHAR(5) | `Y` / `N` — were there injuries? |
| `preventable_flag` | NVARCHAR(5) | `Y` / `N` — was the incident preventable? |
| `description` | NVARCHAR(200) | Free-text incident description |

---

### `gold.fact_delivery`

**Grain:** One pickup or delivery event at a facility.

| Column | Type | Description |
|---|---|---|
| `delivery_key` | INT (PK) | Surrogate key |
| `facility_key` | INT (FK) | → `dim_facility.facility_key` |
| `delivery_date_key` | INT (FK) | → `dim_date.date_key` (from `actual_datetime`, fallback to `scheduled_datetime`) |
| `event_id` | NVARCHAR(20) | Natural key |
| `load_id` | NVARCHAR(20) | Associated load natural key |
| `trip_id` | NVARCHAR(20) | Associated trip natural key |
| `detention_minutes` | INT | Minutes held beyond scheduled time (cost driver) |
| `event_type` | NVARCHAR(15) | `Pickup` or `Delivery` |
| `scheduled_datetime` | TIME | Scheduled arrival/departure time |
| `actual_datetime` | TIME | Actual arrival/departure time |
| `on_time_flag` | NVARCHAR(5) | `Y` = on time / `N` = late |
| `location_city` | NVARCHAR(50) | City of the event |
| `location_state` | NCHAR(2) | State of the event |

---

## 🔍 KPI Views

Pre-aggregated views for fast reporting — no complex JOINs needed.

---

### `gold.vw_driver_performance`

One row per driver. Aggregates trips, miles, revenue, safety incidents, and on-time delivery rate.

| Column | Description |
|---|---|
| `driver_id` | Natural key |
| `full_name` | Display name |
| `home_terminal` | Current terminal |
| `total_trips` | Lifetime completed trips |
| `total_miles` | Lifetime miles driven |
| `total_revenue_generated` | Total revenue from associated trips |
| `total_safety_incidents` | Count of safety incidents |
| `total_damage_cost_caused` | Sum of damage costs from incidents |
| `total_deliveries` | Total delivery events linked to this driver |
| `on_time_delivery_pct` | On-time delivery percentage (0–100) |

---

### `gold.vw_route_profitability`

One row per route lane. Revenue and distance aggregates per lane.

| Column | Description |
|---|---|
| `route_id` | Natural key |
| `lane_description` | `"Chicago, IL → Dallas, TX"` |
| `typical_distance_miles` | Standard lane distance |
| `trip_count` | Number of trips on this lane |
| `actual_miles_driven` | Total actual miles across all trips |
| `total_revenue` | Total revenue generated |
| `total_gallons_used` | Total fuel consumed |
| `avg_revenue_per_trip` | Revenue per trip |
| `revenue_per_mile` | Revenue efficiency (USD/mile) |

---

### `gold.vw_fleet_utilization`

One row per truck per month. Measures truck productivity over time.

| Column | Description |
|---|---|
| `truck_id` | Natural key |
| `make` | Truck manufacturer |
| `model_year` | Year of manufacture |
| `truck_age_years` | Current age in years |
| `year_month` | Month (format: `yyyy-MM`) |
| `total_trips` | Trips completed this month |
| `total_miles_driven` | Miles driven this month |
| `revenue_generated` | Revenue from this truck this month |
| `maintenance_events` | Number of maintenance events this month |
| `maintenance_cost` | Total maintenance spend this month |
| `downtime_hours` | Hours offline for maintenance |

---

### `gold.vw_fuel_efficiency`

One row per trip. Tracks actual vs expected MPG by driver and truck.

| Column | Description |
|---|---|
| `trip_id` | Natural key |
| `driver_name` | Driver full name |
| `truck_id` | Truck natural key |
| `truck_make` | Manufacturer |
| `truck_age_years` | Truck age |
| `dispatch_month` | Month of dispatch (`yyyy-MM`) |
| `actual_distance_miles` | Miles driven |
| `fuel_gallons_used` | Gallons consumed |
| `idle_time_hours` | Idle engine hours |
| `actual_mpg` | **Derived:** `actual_distance_miles / fuel_gallons_used` |
| `expected_mpg` | Reported average MPG (from trip record) |

---

## 🚀 Quick Start Queries for Analysts

```sql
-- Top 10 drivers by revenue
SELECT TOP 10 full_name, total_revenue_generated, on_time_delivery_pct
FROM gold.vw_driver_performance
ORDER BY total_revenue_generated DESC;

-- Monthly revenue trend
SELECT year_month, SUM(total_revenue) AS revenue
FROM gold.fact_trip t
JOIN gold.dim_date d ON t.dispatch_date_key = d.date_key
GROUP BY year_month ORDER BY year_month;

-- Most profitable routes
SELECT lane_description, revenue_per_mile, total_revenue
FROM gold.vw_route_profitability
ORDER BY revenue_per_mile DESC;

-- Holiday vs non-holiday delivery on-time rate
SELECT d.is_holiday, d.holiday_name,
       COUNT(*) AS deliveries,
       SUM(CASE WHEN f.on_time_flag = 'Y' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS on_time_pct
FROM gold.fact_delivery f
JOIN gold.dim_date d ON f.delivery_date_key = d.date_key
GROUP BY d.is_holiday, d.holiday_name
ORDER BY d.is_holiday;
```
