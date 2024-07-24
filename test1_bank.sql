select emp_id *10 AS emp_x_10, fname ,UPPER(lname) AS lname_upper, start_date
from employee
order by start_date desc;

select *
from employee;

create view employee_view AS
select emp_id, fname, lname, YEAR(start_date) start_year
from employee;

select *
from employee_view;

SELECT employee.emp_id, employee.fname, 
employee.lname, department.name dept_name
FROM employee INNER JOIN department
 ON employee.dept_id = department.dept_id
 order by emp_id;

SELECT p.product_cd, a.cust_id, a.avail_balance
FROM product p INNER JOIN account a
ON p.product_cd = a.product_cd
 WHERE p.product_type_cd = 'ACCOUNT'
 ORDER BY 1, 2;
 
 select * 
 from product;

 select * 
 from account;
 
 SELECT account_id, product_cd, cust_id, avail_balance
 FROM account
 WHERE product_cd IN ('CHK','SAV','CD','MM');
 
SELECT account_id, product_cd, cust_id, avail_balance
FROM account
WHERE product_cd IN (SELECT product_cd FROM product
 WHERE product_type_cd = 'ACCOUNT');
 
SELECT emp_id, fname, lname
FROM employee
WHERE LEFT(lname, 1) = 'T';

SELECT cust_id, fed_id
FROM customer
WHERE fed_id LIKE '___-__-____';

SELECT emp_id, fname, lname
FROM employee
WHERE lname LIKE 'F%' OR lname LIKE 'G%';

SELECT e.fname, e.lname, d.name
FROM employee e INNER JOIN department d
ON e.dept_id = d.dept_id;

SELECT e.fname, e.lname, d.name
FROM employee e INNER JOIN department d
USING (dept_id);

SELECT a.account_id, a.cust_id, a.open_date, a.product_cd
FROM account a INNER JOIN employee e 
ON a.open_emp_id = e.emp_id
INNER JOIN branch b
ON e.assigned_branch_id = b.branch_id
 WHERE e.start_date < '2007-01-01'
 AND (e.title = 'Teller' OR e.title = 'Head Teller')
 AND b.name = 'Woburn Branch';
 
/*join 3 tables*/ 
SELECT a.account_id, c.fed_id, e.fname, e.lname
FROM account a INNER JOIN customer c
ON a.cust_id = c.cust_id
INNER JOIN employee e
ON a.open_emp_id = e.emp_id
 WHERE c.cust_type_cd = 'B';
 
 /*equivalent to the last query*/ 
 SELECT a.account_id, a.cust_id, a.open_date, a.product_cd
 FROM account a INNER JOIN
  (SELECT emp_id, assigned_branch_id 
	FROM employee
	WHERE start_date < '2007-01-01'
		AND (title = 'Teller' OR title = 'Head Teller')) e
 ON a.open_emp_id = e.emp_id
  INNER JOIN
	(SELECT branch_id
	FROM branch
	WHERE name = 'Woburn Branch') b
ON e.assigned_branch_id = b.branch_id;

 /*join the same table twice to get opening branch 
 and employee's branch*/ 
SELECT a.account_id, e.emp_id, 
b_a.name open_branch, b_e.name emp_branch
FROM account a INNER JOIN branch b_a
 ON a.open_branch_id = b_a.branch_id
 INNER JOIN employee e
 ON a.open_emp_id = e.emp_id
 INNER JOIN branch b_e
 ON e.assigned_branch_id = b_e.branch_id
WHERE a.product_cd = 'CHK';

  /*self join to get managers of the employees 
 (managers are also employees)*/ 
SELECT e.fname, e.lname, 
e_mgr.fname mgr_fname, e_mgr.lname mgr_lname
FROM employee e INNER JOIN employee e_mgr
 ON e.superior_emp_id = e_mgr.emp_id;
 
 /*This query joins two tables that have no foreign key relationships. The intent is to find
 all employees who began working for the bank while the No-Fee Checking product
 was being offered. */
