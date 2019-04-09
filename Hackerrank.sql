/*Advance Join Challenges*/
---------------------------
/* You are given a table, Projects, containing three columns: Task_ID, Start_Date and End_Date. 
   It is guaranteed that the difference between the End_Date and the Start_Date is equal to 1 day for each row in the table.
   If the End_Date of the tasks are consecutive, then they are part of the same project. 
   Samantha is interested in finding the total number of different projects completed.
   Write a query to output the start and end dates of projects listed by the number of days it took to complete the project in ascending order. 
   If there is more than one project that have the same number of completion days, then order by the start date of the project.
*/

SELECT Start_Date, End_Date
FROM 
    (SELECT Start_Date FROM Projects WHERE Start_Date NOT IN (SELECT End_Date FROM Projects)) a,
    (SELECT End_Date FROM Projects WHERE End_Date NOT IN (SELECT Start_Date FROM Projects)) b 
WHERE Start_Date < End_Date
GROUP BY Start_Date 
ORDER BY DATEDIFF(End_Date, Start_Date), Start_Date

/* You are given three tables: Students, Friends and Packages. Students contains two columns: ID and Name. 
   Friends contains two columns: ID and Friend_ID (ID of the ONLY best friend). 
   Packages contains two columns: ID and Salary (offered salary in $ thousands per month).
   Write a query to output the names of those students whose best friends got offered a higher salary than them. 
   Names must be ordered by the salary amount offered to the best friends. 
   It is guaranteed that no two students got same salary offer.
*/
Select S.Name
From (Students S join Friends F on S.ID = F.ID
      join Packages P1 on S.ID=P1.ID
      join Packages P2 on F.Friend_ID=P2.ID)
Where P2.Salary > P1.Salary
Order By P2.Salary;

/* Query the two cities in STATION with the shortest and longest CITY names, as well as their respective lengths (i.e.: number of characters in the name). 
   If there is more than one smallest or largest city, choose the one that comes first when ordered alphabetically.
   STATION: Field, type 
*/
SELECT CITY, LENGTH(CITY) as mlen 
FROM STATION 
ORDER BY  mlen DESC
LIMIT 1;

/* Query the Name of any student in STUDENTS who scored higher than  Marks. Order your output by the last three characters of each name. 
   If two or more students both have names ending in the same last three characters (i.e.: Bobby, Robby, etc.), secondary sort them by ascending ID.
   STUDENTS  : ID, name , marks. 
*/

select name
from students
where marks > 75
order by SUBSTRING(name, -3) asc, ID asc;

/* Write a query identifying the type of each record in the TRIANGLES table using its three side lengths. Output one of the following statements for each record in the table: TRIANGLE: A,B,C
   Not A Triangle: The given values of A, B, and C don't form a triangle.
   Equilateral: It's a triangle with  sides of equal length.
   Isosceles: It's a triangle with  sides of equal length.
   Scalene: It's a triangle with  sides of differing lengths. 
 */	
select case 
	when a+b<=c or b+c<=a or a+c<=b then 'Not A Triangle' 
	when a=b and b=c and c=a then 'Equilateral' 
	when a=b or b=c or a=c then 'Isosceles'
	else 'Scalene' end 
from TRIANGLES 

/* New Companies:
   select employee.company_code,company.founder,count(distinct employee.lead_manager_code),count(distinct employee.senior_manager_code),count(distinct employee.manager_code), count(distinct employee.employee_code) 
   from employee employee inner join company company on employee.company_code = company.company_code 
   group by employee.company_code,company.founder 
   order by employee.company_code;1. 
   Query the two cities in STATION with the shortest and longest CITY names, as well as their respective lengths (i.e.: number of characters in the name). 
   If there is more than one smallest or largest city, choose the one that comes first when ordered alphabetically.
   STATION: Field, type 
*/
SELECT CITY, LENGTH(CITY) as mlen 
FROM STATION 
ORDER BY  mlen DESC
LIMIT 1;

/* Movie and Genres:
   For each genre in the data set, how many genres are the movies in that genre in, on average. 
   For example, a Action movie is in 1.3 genres and the average Adventure movie is in 2.9 genres, 
   so an Action movie is a better defined genre.
   Genres
	id  name
	1   Action
	2   Adventure
	3   Animation
	4   Children's
	5   Comedy
   Genres_movies 
	id movie_id     genre_id
	1  1(Toy Story) 3(Animation)
	2  1(Toy Story) 4(Children's)
	3  1(Toy Story) 5(Comedy)
	4  2(GoldenEye) 1(Action)
	5  2(GoldenEye) 2(Adventure)
	6  2(GoldenEye) 16(Thriller)
*/
select g.name as genre_name,  
          avg(genres_count) as avg_count
