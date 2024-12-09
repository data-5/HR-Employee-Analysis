DROP TABLE IF EXISTS hr;
CREATE TABLE hr
(id VARCHAR(225),
first_name VARCHAR(225),
last_name VARCHAR(225),
birthdate DATE,
gender VARCHAR(225),
race VARCHAR(225),
department VARCHAR(225),
jobtitle VARCHAR(225),
location VARCHAR(225),
hire_date DATE,
termdate VARCHAR(225),
location_city VARCHAR(225),
location_state VARCHAR(225)
);
SELECT * FROM hr;
ALTER TABLE hr
ALTER COLUMN id TYPE VARCHAR(20);   

SELECT *
FROM information_schema.columns
WHERE table_name = 'hr';

UPDATE hr
SET termdate = TO_TIMESTAMP(termdate,'YYYY-MM-DD HH24:MI:SS UTC')::DATE
WHERE termdate IS NOT NULL AND termdate != '';

SELECT * FROM HR;

SELECT TERMDATE FROM HR
WHERE termdate is not null;
-- ADD AGE COLUMN
ALTER TABLE hr 
ADD COLUMN age INT;

-- SET AGE COLUMN
UPDATE hr    
SET age = EXTRACT(YEAR FROM AGE(CURRENT_DATE, birthdate ));
SELECT MIN(age) AS youngest,
		MAX(age) as oldest
	FROM hr;

-- how many records in our table have thier a
SELECT  COUNT(*) FROM hr WHERE age < 18;

-- QUESTIONS
-- 1. What is the gender breakdown of employees in the company?
SELECT gender, COUNT(*) FROM hr
WHERE AGE >= 18 AND (termdate ='0000-00-00' OR termdate IS NULL)
GROUP BY gender;

-- 2. What is the race/ethnicity breakdown of employees in the company
SELECT race, COUNT(race) as race_count
FROM hr
WHERE age >= 18 AND (termdate ='0000-00-00' OR termdate IS NULL)
GROUP BY race
ORDER BY race_count DESC;

-- 3 What is the age distribution of employee in the company?
SELECT age, COUNT(*) as count 
FROM hr
WHERE age >= 18 AND (termdate = '0000-00-00' OR termdate IS NULL)
GROUP BY age
ORDER BY AGE DESC;

SELECT MAX(age) as oldest, MIN(age) as youngest
FROM hr
WHERE age >= 18 AND (termdate = '0000-00-00' OR termdate IS NULL);

SELECT 
CASE 
	WHEN age >= 18 AND age <= 24 THEN '18-24'
	WHEN age >= 25 AND age <= 34 THEN '25-34'
	WHEN age >= 35 AND age <= 44 THEN '35-44'
	WHEN age >= 45 AND age <= 54 THEN '45-54'
	WHEN age >= 55 AND age <= 64 THEN '55-64'
	ELSE '65+'
END as age_group,
COUNT(*) as count
FROM hr
WHERE age >= 18 AND termdate IS NULL
GROUP BY age_group
ORDER BY age_group;


SELECT 
CASE 
	WHEN age >= 18 AND age <= 24 THEN '18-24'
	WHEN age >= 25 AND age <= 34 THEN '25-34'
	WHEN age >= 35 AND age <= 44 THEN '35-44'
	WHEN age >= 45 AND age <= 54 THEN '45-54'
	WHEN age >= 55 AND age <= 64 THEN '55-64'
	ELSE '65+'
END as age_group, gender,
COUNT(*) as count
FROM hr
WHERE age >= 18 AND termdate IS NULL
GROUP BY age_group, gender
ORDER BY age_group,gender;

-- 4. How many employees work at headqaurters versus remote locations?
SELECT location, COUNT(*)AS count 
FROM hr
WHERE age >= 18 AND (termdate = '0000-00-00' OR termdate IS NULL)
GROUP BY location
ORDER BY location;

