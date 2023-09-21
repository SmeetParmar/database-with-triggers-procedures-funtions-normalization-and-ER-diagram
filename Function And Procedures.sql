use group_project;

-- View containing information about provinces and cities of Canada
CREATE VIEW canadaDetails AS
SELECT city, province
FROM city_table;

-- Calling the view,
select * from canadaDetails;

-- To drop this view,
-- Drop view canadaDetails;


-- View providing a brief summary of current weather details
CREATE VIEW summaryView AS
SELECT cw.date, ct.city, wd.temperature, wd.humidity, aqt.air_quality_index
FROM current_weather cw
JOIN city_table ct ON cw.city_id = ct.city_id
JOIN weather_details_table wd ON cw.weather_id = wd.weather_id
JOIN air_quality_table aqt ON cw.air_quality_id = aqt.air_quality_id;

-- Calling the view,
select * from summaryView;

-- To drop this view,
-- Drop view summaryView;


-- Creating users with their respective password,
CREATE USER 'smeet'@'localhost' IDENTIFIED BY '123';
CREATE USER 'kirtan'@'localhost' IDENTIFIED BY '456';
CREATE USER 'harshil'@'localhost' IDENTIFIED BY '789';
CREATE USER 'azmi'@'localhost' IDENTIFIED BY '111';
CREATE USER 'bhanu'@'localhost' IDENTIFIED BY '222';

-- Granting privilegeS for city_table of group_project schema
GRANT SELECT ON group_project.city_table TO kirtan@localhost, azmi@localhost, harshil@localhost, bhanu@localhost;
GRANT SELECT, INSERT, UPDATE, DELETE ON group_project.city_table TO smeet@localhost;

-- Revoking privilegeS for city_table of group_project schema
REVOKE SELECT, INSERT, UPDATE, DELETE ON group_project.city_table FROM kirtan@localhost, azmi@localhost, harshil@localhost, bhanu@localhost;

-- Function to get quality of air according to Air_Quality_Index

DELIMITER //
CREATE FUNCTION CalculateAQI(air_quality_value INT) RETURNS varchar(50)
BEGIN
    DECLARE aqi Varchar(50);
    
    IF air_quality_value > 0 && air_quality_value < 50 THEN
        SET aqi = "GOOD";
    ELSEIF air_quality_value > 50 THEN
        SET aqi = "Moderate";
    ELSEIF air_quality_value < 100 && air_quality_value > 50 THEN
        SET aqi = "Unhealthy";
    ELSE
        SET aqi = "Error Retriving Data";
    END IF;
    
    RETURN aqi;
END //
DELIMITER ;

-- Calling the function
SELECT CalculateAQI(89); -- Replace the value with the air quality value you want to calculate AQI for

-- To Drop the function 
-- Drop function CalculateAQI;


-- Function which suggests activities according to weather condition
DELIMITER //
CREATE FUNCTION GetRecommendedActivities(city_name varchar(30)) RETURNS VARCHAR(200)
BEGIN
    DECLARE conditions VARCHAR(50);
    DECLARE city VARCHAR(30);
    
    SELECT c.city, wc.weather_condition INTO city, conditions FROM current_weather cw
    JOIN city_table c ON cw.city_id = c.city_id 
    JOIN weather_condition_table wc ON cw.weather_condition_id = wc.weather_condition_id
    WHERE c.city = city_name; 

    IF conditions = 'Sunny' || conditions = 'Clear Skies' THEN
        RETURN 'Recommended activities: Picnic, hiking, and outdoor sports.';
    ELSEIF conditions = 'Cloudy' || conditions = 'Partly Cloudy' THEN
        RETURN 'Recommended activities: Walk in the park, photography, and outdoor reading.';
    ELSEIF conditions = 'Rainy' || conditions = 'Snow' THEN
        RETURN 'Recommended activities: Indoor movies, cooking, and cozy indoor activities.';
    ELSE
        RETURN 'Error Retriving Information......';
    END IF;
END//

DELIMITER ;

-- Calling the function
SELECT GetRecommendedActivities("Kitchener");

-- To drop the function.
-- drop function GetRecommendedActivitiesn;

-- prepare for inserting current weather data

DELIMITER //
CREATE PROCEDURE InsertCurrentWeather(
    in_date DATE,
    in_city_id INT,
    in_weather_id INT,
    in_air_quality_id INT,
    in_condition_id INT,
    in_time_id INT
)
BEGIN
    INSERT INTO current_weather (
        date,
        city_id,
        weather_id,
        air_quality_id,
        weather_condition_id,
        time_id
    )
    VALUES (
        in_date,
        in_city_id,
        in_weather_id,
        in_air_quality_id,
        in_condition_id,
        in_time_id
    );
END //
DELIMITER ;

-- Calling procedure,
CALL InsertCurrentWeather('2023-08-07', 1, 1, 1, 3, 1);

-- To drop procedure,
-- Drop procedure InsertCurrentWeather;


-- Procedure for updating weather details

DELIMITER $$
CREATE PROCEDURE UpdateWeatherDetails(
    in_weather_id INT,
    in_temperature INT,
    in_fells_like INT,
    in_humidity VARCHAR(90),
    in_pressure VARCHAR(45),
    in_visibility VARCHAR(45),
    in_uv_index INT
)
BEGIN

    UPDATE weather_details_table
    SET temperature = in_temperature,
        fells_like = in_fells_like,
        humidity = in_humidity,
        pressure = in_pressure,
        visibility = in_visibility,
        uv_index = in_uv_index
    WHERE weather_id = in_weather_id;
    

END $$
DELIMITER ;

-- Starting transaction;
START TRANSACTION;

-- Calling procedure,
CALL UpdateWeatherDetails(4,21,20,'40%','1050hPa','10km',5);

-- Commiting work after successful execution of above query, if there is any error in the above query it will not commit the transaction.
commit;

-- To drop the procedure
-- drop procedure UpdateWeatherDetails;

-- Procedure for deleting old weather data

DELIMITER //
CREATE PROCEDURE DeleteOldWeatherData(
    delete_date DATE
)
BEGIN
    DELETE FROM `group_project`.`current_weather`
    WHERE `date` < delete_date;
END //
DELIMITER  //;

-- Calling the Procedure
CALL DeleteOldWeatherData('2023-08-29');

-- To drop procedure
-- Drop procedure DeleteOldWeatherData;