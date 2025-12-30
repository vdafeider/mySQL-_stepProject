-- SQL step project

-- Database design:
-- 1. Create a database for course management. The database should include the following tables:
-- students: student_no, teacher_no, course_no, student_name, email, birth_date.
-- teachers: teacher_no, teacher_name, phone_no
-- courses: course_no, course_name, start_date, end_date

CREATE DATABASE courses_management;
USE courses_management;

CREATE TABLE IF NOT EXISTS courses_management.teachers (
  teacher_no INT AUTO_INCREMENT PRIMARY KEY,
    teacher_name VARCHAR(100) NOT NULL,
    phone_no VARCHAR(20)
);

CREATE TABLE IF NOT EXISTS courses_management.courses (
    course_no INT AUTO_INCREMENT PRIMARY KEY,
    course_name VARCHAR(100) NOT NULL,
    start_date DATE,
    end_date DATE
);

CREATE TABLE IF NOT EXISTS courses_management.students (
    student_no INT AUTO_INCREMENT PRIMARY KEY,
    teacher_no INT,
    course_no INT,
    student_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    birth_date DATE,
  CONSTRAINT check_email
        CHECK (email REGEXP '^[^@]+@[^@]+\\.[^@]+$'),
    CONSTRAINT fk_teacher
        FOREIGN KEY (teacher_no)
        REFERENCES courses_management.teachers (teacher_no),
    CONSTRAINT fk_course
        FOREIGN KEY (course_no)
        REFERENCES courses_management.courses (course_no)
);

-- 2. Add any data (7–10 rows) to each table.
START TRANSACTION;

INSERT INTO courses_management.courses (course_name, start_date, end_date) VALUES
('SQL Basics', '2025-01-10', '2025-02-10'),
('Advanced SQL', '2025-02-15', '2025-03-15'),
('Python', '2025-03-01', '2025-04-01'),
('Excel', '2025-04-05', '2025-05-05'),
('Power BI', '2025-05-10', '2025-06-10'),
('Tableau', '2025-06-15', '2025-07-15'),
('Machine Learning', '2025-07-20', '2025-08-20');

INSERT INTO courses_management.teachers (teacher_name, phone_no) VALUES
('Vlad Bestuzhev', '0501111111'),
('Emily Johnson', '0502222222'),
('Michael Brown', '0503333333'),
('Sarah Wilson', '0504444444'),
('David Taylor', '0505555555'),
('Laura Anderson', '0506666666'),
('Daniel Thomas', '0507777777');

INSERT INTO courses_management.students (teacher_no, course_no, student_name, email, birth_date) VALUES
(1, 1, 'Anna White', 'anna.white@gmail.com', '2003-05-12'),
(2, 2, 'James Miller', 'james.miller@gmail.com', '2002-11-03'),
(3, 3, 'Emily Clark', 'emily.clark@gmail.com', '2004-01-25'),
(4, 4, 'Robert Lewis', 'robert.lewis@gmail.com', '2001-09-14'),
(5, 5, 'Olivia Harris', 'olivia.harris@gmail.com', '2003-07-30'),
(6, 6, 'William Young', 'william.young@gmail.com', '2002-02-18'),
(7, 7, 'Sophia King', 'sophia.king@gmail.com', '2004-12-09'),
(1, 1, 'Benjamin Scott', 'benjamin.scott@gmail.com', '2003-03-06'),
(3, 5, 'Ivan Ivanenko', 'iv.ivan@gmail.com', '2004-12-09'),
(1, 3, 'Taras Shevchenko', 't.sheva@gmail.com', '2003-03-06');

COMMIT;

-- 3. For each teacher, show the number of students they have worked with
CREATE VIEW courses_management.teacher_student_count AS
SELECT
    t.teacher_no,
    t.teacher_name,
    COUNT(s.student_no) AS student_count
FROM courses_management.teachers t
LEFT JOIN courses_management.students s
    ON t.teacher_no = s.teacher_no
GROUP BY
    t.teacher_no,
    t.teacher_name;
    
SELECT * FROM courses_management.teacher_student_count;

-- 4. Intentionally create 3 duplicates in the students table (add 3 identical rows)
-- 5. Write a query that outputs duplicate rows in the students table
INSERT INTO courses_management.students (teacher_no, course_no, student_name, email, birth_date)
SELECT st.teacher_no, st.course_no, st.student_name, 
       CONCAT('dup', n.n, '_', st.email), st.birth_date
FROM courses_management.students as st
JOIN (SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3) AS n
WHERE st.student_no = 1;

SELECT *
FROM courses_management.students;

SELECT
    st.teacher_no,
    st.course_no,
    st.student_name,
    st.birth_date,
    COUNT(*) AS duplicate_count,
    GROUP_CONCAT(st.student_no) AS student_ids
FROM courses_management.students AS st
GROUP BY 
    st.teacher_no, 
    st.course_no, 
    st.student_name, 
    st.birth_date
HAVING COUNT(*) > 1;

DELETE FROM courses_management.students
WHERE student_no IN (11, 12, 13);




-- Queries to training MySQL dataset
-- 1. Show the average salary of employees for each year up to 2005.
-- Determine the minimum year and store it in a variable
SET @min_year := (
    SELECT MIN(YEAR(from_date))
    FROM employees.salaries
);
-- Recursive CTE to generate years up to 2004
WITH RECURSIVE all_years AS (
    SELECT @min_year AS year
    UNION ALL
    SELECT year + 1
    FROM all_years
    WHERE year + 1 <= 2004
)
SELECT
    y.year,
    AVG(s.salary) AS avg_salary
