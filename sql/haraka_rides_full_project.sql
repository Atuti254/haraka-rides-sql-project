-- =========================================================================
-- ========== HARAKA RIDES PROJECT ========================================= 
-- =========================================================================

-- STEP 1 -Creating the schema so as to keep the raw data organised
create schema safari_connect;

set search_path to safari_connect;

show search_path;

-- STEP 2 -Creating tables - since there were two raw files we'll create two tables
-- Ill set the data type to VARCHAR since its raw data
-- Creating tables for the data collected by the booking systems - trips_staging
create table safari_connect.trips_staging (
    trip_id VARCHAR(50),
    customer_name VARCHAR(100),
    customer_phone VARCHAR(50),
    customer_area VARCHAR(100),
    driver_name VARCHAR(100),
    driver_phone VARCHAR(50),
    vehicle_plate VARCHAR(50),
    vehicle_make VARCHAR(50),
    vehicle_model VARCHAR(50),
    pickup_area VARCHAR(100),
    dropoff_area VARCHAR(100),
    trip_date VARCHAR(50),
    pickup_time VARCHAR(50),
    distance_km VARCHAR(50),
    payment_method VARCHAR(50),
    status VARCHAR(50),
    fare_amount VARCHAR(50),
    customer_rating VARCHAR(50)
);



select * from safari_connect.trips_staging;


-- Creating tables for the fleet system - fleet_staging
create table safari_connect.fleet_staging (
    log_id VARCHAR(50),
    vehicle_plate VARCHAR(50),
    vehicle_make VARCHAR(50),
    vehicle_model VARCHAR(50),
    vehicle_year VARCHAR(50),
    vehicle_type VARCHAR(50),
    vehicle_status VARCHAR(50),
    event_type VARCHAR(50),
    event_date VARCHAR(50),
    liters VARCHAR(50),
    fuel_cost VARCHAR(50),
    odometer_reading VARCHAR(50),
    station_name VARCHAR(100),
    service_type VARCHAR(100),
    maintenance_cost VARCHAR(50),
    mechanic_name VARCHAR(100),
    next_service_due VARCHAR(50)
);

select * from safari_connect.fleet_staging;

-- STEP 3 -Now that after creating the tables I'll import the CSV data using dbeaver's import tool
-- Import Data Process is simply right clicking on the tables I have created and select the import option 
-- I then will browse the data I want to import and click proceed

-- Confirming the data has been imported succesfully
-- Using the COUNT() function
SELECT count(*) FROM safari_connect.trips_staging;
SELECT count(*) FROM safari_connect.fleet_staging;

-- STEP 4 - Data cleaning
-- The functions we'll be using in data cleaning fall under Data Manipulation Language(DML)

-- Cleaning the cutomer_name column on safari_connect.trips_staging
-- We are stripping away extra spaces and converting the names to propercase
-- Testing
SELECT 
    customer_name, 
    INITCAP(TRIM(customer_name)) AS cleaned_customer_name
FROM safari_connect.trips_staging
LIMIT 10;

UPDATE safari_connect.trips_staging
SET customer_name = INITCAP(TRIM(customer_name));

-- Cleaning the cutomer_phone column
-- Errors epected -extra spaces, inconsistent phone formats, dashes, leading/trailing country codes, blanks 
-- clauses used ; REPLACE() - Strips out hyphens to remove punctuation inconsistencies
--                REGEXP_REPLACE() - Standardizes international country codes (+254 or 254) at the start of the string to the local '0' prefix
SELECT customer_phone 
FROM safari_connect.trips_staging 
LIMIT 10;

SELECT 
    customer_phone,
    REGEXP_REPLACE(
        REPLACE(customer_phone, '-', ''), 
        '^\+?254', 
        '0'
    ) AS cleaned_phone
FROM safari_connect.trips_staging
LIMIT 10;


update safari_connect.trips_staging 
set customer_phone = REGEXP_REPLACE(
                     REPLACE(customer_phone, '-', ''), '^\+?254', '0');

-- Cleaning customer_area column
-- Errors expected typos,inconstistent cases,extra spaces,
-- To inspect the rows well will use the DISTINCT function
 
select distinct customer_area from safari_connect.trips_staging;

select customer_area, 
       INITCAP(TRIM(customer_area)) 
       as cap_customer_area 
from safari_connect.trips_staging
limit 10;

-- Now am dealing with typos.Here when using set the 'WHERE' clause is essential as it filters only the rows that will be changed
update safari_connect.trips_staging
set customer_area = INITCAP(TRIM(customer_area)); 

