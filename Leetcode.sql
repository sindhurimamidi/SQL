/*
SQL tips:
1. join : between A and B
        : A < B 
	: A != B gets all permutations and combinations.
2. “is NULL” —> use left/right joins to get null values and use this condition in where clause.
    IFNULL(A, 0)
3. row_number over (partition by A order by B ) rn
4. union all for duplicates, union for set.
5. if(condition, then, else)
6. case when  A then a
        when B then b
        else c
   end 
 7. aggregate: avg,sum, min, max,count
 8. math: floor, pow(num,2) , round(num,2), abs, sqrt, square
 9. Where condition on 2 variables: a,b in (select a,b from table)
 10. LAG(col,1) over (partition by col2 order by col3 asc) --> LAG or LEAD
 11. Window functions: over() partion by -- order by -- etc.
 12: CTE(common table expressions): With table_name as (select * from table) --> creates a view.
*/

--175. Combine Two Tables 
select p.FirstName, 
       p.LastName,
       a.City,
       a.State
from Person p
left join Address a
on p.PersonId = a.PersonId

--176. Second highest Salary
select max(salary) as SecondHighestSalary
from Employee
where salary < (select max(salary) 
		from Employee)

-- Employee name with Second highest Salary
SELECT name, salary 
FROM employees e
WHERE 2=(SELECT COUNT(DISTINCT salary) 
         FROM employees p 
         WHERE e.salary<=p.salary)

--177. Nth Highest Salary
Select salary 
from (Select Salary, 
      	     Row_Number() over (Order by Salary Desc) Salaryrank 
      From Employee)
Where Salaryrank = N

--178. Rank scores
select Score, 
       Dense_Rank() over (order by score DESC) as Rank from Scores
# version 2
SELECT s.Score, 
       count(distinct t.score) Rank
FROM Scores s 
JOIN Scores t 
ON s.Score <= t.score
GROUP BY s.Id
ORDER BY s.Score desc

--180. Consecutive Numbers
select DISTINCT l1.Num as ConsecutiveNums
from Logs l1, 
     Logs l2, 
     Logs l3
where l1.Num = l2.Num 
  and l2.Num = l3.Num
  and l1.Id = l2.Id-1 
  and l2.Id = l3.Id-1

--181. Employees Earning More Than Their Managers
select e1.Name as Employee
from Employee as e1 
left outer join 
     Employee as e2 
on e1.ManagerId=e2.Id 
where e1.Salary > e2.Salary

--182. Duplicate Emails
select Email
from Person
group by Email 
having count(*) > 1

--183. Customers Who Never Order
select Name as Customers
from Customers 
where Id NOT IN (select CustomerId 
		 from Orders)

--184. Department Highest Salary
select d.Name as Department,
       e.Name as Employee, 
       e.Salary as Salary
from Employee as e, 
     Department as d 
where e.DepartmentId=d.id
and (DepartmentId,Salary) in (SELECT DepartmentId,
			             max(Salary) as max 
			      FROM Employee 
			      GROUP BY DepartmentId)

--185. Department Top 3 Salaries
select 
    D.Name as Department, 
    E.Name as Employee,
    E.Salary as Salary
from
    (select Name,Salary,DepartmentId, row_number() over (partition by DepartmentId order by Salary Desc) as rn
     from Employee
     group by Name,Salary,DepartmentId) as E
join (select Id, Name 
      from Department) as D
on E.DepartmentId = D.Id
where E.rn < = 3

MYSQL:
SELECT
  d.Name AS 'Department', 
  e1.Name AS 'Employee', 
  e1.Salary
FROM Employee e1
JOIN Department d 
ON e1.DepartmentId = d.Id
WHERE
  3 > (SELECT
         COUNT(DISTINCT e2.Salary)
       FROM Employee e2
       WHERE e2.Salary > e1.Salary
         AND e1.DepartmentId = e2.DepartmentId);

--196. Delete Duplicate Emails
Delete p
from Person p,
     Person q
where p.Id > q.Id 
  and p.Email = q.EMail

--197. Rising Temperature.
select d.Name as Department,
       e.Name as Employee, 
       e.Salary as Salary
from Employee as e, 
     Department as d 
where e.DepartmentId=d.id
  and (DepartmentId,Salary) in 
  (SELECT DepartmentId,max(Salary) as max 
   FROM Employee 
   GROUP BY DepartmentId)

--262. Trips and users
select Request_at as Day,
       round(sum(case when Status like 'cancelled_%' then 1 else 0 end)/count(*),2) Cancellation_Rate
from (select * 
      from Trips t
      left outer join 
      Users u
      on t.Client_Id=u.Users_Id) as k
where Banned = 'No' 
  and Request_at  >= '2013-10-01' and Request_at <= '2013-10-03'
group by Day

--595. Big Countries
select name,
       population,
       area
from World
where population > 25000000 
   or area > 3000000

--596. Classes More Than 5 Students
select class
from courses
group by class
having count(distinct student) >= 5

--601. Human Traffic of Stadium
select distinct s1.*
from Stadium s1, 
     Stadium s2, 
     Stadium s3
where ((s2.id=s1.id+1 and s3.id = s1.id+2) 
    or (s2.id=s1.id-1 and s3.id = s1.id+1) 
    or (s2.id=s1.id-2 and s3.id = s1.id-1)) 
    and s1.people>=100 
    and s2.people>=100 
    and s3.people>=100
order by s1.id

--620. Not Boring Movies
select *
from cinema
where description != 'boring' 
  and id mod 2 !=0
order by rating DESC

--626. Exchange seats: 
select 
    #if (condition,then, else)
    if(id < (select count(*) from seat), 
    if(id mod 2=0, id-1, id+1), 
    if(id mod 2=0, id-1, id)) as id, 
    student
from seat
order by id asc

--627. Swap Salary
UPDATE salary
SET sex  = (CASE WHEN sex = 'm' THEN  'f' ELSE 'm' 
    			END)

--579. Find Cumulative Salary of an Employee
SELECT E1.id, 
       E1.month,
      (IFNULL(E1.salary, 0) + IFNULL(E2.salary, 0) + IFNULL(E3.salary, 0)) AS Salary
FROM
    (SELECT id, 
     	    MAX(month) AS month
    FROM Employee
    GROUP BY id
    HAVING COUNT(*) > 1) AS maxmonth
        LEFT JOIN
    Employee E1 ON (maxmonth.id = E1.id
        AND maxmonth.month > E1.month)
        LEFT JOIN
    Employee E2 ON (E2.id = E1.id
        AND E2.month = E1.month - 1)
        LEFT JOIN
    Employee E3 ON (E3.id = E1.id
        AND E3.month = E1.month - 2)
ORDER BY id ASC , month DESC

--614. Second Degree Follower 
Select f1.follower, 
       count(distinct f2.follower) as num
from follow f1,
     follow f2 
on f1.follower = f2.followee
Group by f1.follower

--578. Get Highest Answer Rate Question
select question_id, 
       SUM(CASE when action = 'answer' then 1 END as num_ans)/SUM(CASE when action = 'show' then 1 END as num_show)
from survey_log
group by question_id

--574. Winning Candidate 
select Name 
from Candidate c, 
     (select candidateId,
 	      count(candidateId) as cnt 
      from Vote
      group by candidateId
      order by cnt DESC
      limit 1) as v
where c.id = v.CandidateId 

--580. Count Student Number in Departments 
select d.dept_name, 
       s.cnt
from department d 
left outer join 
     (select count(dept_id) as cnt,
             dept_id from student 
      group by dept_id) as s
on s.dept_id = d.dept_id

--602. Friend Requests II: Who Has Most Friend?
select ids, 
       count(ids) as num
from 
    (select requester_id as ids 
     from request_accepted
union all
     select accepter_id 
     from request_accepted) as u
group by ids
order by num DESC
limit 1

