

-- MVP
--Q1
-- (a). Find the first name, last name and team name of employees who are members of
-- teams.

SELECT 
	E.first_name,
	E.last_name,
	T."name"
FROM employees AS E
INNER JOIN teams AS T ON T.id = E.team_id; 

-- (b). Find the first name, last name and team name of employees who are members of
-- teams and are enrolled in the pension scheme.

SELECT 
	E.first_name,
	E.last_name,
	T."name"
FROM employees AS E
INNER JOIN teams AS T ON T.id = E.team_id
WHERE pension_enrol IS TRUE AND T.id IS NOT NULL;

-- (c). Find the first name, last name and team name of employees who are members of
-- teams, where their team has a charge cost greater than 80.

SELECT 
	E.first_name,
	E.last_name,
	T."name",
	T.charge_cost
FROM employees AS E
INNER JOIN teams AS T ON T.id = E.team_id
WHERE CAST(T.charge_cost AS DECIMAL) > 80;

-- Q2
-- (a). Get a table of all employees details, together with their local_account_no and
-- local_sort_code, if they have them.

SELECT *
FROM employees AS E
LEFT JOIN pay_details AS PD ON E.pay_detail_id = PD.id;

-- (b). Amend your query above to also return the name of the team that each employee
-- belongs to.

SELECT *
FROM employees AS E
LEFT JOIN pay_details AS PD ON E.pay_detail_id = PD.id
LEFT JOIN teams AS T ON E.team_id = T.id;

-- Q3
-- (a). Make a table, which has each employee id along with the team that employee
-- belongs to.

SELECT 
	E.id,
	T."name" 
FROM employees AS E
LEFT JOIN teams AS T ON E.team_id = T.id;

-- (b). Breakdown the number of employees in each of the teams.

SELECT
	T."name", 
	count(E.id)
FROM employees AS E
LEFT JOIN teams AS T ON E.team_id = T.id
GROUP BY T."name";

-- (c). Order the table above by so that the teams with the least employees come first.

SELECT
	T."name", 
	count(*) AS team_members
FROM employees AS E
LEFT JOIN teams AS T ON E.team_id = T.id
GROUP BY T."name"
ORDER BY team_members ASC;

-- Q4
-- (a). Create a table with the team id, team name and the count of the number of
-- employees in each team.

SELECT
	T.id,
	T."name", 
	count(*) AS team_members
FROM employees AS E
LEFT JOIN teams AS T ON E.team_id = T.id
GROUP BY T. id, T."name"
ORDER BY T.id;

-- (b). The total_day_charge of a team is defined as the charge_cost of the team
-- multiplied by the number of employees in the team. Calculate the total_day_charge
-- for each team.

SELECT
	T.id,
	T."name",
	count(T.id) * CAST(T.charge_cost AS DECIMAL) AS total_day_charge
FROM employees AS E
LEFT JOIN teams AS T ON E.team_id = T.id
GROUP BY t.id
ORDER BY T.id;

-- (c). How would you amend your query from above to show only those teams with a
-- total_day_charge greater than 5000?

SELECT
	T.id,
	T."name",
	count(T.id) * CAST(T.charge_cost AS DECIMAL) AS total_day_charge
FROM employees AS E
LEFT JOIN teams AS T ON E.team_id = T.id
GROUP BY t.id
HAVING count(T.id) * CAST(T.charge_cost AS DECIMAL) > 5000
ORDER BY T.id;

-- EXTENSION
-- Q5.
-- How many of the employees serve on one or more committees?

--SELECT *
--FROM employees AS E
--LEFT JOIN employees_committees AS EC ON E.id = EC.employee_id
--LEFT JOIN committees AS C ON EC.committee_id = C.id;
--
--SELECT 
--	C.name,
--	E.first_name,
--	E.last_name,
--	count(DISTINCT(E.id))
--FROM committees AS C
--LEFT JOIN employees_committees AS CE ON C.id = CE.committee_id
--LEFT JOIN employees AS E ON E.id = CE.employee_id
--GROUP BY C.name, E.first_name, E.last_name;

SELECT 
	count(DISTINCT(employee_id)) AS distinct_employees_in_comittees,
FROM employees_committees

-- Q6
-- How many of the employees do not serve on a committee?

SELECT
	count(*) AS num_no_committees
FROM employees AS E
LEFT JOIN employees_committees AS EC ON E.id = EC.employee_id
WHERE EC.committee_id IS NULL;