update safari_connect.trips_staging
set customer_area = 'Cbd'
where customer_area = 'Cbbd';

update safari_connect.trips_staging
set customer_area = 'Buruburu'
where customer_area = 'Burubburu';

update safari_connect.trips_staging
set customer_area = 'Parklands'
where customer_area = 'Parkllands';

update safari_connect.trips_staging
set customer_area = 'Lavington'
where customer_area = 'Lavinngton';

update safari_connect.trips_staging
set customer_area = 'Westlands'
where customer_area = 'Westllands';

update safari_connect.trips_staging
set customer_area = 'Runda'
where customer_area = 'Runnda';

update safari_connect.trips_staging
set customer_area = 'South B'
where customer_area = 'Soutth B';

update safari_connect.trips_staging
set customer_area = 'Langata'
where customer_area = 'Langgata';

update safari_connect.trips_staging
set customer_area = 'South C'
where customer_area = 'Soutth C';

update safari_connect.trips_staging
set customer_area = 'Kasarani'
where customer_area = 'Kasarrani';

update safari_connect.trips_staging
set customer_area = 'CBD'
where customer_area = 'Cbd';


select distinct customer_area from safari_connect.trips_staging;

-- Cleaning driver_name column
-- Errors expected inconsistent casing, extra spaces
select driver_name from safari_connect.trips_staging limit 10;

select driver_name, 
       INITCAP(TRIM(driver_name)) as cleaned_driver_name
from safari_connect.trips_staging
limit 10;

update safari_connect.trips_staging 
set driver_name = INITCAP(TRIM(driver_name));

-- Cleaning driver_phone
-- Errors expected -extra spaces, inconsistent phone formats, dashes, leading/trailing country codes, blanks

select driver_phone from safari_connect.trips_staging limit 15;07

-- Removing dashes
update safari_connect.trips_staging
set driver_phone = replace(driver_phone, '-', '');

-- Standardize phone format
update safari_connect.trips_staging 
set driver_phone = replace(driver_phone, '+254', '0') 
where driver_phone like '+254%';

-- Handling missing date - Converted blank into proper Null values
select driver_phone, 
       LENGTH(TRIM(driver_phone)) as trimmed_length
from safari_connect.trips_staging 
where LENGTH(driver_phone) != 10;

update safari_connect.trips_staging 
set driver_phone = null 
where TRIM(driver_phone) = '';

select driver_phone from safari_connect.trips_staging where LENGTH(driver_phone) != 10;

-- Cleaning vehicle_plate
-- Errors expected -extra white spaces, inconsistent casing,

update safari_connect.trips_staging
set vehicle_plate = UPPER(TRIM(vehicle_plate));

select vehicle_plate from safari_connect.trips_staging limit 15;

-- Cleaning vehicle_make
-- Errors expected -inconsistent casing, extra white spaces
select distinct vehicle_make from safari_connect.trips_staging;

update safari_connect.trips_staging
set vehicle_make = UPPER(TRIM(vehicle_make));

-- Cleaning vehicle_model 
-- Errors expected -Inconsistent casing,Extra white spaces, 
select distinct vehicle_model from safari_connect.trips_staging;

update safari_connect.trips_staging
set vehicle_model = INITCAP(TRIM(vehicle_model));

-- Cleaning pickup_area
-- Errors expected Inconsistent casing, Spelling errors,
select distinct pickup_area from safari_connect.trips_staging;

update safari_connect.trips_staging
set pickup_area = INITCAP(TRIM(pickup_area));

select pickup_area, count(*)
from safari_connect.trips_staging 
group by pickup_area 
order by pickup_area;
 
-- Correcting the typos - Use case statement
update safari_connect.trips_staging 
set pickup_area = case 
	      when pickup_area = 'Cbbd' then 'Cbd'
	      when pickup_area = 'Karren' then 'Karen'
	      when pickup_area = 'Kasarrani' then 'Kasarani'
	      when pickup_area = 'Ngong  Road' then 'Ngong Road'
	      when pickup_area = 'Parkllands' then 'Parklands'
	      when pickup_area = 'Runnda' then 'Runda'
	      when pickup_area = 'Soutth C' then 'South C'
	      when pickup_area = 'Westllands' then 'Westlands'
	      when pickup_area = 'Lavinngton' then 'Lavington'
	      when pickup_area = 'Langgata' then 'Langata'
	      when pickup_area = 'Kilimmani' then 'Kilimani'
	      else pickup_area
