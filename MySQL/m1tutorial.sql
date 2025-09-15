-- (1) DDL - Data Definition Language
-- 1 - Creation of DB
-- list all the databases in the server
show databases; 
-- create db
create database if not exists db_name;
create database if not exists organisation;
-- make switching b/w DBs 
use organisation;
-- list tables in the selected db
show tables;
-- drop db 
drop database if exists db_name;

-- 2 - Creation of Tables
-- parent table 
create table department(
d_id int,
d_name varchar(50),
d_location varchar(50)
);
-- child table
create table tb_name(
-- create column in the table
id int,
name char(20)
);

-- 3 ALTER Operations - to change in the database schema
-- RENAME TO - rename table name itself
alter table tb_name rename to employee; 
-- CHANGE COLUMN - rename column namedepartmentemployee
alter table employee change column id e_id int;
alter table employee change column name e_name char(20);
-- MODIFY - change datatype of an attribute
alter table employee modify e_name varchar(20);
-- ADD - add new column
alter table employee add e_age int, add e_gender varchar(50), add e_salary int, add e_dept_id int;
-- DROP COLUMN - drop a column completely
alter table employee drop column col_name;

-- 4 - Constraints
-- PRIMARY KEY, NOT NULL, UNIQUE constraints
alter table department modify d_id int primary key not null unique;
alter table employee modify e_id int primary key not null unique;
-- CHECK constraint
alter table employee modify e_age int check (e_age > 18); 
-- DEFAULT constraint
alter table employee modify e_dept_id int default 1;
-- FOREIGN KEY, ON UPDATE CASCADE, ON DELETE SET NULL, ON DELETE CASCADE constraints
alter table employee modify e_dept_id int, add foreign key (e_dept_id) references department(d_id); -- we do not use this alone because of delete constraints
alter table employee modify e_dept_id int, add foreign key (e_dept_id) references department(d_id) on update cascade; -- we also do not use this because of the same reason 
alter table employee modify e_dept_id int, add foreign key (e_dept_id) references department(d_id) on delete set null;
alter table employee modify e_dept_id int, add foreign key (e_dept_id) references department(d_id) on delete cascade;
alter table employee modify e_dept_id int, add foreign key (e_dept_id) references department(d_id) on delete set null,
    add foreign key (e_dept_id) references department(d_id) on delete cascade;

create table student1(
    st1_id int primary key unique not null,
    st1_name varchar(50),
    st1_college_name varchar(100)
    );
create table student2(
    st2_id int primary key unique not null,
    st2_name varchar(50),
    st2_college_name varchar(100)
    );
    
-- (2) DML - Data Manipulation Language
-- 1 - INSERT - used to add tuples or to insert data into table
insert into department(d_id, d_name, d_location) value
   (1, 'worker', 'India'),
   (2, 'Tech', 'Chicago'),
   (3, 'Finance', 'New York'),
   (4, 'Sales', 'Boston'),
   (5, 'Analytics', 'Germany'),
   (6, 'Content', 'Chicago');
insert into employee(e_id, e_name, e_age, e_gender, e_salary, e_dept_id) values
   (1, 'Sam', 30, 'Male', 50000, 3),
   (3, 'Anne', 25, 'Female', 30000, 4),
   (6, 'jeff', 27, 'Male', 40000, 6),
   (7, 'Adam', 40, 'Male', 80000, 2),
   (8, 'Priya', 35, 'Female', 60000, 5);
insert into student1 (st1_id, st1_name, st1_college_name) values
    (2, 'Riya', 'iitk'), 
    (3, 'Amit', 'iitm'), 
    (4, 'Neha', 'iitd'), 
    (7, 'Rahul', 'iitd');
insert into student2 (st2_id, st2_name, st2_college_name) values
    (4, 'Neha', 'iitd'), 
    (5, 'Sachin', 'iitb'), 
    (6, 'Karan', 'iitg'), 
    (7, 'Simran', 'iitr'); 
    
