# Haraka Rides Data Engineering & Analytics Project

## Project Overview
Haraka Rides is an urban ride-hailing and fleet operations service. The objective of this project is to build an end-to-end data pipeline in PostgreSQL, transforming raw, unstructured operational data into a Star Schema data warehouse to evaluate fleet profitability.

The primary business objective is to compute the net profit for each vehicle by aggregating revenue from trips against expenses incurred from fuel and maintenance logs.

---

## Architecture & Schema Design

### Staging Layer
Raw operational datasets were ingested into staging tables:
- `safari_connect.trips_staging`: Ingested trip logs containing fare amounts, distances, and operational statuses.
- `safari_connect.fleet_staging`: Ingested operational logs containing fuel transactions and vehicle maintenance records.

### Star Schema Production Layer
Data was cleaned, standardized, and migrated into a production Star Schema consisting of three dimension tables and three fact tables:

+----------------------+
              |     dim_vehicles     |
              +----------------------+
              | vehicle_id (PK)      |
              | vehicle_plate        |
              | vehicle_make         |
              | vehicle_model        |
              +----------+-----------+
                         |
     +-------------------+-------------------+
     |                   |                   |
     v                   v                   v

     +------------------+ +------------------+ +------------------------+
|    fact_trips    | |  fact_fuel_logs  | | fact_maintenance_logs  |
+------------------+ +------------------+ +------------------------+
| trip_id (PK)     | | fuel_log_id (PK) | | maintenance_log_id(PK) |
| vehicle_id (FK)  | | vehicle_id (FK)  | | vehicle_id (FK)        |
| driver_id (FK)   | | event_date       | | event_date             |
| customer_id (FK) | | liters           | | service_type           |
| fare_amount      | | fuel_cost        | | maintenance_cost       |
| status           | +------------------+ +------------------------+
+------------------+

#### Dimension Tables
- `safari_connect.dim_vehicles`: Unique vehicle entity attributes.
- `safari_connect.dim_drivers`: Unique driver demographic details.
- `safari_connect.dim_customers`: Unique customer profile information.

#### Fact Tables
- `safari_connect.fact_trips`: Transactional trip events including distances, fare amounts, and completion status.
- `safari_connect.fact_fuel_logs`: Fuel purchase transactions per vehicle.
- `safari_connect.fact_maintenance_logs`: Service and repair transactions per vehicle.

---

## Data Cleaning & Transformation Operations
Key transformations performed during the ETL process include:
- Removing currency formatting and casting text values to native numeric types (`NUMERIC`, `INTEGER`).
- Standardizing casing across entities (`UPPER` for license plates, `INITCAP` for names and vehicle models).
- Converting text fields to native `DATE` and `TIME` data types.
- Cleaning invalid negative values in trip distances.
- Deduplicating transactional logs using `DISTINCT ON` logic to ensure data integrity.

---

## Data Validation Summary

| Table Name | Record Count |
| :--- | :--- |
| `dim_vehicles` | 12 |
| `dim_drivers` | 26 |
| `dim_customers` | 63 |
| `fact_trips` | 400 |
| `fact_fuel_logs` | 69 |
| `fact_maintenance_logs` | 33 |

---

## Business Analytics: Vehicle Profitability

### Profitability Formula
Net Profit = Total Trip Revenue - (Total Fuel Expenses + Total Maintenance Expenses)

### Executive Summary Results

| Vehicle Plate | Make | Model | Total Revenue (KES) | Fuel Cost (KES) | Maintenance Cost (KES) | Net Profit (KES) |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **KDB833G** | Toyota | Fielder | 30,277 | 6,552 | 0 | **+23,725** |
| **KDE169J** | Mazda | Demio | 14,999 | 0 | 0 | **+14,999** |
| **KDD156F** | Nissan | Advan | 24,319 | 15,470 | 0 | **+8,849** |
| **KDC384M** | Subaru | Impreza | 32,464 | 28,210 | 17,039 | **-12,785** |
| **KDA950K** | Honda | Fit | 29,114 | 29,302 | 18,187 | **-18,375** |
| **KDB560L** | Toyota | Vitz | 28,122 | 22,750 | 38,655 | **-33,283** |
| **KDC598H** | Nissan | Note | 26,384 | 32,032 | 34,289 | **-39,937** |
| **KDE501G** | Toyota | Wish | 11,628 | 21,112 | 34,861 | **-44,345** |
| **KDA542H** | Mazda | Axela | 31,864 | 38,948 | 38,336 | **-45,420** |
| **KDA496F** | Toyota | Axio | 29,238 | 47,866 | 36,518 | **-55,146** |
| **KDD693I** | Toyota | Premio | 17,423 | 12,558 | 72,545 | **-67,680** |
| **KDB869I** | Toyota | Probox | 0 | 11,648 | 116,804 | **-128,452** |

---

## Key Insights & Recommendations
- **Top Performing Asset**: Toyota Fielder (`KDB833G`) generated the highest net profit (+23,725 KES) due to zero maintenance incidents and consistent fare revenue.
- **Underperforming Asset**: Toyota Probox (`KDB869I`) generated the largest net loss (-128,452 KES) driven by excessive maintenance costs and zero completed trips. Recommend decommissioning or immediate audit.

---

## How to Run

1. Clone this repository:
   ```bash
   git clone [https://github.com/Atuti254/haraka-rides-sql-project.git](https://github.com/Atuti254/haraka-rides-sql-project.git)