end;

-- Cleaning droppoff_area
-- Errors expected - Inconsistent casing, typos,extra white spaces
select distinct dropoff_area from safari_connect.trips_staging;

update safari_connect.trips_staging 
set dropoff_area = INITCAP(TRIM(dropoff_area));

select dropoff_area, 
       count(*) 
from safari_connect.trips_staging
group by dropoff_area 
order by dropoff_area;
 
-- Correcting typos
update safari_connect.trips_staging
set dropoff_area = case 
	       when dropoff_area = 'Burubburu' then 'Buruburu'
	       when dropoff_area = 'Cbbd' then 'Cbd'
	       when dropoff_area = 'Embakkasi' then 'Embakasi'
	       when dropoff_area = 'Kasarrani' then 'Kasarani'
	       when dropoff_area = 'Kilimmani' then 'Kilimani'
	       when dropoff_area = 'Langgata' then 'Langata'
	       when dropoff_area = 'Lavinngton' then 'Lavington'
	       when dropoff_area = 'Ngong  Road' then 'Ngong Road'
	       when dropoff_area = 'Parkllands' then 'Parklands'
	       when dropoff_area = 'Runnda' then 'Runda'
	       when dropoff_area = 'Soutth C' then 'South C'
	       when dropoff_area = 'Soutth B' then 'South B'
	       when dropoff_area = 'Westllands' then 'Westlands'
	       else dropoff_area
end;

-- Cleaning trip_dates
-- Errors expected -Inconsistent date formats,

select MIN(trip_date) as earliest_date,
       MAX(trip_date) as latest_date,
       COUNT(*) filter (where trip_date is null) as misssing_counts,
       COUNT(*) as total_rows
from safari_connect.trips_staging;

-- Standardizing the date separatos - Replacing '/' with '_'
update safari_connect.trips_staging
set trip_date = REPLACE(trip_date, '/', '-');

-- Changing column type to date
alter table safari_connect.trips_staging
alter column trip_date type DATE 
using TO_DATE(trip_date, 'DD-MM-YYYY');

-- Standardizing all string to yyyy-mm-dd fromat using CASE pattern matching
update safari_connect.trips_staging 
set trip_date = case
	-- Format 1: YYYY-MM--DD
	when trip_date ~ '^\d{4}-\d{2}-\d{2}$'
	then trip_date 
	-- Format 2: 2-digit year 
	when trip_date ~ '^\d{2}-\d{2}-\d{2}$'
	then to_char(to_date(trip_date, 'DD-MM-YY'), 'YYYY-MM-DD')
	-- Fromat 3: 4-digit year 1st number . 12 -> MUST be DD-MM-YYYY
	when trip_date ~ '^\d{2}-\d{2}-\d{4}$'
	and cast(split_part(trip_date, '-', 1) as integer) > 12
	then to_char(to_date(trip_date, 'DD-MM-YYYY'), 'YYYY-MM-DD')
	-- Format 4: 4-digit year where 2nd number > 12 -> MUST be MM-DD-YYYY (e.g., 03-27-2025)
	when trip_date ~ '^\d{2}-\d{2}-\d{4}$'
	and cast(split_part(trip_date, '-', 2) as integer) > 12
	then to_char(to_date(trip_date, 'MM-DD-YYYY'), 'YYYY-MM-DD')
	-- Format 5: Ambiguous 4-digit year (e.g., 08-01-2025) - Default to DD-MM-YYYY
	when trip_date ~ '^\d{2}-\d{2}-\d{4}$'
	then to_char(to_date(trip_date, 'DD-MM-YYYY'), 'YYYY-MM-DD')
	else trip_date
end;

-- Altering the column type
alter table safari_connect.trips_staging 
alter column trip_date type DATE
using TRIP_DATE::DATE;

select min(trip_date), max(trip_date), count(*) from safari_connect.trips_staging;

-- Cleaning pick_up time
-- Errors expected trailing spaces, 
select 
     pickup_time,
     TRIM(pickup_time) as cleaned_time
from safari_connect.trips_staging 
limit 15;

-- the pick_up time column loks okay now is to remove any hidden spaces incase there's one
update safari_connect.trips_staging
set pickup_time = TRIM(pickup_time);

-- Cleaning distance_km
-- Errors expected negative numbers, stray spaces, empty values
select 
      distance_km,
      TRIM(distance_km) as trimmed_distance
from safari_connect.trips_staging 
where distance_km like '-%'
   or distance_km is null
   or TRIM(distance_km) = '';

