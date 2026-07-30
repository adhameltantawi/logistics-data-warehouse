# Logistics Data Warehouse - Executive Dashboard Presentation

- **[View Live Google Sheets Dashboard](https://docs.google.com/spreadsheets/d/1KwzlXp6mJhAZQ7D-3wx9NzWysxX2GLc3MCvLxTdEde0/edit?usp=sharing)**

![Executive Dashboard Overview](image.png)
![Dashboard KPIs](dashboard_kpis.png)
![Dashboard Charts](dashboard_charts.png)
![Dashboard Analysis](dashboard_analysis.png)

## Executive Summary
This dashboard provides a unified, top-down view of our logistics operations by connecting fleet performance, dispatch efficiency, and financial health into a single pane of glass. Built on top of the Medallion Architecture Data Warehouse, it empowers executives and operational managers to transition from reactive troubleshooting to proactive strategy, identifying cost drivers and revenue opportunities in real time.

---

## Key Performance Indicators (KPIs)

The dashboard tracks 13 primary metrics across three core pillars: Financials, Operations, and Fleet Health.

### Financial Performance
- **Total Revenue**: `$298.6M` - Gross revenue generated from all completed and billed trips.
- **Net Operating Income**: `$197.3M` - Profitability after deducting direct operational expenses (fuel and maintenance).
- **Revenue Per Mile**: `$2.44` - The yield generated for every mile driven, a key indicator of pricing efficiency.
- **Total Fuel Cost**: `$95.6M` - The total expenditure on fuel across the fleet.
- **Total Maintenance Cost**: `$5.7M` - Total spending on parts, labor, and routine fleet upkeep.

### Operational Efficiency
- **On-Time Delivery %**: `56.0%` - The percentage of deliveries made on or before the promised delivery time.
- **Total Deliveries**: `170,820` - The absolute volume of shipments completed.
- **Avg Detention Time**: `92 min` - The average time drivers spend waiting at customer facilities for loading/unloading.
- **Active Customers**: `168` - The number of unique clients actively utilizing our freight services.

### Fleet & Safety Health
- **Total Miles Driven**: `122.2M` - Total physical distance covered by the fleet.
- **Total Safety Incidents**: `170` - Total recorded incidents including accidents, violations, and equipment damage.
- **Active Drivers**: `124` - Currently employed and active drivers in the roster.
- **Active Trucks**: `92` - Currently operational and dispatch-ready Class 8 trucks.

---

## Visual Analytics & Charts

### 1. Monthly Revenue & Trips Trend (Combo Chart)
Tracks the historical correlation between trip volume and top-line revenue month-over-month. Helps identify seasonal peaks and assess if revenue growth is keeping pace with operational volume.

### 2. Top 10 Customers by Revenue (Bar Chart)
Highlights the most valuable accounts. Used for targeted account management, contract renegotiations, and assessing client concentration risk.

### 3. Monthly Profitability (Line Chart)
A layered breakdown of Revenue vs. Fuel Cost vs. Maintenance Cost, resulting in Net Profit. Identifies margin compression trends (e.g., when fuel costs spike independently of revenue).

### 4. Top 10 Routes by Revenue (Bar Chart)
Pinpoints the most lucrative shipping lanes. Essential for network optimization, pricing strategy, and resource allocation.

### 5. Fleet Composition by Make (Donut Chart)
Visualizes the breakdown of the fleet by manufacturer (Freightliner, Volvo, Peterbilt, etc.). Useful for standardizing maintenance protocols and negotiating bulk purchasing agreements.

### 6. Safety Incidents by Type (Bar Chart)
Categorizes incidents into Accidents, Customer Complaints, DOT Violations, Equipment Damage, and Moving Violations. Highlights areas requiring immediate safety training or policy enforcement.

### 7. Delivery Event Split (Donut Chart)
Shows the ratio of Pickup events vs. Delivery events. Helps balance dispatch load and terminal capacity.

### 8. Top 10 Drivers by Revenue (Bar Chart)
Identifies the highest-performing drivers based on the revenue they generate. Crucial for retention programs, bonuses, and identifying best practices.

### 9. Monthly Fuel Expenditure (Line Chart)
Isolates fuel costs over time, allowing the team to correlate spikes with macroeconomic fuel prices or seasonal efficiency drops.

### 10. Maintenance Cost by Type (Donut Chart)
Breaks down maintenance spend into categories (Brakes, Engine, Tires, Preventive, Transmission). Highlights persistent mechanical issues or the need for fleet renewal.

### 11. On-Time Delivery Rate by Month (Line Chart)
Tracks the historical trend of delivery reliability. A critical metric for customer satisfaction and avoiding SLA penalties.

### 12. Avg Detention Minutes by Month (Bar Chart)
Monitors facility wait times over time. High detention times lead to driver dissatisfaction, increased fuel burn (idling), and lost revenue opportunities.

---

## Key Business Insights

1. **Robust Profitability:** Operating Margin stands strong at **~66%**, generating over **$197M** in net operating income. The pricing strategy relative to direct costs is highly effective.
2. **Fuel is the Primary Cost Driver:** Fuel represents the largest operational expense at **~$95.6M**, consuming **~32%** of total revenue. Any incremental improvement in route efficiency or MPG will yield massive bottom-line results.
3. **Operational Bottleneck:** On-Time Delivery is severely lagging, currently tracking at just **~56%**, compounded by an average detention time of **92 minutes**. This is the primary threat to customer retention and fleet utilization.
4. **Preventable Costs:** Over **37%** of safety incidents are classified as preventable (moving violations, minor equipment damage), representing a clear, actionable area for cost reduction through driver training programs.

---

## Strategic Recommendations

### 1. Tackle Detention to Improve On-Time Delivery
The correlation between the 92-minute average detention time and the low 56% on-time delivery rate is the most critical operational flaw. 
- **Action:** Implement strict detention billing (charging customers for wait times exceeding 60 minutes) to incentivize faster turnaround.
- **Action:** Work directly with the top 10 customers to optimize appointment scheduling and drop-and-hook programs.

### 2. Fuel Efficiency Programs
With fuel consuming nearly a third of all revenue, minor optimizations yield millions in savings.
- **Action:** Launch an idle-reduction campaign and incentivize drivers based on MPG performance.
- **Action:** Utilize the 'Top Routes' data to negotiate targeted volume discounts at specific truck stops along those high-frequency corridors.

### 3. Fleet Standardization
The 'Maintenance Cost by Type' and 'Fleet Composition' charts should be cross-referenced to identify which truck makes are generating the highest specific repair costs (e.g., Engine vs. Transmission).
- **Action:** Phase out underperforming models and standardize purchasing around the most reliable manufacturer to reduce parts inventory and mechanic training costs.

### 4. Safety & Retention
- **Action:** Implement a targeted safety course specifically addressing the most common 'Preventable' incident types identified in the dashboard.
- **Action:** Reward the 'Top 10 Drivers by Revenue' with retention bonuses and assign them as mentors to new hires to replicate their efficiency.