SELECT e.emp_id, e.fname, e.lname, e.start_date
 FROM employee e INNER JOIN product p
 ON e.start_date >= p.date_offered
 AND e.start_date <= p.date_retired
 WHERE p.name = 'no-fee checking';
 
  /*pair employees for chess matches*/ 
 SELECT e1.fname, e1.lname, 'VS' vs, e2.fname, e2.lname, 0 as result
FROM employee e1 INNER JOIN employee e2
ON e1.emp_id < e2.emp_id
 WHERE e1.title = 'Teller' AND e2.title = 'Teller';

SELECT 'abcdefg', CHAR(97,98,99,100,101,102,103);
SELECT CHAR(148,149,150,151,152,153,154,155,156,157);  

SELECT open_emp_id, COUNT(*) how_many
FROM account
GROUP BY open_emp_id
 HAVING COUNT(*) > 4;  

/*across the 10 checking accounts in the
 account table*/ 
SELECT product_cd,
MAX(avail_balance) max_balance,
MIN(avail_balance) min_balance,
AVG(avail_balance) avg_balance,
SUM(avail_balance) tot_balance,
COUNT(*) num_accounts
 FROM account
 WHERE product_cd = 'CHK';

SELECT product_cd,
MAX(avail_balance) max_balance,
MIN(avail_balance) min_balance,
AVG(avail_balance) avg_balance,
SUM(avail_balance) tot_balance,
COUNT(*) num_accounts
 FROM account
GROUP BY product_cd;

SELECT open_emp_id, COUNT(account_id)
FROM account
GROUP BY open_emp_id;

SELECT EXTRACT(YEAR FROM start_date) year,
COUNT(*) how_many
FROM employee
 GROUP BY EXTRACT(YEAR FROM start_date);

/*also get the sum for the group*/
SELECT product_cd, open_branch_id,
SUM(avail_balance) tot_balance
FROM account
 GROUP BY product_cd, open_branch_id WITH ROLLUP;
 
/*also get the sum for the group*/
SELECT product_cd, SUM(avail_balance) prod_balance
FROM account
WHERE status = 'ACTIVE'
 GROUP BY product_cd
 HAVING SUM(avail_balance) >= 10000;

SELECT account_id, product_cd, cust_id, avail_balance
FROM account
WHERE account_id = (SELECT MAX(account_id) FROM account);

/*to see which employees supervise other employees*/
SELECT emp_id, fname, lname, title
FROM employee
WHERE emp_id IN (SELECT superior_emp_id
 FROM employee);  
 
SELECT superior_emp_id
 FROM employee
 WHERE superior_emp_id IS NOT NULL ;

/*This query finds all employees who do not supervise other people.*/ 
SELECT emp_id, fname, lname, title
FROM employee
WHERE emp_id NOT IN (SELECT superior_emp_id
 FROM employee
 WHERE superior_emp_id IS NOT NULL); 

/* finds all accounts having a balance smaller than all Frank’s accounts (lowest)*/ 
SELECT account_id, cust_id, product_cd, avail_balance
FROM account
WHERE avail_balance < ALL (SELECT a.avail_balance
 FROM account a INNER JOIN individual i
 ON a.cust_id = i.cust_id
 WHERE i.fname = 'Frank' AND i.lname = 'Tucker');
 
/* finds all accounts having a balance greater than any of Frank’s accounts*/ 
SELECT account_id, cust_id, product_cd, avail_balance
FROM account
WHERE avail_balance > ANY (SELECT a.avail_balance
 FROM account a INNER JOIN individual i
 ON a.cust_id = i.cust_id
 WHERE i.fname = 'Frank' AND i.lname = 'Tucker'); 

SELECT account_id, product_cd, cust_id
FROM account
WHERE (open_branch_id, open_emp_id) IN
 (SELECT b.branch_id, e.emp_id
 FROM branch b INNER JOIN employee e
 ON b.branch_id = e.assigned_branch_id
 WHERE b.name = 'Woburn Branch'
 AND (e.title = 'Teller' OR e.title = 'Head Teller')); 
 
 /* customers having 2 accounts. note: a Correlated Subquery
is executed for each row*/ 
SELECT c.cust_id, c.cust_type_cd, c.city
FROM customer c 
WHERE 2 = (SELECT COUNT(*)
 FROM account a
 WHERE a.cust_id = c.cust_id);
 
  /* customers having total account balance within this range. */