from genres_movies as n
join 
    (select movie_id, 
                count(genre_id) as genres_count
      from genres_movies
      group by movie_id) as gm
on gm.movie_id = n.movie_id
join
    genres as g
on n.genre_id = g.id
group by g.name
order by avg_count desc

/* BASIC JOIN */
---------------
/* Given the CITY and COUNTRY tables, query the sum of the populations of all cities where the CONTINENT is 'Asia'. 
   CITY:id, name,countrycode, district, population
   COUNTRY: codename, continent, region,surfacearea,indepyear,population,lifeexpectancy,gnp,gnpold,localname,governmentform,headofstate,capital,code2
*/
select sum(c.population)
from city as c
join country as cn
on cn.code = c.countrycode
where cn.continent = 'Asia'
order by c.name;

/* Given the CITY and COUNTRY tables, query the names of all the continents (COUNTRY.Continent) and their respective average city populations (CITY.Population) 
   rounded down to the nearest integer.
*/
select c.continent,floor(avg(ci.population)) as 'avg_population'
from city ci
inner join country c
ON ci.countrycode = c.code
group by c.continent;

/* Student: id, name, marks
   Grade: grade, min_mark,max_mark
   Ketty gives Eve a task to generate a report containing three columns: Name, Grade and Mark. Ketty doesn't want the NAMES of those students who received a grade lower than 8. The report must be in descending order by grade -- i.e. higher grades are entered first. If there is more than one student with the same grade (8-10) assigned to them, order those particular students by their name alphabetically. Finally, if the grade is lower than 8, use "NULL" as their name and list them by their grades in descending order. If there is more than one student with the same grade (1-7) assigned to them, order those particular students by their marks in ascending order.
   Write a query to help Eve.
 */
select 
    if (grade >= 8 , s.name, NULL),
    g.grade,
    s.marks
from students as s 
join grades as g 
on s.marks between g.min_mark and g.max_mark
order by grade desc, s.name;

/* Julia just finished conducting a coding contest, and she needs your help assembling the leaderboard! Write a query to print the respective hacker_id and name of hackers who achieved full scores for more than one challenge. Order your output in descending order by the total number of challenges in which the hacker earned a full score. If more than one hacker received full scores in same number of challenges, then sort them by ascending hacker_id.
   hacker:          hacker_id,name
   difficulty:       difficulty_level, score
   challenges:    challenge_id,hacker_id, difficulty_level
   submissions:  submission_id,hacker_id,challenge_id,score
*/

select h.hacker_id, h.name
from submissions s
join challenges c
  on s.challenge_id = c.challenge_id
join difficulty d
  on c.difficulty_level = d.difficulty_level 
join hackers h
  on s.hacker_id = h.hacker_id
where s.score = d.score and c.difficulty_level = d.difficulty_level
group by 1,2
having count(s.hacker_id) > 1
order by count(s.hacker_id) desc, s.hacker_id asc

/* Harry Potter and his friends are at Ollivander's with Ron, finally replacing Charlie's old broken wand.Hermione decides the best way to choose is by determining the minimum number of gold galleons needed to buy each non-evil wand of high power and age. Write a query to print the id, age, coins_needed, and power of the wands that Ron's interested in, sorted in order of descending power. If more than one wand has same power, sort the result in order of descending age.
   Wands: The id is the id of the wand, code is the code of the wand, coins_needed is the total number of gold galleons needed to buy the wand, and power denotes the quality of the wand (the higher the power, the better the wand is).
   Wands_Property: The code is the code of the wand, age is the age of the wand, and is_evil denotes whether the wand is good for the dark arts. If the value of is_evil is 0, it means that the wand is not evil. The mapping between code and age is one-one, meaning that if there are two pairs,(code1,age1) and (code2,age2), then code1!=code2 and age1!=age2.*/
select w.id, p.age, w.coins_needed, w.power 
from Wands as w 
join Wands_Property as p 
  on (w.code = p.code) 
where p.is_evil = 0 
    and w.coins_needed = (select min(coins_needed) 
                                            from Wands as w1 
					   join Wands_Property as p1 
					     on (w1.code = p1.code) 
					   where w1.power = w.power 
        					       and p1.age = p.age) 
order by w.power desc, p.age desc

or

select id,age,coins_needed,power
from
     (select 
           w.id, 
           p.age, 
           w.coins_needed, 
           w.power, 
           row_number() over (partition by w.code, w.power order by w.coins_needed, w.power desc) as rn
      from Wands as w 
      join Wands_Property as p 
        on w.code = p.code
       where p.is_evil = 0) as wp
where rn =1 
order by power desc, age desc