--585. Investments in 2016
SELECT SUM(insurance.TIV_2016) AS TIV_2016
FROM insurance
WHERE insurance.TIV_2015 IN
    (SELECT TIV_2015
      FROM insurance
      GROUP BY TIV_2015
      HAVING COUNT(*) > 1)
    AND CONCAT(LAT, LON) IN
    (SELECT CONCAT(LAT, LON)
      FROM insurance
      GROUP BY LAT , LON
      HAVING COUNT(*) = 1 //rows which appear only once.)

--612. Shortest Distance in a Plane
SELECT ROUND(SQRT(MIN((POW(p1.x - p2.x, 2) + POW(p1.y - p2.y, 2)))), 2) AS shortest
FROM point_2d p1
JOIN point_2d p2 
 ON p1.x != p2.x 
 OR p1.y != p2.y;  

--608. Tree Node  
select id, 
       CASE when pid is Null then 'root' 
            when id in (select pid from tree) then 'inner'
            else 'leaf'
       END as Type
from tree;

--570. Managers with at Least 5 Direct Reports 
SELECT Name
FROM Employee AS t1 JOIN
    (SELECT ManagerId
     FROM Employee
     GROUP BY ManagerId
     HAVING COUNT(ManagerId) >= 5) AS t2
     ON t1.Id = t2.ManagerId;  

/* LOCKED QUESTIONS */

-- 613. Shortest Distance in a Line
/* Table point holds the x coordinate of some points on x-axis in a plane, which are all integers.
Write a query to find the shortest distance between two points in these points.
| x   |
|-----|
| -1  |
| 0   |
| 2   | */
select min(p2.x-p1.x) as shortest
from point p1
join point p2
on p1.x < p2.x;

--584. Find Customer Referee
/* 
Given a table customer holding customers information and the referee.
+------+------+-----------+
| id   | name | referee_id|
+------+------+-----------+
|    1 | Will |      NULL |
|    2 | Jane |      NULL |
|    3 | Alex |         2 |
|    4 | Bill |      NULL |
|    5 | Zack |         1 |
|    6 | Mark |         2 |
+------+------+-----------+
Write a query to return the list of customers NOT referred by the person with id '2'.
For the sample data above, the result is:
+------+
| name |
+------+
| Will |
| Jane |
| Bill |
| Zack |
+------+
*/
select name 
from customer
where referee_id != 2 
   or referee_id is NULL;
 
--586. Customer Placing the Largest Number of Orders
/*
Query the customer_number from the orders table for the customer who has placed the largest number of orders.
It is guaranteed that exactly one customer will have placed more orders than any other customer.
The orders table is defined as follows:
| Column            | Type      |
|-------------------|-----------|
| order_number (PK) | int       |
| customer_number   | int       |
| order_date        | date      |
| required_date     | date      |
| shipped_date      | date      |
| status            | char(15)  |
| comment           | char(200) |
*/
SELECT
    customer_number
FROM
    orders
GROUP BY customer_number
ORDER BY COUNT(*) DESC
LIMIT 1
;

--610. Triangle Judgement
/*
A pupil Tim gets homework to identify whether three line segments could possibly form a triangle.
However, this assignment is very heavy because there are hundreds of records to calculate.
Could you help Tim by writing a query to judge whether these three sides can form a triangle, assuming table triangle holds the length of the three sides x, y and z.
| x  | y  | z  |
|----|----|----|
| 13 | 15 | 30 |
| 10 | 20 | 15 |
*/
select 
   x,y,z,
   case
      when (x+y>z and x+z>y and z+y>x ) then 'Yes'
      else 'No'
   end as triangle
from triangle

--603. Consecutive Available Seats
/*
Several friends at a cinema ticket office would like to reserve consecutive available seats.
Can you help to query all the consecutive available seats order by the seat_id using the following cinema table?
| seat_id | free |
|---------|------|
| 1       | 1    |
| 2       | 0    |
| 3       | 1    |
| 4       | 1    |
| 5       | 1    |
*/
select distinct c1.seat_id
from cinema c1, cinema c2
where c1.free = '1' and c2.free = '1' and abs(c2.seat_id - c1.seat_id) = 1
order by c1.seat_id;

--607. Sales Person
/* Given three tables: 
   salesperson: sales_id | name | salary  | commission_rate | hire_date
   company:      com_id  | name | city   
   orders:      order_id | date | com_id  | sales_id | amount
   Output all the names in the table salesperson, who didn’t have sales to company 'RED'.*/
select s.name 
from salesperson s
where s.sales_id not in (select o.sales_id
                         from orders o
                         join company c
                          on c.com_id= o.com_id
                         where c.name = 'RED')
--577. Employee Bonus
/* Select all employee's name and bonus whose bonus is < 1000.
   Employee: empId |  name  | supervisor| salary 
   Bonus:    empId | bonus 
*/
select e.name as name, b.bonus as bonus
from employee e
left join bonus b
on e.empId=b.empId
where b.bonus < 1000 or b.bonus is NULL

--597. Friend Requests I: Overall Acceptance Rate
/* In social network like Facebook or Twitter, people send friend requests and accept others’ requests as well. 
   Now given two tables as below, Write a query to find the overall acceptance rate of requests rounded to 2 decimals, 
   which is the number of acceptance divide the number of requests.
   friend_request:      sender_id | send_to_id  |request_date
   request_accepted: requester_id | accepter_id |accept_date 
*/
select round(
            ifnull((select count(*) from (select distinct requester_id,accepter_id from request_accepted) B)/
                   (select count(*) from (select distinct sender_id,send_to_id from friend_request) A), 
		 0),
            2) as accept_rate;
	    
--619. Biggest Single Number 
/* Table number contains many numbers in column num including duplicated ones.
  Can you write a SQL query to find the biggest number, which only appears once.*/
select max(n.num) as num
from (select num
      from number
      group by num
      having count(num) = 1) n
   
/* MEDIUM */
--570. Managers with at Least 5 Direct Reports
/* The Employee table holds all employees including their managers. Every employee has an Id, and there is also a column for the manager Id.
   |Id  |Name  |Department |ManagerId 
   Given the Employee table, write a SQL query that finds out managers with at least 5 direct report. */
select name 
from Employee e1
join  (select ManagerId
       from Employee 
       group by ManagerId
       having count(*) >=5) e2
on e1.Id = e2.ManagerId
       
--612. Shortest Distance in a Plane
/* Table point_2d holds the coordinates (x,y) of some unique points (more than two) in a plane.
   Write a query to find the shortest distance between these points rounded to 2 decimals */
SELECT ROUND(SQRT(MIN((POW(p1.x - p2.x, 2) + POW(p1.y - p2.y, 2)))), 2) AS shortest
FROM point_2d p1
JOIN point_2d p2 ON p1.x != p2.x OR p1.y != p2.y;

--602. Friend Requests II: Who Has the Most Friends
/* In social network like Facebook or Twitter, people send friend requests and accept others' requests as well.
  Table request_accepted holds the data of friend acceptance, while requester_id and accepter_id both are the id of a person.
  request_accepted: requester_id | accepter_id | accept_date| */
select t.id as id, count(*) as num
from (select requester_id as id from request_accepted 
      union all 
      select accepter_id as id from request_accepted ) as t
group by t.id
order by count(*) desc
limit 1

--580. Count Student Number in Departments
/* A university uses 2 data tables, student and department, to store data about its students and the departments associated with each major.
Write a query to print the respective department name and number of students majoring in each department for all departments in the department table (even ones with no current students).
Sort your results by descending number of students; if two or more departments have the same number of students, then sort those departments alphabetically by department name.
where student_id is the student's ID number, student_name is the student's name, gender is their gender, and dept_id is the department ID associated with their declared major.
where dept_id is the department's ID number and dept_name is the department name.
Student :   Column Name | Type  
Department: Column Name | Type  
*/
select d.dept_name,count(s.dept_id) as student_number
from student s
right outer join department d
on s.dept_id = d.dept_id
group by d.dept_name,s.dept_id
order by count(s.dept_id) desc,d.dept_name

--574. Winning Candidate
/* Candidate: id  | Name 
   Vote:      id  | CandidateId 
   Write a sql to find the name of the winning candidate, the above example will return the winner B. */
select name 
from Candidate
where id=(select CandidateId
          from Vote 
          group by CandidateId
          order by count(CandidateId) desc
          limit 1)
	  
--578. Get Highest Answer Rate Question
/* Get the highest answer rate question from a table survey_log with these columns: uid, action, question_id, answer_id, q_num, timestamp.
uid means user id; action has these kind of values: "show", "answer", "skip"; answer_id is not null when action column is "answer", 
while is null for "show" and "skip"; q_num is the numeral order of the question in current session.
Write a sql query to identify the question which has the highest answer rate.
The highest answer rate meaning is: answer number's ratio in show number in the same question. */
select t.question_id as survey_log
from (select question_id,
        sum(case when action='answer' then 1 else 0 end)/sum(case when action='show' then 1 else 0 end) as ans_rate
from survey_log
group by 1) t
order by ans_rate desc
limit 1
-- alternate using if
select 
   question_id,
   sum(if (action='answer',1,0))/sum(if (action='show',1,0)) as ans_rate
from survey_log
group by 1
					 
/* Given a session with userid, url visited and timestamp, create a new table with only one entry per session with 10 mins for a given user.
For ex:
userid  Timestamp         url 
1000    11-11-2018 10:00  google.com
1000    11-11-2018 10:02  google.com
1000    11-11-2018 10:04  google.com
1000    11-11-2018 01:00  google.com
1000    11-12-2018 10:00  fb.com

should return:
sessionid userid timestamp          url
1    	  1000  11-11-2018 10:00  google.com
2         1000  11-11-2018 01:00  google.com
3         1000  11-12-2018 10:00  fb.com					 
*/			 

select 
  user_id,
  case 
    when (current_date-prev_date) < 10 then '0'
    else '1'
  end as flag
from
(SELECT
    user_id,
    url,
    Timestamp as current_date,
    LAG(Timestamp,1) OVER(PARTITION BY user_id ORDER BY Timestamp ASC) as prev_date
 from table)
where flag = 1;
		
-- Check for item in an array.					 
select *
from
where contains(item,element)
					 
---534. Game Play Analysis III
/* Write an SQL query that reports for each player and date, how many games played so far by the player. 
 That is, the total number of games played by the player until that date. Check the example for clarity.
The query result format is in the following example:
Activity table:
+-----------+-----------+------------+--------------+
| player_id | device_id | event_date | games_played |
+-----------+-----------+------------+--------------+
| 1         | 2         | 2016-03-01 | 5            |
| 1         | 2         | 2016-05-02 | 6            |
| 1         | 3         | 2017-06-25 | 1            |
| 3         | 1         | 2016-03-02 | 0            |
| 3         | 4         | 2018-07-03 | 5            |
+-----------+-----------+------------+--------------+

Result table:
+-----------+------------+---------------------+
| player_id | event_date | games_played_so_far |
+-----------+------------+---------------------+
| 1         | 2016-03-01 | 5                   |
| 1         | 2016-05-02 | 11                  |
| 1         | 2017-06-25 | 12                  |
| 3         | 2016-03-02 | 0                   |
| 3         | 2018-07-03 | 5                   |
+-----------+------------+---------------------+
For the player with id 1, 5 + 6 = 11 games played by 2016-05-02, and 5 + 6 + 1 = 12 games played by 2017-06-25.
For the player with id 3, 0 + 5 = 5 games played by 2018-07-03.
Note that for each player we only care about the days when the player logged in. */	
select a1.player_id, a1.event_date, sum(a2.games_played) as games_played_so_far
from activity as a1
inner join activity as a2
on a1.event_date >= a2.event_date
and a1.player_id = a2.player_id
group by  a1.player_id, a1.event_date	

-- 550. Game Play Analysis IV
/* Write an SQL query that reports the fraction of players that logged in again on the day after the day they first logged in, 
 rounded to 2 decimal places. In other words, you need to count the number of players that logged in for at least two consecutive days 
 starting from their first login date, then divide that number by the total number of players.
Activity table:
+-----------+-----------+------------+--------------+
| player_id | device_id | event_date | games_played |
+-----------+-----------+------------+--------------+
| 1         | 2         | 2016-03-01 | 5            |
| 1         | 2         | 2016-03-02 | 6            |
| 2         | 3         | 2017-06-25 | 1            |
| 3         | 1         | 2016-03-02 | 0            |
| 3         | 4         | 2018-07-03 | 5            |
+-----------+-----------+------------+--------------+

Result table:
+-----------+
| fraction  |
+-----------+
| 0.33      |
+-----------+
Only the player with id 1 logged back in after the first day he had logged in so the answer is 1/3 = 0.33					 
*/
SELECT 
  ROUND(SUM(event_date = min_date + 1)/COUNT(DISTINCT player_id), 2) fraction
FROM
(SELECT 
   player_id, 
   event_date, 
   MIN(event_date) OVER (Partition by player_id) min_date --since first login date;
 FROM Activity) t

--569. Median Employee Salary
/* The Employee table holds all employees. The employee table has three columns: Employee Id, Company Name, and Salary.
+-----+------------+--------+
|Id   | Company    | Salary |
+-----+------------+--------+
|1    | A          | 2341   |
|2    | A          | 341    |
|3    | A          | 15     |
|4    | A          | 15314  |
|5    | A          | 451    |
|6    | A          | 513    |
|7    | B          | 15     |
|8    | B          | 13     |
|9    | B          | 1154   |
|10   | B          | 1345   |
|11   | B          | 1221   |
|12   | B          | 234    |
|13   | C          | 2345   |
|14   | C          | 2645   |
|15   | C          | 2645   |
|16   | C          | 2652   |
|17   | C          | 65     |
+-----+------------+--------+
Write a SQL query to find the median salary of each company. Bonus points if you can solve it without using any built-in SQL functions.
+-----+------------+--------+
|Id   | Company    | Salary |
+-----+------------+--------+
|5    | A          | 451    |
|6    | A          | 513    |
|12   | B          | 234    |
|9    | B          | 1154   |
|14   | C          | 2645   |
+-----+------------+--------+
*/
select 
    t.id as Id,
    t.company as Company, 
    salary as Salary
from
(select 
    id, 
    company, 
    salary, 
    row_number()over(partition by company order by salary,Id asc) as sequence,
    floor((count(id)over(partition by Company ) /2 +1 )) odd_even_count, 
    (case 
        when count(id)over(partition by Company ) %2=0 
        then floor((count(id)over(partition by Company ) /2 )) 
     end) as even_count 
 from employee) as t
where t.sequence in (even_count,odd_even_count)
					 
/* MEDIUM */
--1445. Apples & Oranges
/*
+---------------+---------+
| Column Name   | Type    |
+---------------+---------+
| sale_date     | date    |
| fruit         | enum    | 
| sold_num      | int     | 
+---------------+---------+
(sale_date,fruit) is the primary key for this table.
This table contains the sales of "apples" and "oranges" sold each day.
Write an SQL query to report the difference between number of apples and oranges sold each day.
Return the result table ordered by sale_date in format ('YYYY-MM-DD').
The query result format is in the following example:

Sales table:
+------------+------------+-------------+
| sale_date  | fruit      | sold_num    |
+------------+------------+-------------+
| 2020-05-01 | apples     | 10          |
| 2020-05-01 | oranges    | 8           |
| 2020-05-02 | apples     | 15          |
| 2020-05-02 | oranges    | 15          |
| 2020-05-03 | apples     | 20          |
| 2020-05-03 | oranges    | 0           |
| 2020-05-04 | apples     | 15          |
| 2020-05-04 | oranges    | 16          |
+------------+------------+-------------+

Result table:
+------------+--------------+
| sale_date  | diff         |
+------------+--------------+
| 2020-05-01 | 2            |
| 2020-05-02 | 0            |
| 2020-05-03 | 20           |
| 2020-05-04 | -1           |
+------------+--------------+

Day 2020-05-01, 10 apples and 8 oranges were sold (Difference  10 - 8 = 2).
Day 2020-05-02, 15 apples and 15 oranges were sold (Difference 15 - 15 = 0).
Day 2020-05-03, 20 apples and 0 oranges were sold (Difference 20 - 0 = 20).
Day 2020-05-04, 15 apples and 16 oranges were sold (Difference 15 - 16 = -1).
*/					 
select s1.sale_date,s1.sold_num-s2.sold_num as diff
from Sales s1
join Sales s2
on s1.sale_date = s2.sale_date and s2.fruit!=s1.fruit
where s1.fruit = 'apples'
  and s2.fruit = 'oranges'

--1077. Project Employees III
/*
Table: Project
+-------------+---------+
| Column Name | Type    |
+-------------+---------+
| project_id  | int     |
| employee_id | int     |
+-------------+---------+
(project_id, employee_id) is the primary key of this table.
employee_id is a foreign key to Employee table.
					 
Table: Employee
+------------------+---------+
| Column Name      | Type    |
+------------------+---------+
| employee_id      | int     |
| name             | varchar |
| experience_years | int     |
+------------------+---------+
employee_id is the primary key of this table.
 
Write an SQL query that reports the most experienced employees in each project. In case of a tie, report all employees with the maximum number of experience years.
The query result format is in the following example:

Project table:
+-------------+-------------+
| project_id  | employee_id |
+-------------+-------------+
| 1           | 1           |
| 1           | 2           |
| 1           | 3           |
| 2           | 1           |
| 2           | 4           |
+-------------+-------------+

Employee table:
+-------------+--------+------------------+
| employee_id | name   | experience_years |
+-------------+--------+------------------+
| 1           | Khaled | 3                |
| 2           | Ali    | 2                |
| 3           | John   | 3                |
| 4           | Doe    | 2                |
+-------------+--------+------------------+

Result table:
+-------------+---------------+
| project_id  | employee_id   |
+-------------+---------------+
| 1           | 1             |
| 1           | 3             |
| 2           | 1             |
+-------------+---------------+
Both employees with id 1 and 3 have the most experience among the employees of the first project. For the second project, the employee with id 1 has the most experience.
*/
select project_id,employee_id
from(
select 
    p.project_id,
    e.employee_id,
    e.experience_years,
    rank() over (partition by p.project_id order by e.experience_years desc)rn
from Project p
join Employee e
on p.employee_id= e.employee_id)u
where rn=1					 
	
-- 1355. Activity Participants
/* Table: Friends
+---------------+---------+
| Column Name   | Type    |
+---------------+---------+
| id            | int     |
| name          | varchar |
| activity      | varchar |
+---------------+---------+
id is the id of the friend and primary key for this table.
name is the name of the friend.
activity is the name of the activity which the friend takes part in.
Table: Activities
+---------------+---------+
| Column Name   | Type    |
+---------------+---------+
| id            | int     |
| name          | varchar |
+---------------+---------+
id is the primary key for this table.
name is the name of the activity.

Write an SQL query to find the names of all the activities with neither maximum, nor minimum number of participants.
Return the result table in any order. Each activity in table Activities is performed by any person in the table Friends.
The query result format is in the following example:

Friends table:
+------+--------------+---------------+
| id   | name         | activity      |
+------+--------------+---------------+
| 1    | Jonathan D.  | Eating        |
| 2    | Jade W.      | Singing       |
| 3    | Victor J.    | Singing       |
| 4    | Elvis Q.     | Eating        |
| 5    | Daniel A.    | Eating        |
| 6    | Bob B.       | Horse Riding  |
+------+--------------+---------------+

Activities table:
+------+--------------+
| id   | name         |
+------+--------------+
| 1    | Eating       |
| 2    | Singing      |
| 3    | Horse Riding |
+------+--------------+

Result table:
+--------------+
| activity     |
+--------------+
| Singing      |
+--------------+

Eating activity is performed by 3 friends, maximum number of participants, (Jonathan D. , Elvis Q. and Daniel A.)
Horse Riding activity is performed by 1 friend, minimum number of participants, (Bob B.)
Singing is performed by 2 friends (Victor J. and Jade W.)
*/
select a.activity Activity
from(
select 
    count(id) count_number,
    activity,
    rank() over(order by count(id) desc) desc_count,
    rank() over(order by count(id) asc) asc_count
from Friends 
group by activity)a
where a.desc_count!=1 and a.asc_count!=1
					 					 
-- Find the missing Id.
/*+---------------+---------+
| Column Name   | Type    |
+---------------+---------+
| customer_id   | int     |
| customer_name | varchar |
+---------------+---------+
customer_id is the primary key for this table.
Each row of this table contains the name and the id customer.
Write an SQL query to find the missing customer IDs. The missing IDs are ones that are not in the Customers table but are in the range between 1 and the maximum customer_id present in the table.
Notice that the maximum customer_id will not exceed 100.
Return the result table ordered by ids in ascending order.
The query result format is in the following example.
 
Customers table:
+-------------+---------------+
| customer_id | customer_name |
+-------------+---------------+
| 1           | Alice         |
| 4           | Bob           |
| 5           | Charlie       |
+-------------+---------------+

Result table:
+-----+
| ids |
+-----+
| 2   |
| 3   |
+-----+
The maximum customer_id present in the table is 5, so in the range [1,5], IDs 2 and 3 are missing from the table.*/					 
 WITH RECURSIVE seq AS (
    SELECT 1 AS value 
    UNION ALL 
    SELECT value + 1 
    FROM seq 
    WHERE value < (SELECT MAX(customer_id) FROM Customers))
SELECT DISTINCT s.value AS ids
FROM seq s, Customers c
WHERE s.value not in (SELECT customer_id FROM Customers)
ORDER BY 1 ASC;
		   
--Three most recent orders
/*Table: Customers
+---------------+---------+
| Column Name   | Type    |
+---------------+---------+
| customer_id   | int     |
| name          | varchar |
+---------------+---------+
customer_id is the primary key for this table.
This table contains information about customers.

Table: Orders
+---------------+---------+
| Column Name   | Type    |
+---------------+---------+
| order_id      | int     |
| order_date    | date    |
| customer_id   | int     |
| cost          | int     |
+---------------+---------+
order_id is the primary key for this table.
This table contains information about the orders made by customer_id.
Each customer has one order per day.
 
Write an SQL query to find the most recent 3 orders of each user. If a user ordered less than 3 orders return all of their orders.
Return the result table sorted by customer_name in ascending order and in case of a tie by the customer_id in ascending order.
If there still a tie, order them by the order_date in descending order.
The query result format is in the following example:

Customers
+-------------+-----------+
| customer_id | name      |
+-------------+-----------+
| 1           | Winston   |
| 2           | Jonathan  |
| 3           | Annabelle |
| 4           | Marwan    |
| 5           | Khaled    |
+-------------+-----------+

Orders
+----------+------------+-------------+------+
| order_id | order_date | customer_id | cost |
+----------+------------+-------------+------+
| 1        | 2020-07-31 | 1           | 30   |
| 2        | 2020-07-30 | 2           | 40   |
| 3        | 2020-07-31 | 3           | 70   |
| 4        | 2020-07-29 | 4           | 100  |
| 5        | 2020-06-10 | 1           | 1010 |
| 6        | 2020-08-01 | 2           | 102  |
| 7        | 2020-08-01 | 3           | 111  |
| 8        | 2020-08-03 | 1           | 99   |
| 9        | 2020-08-07 | 2           | 32   |
| 10       | 2020-07-15 | 1           | 2    |
+----------+------------+-------------+------+

Result table:
+---------------+-------------+----------+------------+
| customer_name | customer_id | order_id | order_date |
+---------------+-------------+----------+------------+
| Annabelle     | 3           | 7        | 2020-08-01 |
| Annabelle     | 3           | 3        | 2020-07-31 |
| Jonathan      | 2           | 9        | 2020-08-07 |
| Jonathan      | 2           | 6        | 2020-08-01 |
| Jonathan      | 2           | 2        | 2020-07-30 |
| Marwan        | 4           | 4        | 2020-07-29 |
| Winston       | 1           | 8        | 2020-08-03 |
| Winston       | 1           | 1        | 2020-07-31 |
| Winston       | 1           | 10       | 2020-07-15 |
+---------------+-------------+----------+------------+
Winston has 4 orders, we discard the order of "2020-06-10" because it is the oldest order.
Annabelle has only 2 orders, we return them.
Jonathan has exactly 3 orders.
Marwan ordered only one time.
We sort the result table by customer_name in ascending order, by customer_id in ascending order and by order_date in descending order in case of a tie.*/
select customer_name,customer_id,order_id,order_date 
from(
select 
    c.name as customer_name,
    c.customer_id as customer_id,
    o.order_id as order_id,
    o.order_date as order_date,
    row_number() over (partition by o.customer_id order by o.order_date desc) rn 
from Customers c
join Orders o
on c.customer_id = o.customer_id)p
where  rn<= 3
order by customer_name asc,customer_id asc,order_date desc

/* Facebook */
--1661. Average Time of Process per Machine
/* Table: Activity
+----------------+---------+
| Column Name    | Type    |
+----------------+---------+
| machine_id     | int     |
| process_id     | int     |
| activity_type  | enum    |
| timestamp      | float   |
+----------------+---------+
The table shows the user activities for a factory website.
(machine_id, process_id, activity_type) is the primary key of this table.
machine_id is the ID of a machine.
process_id is the ID of a process running on the machine with ID machine_id.
activity_type is an ENUM of type ('start', 'end').
timestamp is a float representing the current time in seconds.
'start' means the machine starts the process at the given timestamp and 'end' means the machine ends the process at the given timestamp.
The 'start' timestamp will always be before the 'end' timestamp for every (machine_id, process_id) pair.
 
There is a factory website that has several machines each running the same number of processes. Write an SQL query to find the average time each machine takes to complete a process.
The time to complete a process is the 'end' timestamp minus the 'start' timestamp. The average time is calculated by the total time to complete every process on the machine divided by the number of processes that were run.
The resulting table should have the machine_id along with the average time as processing_time, which should be rounded to 3 decimal places.
The query result format is in the following example:

Activity table:
+------------+------------+---------------+-----------+
| machine_id | process_id | activity_type | timestamp |
+------------+------------+---------------+-----------+
| 0          | 0          | start         | 0.712     |
| 0          | 0          | end           | 1.520     |
| 0          | 1          | start         | 3.140     |
| 0          | 1          | end           | 4.120     |
| 1          | 0          | start         | 0.550     |
| 1          | 0          | end           | 1.550     |
| 1          | 1          | start         | 0.430     |
| 1          | 1          | end           | 1.420     |
| 2          | 0          | start         | 4.100     |
| 2          | 0          | end           | 4.512     |
| 2          | 1          | start         | 2.500     |
| 2          | 1          | end           | 5.000     |
+------------+------------+---------------+-----------+

Result table:
+------------+-----------------+
| machine_id | processing_time |
+------------+-----------------+
| 0          | 0.894           |
| 1          | 0.995           |
| 2          | 1.456           |
+------------+-----------------+

There are 3 machines running 2 processes each.
Machine 0's average time is ((1.520 - 0.712) + (4.120 - 3.140)) / 2 = 0.894
Machine 1's average time is ((1.550 - 0.550) + (1.420 - 0.430)) / 2 = 0.995
Machine 2's average time is ((4.512 - 4.100) + (5.000 - 2.500)) / 2 = 1.456
*/
SELECT machine_id,
ROUND((SUM(CASE WHEN activity_type = 'end' THEN timestamp END)- SUM(CASE WHEN activity_type = 'start' THEN timestamp END))/COUNT(DISTINCT process_id), 3) processing_time
FROM Activity
GROUP BY 1

--1211. Queries Quality and Percentage
/*
Table: Queries
+-------------+---------+
| Column Name | Type    |
+-------------+---------+
| query_name  | varchar |
| result      | varchar |
| position    | int     |
| rating      | int     |
+-------------+---------+
There is no primary key for this table, it may have duplicate rows.
This table contains information collected from some queries on a database.
The position column has a value from 1 to 500.
The rating column has a value from 1 to 5. Query with rating less than 3 is a poor query.

We define query quality as:
The average of the ratio between query rating and its position.
We also define poor query percentage as:
The percentage of all queries with rating less than 3.
Write an SQL query to find each query_name, the quality and poor_query_percentage.
Both quality and poor_query_percentage should be rounded to 2 decimal places.
The query result format is in the following example:

Queries table:
+------------+-------------------+----------+--------+
| query_name | result            | position | rating |
+------------+-------------------+----------+--------+
| Dog        | Golden Retriever  | 1        | 5      |
| Dog        | German Shepherd   | 2        | 5      |
| Dog        | Mule              | 200      | 1      |
| Cat        | Shirazi           | 5        | 2      |
| Cat        | Siamese           | 3        | 3      |
| Cat        | Sphynx            | 7        | 4      |
+------------+-------------------+----------+--------+

Result table:
+------------+---------+-----------------------+
| query_name | quality | poor_query_percentage |
+------------+---------+-----------------------+
| Dog        | 2.50    | 33.33                 |
| Cat        | 0.66    | 33.33                 |
+------------+---------+-----------------------+

Dog queries quality is ((5 / 1) + (5 / 2) + (1 / 200)) / 3 = 2.50
Dog queries poor_ query_percentage is (1 / 3) * 100 = 33.33

Cat queries quality equals ((2 / 5) + (3 / 3) + (4 / 7)) / 3 = 0.66
Cat queries poor_ query_percentage is (1 / 3) * 100 = 33.33
*/
select 
    query_name, 
    round(sum(rating/position)/count(query_name),2) as quality, 
    round((sum(case when rating <3 then 1 end)/count(query_name))*100,2) as poor_query_percentage
from Queries
group by query_name

--1241. Number of Comments per Post
/*Table: Submissions

+---------------+----------+
| Column Name   | Type     |
+---------------+----------+
| sub_id        | int      |
| parent_id     | int      |
+---------------+----------+
There is no primary key for this table, it may have duplicate rows.
Each row can be a post or comment on the post.
parent_id is null for posts.
parent_id for comments is sub_id for another post in the table.

Write an SQL query to find number of comments per each post.

Result table should contain post_id and its corresponding number_of_comments, and must be sorted by post_id in ascending order.
Submissions may contain duplicate comments. You should count the number of unique comments per post.
Submissions may contain duplicate posts. You should treat them as one post.
The query result format is in the following example:

Submissions table:
+---------+------------+
| sub_id  | parent_id  |
+---------+------------+
| 1       | Null       |
| 2       | Null       |
| 1       | Null       |
| 12      | Null       |
| 3       | 1          |
| 5       | 2          |
| 3       | 1          |
| 4       | 1          |
| 9       | 1          |
| 10      | 2          |
| 6       | 7          |
+---------+------------+

Result table:
+---------+--------------------+
| post_id | number_of_comments |
+---------+--------------------+
| 1       | 3                  |
| 2       | 2                  |
| 12      | 0                  |
+---------+--------------------+

The post with id 1 has three comments in the table with id 3, 4 and 9. The comment with id 3 is repeated in the table, we counted it only once.
The post with id 2 has two comments in the table with id 5 and 10.
The post with id 12 has no comments in the table.
The comment with id 6 is a comment on a deleted post with id 7 so we ignored it.*/
select 
    s1.sub_id as post_id,
    count(distinct s2.sub_id) as number_of_comments
from Submissions s1 
left join Submissions s2 
  on  s2.parent_id = s1.sub_id
where s1.parent_id is null
GROUP BY 1
 
--1322. Ads Performance
/*Table: Ads

+---------------+---------+
| Column Name   | Type    |
+---------------+---------+
| ad_id         | int     |
| user_id       | int     |
| action        | enum    |
+---------------+---------+
(ad_id, user_id) is the primary key for this table.
Each row of this table contains the ID of an Ad, the ID of a user and the action taken by this user regarding this Ad.
The action column is an ENUM type of ('Clicked', 'Viewed', 'Ignored').
 
A company is running Ads and wants to calculate the performance of each Ad.
Performance of the Ad is measured using Click-Through Rate (CTR) where:
ctr = 0 if total_clicks + total_views = 0
    = total_clicks/(total_clicks + total_views)

Write an SQL query to find the ctr of each Ad.
Round ctr to 2 decimal points. Order the result table by ctr in descending order and by ad_id in ascending order in case of a tie.
The query result format is in the following example:

Ads table:
+-------+---------+---------+
| ad_id | user_id | action  |
+-------+---------+---------+
| 1     | 1       | Clicked |
| 2     | 2       | Clicked |
| 3     | 3       | Viewed  |
| 5     | 5       | Ignored |
| 1     | 7       | Ignored |
| 2     | 7       | Viewed  |
| 3     | 5       | Clicked |
| 1     | 4       | Viewed  |
| 2     | 11      | Viewed  |
| 1     | 2       | Clicked |
+-------+---------+---------+
Result table:
+-------+-------+
| ad_id | ctr   |
+-------+-------+
| 1     | 66.67 |
| 3     | 50.00 |
| 2     | 33.33 |
| 5     | 0.00  |
+-------+-------+
for ad_id = 1, ctr = (2/(2+1)) * 100 = 66.67
for ad_id = 2, ctr = (1/(1+2)) * 100 = 33.33
for ad_id = 3, ctr = (1/(1+1)) * 100 = 50.00
for ad_id = 5, ctr = 0.00, Note that ad_id = 5 has no clicks or views.
Note that we don't care about Ignored Ads.
Result table is ordered by the ctr. in case of a tie we order them by ad_id */
SELECT 
    ad_id, 
    ROUND(IFNULL(SUM(IF(action='clicked',1,0))/SUM(IF(action='clicked' OR action='viewed',1,0))*100,0),2) AS ctr
FROM Ads
GROUP BY ad_id
ORDER BY ctr DESC, ad_id

--1141. User Activity for the Past 30 Days I
/* Table: Activity

+---------------+---------+
| Column Name   | Type    |
+---------------+---------+
| user_id       | int     |
| session_id    | int     |
| activity_date | date    |
| activity_type | enum    |
+---------------+---------+
There is no primary key for this table, it may have duplicate rows.
The activity_type column is an ENUM of type ('open_session', 'end_session', 'scroll_down', 'send_message').
The table shows the user activities for a social media website. 
Note that each session belongs to exactly one user.
 

Write an SQL query to find the daily active user count for a period of 30 days ending 2019-07-27 inclusively. A user was active on some day if he/she made at least one activity on that day.

The query result format is in the following example:

Activity table:
+---------+------------+---------------+---------------+
| user_id | session_id | activity_date | activity_type |
+---------+------------+---------------+---------------+
| 1       | 1          | 2019-07-20    | open_session  |
| 1       | 1          | 2019-07-20    | scroll_down   |
| 1       | 1          | 2019-07-20    | end_session   |
| 2       | 4          | 2019-07-20    | open_session  |
| 2       | 4          | 2019-07-21    | send_message  |
| 2       | 4          | 2019-07-21    | end_session   |
| 3       | 2          | 2019-07-21    | open_session  |
| 3       | 2          | 2019-07-21    | send_message  |
| 3       | 2          | 2019-07-21    | end_session   |
| 4       | 3          | 2019-06-25    | open_session  |
| 4       | 3          | 2019-06-25    | end_session   |
+---------+------------+---------------+---------------+

Result table:
+------------+--------------+ 
| day        | active_users |
+------------+--------------+ 
| 2019-07-20 | 2            |
| 2019-07-21 | 2            |
+------------+--------------+ 
Note that we do not care about days with zero active users. */
select 
    activity_date as day, 
    count(distinct user_id) as active_users 
from Activity
where datediff('2019-07-27', activity_date) <30
group by activity_date
			
--1142. User Activity for the Past 30 Days II
/* Write an SQL query to find the average number of sessions per user for a period of 30 days ending 2019-07-27 inclusively, rounded to 2 decimal places.
The sessions we want to count for a user are those with at least one activity in that time period. 
Activity table:
+---------+------------+---------------+---------------+
| user_id | session_id | activity_date | activity_type |
+---------+------------+---------------+---------------+
| 1       | 1          | 2019-07-20    | open_session  |
| 1       | 1          | 2019-07-20    | scroll_down   |
| 1       | 1          | 2019-07-20    | end_session   |
| 2       | 4          | 2019-07-20    | open_session  |
| 2       | 4          | 2019-07-21    | send_message  |
| 2       | 4          | 2019-07-21    | end_session   |
| 3       | 2          | 2019-07-21    | open_session  |
| 3       | 2          | 2019-07-21    | send_message  |
| 3       | 2          | 2019-07-21    | end_session   |
| 3       | 5          | 2019-07-21    | open_session  |
| 3       | 5          | 2019-07-21    | scroll_down   |
| 3       | 5          | 2019-07-21    | end_session   |
| 4       | 3          | 2019-06-25    | open_session  |
| 4       | 3          | 2019-06-25    | end_session   |
+---------+------------+---------------+---------------+

Result table:
+---------------------------+ 
| average_sessions_per_user |
+---------------------------+ 
| 1.33                      |
+---------------------------+ 
User 1 and 2 each had 1 session in the past 30 days while user 3 had 2 sessions so the average is (1 + 1 + 2) / 3 = 1.33.			
*/
select IFNULL(ROUND(COUNT(DISTINCT user_id,session_id)/COUNT(DISTINCT user_id),2),0) AS average_sessions_per_user 
from Activity
where datediff('2019-07-27',activity_date) <= 30

-- 1076. Project Employees II
/*Table: Project

+-------------+---------+
| Column Name | Type    |
+-------------+---------+
| project_id  | int     |
| employee_id | int     |
+-------------+---------+
(project_id, employee_id) is the primary key of this table.
employee_id is a foreign key to Employee table.

Table: Employee
+------------------+---------+
| Column Name      | Type    |
+------------------+---------+
| employee_id      | int     |
| name             | varchar |
| experience_years | int     |
+------------------+---------+
employee_id is the primary key of this table.

Write an SQL query that reports all the projects that have the most employees.
The query result format is in the following example:
Project table:
+-------------+-------------+
| project_id  | employee_id |
+-------------+-------------+
| 1           | 1           |
| 1           | 2           |
| 1           | 3           |
| 2           | 1           |
| 2           | 4           |
+-------------+-------------+

Employee table:
+-------------+--------+------------------+
| employee_id | name   | experience_years |
+-------------+--------+------------------+
| 1           | Khaled | 3                |
| 2           | Ali    | 2                |
| 3           | John   | 1                |
| 4           | Doe    | 2                |
+-------------+--------+------------------+

Result table:
+-------------+
| project_id  |
+-------------+
| 1           |
+-------------+
The first project has 3 employees while the second one has 2.*/
SELECT project_id
FROM project
GROUP BY project_id
HAVING COUNT(employee_id) =
(
    SELECT count(employee_id)
    FROM project
    GROUP BY project_id
    ORDER BY count(employee_id) desc
    LIMIT 1
)
			
--597. Friend Requests I: Overall Acceptance Rate
/*Table: FriendRequest

+----------------+---------+
| Column Name    | Type    |
+----------------+---------+
| sender_id      | int     |
| send_to_id     | int     |
| request_date   | date    |
+----------------+---------+
There is no primary key for this table, it may contain duplicates.
This table contains the ID of the user who sent the request, the ID of the user who received the request, and the date of the request.
Table: RequestAccepted

+----------------+---------+
| Column Name    | Type    |
+----------------+---------+
| requester_id   | int     |
| accepter_id    | int     |
| accept_date    | date    |
+----------------+---------+
There is no primary key for this table, it may contain duplicates.
This table contains the ID of the user who sent the request, the ID of the user who received the request, and the date when the request was accepted.
Write an SQL query to find the overall acceptance rate of requests, which is the number of acceptance divided by the number of requests. Return the answer rounded to 2 decimals places.

Note that:
The accepted requests are not necessarily from the table friend_request. In this case, you just need to simply count the total accepted requests (no matter whether they are in the original requests), and divide it by the number of requests to get the acceptance rate.
It is possible that a sender sends multiple requests to the same receiver, and a request could be accepted more than once. In this case, the ‘duplicated’ requests or acceptances are only counted once.
If there are no requests at all, you should return 0.00 as the accept_rate.
The query result format is in the following example:

FriendRequest table:
+-----------+------------+--------------+
| sender_id | send_to_id | request_date |
+-----------+------------+--------------+
| 1         | 2          | 2016/06/01   |
| 1         | 3          | 2016/06/01   |
| 1         | 4          | 2016/06/01   |
| 2         | 3          | 2016/06/02   |
| 3         | 4          | 2016/06/09   |
+-----------+------------+--------------+

RequestAccepted table:
+--------------+-------------+-------------+
| requester_id | accepter_id | accept_date |
+--------------+-------------+-------------+
| 1            | 2           | 2016/06/03  |
| 1            | 3           | 2016/06/08  |
| 2            | 3           | 2016/06/08  |
| 3            | 4           | 2016/06/09  |
| 3            | 4           | 2016/06/10  |
+--------------+-------------+-------------+

Result table:
+-------------+
| accept_rate |
+-------------+
| 0.8         |
+-------------+
There are 4 unique accepted requests, and there are 5 requests in total. So the rate is 0.80.*/
SELECT 
    ROUND(IFNULL(
                COUNT(DISTINCT requester_id, accepter_id) / 
                COUNT(DISTINCT sender_id, send_to_id)
              , 0)
       , 2) AS accept_rate
FROM FriendRequest, RequestAccepted;
		   
--1398. Customers Who Bought Products A and B but Not C
/* Table: Customers
+---------------------+---------+
| Column Name         | Type    |
+---------------------+---------+
| customer_id         | int     |
| customer_name       | varchar |
+---------------------+---------+
customer_id is the primary key for this table.
customer_name is the name of the customer.

Table: Orders
+---------------+---------+
| Column Name   | Type    |
+---------------+---------+
| order_id      | int     |
| customer_id   | int     |
| product_name  | varchar |
+---------------+---------+
order_id is the primary key for this table.
customer_id is the id of the customer who bought the product "product_name".
 
Write an SQL query to report the customer_id and customer_name of customers who bought products "A", "B" but did not buy the product "C" since we want to recommend them buy this product.
Return the result table ordered by customer_id.
The query result format is in the following example.

Customers table:
+-------------+---------------+
| customer_id | customer_name |
+-------------+---------------+
| 1           | Daniel        |
| 2           | Diana         |
| 3           | Elizabeth     |
| 4           | Jhon          |
+-------------+---------------+

Orders table:
+------------+--------------+---------------+
| order_id   | customer_id  | product_name  |
+------------+--------------+---------------+
| 10         |     1        |     A         |
| 20         |     1        |     B         |
| 30         |     1        |     D         |
| 40         |     1        |     C         |
| 50         |     2        |     A         |
| 60         |     3        |     A         |
| 70         |     3        |     B         |
| 80         |     3        |     D         |
| 90         |     4        |     C         |
+------------+--------------+---------------+

Result table:
+-------------+---------------+
| customer_id | customer_name |
+-------------+---------------+
| 3           | Elizabeth     |
+-------------+---------------+
Only the customer_id with id 3 bought the product A and B but not the product C.*/
select a.customer_id, a.customer_name
from customers a
where customer_id in (select customer_id from orders where product_name = 'A') 
and customer_id in (select customer_id from orders where product_name = 'B')
and customer_id not in (select customer_id from orders where product_name = 'C')
order by customer_id

--1264. Page Recommendations
/*Table: Friendship
+---------------+---------+
| Column Name   | Type    |
+---------------+---------+
| user1_id      | int     |
| user2_id      | int     |
+---------------+---------+
(user1_id, user2_id) is the primary key for this table.
Each row of this table indicates that there is a friendship relation between user1_id and user2_id.

Table: Likes
+-------------+---------+
| Column Name | Type    |
+-------------+---------+
| user_id     | int     |
| page_id     | int     |
+-------------+---------+
(user_id, page_id) is the primary key for this table.
Each row of this table indicates that user_id likes page_id.

Write an SQL query to recommend pages to the user with user_id = 1 using the pages that your friends liked. It should not recommend pages you already liked.
Return result table in any order without duplicates.
The query result format is in the following example:

Friendship table:
+----------+----------+
| user1_id | user2_id |
+----------+----------+
| 1        | 2        |
| 1        | 3        |
| 1        | 4        |
| 2        | 3        |
| 2        | 4        |
| 2        | 5        |
| 6        | 1        |
+----------+----------+
Likes table:
+---------+---------+
| user_id | page_id |
+---------+---------+
| 1       | 88      |
| 2       | 23      |
| 3       | 24      |
| 4       | 56      |
| 5       | 11      |
| 6       | 33      |
| 2       | 77      |
| 3       | 77      |
| 6       | 88      |
+---------+---------+
Result table:
+------------------+
| recommended_page |
+------------------+
| 23               |
| 24               |
| 56               |
| 33               |
| 77               |
+------------------+
User one is friend with users 2, 3, 4 and 6.
Suggested pages are 23 from user 2, 24 from user 3, 56 from user 3 and 33 from user 6.
Page 77 is suggested from both user 2 and user 3.
Page 88 is not suggested because user 1 already likes it.*/
select distinct l.page_id as recommended_page
from Likes l
join Friendship f
on f.user2_id = l.user_id or f.user1_id =l.user_id
where (user1_id = 1 or user2_id = 1) 
  and page_id not in (select distinct page_id from Likes where user_id = 1)
  
--602. Friend Requests II: Who Has the Most Friends
/*Table request_accepted
+--------------+-------------+------------+
| requester_id | accepter_id | accept_date|
|--------------|-------------|------------|
| 1            | 2           | 2016_06-03 |
| 1            | 3           | 2016-06-08 |
| 2            | 3           | 2016-06-08 |
| 3            | 4           | 2016-06-09 |
+--------------+-------------+------------+
This table holds the data of friend acceptance, while requester_id and accepter_id both are the id of a person.
 
Write a query to find the the people who has most friends and the most friends number under the following rules:
It is guaranteed there is only 1 people having the most friends.
The friend request could only been accepted once, which mean there is no multiple records with the same requester_id and accepter_id value.
For the sample data above, the result is:

Result table:
+------+------+
| id   | num  |
|------|------|
| 3    | 3    |
+------+------+
The person with id '3' is a friend of people '1', '2' and '4', so he has 3 friends in total, which is the most number than any others.
Follow-up:
In the real world, multiple people could have the same most number of friends, can you find all these people in this case?*/
select 
    id1 as id, 
    count(id2) as num
from
    (select requester_id as id1, accepter_id as id2 
    from request_accepted
    union
    select accepter_id as id1, requester_id as id2 
    from request_accepted) tmp1
group by id1 
order by num desc 
limit 1

--578. Get Highest Answer Rate Question
/* 
Get the highest answer rate question from a table survey_log with these columns: id, action, question_id, answer_id, q_num, timestamp.
id means user id; action has these kind of values: "show", "answer", "skip"; answer_id is not null when action column is "answer", 
while is null for "show" and "skip"; q_num is the numeral order of the question in current session.
Write a sql query to identify the question which has the highest answer rate.

Example:
Input:
+------+-----------+--------------+------------+-----------+------------+
| id   | action    | question_id  | answer_id  | q_num     | timestamp  |
+------+-----------+--------------+------------+-----------+------------+
| 5    | show      | 285          | null       | 1         | 123        |
| 5    | answer    | 285          | 124124     | 1         | 124        |
| 5    | show      | 369          | null       | 2         | 125        |
| 5    | skip      | 369          | null       | 2         | 126        |
+------+-----------+--------------+------------+-----------+------------+
Output:
+-------------+
| survey_log  |
+-------------+
|    285      |
+-------------+
Explanation:
question 285 has answer rate 1/1, while question 369 has 0/1 answer rate, so output 285.
Note: The highest answer rate meaning is: answer number's ratio in show number in the same question.*/
select question_id as survey_log from survey_log
group by question_id
order by count(answer_id)/count(*) desc
limit 1

--1132. Reported Posts II
/*
Table: Actions
+---------------+---------+
| Column Name   | Type    |
+---------------+---------+
| user_id       | int     |
| post_id       | int     |
| action_date   | date    |
| action        | enum    |
| extra         | varchar |
+---------------+---------+
There is no primary key for this table, it may have duplicate rows.
The action column is an ENUM type of ('view', 'like', 'reaction', 'comment', 'report', 'share').
The extra column has optional information about the action such as a reason for report or a type of reaction. 
Table: Removals
+---------------+---------+
| Column Name   | Type    |
+---------------+---------+
| post_id       | int     |
| remove_date   | date    | 
+---------------+---------+
post_id is the primary key of this table.
Each row in this table indicates that some post was removed as a result of being reported or as a result of an admin review.
Write an SQL query to find the average for daily percentage of posts that got removed after being reported as spam, rounded to 2 decimal places.
The query result format is in the following example:
Actions table:
+---------+---------+-------------+--------+--------+
| user_id | post_id | action_date | action | extra  |
+---------+---------+-------------+--------+--------+
| 1       | 1       | 2019-07-01  | view   | null   |
| 1       | 1       | 2019-07-01  | like   | null   |
| 1       | 1       | 2019-07-01  | share  | null   |
| 2       | 2       | 2019-07-04  | view   | null   |
| 2       | 2       | 2019-07-04  | report | spam   |
| 3       | 4       | 2019-07-04  | view   | null   |
| 3       | 4       | 2019-07-04  | report | spam   |
| 4       | 3       | 2019-07-02  | view   | null   |
| 4       | 3       | 2019-07-02  | report | spam   |
| 5       | 2       | 2019-07-03  | view   | null   |
| 5       | 2       | 2019-07-03  | report | racism |
| 5       | 5       | 2019-07-03  | view   | null   |
| 5       | 5       | 2019-07-03  | report | racism |
+---------+---------+-------------+--------+--------+

Removals table:
+---------+-------------+
| post_id | remove_date |
+---------+-------------+
| 2       | 2019-07-20  |
| 3       | 2019-07-18  |
+---------+-------------+

Result table:
+-----------------------+
| average_daily_percent |
+-----------------------+
| 75.00                 |
+-----------------------+
The percentage for 2019-07-04 is 50% because only one post of two spam reported posts was removed.
The percentage for 2019-07-02 is 100% because one post was reported as spam and it was removed.
The other days had no spam reports so the average is (50 + 100) / 2 = 75%
Note that the output is only one number and that we do not care about the remove dates.
*/
SELECT ROUND(AVG(cnt), 2) AS average_daily_percent 
FROM
  (SELECT (COUNT(DISTINCT r.post_id)/ COUNT(DISTINCT a.post_id))*100  AS cnt
   FROM Actions a
   LEFT JOIN Removals r
   ON a.post_id = r.post_id
   WHERE extra ='spam' and action = 'report'
   GROUP BY action_date) tmp

--614. Second Degree Follower
/*In facebook, there is a follow table with two columns: followee, follower.
Please write a sql query to get the amount of each follower’s follower if he/she has one.
For example:

+-------------+------------+
| followee    | follower   |
+-------------+------------+
|     A       |     B      |
|     B       |     C      |
|     B       |     D      |
|     D       |     E      |
+-------------+------------+
should output:
+-------------+------------+
| follower    | num        |
+-------------+------------+
|     B       |  2         |
|     D       |  1         |
+-------------+------------+
Explaination:
Both B and D exist in the follower list, when as a followee, B's follower is C and D, and D's follower is E. A does not exist in follower list.

Note:
Followee would not follow himself/herself in all cases.
Please display the result in follower's alphabet order.*/
select 
    followee as follower,
    count(distinct follower) as num
from follow
where followee in (Select follower from follow)
group by 1
order by 1
	
--1225. Report Contiguous Dates
/*Table: Failed

+--------------+---------+
| Column Name  | Type    |
+--------------+---------+
| fail_date    | date    |
+--------------+---------+
Primary key for this table is fail_date.
Failed table contains the days of failed tasks.
Table: Succeeded

+--------------+---------+
| Column Name  | Type    |
+--------------+---------+
| success_date | date    |
+--------------+---------+
Primary key for this table is success_date.
Succeeded table contains the days of succeeded tasks.

A system is running one task every day. Every task is independent of the previous tasks. The tasks can fail or succeed.
Write an SQL query to generate a report of period_state for each continuous interval of days in the period from 2019-01-01 to 2019-12-31.
period_state is 'failed' if tasks in this interval failed or 'succeeded' if tasks in this interval succeeded. Interval of days are retrieved as start_date and end_date.

Order result by start_date.

The query result format is in the following example:

Failed table:
+-------------------+
| fail_date         |
+-------------------+
| 2018-12-28        |
| 2018-12-29        |
| 2019-01-04        |
| 2019-01-05        |
+-------------------+

Succeeded table:
+-------------------+
| success_date      |
+-------------------+
| 2018-12-30        |
| 2018-12-31        |
| 2019-01-01        |
| 2019-01-02        |
| 2019-01-03        |
| 2019-01-06        |
+-------------------+

Result table:
+--------------+--------------+--------------+
| period_state | start_date   | end_date     |
+--------------+--------------+--------------+
| succeeded    | 2019-01-01   | 2019-01-03   |
| failed       | 2019-01-04   | 2019-01-05   |
| succeeded    | 2019-01-06   | 2019-01-06   |
+--------------+--------------+--------------+

The report ignored the system state in 2018 as we care about the system in the period 2019-01-01 to 2019-12-31.
From 2019-01-01 to 2019-01-03 all tasks succeeded and the system state was "succeeded".
From 2019-01-04 to 2019-01-05 all tasks failed and system state was "failed".
From 2019-01-06 to 2019-01-06 all tasks succeeded and system state was "succeeded".*/
WITH combined as 
(
     SELECT 
        fail_date as dt, 
        'failed' as period_state,
        DAYOFYEAR(fail_date) - row_number() over(ORDER BY fail_date) as period_group 
     FROM 
        Failed
     WHERE fail_date BETWEEN '2019-01-01' AND '2019-12-31'
     UNION ALL
     SELECT 
        success_date as dt, 
        'succeeded' as period_state,
        DAYOFYEAR(success_date) - row_number() over(ORDER BY success_date) as period_group 
     FROM Succeeded
     WHERE success_date BETWEEN '2019-01-01' AND '2019-12-31'  
)
SELECT 
    period_state,
    min(dt) as start_date,
    max(dt) as end_date
FROM combined
GROUP BY period_state,period_group
ORDER BY start_date
	   
	   
