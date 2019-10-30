--1.0 Setting up Oracle Chinook
--In this section you will begin the process of working with the Oracle Chinook database
--Task – Open the Chinook_Oracle.sql file and execute the scripts within.
--2.0 SQL Queries
--In this section you will be performing various queries against the Oracle Chinook database.
--2.1 SELECT
--Task – Select all records from the Employee table.
SELECT * FROM employee;
--Task – Select all records from the Employee table where last name is King.
SELECT * FROM employee
WHERE lastname = 'King';
--Task – Select all records from the Employee table where first name is Andrew and REPORTSTO is NULL.
SELECT * FROM employee
WHERE firstname = 'Andrew'
AND reportsto IS NULL; 
--2.2 ORDER BY
--Task – Select all albums in Album table and sort result set in descending order by title.
SELECT * FROM album
ORDER BY title DESC;
--Task – Select first name from Customer and sort result set in ascending order by city
SELECT firstname FROM customer 
ORDER BY city;
--2.3 INSERT INTO
--Task – Insert two new records into Genre table
INSERT INTO genre
(genreid, name)
VALUES(26,'EDM');

INSERT INTO genre
(genreid, name)
VALUES(27,'Christian Rock');
--commit; 


--Task – Insert two new records into Employee table

INSERT INTO employee
(employeeid, lastname, firstname, title, reportsto, birthdate, hiredate, address, city, state, country, postalcode, phone, fax, email)
VALUES(9,'Coe', 'Brian', 'Janitor', 1, TO_DATE('1996-10-24 00:00:00','yyyy-mm-dd hh24:mi:ss'), TO_DATE('2019-9-30 00:00:00','yyyy-mm-dd hh24:mi:ss'), '123 Way St.', 'Reston', 'Virginia', 'USA', 'T2P 5M5', '1 (123) 456-7890', '1 (123) 456-7899','email@.com');

INSERT INTO employee
(employeeid, lastname, firstname, title, reportsto, birthdate, hiredate, address, city, state, country, postalcode, phone, fax, email)
VALUES(10,'Co', 'Bri', 'Janitor', 9, TO_DATE('1998-12-09 00:00:00','yyyy-mm-dd hh24:mi:ss'), TO_DATE('2019-9-30 00:00:00','yyyy-mm-dd hh24:mi:ss'), '1234 Way St.', 'Reston', 'Virginia', 'USA', 'T2P 5M5', '1 (123) 456-7880', '1 (123) 446-7899','email2@.com');
--commit;

--Task – Insert two new records into Customer table

INSERT INTO customer
(customerid, firstname, lastname, city, supportrepid, email)
VALUES(60, 'Kevin', 'Smith', 'Reston', 2, 'email@email.com');

INSERT INTO customer
(customerid, firstname, lastname, city, country, supportrepid, email)
VALUES(61, 'Kelly', 'Smith', 'Berlin', 'Germany', 2, 'email2@email.com');
--commit;

--2.4 UPDATE
--Task – Update Aaron Mitchell in Customer table to Robert Walter
UPDATE customer
SET firstname = 'Robert', lastname = 'Walter'
WHERE firstname = 'Aaron' AND lastname = 'Mitchell';
--Task – Update name of artist in the Artist table “Creedence Clearwater Revival” to “CCR”
UPDATE artist
SET name = 'CCR'
WHERE name = 'Creedence Clearwater Revival';
--2.5 LIKE
--Task – Select all invoices with a billing address like “T%”
SELECT * FROM invoice
WHERE billingaddress LIKE 'T%';
--2.6 BETWEEN
--Task – Select all invoices that have a total between 15 and 50
SELECT * FROM invoice
WHERE total BETWEEN 15 AND 50;
--Task – Select all employees hired between 1st of June 2003 and 1st of March 2004
SELECT * FROM employee
WHERE hiredate BETWEEN TO_DATE('2003-06-01 00:00:00','yyyy-mm-dd hh24:mi:ss') AND TO_DATE('2004-03-01 00:00:00','yyyy-mm-dd hh24:mi:ss');
--2.7 DELETE
--Task – Delete a record in Customer table where the name is Robert Walter (There may be constraints that rely on this, find out how to resolve them).
DELETE FROM invoiceline
WHERE invoiceid IN (SELECT invoiceid FROM invoice WHERE customerid IN (SELECT customerid FROM customer WHERE firstname = 'Robert' and lastname = 'Walter'));
DELETE FROM invoice
WHERE customerid IN (SELECT customerid FROM customer WHERE firstname = 'Robert' and lastname = 'Walter');
DELETE FROM customer
WHERE firstname = 'Robert' and lastname = 'Walter';
--
--3.0 SQL Functions
--In this section you will be using the Oracle system functions, as well as your own functions, 
--to perform various actions against the database
--3.1 System Defined Functions
--Task – Create a function that returns the current time.
SELECT TO_CHAR
(SYSDATE, 'MM-DD-YYYY HH24:MI:SS') "NOW"
FROM DUAL; 