-- 2 - UPDATE - used to update the values of a column
update department set d_name = 'Management', d_location = 'United States' where d_id = 1;
update employee set e_salary = '50000', e_dept_id = 5 where e_id = 6;
-- important 
set sql_safe_updates = 0;
update employee set e_age = e_age + 2;
set sql_safe_updates = 1;

-- 3 - DELETE - used to remove rows of a table
-- delete spcific rows
delete from department where d_id = 6;
delete from employee where e_id = 7;
-- delete all rows of the table
set sql_safe_updates = 0;
delete from department;
delete from employee;
set sql_safe_updates = 1;
-- TRUNCATE - deletes all tuples of the table
truncate table employee;
-- update and delete using join
update employee join department on employee.e_dept_id = department.d_id set e_age = e_age + 10 where d_location = 'New York'; 
delete employee from employee join department on employee.e_dept_id = department.d_id where d_location = 'Germany';

-- 4 - REPLACE - primarily used for already present tuples
-- used as insert if there is no data
replace into employee (e_id, e_name, e_salary) values(7, 'Adam', 80000);
-- used as update when there is already an entry
replace into employee (e_id, e_name, e_salary) values(1, 'Sam', 35000);

-- 5 - MERGE - merge is the combination of insert, update and delete statements
-- for this we sholud have two table of the same structure,
-- one source table and second target table on which the changes has to be applied
-- merge student2 as t using student1 as s on t.st2_id = s.st1_id 
--     when matched then update set t.st2_name = s.st1_name, t.st2_college_name = s.st1_college_name
--     when not matched by target then insert (st2_id, st2_name, st2_college_name) values (s.st1_id, s.st1_name, s.st1_college_name)
--     when not matched by source then delete;
-- this is present in SQL server but not in MySQL 

-- 6 - TRIGGER - is a stored database object that is automatically executed or fired
-- when a specified event  (like INSERT, UPDATE, or DELETE) occurs on a particular table or view.
-- Maintain audit trails (record changes), Automatically validate or transform data,Enforce data consistency
-- Events that can activate a Trigger - BEFORE INSERT, AFTER INSERT, BEFORE UPDATE, AFTER UPDATE, BEFORE DELETE, AFTER DELETE 
-- CREATE TRIGGER trigger_name
-- {BEFORE | AFTER} {INSERT | UPDATE | DELETE}
-- ON table_name
-- FOR EACH ROW
-- BEGIN
--     -- SQL statements
-- END;
-- Step 1: Create a log table
CREATE TABLE employee_log (
    id INT AUTO_INCREMENT PRIMARY KEY,
    message VARCHAR(255),
    log_time DATETIME
);
-- Step 2: Create the trigger
DELIMITER //
CREATE TRIGGER delete_tri
AFTER DELETE ON employee
FOR EACH ROW
BEGIN
   INSERT INTO employee_log(message, log_time)
   VALUES ('deleted', NOW());
END; 
// DELIMITER ;
drop trigger if exists tri_emp;
select * from employee;
insert into employee values (1, 'Raj', 34, 'Male', 60000, 2);
delete from employee where e_id = 7;
select * from employee_log;


-- (3) DRL - Data Retrieval Language
-- 1- SELECT 
select * from department; 
select e_id, e_name, e_gender from employee;
select * from employee;

-- 2 - different keywords used
-- WHERE - used when a condition is given
select e_id, e_name from employee where e_salary > 50000;
-- IN - from a given set of values 
select e_id, e_name, e_salary from employee where e_dept_id in (2,3,5);
-- AND, OR, NOT - used when two or more conditions are given
select * from employee where e_age < 30 and e_salary >= 50000;
select * from employee where e_age < 30 or e_salary < 50000;
select * from employee where e_dept_id not in (2,3,5);
-- BETWEEN - to extract from a given range 
select * from employee where e_age between 20 and 30;
-- IS NULL 
select * from employee where e_dept_id is null;
-- DISTINCT - find distinct values in the table
select distinct (e_gender) from employee; 
  
