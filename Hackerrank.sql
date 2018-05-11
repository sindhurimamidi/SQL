/*Advance Join Challenges*/

/* You are given a table, Projects, containing three columns: Task_ID, Start_Date and End_Date. 
It is guaranteed that the difference between the End_Date and the Start_Date is equal to 1 day for each row in the table.
If the End_Date of the tasks are consecutive, then they are part of the same project. 
Samantha is interested in finding the total number of different projects completed.
Write a query to output the start and end dates of projects listed by the number of days it took to complete the project in ascending order. 
If there is more than one project that have the same number of completion days, then order by the start date of the project. */

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
STUDENTS  : ID, name , marks. */

select name
from students
where marks > 75
order by SUBSTRING(name, -3) asc, ID asc;

/* Write a query identifying the type of each record in the TRIANGLES table using its three side lengths. Output one of the following statements for each record in the table: TRIANGLE: A,B,C
 * Not A Triangle: The given values of A, B, and C don't form a triangle.
 * Equilateral: It's a triangle with  sides of equal length.
 * Isosceles: It's a triangle with  sides of equal length.
 * Scalene: It's a triangle with  sides of differing lengths. 
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