--Task – create a function that returns the length of a mediatype from the mediatype table
SELECT LENGTH(name) FROM mediatype;
--3.2 System Defined Aggregate Functions
--Task – Create a function that returns the average total of all invoices
SELECT AVG(total) FROM invoice;
--Task – Create a function that returns the most expensive track
SELECT MAX(unitprice) FROM track;
--3.3 User Defined Scalar Functions
--Task – Create a function that returns the average price of invoiceline items in the invoiceline table
CREATE OR REPLACE FUNCTION get_avg_price
RETURN NUMBER
IS
avg_price number;
BEGIN
    SELECT AVG(unitprice) INTO avg_price FROM invoiceline;
    RETURN avg_price;
END;
/



--3.4 User Defined Table Valued Functions
--Task – Create a function that returns all employees who are born after 1968.

CREATE OR REPLACE FUNCTION born_after(date_in IN VARCHAR2)
 RETURN SYS_REFCURSOR
AS
  employees SYS_REFCURSOR;
--IS
--DECLARE employees CURSOR;
BEGIN
    OPEN employees FOR SELECT * FROM employee
    WHERE birthdate > TO_DATE(date_in,'yyyy-mm-dd hh24:mi:ss');
    
    RETURN employees;
END born_after;
/



SELECT born_after('1969-00-00 00:00:00') FROM dual;

--SELECT * FROM employee
--WHERE birthdate > TO_DATE('1968-12-31 23:59:59','yyyy-mm-dd hh24:mi:ss');


--4.0 Stored Procedures
-- In this section you will be creating and executing stored procedures. 
-- You will be creating various types of stored procedures that take input and output parameters.
--4.1 Basic Stored Procedure
--Task – Create a stored procedure that selects the first and last names of all the employees.

CREATE OR REPLACE PROCEDURE employee_names
(results OUT sys_refcursor)
IS
BEGIN
   OPEN results FOR SELECT firstname, lastname FROM employee;
       
END employee_names;
/
SET SERVEROUTPUT ON;
DECLARE
   results sys_refcursor;
   first_name VARCHAR2(30);
   last_name VARCHAR2(30);
   
BEGIN
   employee_names(results);
   LOOP
       FETCH results INTO first_name, last_name;
       EXIT WHEN results%notfound;
       dbms_output.put_line(first_name || ' | ' || last_name);
   END LOOP;
END;


  
--4.2 Stored Procedure Input Parameters
--Task – Create a stored procedure that updates the personal information of an employee.
CREATE OR REPLACE PROCEDURE update_employee
(l_name IN VARCHAR2, f_name IN VARCHAR2, e_title IN VARCHAR2, l_orig IN VARCHAR2, f_orig IN VARCHAR2)
IS
BEGIN
    UPDATE employee
    SET lastname = l_name, firstname = f_name, title = e_title
    WHERE firstname = f_orig AND lastname = l_orig;
    
END update_employee;


SET SERVEROUTPUT ON;
DECLARE
   
--   f_name VARCHAR2(30);
--   l_name VARCHAR2(30);
--   f_orig VARCHAR2(30);
--   l_orig VARCHAR2(30);
--   e_title VARCHAR2(30);
   
BEGIN
   update_employee('Last', 'First', 'titlessss', 'name', 'namer');
   
END;

--Task – Create a stored procedure that returns the managers of an employee.
CREATE OR REPLACE PROCEDURE find_managers
(employeeidin IN NUMBER, results OUT sys_refcursor)
IS
BEGIN
    OPEN results FOR SELECT employeeid, firstname, lastname FROM employee
    WHERE employeeid = (SELECT reportsto FROM employee WHERE employeeid = employeeidin);
    
END find_managers;
/
SET SERVEROUTPUT ON;
DECLARE
   results sys_refcursor;
   e_id number;
   first_name varchar2(20);
   last_name varchar2(20);
BEGIN
   find_managers(7, results);
   LOOP
       FETCH results INTO e_id, first_name, last_name;
       EXIT WHEN results%notfound;
       dbms_output.put_line(e_id || ' | ' || first_name || ' | ' || last_name);
   END LOOP;
