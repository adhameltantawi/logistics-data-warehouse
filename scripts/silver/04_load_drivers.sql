INSERT INTO silver.drivers 
(
    driver_id,
    first_name,
    last_name,
    hire_date,
    termination_date,
    license_number,
    license_state,
    date_of_birth,
    home_terminal,
    employment_status,
    cdl_class,
    years_experience
)
SELECT
    *
FROM bronze.drivers;