/* Julia asked her students to create some coding challenges. Write a query to print the hacker_id, name, and the total number of challenges created by each student. 
   Sort your results by the total number of challenges in descending order. If more than one student created the same number of challenges, then sort the result by hacker_id. 
   If more than one student created the same number of challenges and the count is less than the maximum number of challenges created, then exclude those students from the result.
   hackers : hacker_id,name
   challenges: hacker_id, challenge_id 
*/
select 
	h.hacker_id, 
	h.name, 
	count(c.challenge_id) as c_count
from hackers h
join challenges c
on c.hacker_id=h.hacker_id	
group by 1,2
having c_count = (select max(t.count_c)
                  from (select count(hacker_id) as count_c
                       from challenges
                       group by hacker_id
                       order by hacker_id) t)
    or c_count in (select t.cnt
                   from (select count(*) as cnt 
                         from challenges
                         group by hacker_id) t
                   group by t.cnt
                   having count(t.cnt) = 1)
order by c_count desc, h.hacker_id;

/* Advanced select */
--------------------
/* The PADS */	
select concat(name,'(',left(occupation,1),')')
from occupations
order by name;

select CONCAT('There are a total of ',count(occupation),' ',LOWER(occupation),'s.')
from occupations
group by occupation
order by count(occupation) ASC, occupation ASC;	

/* Pivot the Occupation column in OCCUPATIONS so that each Name is sorted alphabetically and displayed underneath its corresponding Occupation. The output column headers should be Doctor, Professor, Singer, and Actor, respectively.
   Note: Print NULL when there are no more names corresponding to an occupation. 
   Occupations : name, occupation 
*/
set @r1=0, @r2=0, @r3=0, @r4=0;
select min(Doctor), min(Professor), min(Singer), min(Actor)
from(
  select 
     case 
       when Occupation='Doctor' then (@r1:=@r1+1)
       when Occupation='Professor' then (@r2:=@r2+1)
       when Occupation='Singer' then (@r3:=@r3+1)
       when Occupation='Actor' then (@r4:=@r4+1) 
     end as RowNumber,
     case when Occupation='Doctor' then Name end as Doctor,
     case when Occupation='Professor' then Name end as Professor,
     case when Occupation='Singer' then Name end as Singer,
     case when Occupation='Actor' then Name end as Actor
  from OCCUPATIONS
  order by Name
) Temp
group by RowNumber

/* Amber's conglomerate corporation just acquired some new companies. Each of the companies follows this hierarchy: Founder > LM > SM > M > E 
   write a query to print the company_code, founder name, total number of lead managers, total number of senior managers, total number of managers, and total number of employees. 
   Order your output by ascending company_code.The tables may contain duplicate records.
   The company_code is string, so the sorting should not be numeric.For example, if the company_codes are C_1, C_2, and C_10, then the ascending company_codes will be C_1, C_10, and C_2.
   company - company_code, founder
   lead_manager - lead_manager_code, company_code
   senior_manager - senior_manager_code, lead_manager_code, company_code
   Manager - manager_code, senior_manager_code, lead_manager_code, company_code.
   Employee - employee_code, manager_code, senior_manager_code, lead_manager_code, company_code 
*/			  
Select 
  c.company_code, 
  c.founder,
  count(distinct l.lead_manager_code),
  count(distinct s.senior_manager_code),
  count(distinct m.manager_code),
  count(distinct e.employee_code)
From company as c
Join lead_manager as l 
On c.company_code = l.company_code 
Join senior_manager as s
On l.lead_manager_code = s.lead_manager_code
Join manager as m
On m.senior_manager_code = s.senior_manager_code
Join employee as e
On e.manager_code = m.manager_code
group by 1,2
order by c.company_code;

/* You are given a table, BST, containing two columns: N and P, where N represents the value of a node in Binary Tree, and P is the parent of N. 
   Write a query to find the node type of Binary Tree ordered by the value of the node. Output one of the following for each node:
   Root: If node is root node.
   Leaf: If node is leaf node.
   Inner: If node is neither root nor leaf node.
    Table BST - N, P
*/
select N,
 case
  when P is null then 'Root'
  when N in (select P from BST) then 'Inner'
  else 'Leaf'
 end as node
from BST
order by N

/* Samantha was tasked with calculating the average monthly salaries for all employees in the EMPLOYEES table, but did not realize her keyboard's 0 key was broken until after completing the calculation. 
   She wants your help finding the difference between her miscalculation (using salaries with any zeroes removed), and the actual average salary.
   Write a query calculating the amount of error (i.e.: actual - miscalculated average monthly salaries), and round it up to the next integer. 
*/			     
select CEIL(avg(salary)-avg(replace(CAST(salary as CHAR(10)),'0','')))
from employees
							
/* We define an employee's total earnings to be their monthly salary x months worked, and the maximum total earnings to be the maximum total earnings for any employee in the Employee table. 
   Write a query to find the maximum total earnings for all employees as well as the total number of employees who have maximum total earnings. 
   Then print these values as  space-separated integers. 
   employee - id,name,salary,month 
*/
select (salary * months) as earnings ,count(*) 
from employee 
group by 1 
order by earnings desc 
limit 1

/* A median is defined as a number separating the higher half of a data set from the lower half. 
   Query the median of the Northern Latitudes (LAT_N) from STATION and round your answer to 4 decimal places.
   Station :id,city,state,lat_n,long_w 
*/					
select round(S.LAT_N,4) as median 
from station S 
where (select count(Lat_N) 
       from station 
       where Lat_N < S.LAT_N ) = (select count(Lat_N) 
                                  from station 
                                  where Lat_N > S.LAT_N)							
							
/* Query the two cities in STATION with the shortest and longest CITY names, as well as their respective lengths (i.e.: number of characters in the name). 
   If there is more than one smallest or largest city, choose the one that comes first when ordered alphabetically.
   Station :id,city,state,lat_n,long_w 
*/
select city, length(city)
from station
order by length(city), city asc
limit 1;
select city, length(city)
from station
order by length(city) desc
limit 1;							
							
/* You are given two tables: Students and Grades. 
   Students : ID, Name and Marks. 
   Grade : grade, min_mark, max_mark
   Ketty gives Eve a task to generate a report containing three columns: Name, Grade and Mark. 
   Ketty doesn't want the NAMES of those students who received a grade lower than 8. The report must be in descending order by grade -- 
   i.e. higher grades are entered first. If there is more than one student with the same grade (8-10) assigned to them, order those particular students by their name alphabetically.
   Finally, if the grade is lower than 8, use "NULL" as their name and list them by their grades in descending order. If there is more than one student with the same grade (1-7) assigned to them, 
   order those particular students by their marks in ascending order.
   Write a query to help Eve.							
*/							
select 
  if(grade > 7, name, null), 
  grade, 
  marks 
from students, grades 
where marks between min_mark and max_mark 
order by grade desc, name
							
/* Julia just finished conducting a coding contest, and she needs your help assembling the leaderboard! Write a query to print the respective hacker_id and name of hackers 
   who achieved full scores for more than one challenge. Order your output in descending order by the total number of challenges in which the hacker earned a full score. 
   If more than one hacker received full scores in same number of challenges, then sort them by ascending hacker_id.
   Hackers: hacker_id, name
   Difficulty: difficult_level, score
   Challenges: challenge_id, hacker_id, difficulty_level
   Submissions: submission_id, hacker_id, challenge_id, score						
*/
select 
  h.name,
  h.hacker_id
from hackers h
join (Submissions s, Challenges c, difficulty d)
  on (s.hacker_id = h.hacker_id
  and c.difficulty_level = d.difficulty_level
  and c.challenge_id = s.challenge_id)
where s.score = d.score
group by 1,2
having count(*) > 1
order by count(*) desc, h.hacker_id 							
							
/* Harry Potter and his friends are at Ollivander's with Ron, finally replacing Charlie's old broken wand.
   Hermione decides the best way to choose is by determining the minimum number of gold galleons needed to buy each non-evil wand of high power and age.
   Write a query to print the id, age, coins_needed, and power of the wands that Ron's interested in, sorted in order of descending power. If more than one wand has same power, sort the result in order of descending age.
   wands:id,code,coins_needed,power
   wands_property:code,is_evil,age
*/
select n.id, n.age,n.coins_needed,n.power
from
   (select 
      w.id, 
      wp.age, 
      w.coins_needed,
      w.power,
      row_number() over(partition by wp.age,w.power order by w.coins_needed ) rn
    from wands w
    join wands_property wp
      on w.code = wp.code
    where wp.is_evil = 0) n
where n.rn =1
order by n.power desc,n.age desc;

/* Julia asked her students to create some coding challenges. Write a query to print the hacker_id, name, 
   and the total number of challenges created by each student. Sort your results by the total number of challenges in descending order. 
   If more than one student created the same number of challenges, then sort the result by hacker_id. If more than one student created the 
   same number of challenges and the count is less than the maximum number of challenges created, then exclude those students from the result.
   Hackers: hacker_id,name
   Challengers: challenge_id,hacker_id
*/
  Select 
    h.hacker_id,
    h.name,
    count(c.challenge_id) as ch
  From hackers h
  Join challenges c
    On c.hacker_id = h.hacker_id
  Group by h.hacker_id,h.name
  having count(c.challenge_id) = (select max(m.c)
               from (select count(challenge_id) as c
                     from challenges
                     group by hacker_id) m)
       or count(c.challenge_id) in 
	       (select t.c
                from (select count(*) as c 
                      from challenges
                      group by hacker_id) t
                group by t.c
                having count(t.c) = 1)
  Order by count(c.challenge_id) desc, h.hacker_id;