-- previewing the script
select 
      distance_km,
      ABS(cast(TRIM(distance_km) as numeric)) as fixed_distance
from safari_connect.trips_staging 
where distance_km like '-%';
-- 
update safari_connect.trips_staging
set distance_km = ABS(cast(TRIM(distance_km) as numeric))::VARCHAR
where distance_km like '-%';






select * from safari_connect.trips_staging;

select 
    column_name, 
    data_type, 
    is_nullable
from information_schema.columns 
where table_schema = 'safari_connect' 
  and table_name = 'fleet_staging'
order by ordinal_position;

-- I seem to have lost the queries I used for cleaning buh the database is well and 

/*
====================================================================
  HARAKA RIDES DATA ENGINEERING & ANALYTICS PROJECT
====================================================================

--------------------------------------------------------------------
  PROJECT PROGRESS & ACHIEVEMENTS SO FAR
--------------------------------------------------------------------
  1. DATABASE & STAGING ENVIRONMENT SETUP
     - Schema Created: safari_connect
     - Staging Tables Imported: 
       * safari_connect.trips_staging
       * safari_connect.fleet_staging

  2. TRIPS_STAGING CLEANING
     - Standardized names, phone numbers, and location areas.
     - Normalized categorical values:
       * payment_method -> 'M-Pesa', 'Card', 'Cash'
       * status         -> 'Completed', 'Cancelled', 'No-Show'
     - Cleaned numerical data:
       * Fixed negative distance values using abs()
       * Removed 'KES' prefixes and commas from fare_amount
       * Nullified invalid ratings (< 1 or > 5) in customer_rating
     - Standardized multi-format dates to YYYY-MM-DD and pickup_time to 24-hour HH:MI.

  3. FLEET_STAGING CLEANING
     - Standardized casing across plates (UPPER) and text fields (INITCAP).
     - Fixed date year typos ('0025-' -> '2025-') and parsed multi-format dates to YYYY-MM-DD.
     - Stripped currency text ('KES') and non-numeric symbols from cost fields.
     - Converted empty text strings ('') into true database NULL values.

  4. TYPE CASTING & DATA INTEGRITY
     - Successfully converted all text (varchar) columns into native 
       PostgreSQL data types: DATE, TIME, NUMERIC, and INTEGER.

--------------------------------------------------------------------
  PROJECT ROADMAP & NEXT STEPS
--------------------------------------------------------------------
  PHASE 3: DATA MODELING (STAR SCHEMA)
  ------------------------------------
  1. Build Dimension Tables (Context / Entities):
     - safari_connect.dim_vehicles    (plate, make, model, year, type, status)
     - safari_connect.dim_drivers     (driver_name, driver_phone)
     - safari_connect.dim_customers   (customer_name, customer_phone, customer_area)

  2. Build Fact Tables (Transactional Events):
     - safari_connect.fact_trips             (trip events, fares, distances, ratings)
     - safari_connect.fact_fuel_logs         (fuel events, liters, fuel costs, station names)
     - safari_connect.fact_maintenance_logs  (repair events, service types, costs, mechanic details)

  3. Transform & Load (ETL):
     - Populate production tables using INSERT INTO ... SELECT DISTINCT.
     - Set Primary Keys and Foreign Key relationships.

  PHASE 4: ANALYTICS & BUSINESS INSIGHTS
  --------------------------------------
  - Write SQL analytical queries for fleet utilization, revenue per vehicle,
    fuel efficiency, driver performance, and customer satisfaction.

====================================================================
*/

--==================================================================
--============PART 3: DATA MODELLING ================================
--=======================================================================

-- CREATING DIMENSION TABLES
-- create the vehicle dimension table
create table safari_connect.dim_vehicles (
    vehicle_id serial primary key,         -- auto-incrementing unique id
    vehicle_plate varchar(20) unique not null, -- natural key from fleet
    vehicle_make varchar(50),
    vehicle_model varchar(50),
    vehicle_year integer,
    vehicle_type varchar(30),
    vehicle_status varchar(30)
);


-- insert unique vehicle records into our dimension table
insert into safari_connect.dim_vehicles (
    vehicle_plate,
    vehicle_make,
    vehicle_model,
    vehicle_year,
    vehicle_type,
    vehicle_status
)
-- select distinct ensures each vehicle appears only once
select distinct
    vehicle_plate,
    vehicle_make,
    vehicle_model,
    vehicle_year,
    vehicle_type,
    vehicle_status
