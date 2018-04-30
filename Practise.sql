#MY SQL
create table salesperson
(
  id            int,
  name     varchar(255),
  age           int,
  salary        int,

 primary key(id)
);

insert into salesperson
  (id, name, age, salary)
values
  (1,'Abe',61,140000),
  (2,'Bob',34,44000),
  (5,'Chris',34,40000),
  (7,'Dan',41,52000),
  (8,'Ken',57,115000),
  (11,'Joe',38,38000);

create table customer
(
  id            int,
  name          varchar(255),
  city          varchar(255),
  industry_type varchar(255),

 primary key(id)
);

insert into customer
  (id,name,city,industry_type)
values
(4,'samsonic','pleasant','J'),
(6,'panasung','oaktown','J'),
(7,'samony','jackson','B'),
(9,'orange','jackson','B');

create table orders
(
  number        int ,
  order_date    varchar(255),
  cust_id       int,
  salesperson_id  int,
  amount         int

);

insert into orders
  (number,order_date,cust_id,salesperson_id,amount)
values
   (10,'8/2/96',4,2,540),
  (20,'1/30/99',4,8,1800),
  (30,'7/14/95',9,1,460),
  (40,'1/29/98',7,2,2400),
  (50,'2/3/98',6,7,600),
  (60,'3/2/98',6,7,720),
  (70,'5/6/98',9,7,150);

# Given the tables above, find the following: 
#  a. The names of all salespeople that have an order with Samsonic. 
select s.name
from salesperson s
join
(select 
	o.cust_id ,
	o.salesperson_id,
	c.name
from orders o
join customer c
on o.cust_id = c.id) n
on s.id = n.salesperson_id
where n.name = 'samsonic'
 
#b. The names of all salespeople that do not have any order with Samsonic.
select s.name
from salesperson s
join
(select 
	o.cust_id ,
	o.salesperson_id,
	c.name
from orders o
join customer c
on o.cust_id = c.id) n
on s.id = n.salesperson_id
where n.name != 'samsonic'
group by s.name 
 
#c. The names of salespeople that have 2 or more orders. 
select s.name
from salesperson s
join
(select salesperson_id,count(*) as c
from orders
group by salesperson_id) o
on o.salesperson_id=s.id
where o.c>2
 
#d. The names and ages of all salespersons must having a salary of 100,000 or greater. 
select name, age
from salesperson
where salary > 100000
 
#e. What sales people have sold more than 1400 total units?
select s.name
from salesperson s
join (select amount,salesperson_id
from orders
where amount > 1400) o
on s.id = o.salesperson_id  f. When was the earliest and latest order made to Samony?
select o.order_date 
from orders o
join 
(select name, id
from customer 
where name = 'samony') c
on c.id = o.cust_id

