--175. Combine Two Tables 
select p.FirstName, p.LastName,a.City,a.State
from Person p
left join Address a
on p.PersonId = a.PersonId

--176. Second highest Salary
select max(salary) as SecondHighestSalary
from Employee
where salary < (select max(salary) from Employee)

--177. Nth Highest Salary
Select salary from 
     (Select Salary, Row_Number() over (Order by Salary Desc) Salaryrank 
      From Employee)
Where Salaryrank = N

--178. Rank scores
select Score, Dense_Rank() over (order by score DESC) as Rank from Scores
# version 2
SELECT s.Score, count(distinct t.score) Rank
FROM Scores s JOIN Scores t ON s.Score <= t.score
GROUP BY s.Id
ORDER BY s.Score desc

--180. Consecutive Numbers
 select DISTINCT l1.Num as ConsecutiveNums
from Logs l1, Logs l2, Logs l3
where l1.Num = l2.Num and l2.Num = l3.Num
and l1.Id = l2.Id-1 and l2.Id = l3.Id-1

--181. Employees Earning More Than Their Managers
select e1.Name as Employee
from Employee as e1 
left outer join Employee as e2 on e1.ManagerId=e2.Id 
where e1.Salary > e2.Salary

--182. Duplicate Emails
select Email
from Person
group by Email 
having count(*) > 1

--183. Customers Who Never Order
select Name as Customers
from Customers 
where Id NOT IN (select CustomerId from Orders)

--184. Department Highest Salary
select d.Name as Department,e.Name as Employee, e.Salary as Salary
from Employee as e, Department as d 
where e.DepartmentId=d.id
and (DepartmentId,Salary) in (SELECT DepartmentId,max(Salary) as max FROM Employee GROUP BY DepartmentId)

--196. Delete Duplicate Emails
Delete p
from Person p,Person q
where p.Id > q.Id AND p.Email = q.EMail

--197. Rising Temperature.
select d.Name as Department,e.Name as Employee, e.Salary as Salary
from Employee as e, Department as d 
where e.DepartmentId=d.id
and (DepartmentId,Salary) in 
  (SELECT DepartmentId,max(Salary) as max FROM Employee GROUP BY DepartmentId)

--262. Trips and users
select Request_at as Day,
round(sum(case when Status like 'cancelled_%' then 1 else 0 end)/count(*),2) Cancellation_Rate
from (select * 
from Trips t
left outer join Users u
on t.Client_Id=u.Users_Id) as k
where Banned = 'No' 
group by Day

--595. Big Countries
select name,population,area
from World
where population > 25000000 or area > 3000000

--596. Classes More Than 5 Students
select class
from courses
group by class
having count(distinct student) >= 5

--601. Human Traffic of Stadium
select distinct s1.*
from Stadium s1, Stadium s2, Stadium s3
where ((s2.id=s1.id+1 and s3.id = s1.id+2) 
	or (s2.id=s1.id-1 and s3.id = s1.id+1) 
	or (s2.id=s1.id-2 and s3.id = s1.id-1) ) 
and s1.people>=100 and s2.people>=100 and s3.people>=100
order by s1.id

--620. Not Boring Movies
select *
from cinema
where description != 'boring' and id mod 2 !=0
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

--Locked Questions:
--579. Find Cumulative Salary of an Employee
SELECT
    E1.id,
    E1.month,
    (IFNULL(E1.salary, 0) + IFNULL(E2.salary, 0) + IFNULL(E3.salary, 0)) AS Salary
FROM
    (SELECT
        id, MAX(month) AS month
    FROM
        Employee
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

--615. Average Salary: Departments VS Company
 

--614. Second Degree Follower 
Select f1.follower, count(distinct f2.follower) as num
from follow f1,follow f2 on f1.follower = f2.followee
Group by f1.follower

--578. Get Highest Answer Rate Question