-- 3 - Wildcard - pattern searching('_', '%')
select * from employee where e_name like '_a_';
select * from employee where e_name like '%a_';
select * from employee where e_name like '_a%';
select * from employee where e_name like '%a%';

-- 4 - grouping 
-- ORDER BY - ordering in increasing or decreasing manner
select * from employee order by e_age; -- by default ascending
select * from employee order by e_age asc;
select * from employee order by e_salary desc;
-- TOP - is used to fetch the top n records from the table - in sql
-- select top 2 * from employee;
-- LIMIT - in mysql
select * from employee limit 2;
-- GROUP BY - used to collect data from multiple records and group the result by one or more columns
select e_gender, sum(e_salary) from employee group by e_gender;
select e_dept_id, avg(e_salary) from employee where e_gender = 'Female' group by e_dept_id;   
-- GROUP BY HAVING - used same as where clause
select e_dept_id, count(e_id) from employee group by e_dept_id having count(e_id) >= 1; 
-- AS - Alias
select count(e_id) as total_employee from employee;
 
-- 5 - joining tables - to apply joins there should be a common attribute
-- INNER JOIN - returns a resultant table that has matching rows from both tables
select * from employee inner join department on e_dept_id = d_id;
select e.*, d.* from employee as e inner join department as d on e.e_dept_id = d.d_id;
-- OUTER JOIN - left or right join
-- LEFT JOIN - returns a resultant table that all data from left table and matched data from right table
select * from employee left join department on e_dept_id = d_id;
-- RIGHT JOIN - returns a resultant table that all data from right table and matched data from left table
select * from employee right join department on e_dept_id = d_id;  
-- FULL JOIN - returns a resultant table that all data when there is a match on left or right table
-- emulated using UNION - left join union right join
select * from employee left join department on e_dept_id = d_id 
union
select * from employee right join department on e_dept_id = d_id;
-- CROSS JOIN - returns all the cartesian product of the data present in both tables
select * from employee cross join department;  
-- SELF JOIN - used to get output from a particular table when the same table is joined to itself
-- emulated using inner join
select * from department as d1 inner join department as d2 on d1.d_id = d2.d_id;
-- join without using join keywords - important
select * from employee, department where e_dept_id = d_id;   
    
-- 6 - set operations - used to combine vertically multiple select statements 
-- UNION - combines two or more select statements
select * from student1 union select * from student2;
-- INTERSECT - returns common values of the tables
-- emulated using inner join
select * from student1 inner join student2 on (st1_college_name = st2_college_name);
select * from student1 intersect select * from student2;
-- MINUS - returns the distinct row from the 1st table that does not accur in the 2nd table
-- emulated using left or right join
select * from student1 left join student2 on (st1_college_name = st2_college_name) where student2.st2_name is null;
-- EXCEPT - in sql
select * from student1 except select * from student2;

-- 7 - subqueries - outer query depends on inner query - these exists mainly in 3 clauses
-- 1- inside a where clause 
-- same table
select * from employee where e_age in (select e_age from employee where e_age > 30);
-- different table
select * from department where d_id in (select e_dept_id from employee);
-- 2- inside a from clause
select sum(e_salary) from (select * from employee where e_gender = 'Female') as temp;
-- 3- inside a select clause
select (select d_id, d_name from department), e_name from employee where d_id = e_dept_id;  
-- 4- derived subquery
select e_id, e_name from (select * from employee where e_gender = 'Male') as temp;
-- 5 - correlated subqueries

Create table ExamResult(name varchar(50), Subject varchar(20), Marks int);
insert into ExamResult values('Adam', 'Maths', 70);
insert into ExamResult values('Adam', 'Science', 80);
insert into ExamResult values('Adam', 'Social', 60);
insert into ExamResult values('Rak', 'Maths', 60);
insert into ExamResult values('Rak', 'Science', 50);
insert into ExamResult values('Rak', 'Social', 70);
insert into ExamResult values('Sam', 'Maths', 90);
insert into ExamResult values('Sam', 'Science', 90);
insert into ExamResult values('Sam', 'Social', 80);


