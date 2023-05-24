/* --------------------------------------
   Code for creating the table schema 
   --------------------------------------*/


CREATE TABLE sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INTEGER
);

INSERT INTO sales VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 
CREATE TABLE menu (
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
);

INSERT INTO menu VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');

CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO members VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');  

/* --------------------
   Problem Statements 
   --------------------*/
/* --
1. What is the total amount each customer spent at the restaurant?
2. How many days has each customer visited the restaurant?
3. What was the first item from the menu purchased by each customer?
4. What is the most purchased item on the menu and how many times was it purchased by all customers?
5. Which item was the most popular for each customer?
6. Which item was purchased first by the customer after they became a member?
7. Which item was purchased just before the customer became a member?
8. What is the total items and amount spent for each member before they became a member?
9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - 
   how many points would each customer have?
10.In the first week after a customer joins the program (including their join date) 
   they earn 2x points on all items, not just sushi -
   how many points do customer A and B have at the end of January?
--*/








-- 1.What is the total amount each customer spent at the restaurant?


select distinct customer_id , sum(price) over (partition by customer_id) 
from (select s.customer_id , m.price from sales s inner join menu m on
s.product_id = m.product_id);

select '------------------------------------------------------' as '';



-- 2.How many days has each customer visited the restaurant?


select customer_id, count(distinct order_date) as visit_count
from sales
group by customer_id;

select '------------------------------------------------------' as '';


-- 3.What was the first item from the menu purchased by each customer?


select customer_id , product_name from
(select customer_id , product_name , row_number() 
over(partition by customer_id order by order_date) as row_num 
from (select s.customer_id, s.order_date, m.product_name from sales s inner join menu m on 
s.product_id = m.product_id)) where row_num = 1;

select '------------------------------------------------------' as '';


-- 4.What is the most purchased item on the menu and how many times was it purchased by all customers?


select count(s.product_id) as most_purch , m.product_name from sales s inner join menu m on
s.product_id = m.product_id group by s.product_id,m.product_name order by most_purch desc limit 1;

select 'MOST PURCHASED ITEM COUNT PER CUSTOMER' as '';
select '--------------------------------------' as '';

select distinct customer_id , count(product_name) over(partition by customer_id) from
(select s.customer_id ,m.product_name from sales s inner join menu m on
s.product_id = m.product_id where product_name is 'ramen');

select '------------------------------------------------------' as '';


-- 5.Which item was the most popular for each customer?


with item_cte as
(
select * , dense_rank() over(partition by customer_id order by order_count desc) as temp_rnk from 
(select s.customer_id , m.product_name ,count(product_name) as order_count from
sales s inner join menu m on s.product_id = m.product_id group by customer_id,product_name)
)

select customer_id, product_name, order_count from item_cte where temp_rnk =1;
select '------------------------------------------------------' as '';



-- 6.Which item was purchased first by the customer after they became a member?



with join_cte as (
select s.customer_id, s.order_date, m.join_date, s.product_id,
dense_rank() over(partition by s.customer_id order by s.order_date) as initial
from sales s inner join members m
on s.customer_id = m.customer_id where order_date>=join_date
)
select j.customer_id, m.product_name from join_cte j inner join menu m on 
j.product_id = m.product_id where initial =1 order by customer_id;

select '------------------------------------------------------' as '';


-- 7. Which item was purchased just before the customer became a member?


with before_cte as (
select s.customer_id, s.order_date , m.join_date , s.product_id,
dense_rank() over(partition by s.customer_id order by s.order_date desc) as before_init
from sales s inner join members m
on s.customer_id = m.customer_id where order_date<join_date
)
select b.customer_id, m.product_name from before_cte b inner join menu m on
b.product_id = m.product_id where before_init = 1 order by customer_id;

select '------------------------------------------------------' as '';



-- 8.What is the total items and amount spent for each member before they became a member?


with bef_spent_cte as (
select s.customer_id, s.order_date , m.join_date , s.product_id
from sales s inner join members m
on s.customer_id = m.customer_id where order_date<join_date
)
select b.customer_id, sum(m.price) from bef_spent_cte b inner join menu m on
b.product_id = m.product_id group by customer_id;

select '------------------------------------------------------' as '';



-- 9.If each $1 spent equates to 10 points and sushi has a 2x points multiplier
-- how many points would each customer have?



with point_cte as (
select * ,
case 
when product_id=1 then price * 20
else price * 10
end as points from menu
)

select s.customer_id, sum(p.points) from point_cte p inner join sales s on
s.product_id = p.product_id group by customer_id;

select '------------------------------------------------------' as '';



-- 10.In the first week after a customer joins the program 
-- (including their join date) they earn 2x points on all items, not just sushi - 
-- how many points do customer A and B have at the end of January?



with offer_cte as (
select s.customer_id, s.order_date, m.join_date,
date(m.join_date, '+6 day') as offer_val_date,
s.product_id, t.price,
case when s.product_id = 1 then t.price * 20
when s.order_date between m.join_date and date(m.join_date, '+6 day') then t.price*20
else t.price*10
end as points
from sales s inner join members m using(customer_id)
inner join menu t using(product_id) where s.order_date<='2021-01-31'
)

select customer_id, sum(points) from offer_cte group by customer_id;


