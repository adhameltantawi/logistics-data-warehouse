IF OBJECT_ID('bronze.drivers', 'U') IS NOT NULL
    DROP TABLE bronze.drivers;
GO

CREATE TABLE bronze.drivers 
(
    driver_id NVARCHAR(15) NULL, -- Format: DRV00001, allows future growth
    first_name NVARCHAR(50) NULL, 
    last_name NVARCHAR(50) NULL,
    hire_date DATE NULL,
    termination_date DATE NULL,
    license_number NVARCHAR(50) NULL,
    license_state NCHAR(2) NULL,
    date_of_birth DATE NULL,
    home_terminal NVARCHAR(50) NULL,
    employment_status NVARCHAR(50) NULL,
    cdl_class NCHAR(1) NULL,
    years_experience INT NULL   
);
GO

IF OBJECT_ID('bronze.customers', 'U') IS NOT NULL
    DROP TABLE bronze.customers;
GO

CREATE TABLE bronze.customers
(
    customer_id VARCHAR(15) NULL,
    customer_name VARCHAR(50) NULL,
    customer_type VARCHAR(50) NULL,
    credit_terms_days VARCHAR(50) NULL,
    primary_freight_type VARCHAR(50) NULL,
    account_status VARCHAR(50) NULL,
    contract_start_date VARCHAR(50) NULL,
    annual_revenue_potential VARCHAR(50) NULL
);
GO