FROM all_years AS y
JOIN employees.salaries AS s
    ON s.from_date <= MAKEDATE(y.year, 365)
   AND s.to_date >= MAKEDATE(y.year, 1)
GROUP BY y.year
ORDER BY y.year;


-- 2. Show the average salary of employees for each department.
-- Note: it is necessary to calculate based on the current salary and the current department of employees
SELECT 
    d.dept_no,
    d.dept_name,
    AVG(s.salary) AS avg_salary
FROM employees.employees AS e
JOIN employees.salaries AS s 
    ON e.emp_no = s.emp_no
JOIN employees.dept_emp AS de 
    ON e.emp_no = de.emp_no
JOIN employees.departments AS d 
    ON de.dept_no = d.dept_no
WHERE s.to_date > CURDATE() -- salary is valid after the current date
  AND de.to_date > CURDATE() -- department assignment is valid after the current date
GROUP BY d.dept_no, d.dept_name
ORDER BY d.dept_no;


-- 3. Show the average salary of employees for each department for each year
-- Determine the minimum year in the salaries table and the current year
SET @min_year := (SELECT MIN(YEAR(from_date)) FROM employees.salaries);
SET @max_year := YEAR(CURDATE());

-- Generate all years from @min_year to the current year using a recursive CTE
WITH RECURSIVE years AS (
    SELECT @min_year AS year
    UNION ALL
    SELECT year + 1
    FROM years
    WHERE year + 1 <= @max_year
)
SELECT
    d.dept_no,
    d.dept_name,
    y.year,
    AVG(s.salary) AS avg_salary
FROM employees.departments AS d
JOIN employees.dept_emp AS de ON d.dept_no = de.dept_no
JOIN employees.employees AS e ON e.emp_no = de.emp_no
JOIN employees.salaries AS s ON e.emp_no = s.emp_no
JOIN years AS y
    ON s.from_date <= MAKEDATE(y.year, 365)  -- salary started before the end of the year (including previous years)
   AND s.to_date >= MAKEDATE(y.year, 1)     -- salary ended after the beginning of the year
GROUP BY d.dept_no, d.dept_name, y.year
ORDER BY d.dept_no, y.year;


-- 4. Show departments where more than 15,000 employees currently work.
SELECT 
    d.dept_no,
    d.dept_name,
    COUNT(*) AS current_employees
FROM employees.dept_emp de
JOIN employees.departments d 
  ON de.dept_no = d.dept_no
WHERE de.to_date > CURDATE()
GROUP BY d.dept_no, d.dept_name
HAVING COUNT(*) > 15000;

-- 5. For the manager who has worked the longest, show their number, department,
-- hire date, and last name
SELECT 
    e.emp_no,
    de.dept_no,
    dep.dept_name,
    de.from_date AS hire_date,
    e.last_name
FROM employees.employees e
JOIN employees.dept_manager dm 
  ON e.emp_no = dm.emp_no
JOIN employees.dept_emp de 
  ON e.emp_no = de.emp_no
JOIN employees.departments as dep
  ON dep.dept_no = de.dept_no
WHERE dm.to_date > CURDATE() 
  AND de.to_date > CURDATE()
ORDER BY de.from_date
LIMIT 1;

-- 6. Show the top 10 active employees of the company with the largest difference
-- between their salary and the average salary in their department.
WITH current_employees AS (
    SELECT 
        e.emp_no,
        CONCAT(e.first_name, ' ', e.last_name) AS full_name,
        s.salary,
        de.dept_no
    FROM employees.employees AS e
    JOIN employees.salaries AS s 
        ON e.emp_no = s.emp_no
    JOIN employees.dept_emp AS de 
        ON e.emp_no = de.emp_no
    WHERE s.to_date > CURDATE() 
      AND de.to_date > CURDATE()
),
dept_avg AS (
  SELECT 
    d.dept_name,
    d.dept_no,
    AVG(s.salary) AS average_salary
  FROM employees e
  JOIN dept_emp de ON e.emp_no = de.emp_no
  JOIN departments d ON de.dept_no = d.dept_no
  JOIN salaries s ON e.emp_no = s.emp_no
  WHERE de.to_date > CURDATE()
    AND s.to_date > CURDATE()
  GROUP BY d.dept_name
),
salary_diff AS (
    SELECT 
        ce.emp_no,
        ce.full_name,
        ce.salary,
        da.average_salary,
        da.dept_name,
        ce.salary - da.average_salary AS salary_difference
    FROM current_employees ce
    JOIN dept_avg da
        ON ce.dept_no = da.dept_no
)
SELECT *
FROM salary_diff
ORDER BY ABS(salary_difference) DESC
LIMIT 10;

-- 7. For each department, show the second manager in order.
-- It is necessary to output the department, the manager’s first and last name,
-- the manager’s hire date, and the date when they became the department manager
WITH ranked_managers AS (
    SELECT 
        dm.dept_no,
        e.first_name,
        e.last_name,
        de.from_date AS hire_date,
        dm.from_date AS manager_from,
        ROW_NUMBER() OVER (PARTITION BY dm.dept_no ORDER BY dm.from_date) AS rn
    FROM employees.dept_manager AS dm
    JOIN employees.employees AS e ON dm.emp_no = e.emp_no
    JOIN employees.dept_emp AS de ON e.emp_no = de.emp_no
)
SELECT *
FROM ranked_managers
WHERE rn = 2
ORDER BY dept_no;

