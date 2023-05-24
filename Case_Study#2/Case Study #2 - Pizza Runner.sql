/* --------------------------------------
   Code for creating the table schema 
   --------------------------------------*/

DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  "runner_id" INTEGER,
  "registration_date" DATE
);
INSERT INTO runners
  ("runner_id", "registration_date")
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');


DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  "order_id" INTEGER,
  "customer_id" INTEGER,
  "pizza_id" INTEGER,
  "exclusions" VARCHAR(4),
  "extras" VARCHAR(4),
  "order_time" TIMESTAMP
);

INSERT INTO customer_orders
  ("order_id", "customer_id", "pizza_id", "exclusions", "extras", "order_time")
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');


DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  "order_id" INTEGER,
  "runner_id" INTEGER,
  "pickup_time" VARCHAR(19),
  "distance" VARCHAR(7),
  "duration" VARCHAR(10),
  "cancellation" VARCHAR(23)
);

INSERT INTO runner_orders
  ("order_id", "runner_id", "pickup_time", "distance", "duration", "cancellation")
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');


DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  "pizza_id" INTEGER,
  "pizza_name" TEXT
);
INSERT INTO pizza_names
  ("pizza_id", "pizza_name")
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  "pizza_id" INTEGER,
  "toppings" TEXT
);
INSERT INTO pizza_recipes
  ("pizza_id", "toppings")
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  "topping_id" INTEGER,
  "topping_name" TEXT
);
INSERT INTO pizza_toppings
  ("topping_id", "topping_name")
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');
  


/* --------------------------------------
            Handeling Data 
   --------------------------------------*/



-- handeling missing values in customer_orders(exclusions and extras)

CREATE TABLE customer_orders_clean as select * from customer_orders;

update customer_orders_clean
set exclusions = 
(
case when exclusions = '' or exclusions like '%null%'
then NULL
else exclusions end
),
extras = 
(
case when extras = '' or extras like '%null%' or extras is NULL
then NULL
else extras end
);

select * from customer_orders_clean;



-- handeling data in runner_orders
select '-----------------------------------------' as '';

CREATE TABLE runner_orders_upd as select * from runner_orders;

update runner_orders_upd
set pickup_time =
(case when pickup_time like '%null%'
then NULL
else pickup_time end
),
distance = 
(case when distance like '%null%'
then NULL
when distance like '%km'
then trim(distance, 'km')
else distance end
),
duration = 
(case when duration like '%null'
then NULL
when duration like '%minutes%'
then trim(duration, 'minutes')
when duration like '%minute%'
then trim(duration, 'minute')
when duration like '%mins%'
then trim(duration, 'mins')
else duration end
),
Cancellation = 
(case when cancellation = '' or cancellation like '%null%' or cancellation is NULL
then NULL
else cancellation end
);

CREATE TABLE runner_orders_clean (
  "order_id" INTEGER,
  "runner_id" INTEGER,
  "pickup_time" TIMESTAMP,
  "distance" REAL,
  "duration" VARCHAR(7),
  "cancellation" VARCHAR(23));
  
INSERT INTO runner_orders_clean
SELECT *
FROM runner_orders_upd;

DROP TABLE runner_orders_upd;






/* --------------------------------------
            A. Pizza Metrics 
   --------------------------------------*/



-- How many pizzas were ordered?
select count(*) as total_pizza_orders from customer_orders_clean;

-- How many unique customer orders were made?
select '-----------------------------------------' as '';
select count(distinct customer_id) from customer_orders_clean;

-- How many successful orders were delivered by each runner?
select '-----------------------------------------' as '';
select runner_id,count(*) from runner_orders_clean where cancellation is NULL
group by runner_id;

-- How many of each type of pizza was delivered?
select '-----------------------------------------' as '';
select pizza_id , count(*) from customer_orders_clean join runner_orders_clean using(order_id)
where cancellation is NULL
group by pizza_id;

-- How many Vegetarian and Meatlovers were ordered by each customer?
select '-----------------------------------------' as '';
select customer_id , pizza_name , count(*) from customer_orders_clean join
pizza_names using(pizza_id) group by customer_id, pizza_name;

-- What was the maximum number of pizzas delivered in a single order?
select '-----------------------------------------' as '';

with orders_insingle as (
select c.order_id, count(*) as num_ord from customer_orders_clean c join runner_orders_clean r
using(order_id) where cancellation is NULL 
group by c.order_id
)
select max(num_ord) from orders_insingle;

-- For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
select '-----------------------------------------' as '';

with changes as (
select c.customer_id , c.exclusions , c.extras from customer_orders_clean c join 
runner_orders_clean r using(order_id) where r.cancellation is NULL
)

select customer_id , 
sum(
case when exclusions is not NULL or extras is not NULL
then 1 else 0 end) as pizza_changes,
sum(
case when exclusions is NULL and extras is NULL
then 1 else 0 end) as no_pizza_changes
from changes group by customer_id;

-- How many pizzas were delivered that had both exclusions and extras?
select '-----------------------------------------' as '';
select count(*) from customer_orders_clean c join runner_orders_clean r using(order_id)
where r.cancellation is NULL and c.exclusions is not NULL and c.extras is not NULL;

-- What was the total volume of pizzas ordered for each hour of the day?
select '-----------------------------------------' as '';
select strftime('%H', order_time) as hour24_frmt,
count(*) from customer_orders_clean
group by strftime('%H', order_time);

-- What was the volume of orders for each day of the week?
select '-----------------------------------------' as '';

with volume_d as (
select case cast(strftime('%w', order_time) as INTEGER)
when 0 then 'sunday'
when 1 then 'monday'
when 2 then 'tuesday'
when 3 then 'wednesday'
when 4 then 'thursday'
when 5 then 'friday'
when 6 then 'saturday'
end as day_of_week,
pizza_id from customer_orders_clean
)