-- IMPORTANT TOPICS 
-- 1 - TEMPORARY TABLES in sql - temporary tables are created in tempDB and deleted as soon as the session is terminated
-- create table #temp_table_name(
-- id int,
-- name char(50)
-- );
-- we can also do the operations similar to normal tables

-- 2 - FUNCTIONS
-- (i) - basic functions - SUM(), AVG(), COUNT(), MIN(), MAX()
select min(e_age) from employee;
-- (ii) - string functions
-- LTRIM() - removes blanks on the left side of the character expression
select '     saNDii';
select ltrim('     saNDii');
-- LOWER() - converts all characters to the lower case letters
select lower('saNDii');
-- UPPER() - convert all characters to the upper case letters
select upper('saNDii');
-- REVERSE() - reverses all the characters in the string
select reverse('saNDii');
-- SUBSTRING() - gives a substring from the original string
select 'my name is anuuu';
select substr('my name is anuuu',12,5);
-- (iii) - CASE statement - helps in multi-way decision making
select 
    case
	  when 10>20 then '10 is greater than 20'
      when 10<20 then '10 is lesser than 20'
	  else '10 is equal to 20'
	end;
select *, 
    case
	  when e_salary < 80000 then 'A'
	  when e_salary < 50000 then 'B'
	  else 'C' 
	end as grade
from employee;
-- (iv) - IF() function - is an alternative for the case statement
-- syntax - if(boolean_exp, true_value, false_value)
select if(20 > 10, '20 is greater than 10', '20 is less than 10');
select *, if(e_age > 30, 'old_employee', 'young_employee') from employee;
-- (v) - UDF(user defined function) - it always gives a return value
-- SCALABILTY - they cab be used anywhere in the current database
-- udf prohibites usage of non-deterministic built-in functions
-- udf can not call stored procedure 
-- udf variations - 1- scalar, 2- inline, 3- multi-statement 
1- Scalar valued - always returns a scalar value
delimiter // 
create function add_num(num1 int, num2 int)
returns int
deterministic  
begin
   return (num1 + num2);
end;
//
select add_num(20, 30);
drop function add_num;
-- 2- Table valued - returns a table - present only in sql not in mysql
-- create function select_gender(@gender varchar(20))
-- returns table
-- as
-- return(select * from employee where e_gender = gender);
-- select * from dbo.select_gender('Male');

-- (6) - RANK Function -  is a window function used to assign a rank to each row within a partition
-- of a result set based on the values of one or more columns.
-- Depending on the function that is used, Equal values get the same rank. Next rank(s) are skipped in case of ties.
-- Ranking functions are non-deterministic
-- RANK 
-- syntax
-- RANK() OVER (
--     [PARTITION BY partition_column]
--     ORDER BY sort_column [ASC|DESC]
-- )
SELECT name, Subject, Marks, 
	RANK() OVER (PARTITION BY name order by Marks desc) 
From ExamResult order by name, Subject;
-- DENSE_RANK 
SELECT name, Subject, Marks, 
	DENSE_RANK() OVER (PARTITION BY name order by Marks desc) 
From ExamResult order by name, Subject;
-- NTILE() - Distributes the rows in an ordered partition into a specified number of groups.
-- It divides the partitioned result set into specified number of groups in an order.
SELECT name, Subject, Marks, 
	NTILE(2) OVER (PARTITION BY name ORDER BY Marks DESC) AS Quartile
FROM ExamResult ORDER BY name, subject;
-- ROW_NUMBER() - Returns the serial number of the row order by specified column.
SELECT name, Subject, Marks, 
       ROW_NUMBER() OVER (ORDER BY name) AS RowNumber 
FROM ExamResult ORDER BY name, Subject;


