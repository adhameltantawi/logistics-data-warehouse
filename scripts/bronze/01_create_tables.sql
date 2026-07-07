IF OBJECT_ID('bronze.drivers', 'U') IS NOT NULL
    DROP TABLE bronze.drivers;
GO

CREATE TABLE bronze.drivers 
(
    driver_id NVARCHAR(50) NULL,
    first_name NVARCHAR(50) NULL,
    last_name NVARCHAR(50) NULL,
    hire_date DATE NULL,
    termination_date DATE NULL,
    license_number NVARCHAR(50) NULL,
    license_state NVARCHAR(50) NULL,
    date_of_birth DATE NULL,
    home_terminal NVARCHAR(50) NULL,
    employment_status NVARCHAR(50) NULL,
    cdl_class NVARCHAR(50) NULL,
    years_experience INT NULL   
);
GO