-- 5. The Average length of employment for employees who have been terminated?
SELECT 
	ROUND(AVG(EXTRACT(YEAR FROM AGE(termdate::DATE,hire_date))),0) AS avg_length_employment
FROM hr
WHERE termdate::DATE <= CURRENT_DATE AND termdate IS NOT NULL AND age>= 18;

-- 6. How does the gender distribution vary across departments and job titles?
SELECT department,
gender,
COUNT(*)
FROM hr
WHERE age >= 18 AND (termdate = '0000-00-00' OR termdate IS NULL)
GROUP BY department,
gender
ORDER BY department;

-- 7. What is the distribution of the job title across the company?
SELECT jobtitle,
COUNT(*) AS count
FROM hr
WHERE age >= 18 AND (termdate = '0000-00-00' OR termdate IS NULL)
GROUP BY jobtitle
ORDER BY jobtitle DESC;

-- 8. Which department has the highest turnover rate?
SELECT 
department,
total_count,
termination_count,
ROUND(termination_count::numeric/total_count::numeric,2) as termination_rate
FROM (
SELECT department,
COUNT(*) AS total_count,
SUM(CASE WHEN termdate IS NOT NULL AND termdate::DATE <= CURRENT_DATE THEN 1 ELSE 0 END) termination_count
FROM hr
WHERE age >= 18 
GROUP BY department
) AS sub_query
ORDER BY 4 DESC;

-- 9. What is the distribution of employees across locations by city and state?
SELECT location_state,
location_city,
COUNT(*)
FROM hr
WHERE age >= 18 AND  termdate IS NULL
GROUP BY location_state,location_city
ORDER BY 1,3 DESC;
-- or we just choose one(location_state)
SELECT location_state,
COUNT(*) AS count
FROM hr
WHERE age >= 18 AND  termdate is NULL
GROUP BY location_state
ORDER BY count DESC;
-- then choose the other (location_city)
SELECT location_city,
COUNT(*) AS count
FROM hr
WHERE age >= 18 AND  termdate is NULL
GROUP BY location_city
ORDER BY count DESC;

-- 10. How has the company's employee count changed over time based on  hire and term dates?
SELECT EXTRACT(YEAR FROM hire_date) AS hire_date,
EXTRACT (YEAR FROM termdate::DATE) AS term_date,
COUNT(*)
FROM hr
WHERE age >= 18
GROUP BY 1,2
ORDER BY 1 DESC;
-- or we create a subquery
SELECT 
year,
hires,
terminations,
hires - terminations AS net_change,
ROUND((hires - terminations)::numeric/hires * 100,2) AS net_change_percent
FROM 
(
SELECT 
EXTRACT(YEAR FROM(hire_date)) as year,
COUNT(hire_date) AS hires,
SUM(CASE WHEN termdate IS NOT NULL AND (EXTRACT(YEAR FROM (termdate::DATE)) = EXTRACT(YEAR FROM(hire_date))) THEN 1 ELSE 0 END) AS terminations
FROM hr
WHERE age >= 18
GROUP BY year
) AS subquery
ORDER BY 1 DESC;

-- 11. What is the tenure distribution for each department?
	SELECT department,
	EXTRACT(YEAR FROM(termdate::DATE)),
	COUNT(*)
FROM hr
GROUP BY 1,2
ORDER BY 1,2; 

-- USING AVERAGE 
SELECT 
department,
ROUND(AVG((termdate::DATE - hire_date)::NUMERIC/365)) AS avg_tenure
FROM hr
WHERE age>=18 AND termdate IS NOT NULL AND termdate::DATE <= CURRENT_DATE
GROUP BY 1;
-- or
SELECT 
department,
AVG(AGE(termdate::DATE,hire_date)) AS avg_tenure
FROM hr
WHERE age>=18 AND termdate IS NOT NULL AND termdate::DATE <= CURRENT_DATE
GROUP BY 1;


