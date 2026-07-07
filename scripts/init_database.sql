/*
===============================================================================
Create Data Warehouse Database & Schemas
===============================================================================
Script Purpose:
    This script initializes the Logistics Data Warehouse by:
    1. Dropping the existing database (if it exists).
    2. Creating a new database.
    3. Creating the Bronze, Silver, and Gold schemas.

Schemas:
    - bronze : Stores raw data imported from source systems.
    - silver : Stores cleansed and transformed data.
    - gold   : Stores business-ready data for reporting and analytics.

Warning:
    Executing this script will permanently delete the existing
    'logistics_dwh' database and all of its contents.

===============================================================================
*/

USE master;
GO

-- Recreate the database if it already exists
IF DB_ID('logistics_dwh') IS NOT NULL
BEGIN
    ALTER DATABASE logistics_dwh SET SINGLE_USER WITH ROLLBACK IMMEDIATE; 
    DROP DATABASE logistics_dwh;
END;
GO

-- create database
CREATE DATABASE logistics_dwh;
GO

USE logistics_dwh;
GO


-- create schemas

CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO

