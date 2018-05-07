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
