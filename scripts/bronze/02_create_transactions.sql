IF OBJECT_ID('bronze.delivery_events', 'U') IS NOT NULL
    DROP TABLE bronze.delivery_events
GO

CREATE TABLE bronze.delivery_events
(
    event_id NVARCHAR(20) NULL,
    load_id NVARCHAR(20) NULL,
    trip_id NVARCHAR(20) NULL,
    event_type NVARCHAR(15) NULL,
    facility_id NVARCHAR(20) NULL,
    scheduled_datetime TIME NULL,
    actual_datetime TIME NULL,
    detention_minutes INT NULL,
    on_time_flag TIME NULL,
    location_city NVARCHAR(50) NULL,
    location_state NCHAR(2) NULL
)