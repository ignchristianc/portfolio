-- This project will analyze traffic accidents in the United States on highways in the year 2021. The data will cover accident locations,
-- accident times, lighting conditions, weather, collision types, intersection types, land use, the presence of drunk drivers, etc.

-- Here are some questions that will be addressed in this project:
-- 1. What conditions increase the risk of accidents?
-- 2. How is the distribution of accidents by state?
-- 3. Are there peak hours for accidents?
-- 4. What is the relationship between drunk drivers and accident rates?
-- 5. How is the distribution of accidents based on land use?
-- 6. Are there any trends in terms of days with more accidents?


-------------------------------------------------------------------------------------------------------------------------------------------------

-- 1. CONDITIONS THAT INCREASE THE RISK OF ACCIDENT
	-- Analysis of accident conditions
	WITH dark_condition AS
		(SELECT 'Dark' AS light_condition,
		COUNT(CASE WHEN light_condition_name ILIKE '%- Lighted' THEN consecutive_number END) AS lighted,
		COUNT(CASE WHEN light_condition_name ILIKE '%- Not Lighted' THEN consecutive_number END) AS not_lighted,
		COUNT(CASE WHEN light_condition_name ILIKE '%- Unknown Lighting' THEN consecutive_number END) AS unknown_lighting
		FROM crash_2021
							GROUP BY light_condition),

	other_than_dark_condition AS (SELECT light_condition_name AS light_condition, 
		COUNT(CASE WHEN light_condition_name ILIKE '%- Lighted' THEN consecutive_number END) AS lighted,
		COUNT(CASE WHEN light_condition_name ILIKE '%- Not Lighted' THEN consecutive_number END) AS not_lighted,
		COUNT(consecutive_number) AS unknown_lighting
		FROM crash_2021
		WHERE light_condition_name NOT IN ('Dark - Lighted', 'Dark - Not Lighted', 'Dark - Unknown Lighting')
		GROUP BY light_condition_name)

	SELECT *
	FROM dark_condition
	UNION
	SELECT *
	FROM other_than_dark_condition
	
	-- Analysis of weather conditions
	SELECT atmospheric_conditions_1_name,
	COUNT(consecutive_number) AS number_of_accient,
	CAST(SUM(number_of_fatalities) AS DECIMAL (10,2))/CAST(COUNT(consecutive_number) AS DECIMAL (10,2))
	AS fatality_to_accident_ratio
	FROM crash_2021
	GROUP BY atmospheric_conditions_1_name
	ORDER BY fatality_to_accident_ratio DESC

	-- Analysis of collision types
	SELECT type_of_intersection_name,
	COUNT(consecutive_number) AS number_of_accient
	FROM crash_2021
	GROUP BY type_of_intersection_name
	ORDER BY number_of_accient DESC

	-- Analysis of intersection types
	SELECT manner_of_collision_name,
	COUNT(consecutive_number) AS number_of_accient
	FROM crash_2021
	GROUP BY manner_of_collision_name
	ORDER BY number_of_accient DESC


-------------------------------------------------------------------------------------------------------------------------------------------------

-- 2. DISTRIBUTION OF ACCIDENT BY STATE
	-- Top 10 states with the highest accident rates
	SELECT state_name, COUNT(consecutive_number) AS number_of_accident
	FROM crash_2021
	GROUP BY state_name
	ORDER BY number_of_accident DESC
	LIMIT 10

	-- Top 10 states with the lowest accident rates
	SELECT state_name, COUNT(consecutive_number) AS number_of_accident
	FROM crash_2021
	GROUP BY state_name
	ORDER BY number_of_accident ASC
	LIMIT 10


-------------------------------------------------------------------------------------------------------------------------------------------------

-- 3. PEAK HOURS FOR ACCIDENT
	-- Average daily accident occurrence by hour
	SELECT EXTRACT(HOUR FROM local_time) AS accident_hour,
	CAST(COUNT(consecutive_number) AS DECIMAL(10,2))/365 AS daily_accident_based_on_hour
	FROM crash_2021
	-- bisa di tambah where state_name untuk melimitasi data untuk masing-masing negara bagian
	GROUP BY EXTRACT(HOUR FROM local_time)
	ORDER BY accident_hour


-------------------------------------------------------------------------------------------------------------------------------------------------

-- 4. RELATIONSHIP BETWEEN DRUNK DRIVERS AND ACCIDENT RATES
	-- Percentage of accidents involving drunk drivers
	SELECT COUNT(CASE WHEN number_of_drunk_drivers > 0 THEN 1 END) AS drunk_accident,
	COUNT (consecutive_number) AS total_accident,
	CAST(COUNT(CASE WHEN number_of_drunk_drivers > 0 THEN 1 END) AS DECIMAL(10,2)) * 100 /
	CAST(COUNT (consecutive_number) AS DECIMAL(10,2)) AS drunk_accident_percentage
	FROM crash_2021

	-- Number of accidents involving drunk drivers by hour
	SELECT EXTRACT(HOUR FROM local_time) AS accident_hour,
	COUNT(CASE WHEN number_of_drunk_drivers > 0 THEN 1 END) AS drunk_accident,
	COUNT(CASE WHEN number_of_drunk_drivers = 0 THEN 1 END) AS sober_accident
	FROM crash_2021
	GROUP BY accident_hour
	ORDER BY accident_hour


-------------------------------------------------------------------------------------------------------------------------------------------------

-- 5. DISTRIBUTION OF ACCIDENT BY LAND USE
	-- Percentage of rural and urban accidents
	SELECT DISTINCT land_use_name, CAST(COUNT(consecutive_number) AS DECIMAL(10,2)) * 100/
	(SELECT CAST(COUNT(consecutive_number) AS DECIMAL(10,2))
	FROM crash_2021) AS accident_percentage
	FROM crash_2021
	GROUP BY land_use_name
	ORDER BY accident_percentage DESC

	-- Percentage of rural and urban accidents in each state
	SELECT state_name,
	COUNT(CASE WHEN land_use_name = 'Rural' THEN 1 END) AS rural,
	COUNT(CASE WHEN land_use_name = 'Urban' THEN 1 END) AS urban
	FROM crash_2021
	GROUP BY state_name


-------------------------------------------------------------------------------------------------------------------------------------------------

-- 6. TRENDS IN DAYS WITH MORE ACCIDENTS
	-- Number of accidents by day of the week
	SELECT CASE EXTRACT(DOW FROM local_time)
	WHEN 0 THEN 'Sunday'
	WHEN 1 THEN 'Monday'
	WHEN 2 THEN 'Tuesday'
	WHEN 3 THEN 'Wednesday'	
	WHEN 4 THEN 'Thursday'
	WHEN 5 THEN 'Friday'
	ELSE 'Saturday' END AS day_name,
	COUNT(consecutive_number) AS number_of_accident
	FROM crash_2021
	GROUP BY day_name, EXTRACT(DOW FROM local_time)
	ORDER BY EXTRACT(DOW FROM local_time)