-- 3 - STORED PROCEDURE - is a precompiled set of sql or mysql code which can be saved and reused
-- reduces code duplication, increased performance, better security
-- 1 - creating procedure 
-- without parameter syntax
DELIMITER //
create procedure employee_age()
begin
	select e_age from employee;
end; // 
-- with parameters syntax
DELIMITER //
create procedure employee_details(in gender varchar(20))
begin
	select * from employee where e_gender = gender;
end; //
-- 2 - calling procedure
call employee_age();
call employee_details('Male');
-- 3 - to view all stored procedure
show procedure status where Db = 'organisation';
-- 4 - to drop a stored procedure
drop procedure if exists employee_age;

-- 4 - VIEW - database object that has no values of its own 
-- virtual table created by a query by joining one or more tables
-- 1- creating view
create view employee_view as select e_id, e_name, e_salary from employee;
-- 2- altering view
alter view employee_view as select e_id, e_name, e_salary from employee where e_salary >= 50000;
-- 3- selecting view 
select * from employee_view;
-- 4- droping view
drop view if exists employee_view;

-- 5 - EXCEPTION HANDING
-- exception - an error condition during a program execution is called an exception
-- exception handling - mechanism for resolving such an exception is exception handling
-- 1- MySQL exception handling is done using DECLARE...HANDLER for SQLEXCEPTION
-- MySQL does not have SQL Server-like ERROR_MESSAGE() or ERROR_NUMBER() functions.
-- Instead, we use: MYSQL_ERRNO, MESSAGE_TEXT with GET DIAGNOSTICS          
DELIMITER //
CREATE PROCEDURE divide_by_zero_error()
BEGIN
    DECLARE val1 INT;
    DECLARE val2 INT;
    DECLARE errmsg TEXT;
    DECLARE errno INT;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
			errmsg = MESSAGE_TEXT, errno = MYSQL_ERRNO;
		SELECT errmsg AS error_message, errno as error_number;
    END;
    SET val1 = 8;
    SET val2 = val1 / 0; -- This will trigger the handler
END; //
DELIMITER ;
-- To run the procedure:
CALL divide_by_zero_error();
drop procedure if exists divide_by_zero_error;

-- 2- sql exception handling is done using TRY and CATCH blocks
-- following system functions can be used to obtain information about the error that caused the handler to be executed
-- ERROR_NUMBER() - returns the number of the error
-- ERROR_SEVERITY() - returns the severity
-- ERROR_STATE() - returns the error state number
-- ERROR_PROCEDURE() - returns the name of the stored procedure or trigger where the error occured
-- ERROR_LINE() - returns the line number inside the routine that caused the error
-- ERROR_MESSAGE() - returns the complete text of the error message
-- declare @val1 int;
-- declare @val2 int;
-- begin try
-- 	   begin
-- 		  set @val1 = 8;
--        set @val2 = @val1/0;
--     end    
-- end try
-- begin catch
--    print error_message()
--    print error_nnumber()
-- end catch

-- 6 - TRANSACTION - is a group of commands that change data stored in a database
-- 1- mysql transaction - uses stored procedure with DECLARE...HANDLER for SQLEXCEPTION
DELIMITER //
CREATE PROCEDURE update_employee_salary()
BEGIN
    DECLARE exit handler for SQLEXCEPTION 
    BEGIN
        ROLLBACK;
        SELECT 'Transaction rolled back' AS message;
    END;
    START TRANSACTION;
    UPDATE employee SET e_salary = 40000 WHERE e_gender = 'Female';
    COMMIT;
    SELECT 'Transaction committed' AS message;
END; //
DELIMITER ;
-- To run the procedure:
CALL update_employee_salary();

-- 2- sql transaction - uses try and catch blocks
-- begin try
-- 	begin transaction
-- 		update employee set e_salary = 40000 where e_gender = 'Female';
--         update employee set e_salary = 60000 where e_gender = 'Male';
--     commit transaction;
--     print 'transaction commited';
-- end try
-- begin catch
-- 	rollback transaction;
-- 		print 'transaction rollback';
-- end catch


 


 
 