from safari_connect.fleet_staging
where vehicle_plate is not null;

select count(*) from safari_connect.dim_vehicles;

-- create the driver dimension table
create table safari_connect.dim_drivers (
    driver_id serial primary key,
    driver_name varchar(100) not null,
    driver_phone varchar(20)
);

-- insert unique driver records into dim_drivers
insert into safari_connect.dim_drivers (
    driver_name,
    driver_phone
)
select distinct
    driver_name,
    driver_phone
from safari_connect.trips_staging
where driver_name is not null;


select count(*) from safari_connect.dim_drivers;


-- create customer dimension table
create table safari_connect.dim_customers (
    customer_id serial primary key,
    customer_name varchar(100) not null,
    customer_phone varchar(20),
    customer_area varchar(50)
);

-- insert unique customers into dim_customers
insert into safari_connect.dim_customers (
    customer_name,
    customer_phone,
    customer_area
)
select distinct
    customer_name,
    customer_phone,
    customer_area
from safari_connect.trips_staging
where customer_name is not null;

select count(*) from safari_connect.dim_customers;


--==================================================
--============ BUILDING FACT TABLES ================

-- create fact_trips table with links to our dimensions
create table safari_connect.fact_trips (
    trip_id integer primary key,
    vehicle_id integer references safari_connect.dim_vehicles(vehicle_id),
    driver_id integer references safari_connect.dim_drivers(driver_id),
    customer_id integer references safari_connect.dim_customers(customer_id),
    pickup_area varchar(50),
    dropoff_area varchar(50),
    trip_date date,
    pickup_time time,
    distance_km numeric,
    payment_method varchar(30),
    status varchar(30),
    fare_amount numeric,
    customer_rating integer
);


-- insert unique trip records into fact_trips using distinct on (trip_id)
insert into safari_connect.fact_trips (
    trip_id,
    vehicle_id,
    driver_id,
    customer_id,
    pickup_area,
    dropoff_area,
    trip_date,
    pickup_time,
    distance_km,
    payment_method,
    status,
    fare_amount,
    customer_rating
)
select distinct on (t.trip_id::integer)
    t.trip_id::integer,
    v.vehicle_id,
    d.driver_id,
    c.customer_id,
    t.pickup_area,
    t.dropoff_area,
    t.trip_date,
    t.pickup_time,
    t.distance_km,
    t.payment_method,
    t.status,
    t.fare_amount,
    t.customer_rating
from safari_connect.trips_staging t
left join safari_connect.dim_vehicles v 
    on upper(trim(t.vehicle_plate)) = v.vehicle_plate
left join safari_connect.dim_drivers d 
    on t.driver_name = d.driver_name 
   and t.driver_phone = d.driver_phone
left join safari_connect.dim_customers c 
    on t.customer_name = c.customer_name 
   and t.customer_phone = c.customer_phone
order by t.trip_id::integer;


select count(*) from safari_connect.fact_trips;

-- 1. create fact_fuel_logs
create table safari_connect.fact_fuel_logs (
    fuel_log_id integer primary key,
    vehicle_id integer references safari_connect.dim_vehicles(vehicle_id),
    event_date date,
    liters numeric,
    fuel_cost numeric,
    odometer_reading numeric,
    station_name varchar(100)
);

-- populate fact_fuel_logs using distinct on (log_id)
insert into safari_connect.fact_fuel_logs (
    fuel_log_id,
    vehicle_id,
    event_date,
    liters,
    fuel_cost,
    odometer_reading,
    station_name
)
select distinct on (f.log_id::integer)
    f.log_id::integer,
    v.vehicle_id,
    f.event_date,
    f.liters,
    f.fuel_cost,
    f.odometer_reading,
    f.station_name
from safari_connect.fleet_staging f
left join safari_connect.dim_vehicles v 
    on upper(trim(f.vehicle_plate)) = v.vehicle_plate
where f.event_type = 'Fuel'
order by f.log_id::integer;


-- 1. create fact_maintenance_logs table
create table safari_connect.fact_maintenance_logs (
    maintenance_log_id integer primary key,
    vehicle_id integer references safari_connect.dim_vehicles(vehicle_id),
    event_date date,
    service_type varchar(100),
    maintenance_cost numeric,
    mechanic_name varchar(100),
    next_service_due date
);