SELECT c.cust_id, c.cust_type_cd, c.city
FROM customer c
WHERE (SELECT SUM(a.avail_balance)
 FROM account a
 WHERE a.cust_id = c.cust_id)
 BETWEEN 5000 AND 10000;
 
  /* You use the exists operator when you want to identify that a
 relationship exists without regard for the quantity 
 The query below finds all the accounts for which a transaction was posted on a particular day, without
 regard for how many transactions were posted*/
SELECT a.account_id, a.product_cd, a.cust_id, a.avail_balance
 FROM account a
 WHERE EXISTS (SELECT 1
  FROM transaction t
  WHERE t.account_id = a.account_id
    AND t.txn_date = '2008-01-05');
    
select *
from transaction;

/*This query finds all customers whose customer ID does not appear in the business
 table, which is a roundabout way of finding all nonbusiness customers.*/
SELECT a.account_id, a.product_cd, a.cust_id
FROM account a
WHERE NOT EXISTS (SELECT 1
 FROM business b
 WHERE b.cust_id = a.cust_id);


UPDATE account a
 SET a.last_activity_date =
 (SELECT MAX(t.txn_date)
  FROM transaction t
  WHERE t.account_id = a.account_id)
 WHERE EXISTS (SELECT 1
  FROM transaction t
  WHERE t.account_id = a.account_id);

  /* Subquery as data source */  
SELECT d.dept_id, d.name, e_cnt.how_many num_employees
FROM department d INNER JOIN
(SELECT dept_id, COUNT(*) how_many
 FROM employee
 GROUP BY dept_id) e_cnt
 ON d.dept_id = e_cnt.dept_id;
 
 SELECT p.name product, b.name branch,
CONCAT(e.fname, ' ', e.lname) name,
account_groups.tot_deposits
 FROM
 (SELECT product_cd, open_branch_id branch_id,
 open_emp_id emp_id,
 SUM(avail_balance) tot_deposits
 FROM account
 GROUP BY product_cd, open_branch_id, open_emp_id) account_groups
 INNER JOIN employee e ON e.emp_id = account_groups.emp_id
 INNER JOIN branch b ON b.branch_id = account_groups.branch_id
 INNER JOIN product p ON p.product_cd = account_groups.product_cd
 WHERE p.product_type_cd = 'ACCOUNT';
 
 SELECT 'Small Fry' name, 0 low_limit, 4999.99 high_limit
 UNION ALL
SELECT 'Average Joes' name, 5000 low_limit, 9999.99 high_limit
 UNION ALL
 SELECT 'Heavy Hitters' name, 10000 low_limit, 9999999.99 high_limit; 
 
SELECT ones.num + tens.num + hundreds.num
     FROM
      (SELECT 0 num UNION ALL
       SELECT 1 num UNION ALL
       SELECT 2 num UNION ALL
       SELECT 3 num UNION ALL
       SELECT 4 num UNION ALL
       SELECT 5 num UNION ALL
       SELECT 6 num UNION ALL
       SELECT 7 num UNION ALL
       SELECT 8 num UNION ALL
       SELECT 9 num) ones
       CROSS JOIN
      (SELECT 0 num UNION ALL
       SELECT 10 num UNION ALL
       SELECT 20 num UNION ALL
       SELECT 30 num UNION ALL
       SELECT 40 num UNION ALL
       SELECT 50 num UNION ALL
       SELECT 60 num UNION ALL
       SELECT 70 num UNION ALL
       SELECT 80 num UNION ALL
       SELECT 90 num) tens
       CROSS JOIN
    (SELECT 0 num UNION ALL
      SELECT 100 num UNION ALL
      SELECT 200 num UNION ALL
      SELECT 300 num) hundreds; 
 
select * from product;

select * from product_type;

