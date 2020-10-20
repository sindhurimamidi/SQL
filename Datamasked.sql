/* 
For each user_id, find the difference between the last action and the second last action. Action here is defined as visiting a page. 
If the user has just one action, you can either remove her from the final results or keep that user_id and have NULL as time difference between the two actions.
The table below shows for each user all the pages she visited and the corresponding timestamp
Query_one : user_id, page, unix_timestamp
*/
SELECT user_id,  
       unix_timestamp - previous_time AS Delta_SecondLast0ne_LastOne  
FROM  
     (SELECT user_id,   
             unix_timestamp,  
             LAG(unix_timestamp, 1) OVER (PARTITION BY user_id ORDER BY unix_timestamp) AS previous_time,  
             ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY unix_timestamp DESC) AS order_desc  
       FROM query_one  
       ) tmp  
WHERE order_desc = 1  
ORDER BY user_id

/*
We have two tables. One table has all mobile actions, i.e. all pages visited by the users on mobile. The other table has all web actions, i.e. all pages visited on web by the users.
Write a query that returns the percentage of users who only visited mobile, only web and both. That is, the percentage of users who are only in the mobile table, only in the web table and in both tables. 
The sum of the percentages should return 1.
data_mobile : user_id, page
data_web : user_id, page
*/
SELECT 100*SUM(CASE WHEN m.user_id IS null THEN 1 ELSE 0 END)/COUNT(*) as WEB_ONLY,
       100*SUM(CASE WHEN w.user_id IS null THEN 1 ELSE 0 END)/COUNT(*) as MOBILE_ONLY,
       100*SUM(CASE WHEN m.user_id IS NOT null AND w.user_id IS NOT null THEN 1 ELSE 0 END)/COUNT(*) as BOTH
FROM
(SELECT distinct user_id FROM query_two_web ) w
FULL OUTER JOIN
(SELECT distinct user_id FROM query_two_mobile ) m
ON m.user_id = w.user_id;

/*
We define as power users those users who bought at least 10 products. Write a query that returns for each user on which day they became a power user. 
That is, for each user, on which day they bought the 10th item.
The table below represents transactions. That is, each row means that the corresponding user has bought something on that date.
Table : user_id, date
*/
SELECT 
   user_id,      
   date
FROM
    (SELECT *, 
     ROW_NUMBER() over(PARTITION BY user_id ORDER BY date) row_num 
     FROM query_three
     ) tmp
WHERE row_num = 10

/*
We have two tables. One table has all $ transactions from users during the month of March and one for the month of April.
Write a query that returns the total amount of money spent by each user. That is, the sum of the column transaction_amount for each user over both tables.
Write a query that returns day by day the cumulative sum of money spent by each user. 
That is, each day a user had a transcation, we should have how much money she has spent in total until that day. 
Obviously, the last day cumulative sum should match the numbers from the previous bullet point.
Table 1:user_id,march_date,transaction_amount
Table 2:user_id,april_date,transaction_amount
*/
SELECT user_id,
       SUM(transaction_amount) as total_amount
FROM
    (SELECT  * FROM query_four_march
     UNION ALL
     SELECT  * FROM query_four_april
    ) tmp
GROUP BY user_id
ORDER BY user_id;

SELECT user_id,
       date,
       SUM(amount) over(PARTITION BY user_id ORDER BY date) as total_amount
FROM
    (SELECT user_id, 
            date, 
            SUM(transaction_amount) as amount
     FROM query_four_march
     GROUP BY user_id, date
     UNION ALL
     SELECT user_id, 
            date, 
            SUM(transaction_amount) as amount
     FROM query_four_april
     GROUP BY user_id, date
    ) tmp
ORDER BY user_id, date;

/*
We have two tables. One is user id and their signup date. 
The other one shows all transactions done by those users, when the transaction happens and its corresponding dollar amount.
Find the average and median transaction amount only considering those transactions that happen on the same date as that user signed-up.
Table 1:user_id,sign_up_date
Table 2:user_id,transaction_date,transaction_amount
*/
SELECT AVG(transaction_amount) AS average,  
       AVG(CASE WHEN row_num_asc BETWEEN row_num_desc-1 and row_num_desc+1 THEN transaction_amount ELSE NULL END ) AS median  
FROM  
    (SELECT transaction_amount,  
             ROW_NUMBER() OVER(ORDER BY transaction_amount) row_num_asc,  
             COUNT(*) OVER() - ROW_NUMBER() OVER(ORDER BY transaction_amount) + 1 AS row_num_desc 
             -- need row number for median.
     FROM query_five_users a  
     JOIN (SELECT *, 
           to_date(transaction_date) AS date_only 
           FROM query_five_transactions
           ) b  
      ON a.user_id = b.user_id AND a.sign_up_date = b.date_only  
) tmp;

/*
We have a table with users, their country and when they created the account. We want to find:
The country with the largest and smallest number of users
A query that returns for each country the first and the last user who signed up (if that country has just one user, it should just return that single user)
Table :user_id, created_at, country
*/
SELECT country,  
       user_count  
FROM  
    (SELECT *,  
            ROW_NUMBER() OVER (ORDER BY user_count) count_asc,  
            ROW_NUMBER() OVER (ORDER BY user_count desc) count_desc  
     FROM (SELECT country, 
                  COUNT(distinct user_id) as user_count  
            FROM query_six  
            GROUP BY country  
           ) a  
     ) tmp  
WHERE count_asc = 1 or count_desc = 1;


SELECT user_id,  
       created_at,  
       country  
FROM  (SELECT *,  
              ROW_NUMBER() OVER (PARTITION BY country ORDER BY created_at) count_asc,  
              ROW_NUMBER() OVER (PARTITION BY country ORDER BY created_at desc) count_desc  
       FROM query_six  
       ) tmp  
WHERE count_asc = 1 or count_desc = 1 ;

/*
• An attendance log for every student in a school district with: 
attendance_events : date | student_id | attendance
• A summary table with demographics for each student in the district: 
all_students : student_id | school_id | grade_level | date_of_birth | hometown
1. What percent of students attend school on their birthday?
2. Which grade level had the largest drop in attendance between yesterday and today?
*/
select sum(case when a.date_of_birth = e.date then 1 else 0)/count(*)
from all_students a
join attendance_events e on a.student_id = e.student_id

SELECT date, grade, today, yesterday
FROM 
    (SELECT 
       a.date, 
       s.grade, 
       COUNT(a.attendance) today, 
       LAG(COUNT(a.attendance), 1) OVER (PARTITION BY grade ORDER BY date) yesterday
     FROM attendance a JOIN students s ON a.student_id = s.student_id     
     WHERE a.attendance = 'present' 
       AND a.date >= DATE_SUB(DATE(NOW()), INTERVAL 1 DAY) -- Yesterday will be NULL for previous date.     
     GROUP BY a.date, s.grade) last_2_days 
WHERE date = date(now()) -- To remove the yesterday's NULL date
ORDER BY yesterday - today -- Drop in attendance
LIMIT 1;

