create database target;
use target;



select * from customers
limit 10;
truncate table customers;
drop table customers;


select * from order_items
limit 10;
truncate table order_items;
drop table order_items;


select * from order_reviews
limit 10;
truncate table order_reviews;
drop table order_reviews;


select * from products
limit 10;
truncate table products;
drop table products;


select * from orders
limit 10;
truncate table orders;
drop table orders;


select * from payments
limit 10;
truncate table payments;
drop table payments;


select * from sellers
limit 10;
truncate table sellers;
drop table sellers;



LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/sellers.csv"
INTO TABLE sellers
-- CHARACTER SET latin1 
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;





CREATE OR REPLACE VIEW v_order_payments AS
SELECT 
    o.order_id,
    o.customer_id,
    o.order_purchase_timestamp,
    o.order_status,
    SUM(p.payment_value) AS total_payment
FROM orders o
JOIN payments p ON o.order_id = p.order_id
GROUP BY o.order_id, o.customer_id, o.order_purchase_timestamp, o.order_status;


CREATE OR REPLACE VIEW v_customer_orders AS
SELECT 
    v.order_id,
    v.customer_id,
    c.customer_unique_id,
    c.customer_city,
    c.customer_state,
    v.order_purchase_timestamp,
    v.order_status,
    v.total_payment
FROM v_order_payments v
JOIN customers c ON v.customer_id = c.customer_id;



CREATE OR REPLACE VIEW v_city_revenue AS
SELECT 
    customer_city,
    customer_state,
    ROUND(SUM(total_payment), 2) AS total_revenue,
    ROUND(SUM(total_payment) / SUM(SUM(total_payment)) OVER() * 100, 2) AS revenue_percent
FROM v_customer_orders
GROUP BY customer_city, customer_state;


CREATE OR REPLACE VIEW v_customer_frequency AS
SELECT 
    customer_unique_id,
    customer_city,
    customer_state,
    COUNT(DISTINCT order_id) AS total_orders
FROM v_customer_orders
GROUP BY customer_unique_id, customer_city, customer_state;


CREATE OR REPLACE VIEW v_qoq_growth AS
SELECT 
    YEAR(order_purchase_timestamp) AS year,
    QUARTER(order_purchase_timestamp) AS quarter,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(total_payment), 2) AS total_revenue,
    ROUND(
        (COUNT(DISTINCT order_id) - LAG(COUNT(DISTINCT order_id)) OVER (ORDER BY YEAR(order_purchase_timestamp), QUARTER(order_purchase_timestamp)))
        / LAG(COUNT(DISTINCT order_id)) OVER (ORDER BY YEAR(order_purchase_timestamp), QUARTER(order_purchase_timestamp)) * 100, 2
    ) AS qoq_growth_orders,
    ROUND(
        (SUM(total_payment) - LAG(SUM(total_payment)) OVER (ORDER BY YEAR(order_purchase_timestamp), QUARTER(order_purchase_timestamp)))
        / LAG(SUM(total_payment)) OVER (ORDER BY YEAR(order_purchase_timestamp), QUARTER(order_purchase_timestamp)) * 100, 2
    ) AS qoq_growth_revenue
FROM v_order_payments
GROUP BY YEAR(order_purchase_timestamp), QUARTER(order_purchase_timestamp);