-- 2. populate fact_maintenance_logs using distinct on (log_id)
insert into safari_connect.fact_maintenance_logs (
    maintenance_log_id,
    vehicle_id,
    event_date,
    service_type,
    maintenance_cost,
    mechanic_name,
    next_service_due
)
select distinct on (f.log_id::integer)
    f.log_id::integer,
    v.vehicle_id,
    f.event_date,
    f.service_type,
    f.maintenance_cost,
    f.mechanic_name,
    f.next_service_due
from safari_connect.fleet_staging f
left join safari_connect.dim_vehicles v 
    on upper(trim(f.vehicle_plate)) = v.vehicle_plate
where f.event_type = 'Maintenance'
order by f.log_id::integer;

select 'dim_vehicles' as table_name, count(*) as row_count from safari_connect.dim_vehicles
union all
select 'dim_drivers', count(*) from safari_connect.dim_drivers
union all
select 'dim_customers', count(*) from safari_connect.dim_customers
union all
select 'fact_trips', count(*) from safari_connect.fact_trips
union all
select 'fact_fuel_logs', count(*) from safari_connect.fact_fuel_logs
union all
select 'fact_maintenance_logs', count(*) from safari_connect.fact_maintenance_logs;



select 
    v.vehicle_plate,
    v.vehicle_make,
    v.vehicle_model,
    coalesce(sum(t.fare_amount), 0) as total_revenue,
    coalesce(f.total_fuel_cost, 0) as total_fuel_cost,
    coalesce(m.total_maint_cost, 0) as total_maintenance_cost,
    coalesce(sum(t.fare_amount), 0) - (coalesce(f.total_fuel_cost, 0) + coalesce(m.total_maint_cost, 0)) as net_profit
from safari_connect.dim_vehicles v
-- calculate total trip revenue per vehicle
left join safari_connect.fact_trips t 
    on v.vehicle_id = t.vehicle_id and t.status = 'Completed'
-- calculate total fuel cost per vehicle
left join (
    select vehicle_id, sum(fuel_cost) as total_fuel_cost 
    from safari_connect.fact_fuel_logs 
    group by vehicle_id
) f on v.vehicle_id = f.vehicle_id
-- calculate total maintenance cost per vehicle
left join (
    select vehicle_id, sum(maintenance_cost) as total_maint_cost 
    from safari_connect.fact_maintenance_logs 
    group by vehicle_id
) m on v.vehicle_id = m.vehicle_id
group by 
    v.vehicle_plate, 
    v.vehicle_make, 
    v.vehicle_model, 
    f.total_fuel_cost, 
    m.total_maint_cost
order by net_profit desc;

-- ====================================================================
-- PHASE 4: VEHICLE PROFITABILITY ANALYSIS
-- ====================================================================

select 
    -- 1. vehicle details from our dimension table
    v.vehicle_plate,
    v.vehicle_make,
    v.vehicle_model,
    
    -- 2. total trip revenue (coalesce replaces nulls with 0 for vehicles with no completed trips)
    coalesce(sum(t.fare_amount), 0) as total_revenue,
    
    -- 3. total fuel expenses per vehicle
    coalesce(f.total_fuel_cost, 0) as total_fuel_cost,
    
    -- 4. total maintenance expenses per vehicle
    coalesce(m.total_maint_cost, 0) as total_maintenance_cost,
    
    -- 5. net profit calculation: revenue minus (fuel + maintenance)
    coalesce(sum(t.fare_amount), 0) - (coalesce(f.total_fuel_cost, 0) + coalesce(m.total_maint_cost, 0)) as net_profit

from safari_connect.dim_vehicles v

-- join completed trips to calculate revenue per vehicle
left join safari_connect.fact_trips t 
    on v.vehicle_id = t.vehicle_id 
   and t.status = 'Completed'

-- subquery to calculate total fuel cost per vehicle
left join (
    select 
        vehicle_id, 
        sum(fuel_cost) as total_fuel_cost 
    from safari_connect.fact_fuel_logs 
    group by vehicle_id
) f on v.vehicle_id = f.vehicle_id

-- subquery to calculate total maintenance cost per vehicle
left join (
    select 
        vehicle_id, 
        sum(maintenance_cost) as total_maint_cost 
    from safari_connect.fact_maintenance_logs 
    group by vehicle_id
) m on v.vehicle_id = m.vehicle_id

-- group by vehicle attributes and aggregated subqueries
group by 
    v.vehicle_plate, 
    v.vehicle_make, 
    v.vehicle_model, 
    f.total_fuel_cost, 
    m.total_maint_cost

-- order by highest net profit first to find top performing vehicles
order by net_profit desc;


