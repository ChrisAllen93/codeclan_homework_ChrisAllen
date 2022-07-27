
-- MVP
-- Question 1.
-- How many employee records are lacking both a grade and salary?

SELECT
	count(id)
FROM employees 
WHERE grade IS NULL AND salary IS NULL;


-- Question 2
-- Produce a table with the two following fields (columns):
-- - the department
-- - the employees full name (first and last name)
-- Order your resulting table alphabetically by department, and then by last name

SELECT
	department,
	concat(first_name, ' ', last_name) AS full_name
FROM employees
ORDER BY department, last_name;

-- Question 3.
-- Find the details of the top ten highest paid employees who have a last_name beginning
-- with ‘A’.

SELECT *
FROM employees
WHERE last_name LIKE 'A%'
ORDER BY salary DESC NULLS LAST
LIMIT 10;

-- Question 4.
-- Obtain a count by department of the employees who started work with the corporation in 2003.

SELECT
	count(id) AS count_started_in_2003
FROM employees 
WHERE start_date BETWEEN '2003-01-01' AND '2003-12-31';

-- Question 5.
-- Obtain a table showing department, fte_hours and the number of employees in each department who work
-- each fte_hours pattern. Order the table alphabetically by department, and then in ascending order of
-- fte_hours.

SELECT
	department,
	fte_hours,
	count(id) AS employees
FROM employees
GROUP BY department, fte_hours
ORDER BY department, fte_hours;

-- Question 6.
-- Provide a breakdown of the numbers of employees enrolled, not enrolled, and with unknown enrollment
-- status in the corporation pension scheme.

SELECT 
	CASE
		WHEN pension_enrol = TRUE THEN 'Yes'
		WHEN pension_enrol = FALSE THEN 'No'
		ELSE 'Unknown'
	END AS is_pension_enrolled,
	count(id)
FROM employees
GROUP BY pension_enrol;

-- Question 7
-- Obtain the details for the employee with the highest salary in the ‘Accounting’ department who is not
-- enrolled in the pension scheme?
	
SELECT *
FROM employees 
WHERE department = 'Accounting' AND pension_enrol IS FALSE
ORDER BY salary DESC NULLS LAST
LIMIT 1;
	
-- Question 8.
-- Get a table of country, number of employees in that country, and the average salary of employees in
-- that country for any countries in which more than 30 employees are based. Order the table by average
-- salary descending.

SELECT 
	country,
	count(id) AS num_employees,
	avg(salary) AS avg_salary
FROM employees
GROUP BY country
HAVING count(id) > 30
ORDER BY avg_salary DESC;

-- Question 9.
-- Return a table containing each employees first_name, last_name, full-time equivalent hours
-- (fte_hours), salary, and a new column effective_yearly_salary which should contain fte_hours
-- multiplied by salary. Return only rows where effective_yearly_salary is more than 30000.

SELECT
	first_name,
	last_name,
	fte_hours,
	salary,
	fte_hours * salary AS effective_yearly_salary
FROM employees
WHERE fte_hours * salary > 30000;

-- Question 10.
-- Find the details of all employees in either Data Team 1 or Data Team 2

SELECT *
FROM employees AS E
INNER JOIN teams AS T ON E.team_id = T.id
WHERE T.name LIKE 'Data Team%';

-- Question 11.
-- Find the first name and last name of all employees who lack a local_tax_code.

SELECT *
FROM employees AS E
INNER JOIN pay_details AS PD ON E.pay_detail_id = PD.id
WHERE PD.local_tax_code IS NULL;

-- Question 12.
-- The expected_profit of an employee is defined as (48 * 35 * charge_cost - salary) * fte_hours, where
-- charge_cost depends upon the team to which the employee belongs. Get a table showing expected_profit
--  for each employee.

(48 * 35 * charge_cost - salary) * fte_hours AS expected_profit


SELECT
	E.first_name,
	E.last_name,
	T.charge_cost,
	E.salary,
	E.fte_hours,
	(48 * 35 * CAST(charge_cost AS decimal) - salary) * fte_hours AS expected_profit
FROM employees AS E
INNER JOIN teams AS T ON E.team_id = T.id; 

-- Question 13.
-- Find the first_name, last_name and salary of the lowest paid employee in Japan who works the least
-- common full-time equivalent hours across the corporation.”

SELECT
	country,
	first_name,
	last_name,
	salary,
	fte_hours 
FROM employees 
WHERE country = 'Japan' AND fte_hours = (
	SELECT
		fte_hours
	FROM employees
	GROUP BY fte_hours
	ORDER BY count(fte_hours)
	LIMIT 1)
