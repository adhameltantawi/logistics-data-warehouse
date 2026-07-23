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
WHERE facility_type IS NULL
   OR facility_type = '';


SELECT DISTINCT facility_type
FROM bronze.facilities;


SELECT city
FROM bronze.facilities
WHERE city IS NULL
   OR city = ''
   OR city != TRIM(city);


SELECT state
FROM bronze.facilities
WHERE city IS NULL
   OR city = ''
   OR city != TRIM(city)
   OR LEN(state) != 2;


SELECT latitude
FROM bronze.facilities
WHERE latitude IS NULL
   OR latitude = ''
   OR latitude NOT BETWEEN -90 AND 90;



SELECT longitude
FROM bronze.facilities
WHERE longitude IS NULL
   OR longitude = ''
   OR longitude NOT BETWEEN -180 AND 180;


SELECT * 
FROM bronze.facilities
WHERE longitude = 0
  AND latitude = 0;


SELECT 
   longitude,
   latitude,
   COUNT(*) AS cnt
FROM bronze.facilities
GROUP BY longitude,
         latitude
HAVING COUNT(*) > 1
ORDER BY cnt DESC;


SELECT
    facility_id,
    facility_name,
    city,
    state,
    latitude,
    longitude
FROM bronze.facilities
WHERE latitude = 25.7617
  AND longitude = -80.1918;


SELECT
    facility_name,
    COUNT(*) AS cnt
FROM bronze.facilities
GROUP BY facility_name
HAVING COUNT(*) > 1;