select day_of_week, count(pizza_id) from volume_d
group by day_of_week;



/* --------------------------------------
      B. Runner and Customer Experience
   --------------------------------------*/



-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

SELECT COUNT(runner_id) as num_runner, strftime('%W',registration_date) AS registration_week
FROM runners
GROUP BY strftime('%W', registration_date);


-- 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

SELECT  r.runner_id, ROUND(AVG(((JULIANDAY(r.pickup_time) - JULIANDAY(c.order_time)) * 86400)/ 60),1) AS avg_time_min
FROM runner_orders_clean r
JOIN customer_orders_clean c USING(order_id)
WHERE pickup_time NOT NULL
GROUP BY runner_id
ORDER BY avg_time_min;

-- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?

WITH pizza_prep AS (
    SELECT  c.order_id, COUNT(c.order_id) as num_pizza, 
    ROUND((((JULIANDAY(r.pickup_time)- JULIANDAY(c.order_time)) *86400) / 60),2)
    AS prep_duration_min
    FROM customer_orders_clean c
    JOIN runner_orders_clean r USING(order_id)
    WHERE r.cancellation is NULL 
    GROUP BY c.order_id )
    
SELECT  num_pizza, ROUND(AVG(prep_duration_min), 0) as avg_prep_min
FROM pizza_prep
GROUP BY num_pizza;


-- 4. What was the average distance travelled for each customer?

SELECT c.customer_id, ROUND(AVG(r.distance_km),1) as avg_distance
FROM customer_orders_clean c
JOIN runner_orders_clean r USING(order_id)
WHERE r.cancellation IS NULL
GROUP BY c.customer_id
ORDER BY c.customer_id;


-- 5. What was the difference between the longest and shortest delivery times for all orders?

SELECT MAX(duration_min) - MIN(duration_min) AS difference
FROM runner_orders_clean
WHERE cancellation IS NULL;

-- 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?

SELECT runner_id, order_id, 
ROUND(AVG(distance_km / (CAST(duration_min AS REAL)/ 60)),1) AS avg_speed_kmph, 
ROUND(AVG((distance_km / 1.609) / (CAST(duration_min AS REAL) / 60)),1)  AS avg_speed_mph
FROM runner_orders_clean
WHERE cancellation IS NULL
GROUP BY runner_id, order_id;

-- 7. What is the successful delivery percentage for each runner?

SELECT runner_id, 
SUM(CASE WHEN cancellation IS NULL THEN 1 ELSE 0 END) / CAST(COUNT(order_id) AS REAL) * 100 AS success_pct
FROM runner_orders_clean
GROUP BY runner_id;



/* --------------------------------------
        C. Ingredient Optimization
   --------------------------------------*/

-- Spliting toppings field in the pizza_recipes table
DROP TABLE IF EXISTS pizza_recipes_mod;

CREATE TEMP TABLE pizza_recipes_mod ('pizza_id' INTEGER, 'toppings' INTEGER );

INSERT INTO pizza_recipes_mod
VALUES 
(1,1),
(1,2),
(1,3),
(1,4),
(1,5),
(1,6),
(1,8),
(1,10),
(2,4),
(2,6),
(2,7),
(2,9),
(2,11),
(2,12);


-- 1. What are the standard ingredients for each pizza?

SELECT n.pizza_name, GROUP_CONCAT(t.topping_name) as toppings
FROM pizza_recipes_mod pr JOIN pizza_toppings t ON pr.toppings = t.topping_id
JOIN pizza_names n ON pr.pizza_id = n.pizza_id
GROUP BY pr.pizza_id;

-- 2. What was the most commonly added extra?

WITH extras AS (
SELECT order_id, pizza_id, CAST(extras AS INTEGER) AS extras
FROM customer_orders_clean
WHERE LENGTH(extras) = 1
AND extras NOT NULL

UNION ALL 

SELECT order_id, pizza_id, CAST(SUBSTR(extras, 0, INSTR(extras, ',')) AS INTEGER)  AS extras
FROM customer_orders_clean
WHERE extras NOT NULL
AND LENGTH(extras)>2

UNION ALL

SELECT order_id, pizza_id, CAST(SUBSTR(extras, 3)AS INTEGER) AS extras
FROM customer_orders_clean
WHERE LENGTH(extras)>2
), 

count_extras AS(

SELECT extras,COUNT(extras) as count
FROM extras
GROUP BY extras
ORDER BY count DESC
LIMIT 1
) 


SELECT topping_name FROM count_extras
JOIN pizza_toppings ON count_extras.extras = pizza_toppings.topping_id;


-- 3. What was the most common exclusion?

WITH exclusions AS (
SELECT order_id, pizza_id, CAST(exclusions AS INTEGER) AS exclusions
FROM customer_orders_clean
WHERE LENGTH(exclusions) = 1
AND exclusions NOT NULL

UNION ALL 

SELECT order_id, pizza_id, CAST(SUBSTR(exclusions, 0, INSTR(exclusions, ',')) AS INTEGER)  AS exclusions
FROM customer_orders_clean
WHERE exclusions NOT NULL
AND LENGTH(exclusions)>2

UNION ALL

SELECT order_id, pizza_id, CAST(SUBSTR(exclusions, 3)AS INTEGER) AS exclusions
FROM customer_orders_clean
WHERE LENGTH(exclusions)>2
), 

count_exclusions AS(

SELECT exclusions,COUNT(exclusions) as count
FROM exclusions
GROUP BY exclusions
ORDER BY count DESC
LIMIT 1
) 


SELECT topping_name FROM count_exclusions
JOIN pizza_toppings ON count_exclusions.exclusions = pizza_toppings.topping_id;

