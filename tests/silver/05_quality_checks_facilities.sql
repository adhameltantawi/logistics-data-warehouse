SELECT facility_id
FROM bronze.facilities
WHERE facility_id IS NULL
   OR facility_id = ''
   OR LEN(facility_id) != 8;


SELECT facility_name
FROM bronze.facilities
WHERE facility_name IS NULL
   OR facility_name = ''
   OR facility_name != TRIM(facility_name);


SELECT facility_type
FROM bronze.facilities
WHERE facility_name IS NULL
   OR facility_name = '';


SELECT DISTINCT facility_type
FROM bronze.facilities