CREATE OR REPLACE VIEW v_customer_churn AS
WITH cust_quarters AS (
    SELECT 
        c.customer_unique_id,
        YEAR(order_purchase_timestamp) AS year,
        QUARTER(order_purchase_timestamp) AS quarter
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE o.order_status NOT IN ('canceled', 'unavailable', 'created')
    GROUP BY c.customer_unique_id, YEAR(order_purchase_timestamp), QUARTER(order_purchase_timestamp)
)
SELECT 
    c1.year,
    c1.quarter,
    COUNT(DISTINCT c1.customer_unique_id) AS total_customers,
    SUM(CASE WHEN c2.customer_unique_id IS NULL THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(SUM(CASE WHEN c2.customer_unique_id IS NULL THEN 1 ELSE 0 END) / COUNT(DISTINCT c1.customer_unique_id) * 100, 2) AS churn_rate_percent
FROM cust_quarters c1
LEFT JOIN cust_quarters c2 
    ON c1.customer_unique_id = c2.customer_unique_id
    AND ((c2.year = c1.year AND c2.quarter = c1.quarter + 1)
      OR (c2.year = c1.year + 1 AND c2.quarter = 1 AND c1.quarter = 4))
GROUP BY c1.year, c1.quarter
ORDER BY c1.year, c1.quarter;



-- Orders by Time of Day
SELECT 
    CASE 
        WHEN HOUR(order_purchase_timestamp) BETWEEN 0 AND 6 THEN 'Dawn'
        WHEN HOUR(order_purchase_timestamp) BETWEEN 7 AND 12 THEN 'Morning'
        WHEN HOUR(order_purchase_timestamp) BETWEEN 13 AND 18 THEN 'Afternoon'
        ELSE 'Night'
    END AS time_of_day,
    COUNT(*) AS total_orders
FROM v_customer_orders
GROUP BY time_of_day
ORDER BY total_orders DESC;


-- Quarter-over-Quarter Growth last 2 years.
set @max_year = (select max(year(order_purchase_timestamp)) from orders);
SELECT 
    year,
    quarter,
    total_orders,
    qoq_growth_orders AS '% QoQ Growth (Orders)',
    total_revenue AS revenue,
    qoq_growth_revenue AS '% QoQ Growth (Revenue)'
FROM v_qoq_growth
WHERE year >= @max_year - 1
ORDER BY year, quarter;


-- Top Revenue-Contributing Cities
SELECT 
    customer_city,
    customer_state,
    total_revenue,
    revenue_percent
FROM v_city_revenue
ORDER BY total_revenue DESC
LIMIT 10;



-- Top 10 Customers by Lifetime Spending
WITH customer_revenue AS (
    SELECT 
        customer_id,
        SUM(total_payment) AS total_revenue
    FROM v_order_payments
    GROUP BY customer_id
)
SELECT 
    customer_id,
    total_revenue,
    ROUND(total_revenue / SUM(total_revenue) OVER() * 100, 2) AS revenue_percent,
    ROUND(SUM(total_revenue) OVER (ORDER BY total_revenue DESC) / SUM(total_revenue) OVER() * 100, 2) AS cumulative_percent
FROM customer_revenue
ORDER BY total_revenue DESC
LIMIT 10;



-- Repeat vs One-Time Buyers
SELECT 
    CASE 
        WHEN total_orders = 1 THEN 'One-Time Buyer'
        ELSE 'Repeat Buyer'
    END AS customer_type,
    COUNT(*) AS num_customers
FROM v_customer_frequency
GROUP BY customer_type;



-- Average Time Gap Between Orders
WITH order_gaps AS (
    SELECT 
        customer_unique_id,
        order_purchase_timestamp,
        LAG(order_purchase_timestamp) OVER (
            PARTITION BY customer_unique_id 
            ORDER BY order_purchase_timestamp
        ) AS prev_order,
        DATEDIFF(
            order_purchase_timestamp, 
            LAG(order_purchase_timestamp) OVER (
                PARTITION BY customer_unique_id 
                ORDER BY order_purchase_timestamp
            )
        ) AS days_gap
    FROM v_customer_orders
),

avg_gap_per_customer AS (
    SELECT 
        customer_unique_id,
        AVG(days_gap) AS avg_days
    FROM order_gaps
    WHERE days_gap IS NOT NULL
    GROUP BY customer_unique_id
)

SELECT 
    CASE 
        WHEN avg_days < 30 THEN 'Less than 1 month'
        WHEN avg_days BETWEEN 30 AND 90 THEN '1–3 months'
        ELSE 'More than 3 months'
    END AS gap_category,
    COUNT(*) AS num_customers
FROM avg_gap_per_customer
GROUP BY gap_category
ORDER BY num_customers DESC;


-- City/State with Highest Order Frequency
SELECT 
    customer_city,
    customer_state,
    ROUND(AVG(total_orders), 2) AS avg_orders_per_customer
FROM v_customer_frequency
GROUP BY customer_city, customer_state
ORDER BY avg_orders_per_customer DESC
LIMIT 10;


-- Churn Trend
SELECT * FROM target.v_customer_churn;


-- Category with Widest Customer Reach
SELECT 
    p.`product category` AS product_category,
    COUNT(DISTINCT c.customer_unique_id) AS unique_customers
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
JOIN customers c ON o.customer_id = c.customer_id
  AND p.`product category` IS NOT NULL
GROUP BY p.`product category`
ORDER BY unique_customers DESC
LIMIT 10;



-- Fastest Growing Categories QoQ
WITH category_quarter AS (
    SELECT 
        p.`product category` AS category,
        YEAR(o.order_purchase_timestamp) AS year,
        QUARTER(o.order_purchase_timestamp) AS quarter,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
      AND p.`product category` IS NOT NULL
    GROUP BY p.`product category`, year, quarter
),
category_growth AS (
    SELECT 
        category,
        year,
        quarter,
        ROUND(
            (total_orders - LAG(total_orders) OVER (PARTITION BY category ORDER BY year, quarter)) /
            NULLIF(LAG(total_orders) OVER (PARTITION BY category ORDER BY year, quarter), 0) * 100, 2
        ) AS qoq_growth_pct
    FROM category_quarter
)

SELECT 
    category, 
    year, 
    quarter, 
    qoq_growth_pct
FROM category_growth
WHERE qoq_growth_pct IS NOT NULL and category <> ''
ORDER BY qoq_growth_pct DESC
LIMIT 10;


-- What is the average order value (AOV) per category?

with prod_cate_price as (
select o.order_id,ot.product_id,price,`product category` from orders o
left join order_items ot
on o.order_id = ot.order_id
left join products p
on p.product_id = ot.product_id
where price is not null and `product category` <> ''
)

select `product category`,count(distinct order_id),round(sum(price),2),
round((sum(price)/count(distinct order_id)),2) as 'avg_order_value'
from prod_cate_price
group by `product category`
order by avg_order_value desc;


-- How does delivery time vary by region or seller?


create or replace view customer_order_dates_city as 
select order_id,customer_unique_id,order_purchase_timestamp,order_delivered_customer_date,
order_estimated_delivery_date,customer_city,customer_state from orders o
inner join customers c
on o.customer_id = c.customer_id
where order_status not in ('canceled','unavailable','created','invoiced','shipped','processing');



create or replace view v_average_delivery_times as 
select customer_city,customer_state,
round(overall_average_delivery_date,2) as 'overall_average_delivery_date',
total_orders,
round(average_del_date_per_state,2) as 'average_del_date_per_state',
orders_per_state,
round(average_del_date_per_city,2) as 'average_del_date_per_city',
orders_per_city
from (
	select *,
	avg(del_date) over() as 'overall_average_delivery_date',
    count(del_date) over() as 'total_orders',
	avg(del_date) over(partition by customer_state) as 'average_del_date_per_state',
    count(del_date) over(partition by customer_state) as 'orders_per_state',
	avg(del_date) over(partition by customer_city) as 'average_del_date_per_city',
    count(del_date) over(partition by customer_city) as 'orders_per_city'
	from (
	select customer_city,customer_state,
	datediff(order_delivered_customer_date,order_purchase_timestamp) as 'del_date'
	from customer_order_dates_city
	) as t
) as t1
group by customer_city,
		 customer_state,
		 total_orders,
         overall_average_delivery_date,
         average_del_date_per_state,
         average_del_date_per_city,
         orders_per_city,
         orders_per_state;

select * from v_average_delivery_times;


-- Average delivery time nationwide
select avg(del_date) as 'avg_del_date_all orders'
from (
select
datediff(order_delivered_customer_date,order_purchase_timestamp) as 'del_date'
from customer_order_dates_city)
as t;


-- Top 5 fastest cities
select customer_city,overall_average_delivery_date,average_del_date_per_state,average_del_date_per_city from v_average_delivery_times
where orders_per_city > 50
order by average_del_date_per_city
limit 10;

-- Top 5 slowest cities/states
select customer_city,overall_average_delivery_date,average_del_date_per_state,average_del_date_per_city from v_average_delivery_times
where orders_per_city > 50
order by average_del_date_per_city desc
limit 10;



























