END;
--4.3 Stored Procedure Output Parameters
--Task – Create a stored procedure that returns the name and company of a customer.


CREATE OR REPLACE PROCEDURE find_customer_info
(cust_id IN number, results OUT sys_refcursor)
IS
BEGIN
   OPEN results FOR SELECT firstname, lastname, company FROM customer
   WHERE customerid = cust_id;
END find_customer_info;
/
SET SERVEROUTPUT ON;
DECLARE
   results sys_refcursor;
   firstname VARCHAR2(20);
   lastname varchar2(20);
   company varchar2(50);
BEGIN
   find_customer_info(1, results);
   LOOP
       FETCH results INTO firstname, lastname, company;
       EXIT WHEN results%notfound;
       dbms_output.put_line(firstname || ' | ' || lastname || ' | ' || company);
   END LOOP;
END;

--6.0 Triggers
--In this section you will create various kinds of triggers that work when certain DML statements are executed on a table.
--6.1 AFTER/FOR
--Task - Create an after insert trigger on the employee table fired after a new record is inserted into the table.
CREATE OR REPLACE TRIGGER employee_insert_trig
AFTER INSERT ON employee
FOR EACH ROW
DECLARE

BEGIN
    UPDATE customer 
    SET customerid = customerid+1
    WHERE firstname = 'Kelly' AND lastname = 'Smith';
END;

--INSERT INTO employee (firstname, lastname,employeeid)
--VALUES ('first', 'not first', 12);
--Task – Create an after update trigger on the album table that fires after a row is inserted in the table
CREATE OR REPLACE TRIGGER album_update_trig
AFTER UPDATE ON album
FOR EACH ROW
BEGIN
    INSERT INTO employee
    (employeeid, firstname, lastname)
    VALUES((SELECT MAX(employeeid)+1 FROM employee), 'TriggerName', 'TriggerName2'); 
END;

--UPDATE album
--SET title = 'Trigger check'
--WHERE albumid = 347;
--SELECT * FROM employee;

--Task – Create an after delete trigger on the customer table that fires after a row is deleted from the table.
CREATE OR REPLACE TRIGGER customer_delete_trig
AFTER DELETE on customer
FOR EACH ROW
BEGIN
    INSERT INTO album
    (albumid, title, artistid)
    VALUES((SELECT MAX(albumid)+1 FROM album), 'This Title', 2);
   
END;
--Task – Create a trigger that restricts the deletion of any invoice that is priced over 50 dollars.
CREATE OR REPLACE TRIGGER invoice_delete_trig
BEFORE DELETE on invoice
FOR EACH ROW
DECLARE

BEGIN
IF :old.total > 50 THEN
    RAISE_APPLICATION_ERROR(-20009, 'Cannot delete this invoice.');
END IF;
   
END;

--INSERT INTO invoice
--(invoiceid, customerid, invoicedate, total)
--VALUES((SELECT MAX(invoiceid)+1 FROM invoice), 1, (SELECT invoicedate FROM invoice WHERE invoiceid = 405), 54);
--
--DELETE FROM invoice
--WHERE total > 50;

--7.0 JOINS
--In this section you will be working with combing various tables through the use of joins. 
--You will work with outer, inner, right, left, cross, and self joins.
--7.1 INNER
--Task – Create an inner join that joins customers and orders and specifies the name of the customer and the invoiceId.
SELECT c.firstname, c.lastname, i.invoiceid FROM customer c
INNER JOIN invoice i ON(c.customerid = i.customerid);
--7.2 OUTER
--Task – Create an outer join that joins the customer and invoice table, 
--specifying the CustomerId, firstname, lastname, invoiceId, and total.
SELECT c.customerid, c.firstname, c.lastname, i.invoiceid, i.total FROM customer c
FULL JOIN invoice i ON(i.customerid = c.customerid);
--7.3 RIGHT
--Task – Create a right join that joins album and artist specifying artist name and title.
SELECT ar.name, al.title FROM album al
RIGHT JOIN artist ar ON(ar.artistid = al.artistid);
--7.4 CROSS
--Task – Create a cross join that joins album and artist and sorts by artist name in ascending order.
SELECT * FROM album al
CROSS JOIN artist ar
ORDER BY ar.name;
--7.5 SELF
--Task – Perform a self-join on the employee table, joining on the reportsto column.
SELECT * FROM employee e1
FULL JOIN employee e2 ON (e1.employeeid = e2.reportsto);







