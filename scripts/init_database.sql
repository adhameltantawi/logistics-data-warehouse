USE master;
GO

IF DB_ID('logistics_dwh') IS NOT NULL
BEGIN
    ALTER DATABASE logistics_dwh SET SINGLE_USER WITH ROLLBACK IMMEDIATE; 
    DROP DATABASE logistics_dwh;
END;
GO

CREATE DATABASE logistics_dwh;
GO

USE logistics_dwh;
GO

CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO

