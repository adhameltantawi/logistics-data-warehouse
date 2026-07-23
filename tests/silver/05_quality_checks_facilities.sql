SELECT facility_id
FROM bronze.facilities
WHERE facility_id IS NULL
   OR facility_id = ''
   OR LEN(facility_id) != 8;
