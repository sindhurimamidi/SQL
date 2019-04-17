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
					 
					 
					 