ORDER BY salary
LIMIT 1;

-- Question 14.
-- Obtain a table showing any departments in which there are two or more employees lacking a stored
-- first name. Order the table in descending order of the number of employees lacking a first name, and
-- then in alphabetical order by department.

SELECT
	department,
	count(id) AS num_missing_fn
FROM employees
WHERE first_name IS NULL
GROUP BY department
HAVING count(id) >= 2
ORDER BY num_missing_fn DESC, department;

-- Question 15.
-- Return a table of those employee first_names shared by more than one employee, together with a count
-- of the number of times each first_name occurs. Omit employees without a stored first_name from the
-- table. Order the table descending by count, and then alphabetically by first_name.

SELECT
	first_name,
	count(id) AS num_matches
FROM employees
WHERE first_name IS NOT NULL
GROUP BY first_name
ORDER BY num_matches DESC, first_name;

-- Question 16
-- Find the proportion of employees in each department who are grade 1.

SELECT
	department,
	CAST(sum(grade) AS REAL) / CAST(count(grade) AS REAL) AS frac_grade_1
FROM employees
GROUP BY department;

-- EXTENSION
-- Question 1.
-- Get a list of the id, first_name, last_name, department, salary and fte_hours of employees in the
-- largest department. Add two extra columns showing the ratio of each employee’s salary to that
-- department’s average salary, and each employee’s fte_hours to that department’s average fte_hours.

SELECT
	id,
	first_name,
	last_name,
	department,
	salary,
	fte_hours,
	salary / avg(salary) OVER (PARTITION BY department) AS frac_dep_salary,
	fte_hours / avg(fte_hours) OVER (PARTITION BY department) frac_dep_fte
FROM employees
WHERE department = (
	SELECT department
	FROM employees
	GROUP BY department
	ORDER BY count(id) DESC
	LIMIT 1
	);

-- [Extension - really tough! - how could you generalise your query to be able to handle the fact that
-- two or more departments may be tied in their counts of employees. In that case, we probably don’t want
-- to arbitrarily return details for employees in just one of these departments].

SELECT
	id,
	first_name,
	last_name,
	department,
	salary,
	fte_hours,
	salary / avg(salary) OVER (PARTITION BY department) AS frac_dep_salary,
	fte_hours / avg(fte_hours) OVER (PARTITION BY department) frac_dep_fte
FROM employees
WHERE department IN (
	SELECT
		department
	FROM employees
	GROUP BY department
	HAVING count(id) = (
		SELECT
			count(id)
		FROM employees
		GROUP BY department
		ORDER BY count(id) DESC
		LIMIT 1)
);

-- Question 2.
-- Have a look again at your table for MVP question 6. It will likely contain a blank cell for the row
-- relating to employees with ‘unknown’ pension enrollment status. This is ambiguous: it would be better
-- if this cell contained ‘unknown’ or something similar. Can you find a way to do this, perhaps using a
-- combination of COALESCE() and CAST(), or a CASE statement?

SELECT 
	CASE
		WHEN pension_enrol = TRUE THEN 'Yes'
		WHEN pension_enrol = FALSE THEN 'No'
		ELSE 'Unknown'
	END AS is_pension_enrolled,
	count(id)
FROM employees
GROUP BY pension_enrol;

-- Question 3.
-- Find the first name, last name, email address and start date of all the employees who are members of
-- the ‘Equality and Diversity’ committee. Order the member employees by their length of service in the
-- company, longest first.

SELECT
	E.first_name,
	E.last_name,
	E.email,
	E.start_date
FROM employees AS E
INNER JOIN employees_committees AS EC ON E.id = EC.employee_id
INNER JOIN committees AS C ON EC.committee_id = C.id
WHERE name = 'Equality and Diversity'
ORDER BY start_date; 

-- Question 4.
-- Use a CASE() operator to group employees who are members of committees into salary_class of 'low'
-- (salary < 40000) or 'high' (salary >= 40000). A NULL salary should lead to 'none' in salary_class.
-- Count the number of committee members in each salary_class.

SELECT
	CASE
		WHEN salary < 40000 THEN 'Low'
		WHEN salary >= 40000 THEN 'High'
		ELSE 'None'
	END AS salary_class,
	count(E.id) AS num_employees
FROM employees AS E
INNER JOIN employees_committees AS EC ON E.id = EC.employee_id
INNER JOIN committees AS C ON EC.committee_id = C.id
GROUP BY salary_class
ORDER BY num_employees DESC;





















