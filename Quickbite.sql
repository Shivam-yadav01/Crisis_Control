create database Quickbite;
show tables from quickbite;
use Quickbite;
select * from dim_customer;
select * from fact_order_items;
select * from fact_orders;
-- Orderpattern pre-crisis, after crisis, recovery phase question 1 Monthly Orders: Compare total orders across pre-crisis (Jan–May 2025) vs crisis
-- (Jun–Sep 2025). How severe is the decline?
select 
case 
when order_timestamp between '2025-01-01 12:00:00' and '2025-06-01 12:00:00' then 'pre_crisis (Jan-May)'
when order_timestamp between '2025-06-01 12:00:00' and '2025-10-01 12:00:00' then 'crisis (Jun-sept)'
else
'recovery'
end as order_pattern, count(*) as total_orders
from fact_orders
group by order_pattern 
order by order_pattern;
-- for experiment
select 
case 
when order_timestamp between '2025-01-01 12:00:00' and '2025-06-01 12:00:00' then 'pre_crisis (Jan-May)'
when order_timestamp between '2025-06-01 12:00:00' and '2025-10-01 12:00:00' then 'crisis (Jun-sept)'
else
'recovery'
end as order_pattern, count(*) as total_orders
from fact_orders
group by order_pattern 
order by order_pattern;
--
select * from dim_delivery_partner_;
--  Question2: Which top 5 city groups experienced the highest percentage decline in orders
-- during the crisis period compared to the pre-crisis period?
select city, count(order_id)as Number_of_orders,
case 
when order_timestamp between '2025-01-01 12:00:00' and '2025-06-01 12:00:00' then 'pre_crisis (Jan-May)'
when order_timestamp between '2025-06-01 12:00:00' and '2025-10-01 12:00:00' then 'crisis (Jun-sept)'
else
'recovery'
end as order_pattern
from(
select p.order_id, p.restaurant_id, l.city,p.order_timestamp
from fact_orders p
inner join dim_restaurant l on p.restaurant_id = l.restaurant_id)as oder_per_city
group by city , order_pattern order by Number_of_orders desc ;


-- End of question 2
-- Question-3 Among restaurants with at least 50 pre-crisis orders, which top 10 high-volume
-- restaurants experienced the largest percentage decline in order counts during
-- the crisis period?

with order_volume as (
select 
a.restaurant_name,
a.city,
a.restaurant_id,
-- b.order_id,
-- b.order_timestamp,
count(
case 
when b.order_timestamp between '2025-01-01 12:00:00' and '2025-06-01 12:00:00' then 1
else NULL
end)as 
pre_crisis_period,
count(
case
when b.order_timestamp between '2025-06-01 12:00:00' and '2025-10-01 12:00:00' then 1
else NULL
end) as 
crisis_period
from dim_restaurant a
inner join fact_orders b on a.restaurant_id = b.restaurant_id
where b.order_timestamp between '2025-01-01 12:00:00' and '2025-10-01 12:00:00' and b.is_cancelled = 'N'
group by a.restaurant_name,
a.city,
a.restaurant_id
),
top_restaurant as (
select 
order_volume.restaurant_name,
order_volume.pre_crisis_period,
order_volume.crisis_period,
rank() over(order by pre_crisis_period desc)as top_rankers from order_volume),
percentage_drops as(
select
top_restaurant.restaurant_name,
top_restaurant.pre_crisis_period,
top_restaurant.crisis_period,
round(((top_restaurant.pre_crisis_period - top_restaurant.crisis_period)*100)/ nullif(top_restaurant.pre_crisis_period,0),2) as percentage_drop from top_restaurant
where top_restaurant.top_rankers <= 50
)
select
percentage_drops.restaurant_name,
percentage_drops.pre_crisis_period,
percentage_drops.crisis_period,
percentage_drops.percentage_drop
from 
percentage_drops
where 
percentage_drops.percentage_drop>0
order by
percentage_drops.percentage_drop desc limit 10;
-- end of question 3
-- Question 4 Cancellation Analysis: What is the cancellation rate trend pre-crisis vs crisis,
-- and which cities are most affected?
with cancellation as(

select
-- fo.order_id,
-- fo.restaurant_id,
-- fo.is_cancelled,
dr.city,
count(
case 
when fo.order_timestamp between '2025-01-01 12:00:00' and '2025-06-01 12:00:00' then 1
-- else NULL
end) as total_pre_crisis_period_order,
count(
case
when fo.order_timestamp between '2025-01-01 12:00:00' and '2025-06-01 12:00:00' and fo.is_cancelled = 'Y' then 1
-- else NULL
end
)as cancelled_pre_crisis_period_order,
 
count(
case
when fo.order_timestamp between '2025-06-01 12:00:00' and '2025-10-01 12:00:00' then 1
-- else NULL
end) as crisis_period,
count(
case
when fo.order_timestamp between '2025-06-01 12:00:00' and '2025-10-01 12:00:00' and fo.is_cancelled = 'Y' then 1
-- else NULL
end) as cancelled_crisis_period_order

from fact_orders fo
inner join dim_restaurant dr on fo.restaurant_id = dr.restaurant_id
group by dr.city
)
select
city,
Round((cancellation.cancelled_pre_crisis_period_order*100)/ NULLIF(cancellation.total_pre_crisis_period_order, 0),2) as pre_crisis_trend,
Round((cancellation.cancelled_crisis_period_order*100)/NULLIF(cancellation.crisis_period,0),2) as crisis_trend,
Round((cancellation.cancelled_crisis_period_order*100)/NULLIF(cancellation.crisis_period,0)-(cancellation.cancelled_pre_crisis_period_order*100)/ NULLIF(cancellation.total_pre_crisis_period_order, 0),0)as trend
from cancellation
order by trend desc;
-- end of question 4
-- Question 5
-- Delivery SLA: Measure average delivery time across phases. Did SLA
-- compliance worsen significantly in the crisis period? select
-- select * from fact_delivery_performance;
-- with delivery_time_period as(
-- use Quickbite;
 select
 fo.order_id,
 fdp.actual_delivery_time_mins,
 fdp.expected_delivery_time_mins,
 fo.order_timestamp,
  CASE
                WHEN fo.order_timestamp >= '2025-01-01'
                AND fo.order_timestamp <= '2025-05-31' THEN 'Pre-Crisis'
                WHEN fo.order_timestamp >= '2025-06-01'
                AND fo.order_timestamp <= '2025-10-01' THEN 'Crisis'
                ELSE NULL
            END AS period,
            CASE
                WHEN fdp.actual_delivery_time_mins <= fdp.expected_delivery_time_mins THEN 1
                ELSE 0
            END AS sla_met
from fact_delivery_performance fdp
 inner join fact_orders fo on fdp.order_id = fo.order_id
         WHERE
            fo.order_timestamp >= '2025-01-01'
            AND fo.order_timestamp <= '2025-10-01'
            AND fo.is_cancelled = 'N';
-- ),
avg_delivery as(
select
round(avg(delivery_time_period.actual_delivery_time_mins),2)as avg_delivery_time,
sum(delivery_time_period.sla_met) as on_time_delivery,
avg(delivery_time_period.sla_met)*100 as sla_complaince_rate
from delivery_time_period 
 where period is not null
group by period)

select
period,
  avg_delivery.avg_delivery_time,
  avg_delivery.on_time_delivery,
  avg_delivery.sla_complaince_rate,
  avg_delivery.avg_delivery_time
  from
  avg_delivery
 order by
 period desc;
  
WITH delivery_time_period AS (
    SELECT
        fdp.actual_delivery_time_mins,
        fdp.expected_delivery_time_mins,
        -- Creating the 'period' column here
        CASE
            WHEN fo.order_timestamp BETWEEN '2025-01-01 00:00:00' AND '2025-05-31 23:59:59' THEN 'Pre-Crisis'
            WHEN fo.order_timestamp BETWEEN '2025-06-01 00:00:00' AND '2025-10-01 23:59:59' THEN 'Crisis'
            ELSE NULL
        END AS period,
        -- Creating the 'sla_met' column here
        CASE
            WHEN fdp.actual_delivery_time_mins <= fdp.expected_delivery_time_mins THEN 1
            ELSE 0
        END AS sla_met
    FROM fact_delivery_performance fdp
    INNER JOIN fact_orders fo ON fdp.order_id = fo.order_id
    WHERE fo.is_cancelled = 'N'
),
avg_delivery AS (
    SELECT
        period, -- <--- THIS IS THE FIX. We must select the column we group by.
        ROUND(AVG(actual_delivery_time_mins), 2) AS avg_delivery_time,
        SUM(sla_met) AS total_on_time_orders,
        ROUND(AVG(sla_met) * 100, 2) AS sla_compliance_pct
    FROM delivery_time_period 
    WHERE period IS NOT NULL
    GROUP BY period
)
-- Final Select pulls directly from the summarized table
SELECT 
    period, 
    avg_delivery_time, 
    total_on_time_orders, 
    sla_compliance_pct 
FROM avg_delivery;
-- end of question 5
-- Ratings Fluctuation: Track average customer rating month-by-month. Which
-- months saw the sharpest drop?
use Quickbite;
select * from fact_ratings;

 with clean_data as(
SELECT 
order_id,
rating,
    STR_TO_DATE(review_timestamp, '%d-%m-%Y') AS review_date
FROM fact_ratings
 ),
  months as(
 select
 month(clean_data.review_date) as monthly,
 monthname(clean_data.review_date)as months_,
 round(avg(clean_data.rating),2) as avg_rating,
 COUNT(order_id) AS total_reviews 
 from clean_data
 WHERE review_date IS NOT NULL
 group by months_,monthly
 )
 select * from months;
-- solution 2 for question 6
 WITH clean_data AS (
    SELECT 
        order_id,
        rating,
        -- Converts your text date into a real SQL date
        STR_TO_DATE(review_timestamp, '%d-%m-%Y') AS review_date
    FROM fact_ratings
),
monthly_avg AS (
    SELECT
        MONTH(review_date) AS month_num,
        MONTHNAME(review_date) AS month_name,
        ROUND(AVG(rating), 2) AS avg_rating,
        COUNT(order_id) AS total_reviews -- Added this so you can see volume
    FROM clean_data
    WHERE review_date IS NOT NULL
    GROUP BY month_num, month_name
)
SELECT 
    month_num,
    month_name,
    avg_rating,
    total_reviews
FROM monthly_avg
ORDER BY month_num; -- This is the magic line that makes it a "Trend"
--
-- 7. Sentiment Insights: During the crisis period, identify the most frequently
-- occurring negative keywords in customer review texts.
select * from fact_ratings;
with during_crisis as(
select review_text from fact_ratings where review_timestamp between '01-06-2025 15:00' and '01-09-2025 12:00')
select 'late/delayed' as keyword, count(*) as frequency from during_crisis where review_text regexp 'late|slow|delayed'
union all
SELECT 'Soggy' AS keyword, COUNT(*) AS frequency 
FROM during_crisis WHERE review_text like '%soggy%'
union all
SELECT 'stale' AS keyword, COUNT(*) AS frequency 
FROM during_crisis WHERE review_text like '%stale%'
union all
SELECT 'bad quality' AS keyword, COUNT(*) AS frequency 
FROM during_crisis WHERE review_text like '%horrible%'
union all
SELECT 'poor experience' AS keyword, COUNT(*) AS frequency 
FROM during_crisis WHERE review_text like '%poor%'
union all
SELECT 'Bad Taste' AS keyword, COUNT(*) AS frequency 
FROM during_crisis WHERE review_text like '%bad taste%'
union all
SELECT 'Bad behaviour' AS keyword, COUNT(*) AS frequency 
FROM during_crisis WHERE review_text like '%rude%'
union all
SELECT 'hotter' AS keyword, COUNT(*) AS frequency 
FROM during_crisis WHERE review_text like '%hotter%'

order by frequency desc;
-- end of question 7
-- Question 8: Revenue Impact: Estimate revenue loss from pre-crisis vs crisis (based on
-- subtotal, discount, and delivery fee)
select * from fact_orders;
select
    CASE
            WHEN order_timestamp BETWEEN '2025-01-01 00:00:00' AND '2025-05-31 23:59:59' THEN 'Pre-Crisis'
            WHEN order_timestamp BETWEEN '2025-06-01 00:00:00' AND '2025-10-01 23:59:59' THEN 'Crisis'
            ELSE NULL
        END AS periods,

order by periods ;
SELECT 
    -- 1. Create the Period Labels
    CASE 
        WHEN order_timestamp BETWEEN '2025-01-01' AND '2025-05-31' THEN 'Pre-Crisis'
        WHEN order_timestamp BETWEEN '2025-06-01' AND '2025-10-30' THEN 'Crisis'
    END AS period,
    
    -- 2. Count Orders and Revenue
    COUNT(order_id) AS total_orders,
    ROUND(SUM(total_amount), 2) AS gross_revenue,
    
    -- 3. Average Monthly Revenue (5 months for Pre-Crisis, 4 for Crisis)
    CASE 
        WHEN order_timestamp <= '2025-05-31' THEN ROUND(SUM(total_amount) / 5, 2)
        ELSE ROUND(SUM(total_amount) / 4, 2)
    END AS avg_monthly_rev

FROM fact_orders
WHERE is_cancelled = 'N' 
GROUP BY period;
-- question 8
SELECT 
    -- 1. Create the Period Labels
    CASE 
        WHEN order_timestamp BETWEEN '2025-01-01' AND '2025-05-31' THEN 'Pre-Crisis'
        WHEN order_timestamp BETWEEN '2025-06-01' AND '2025-10-30' THEN 'Crisis'
    END AS period,
    
    -- 2. Count Orders and Revenue
    COUNT(order_id) AS total_orders,
    ROUND(SUM(total_amount), 2) AS gross_revenue,
    
    -- 3. Average Monthly Revenue (Fixed by adding MAX() so SQL can group it)
    CASE 
        WHEN MAX(order_timestamp) <= '2025-05-31' THEN ROUND(SUM(total_amount) / 5, 2)
        ELSE ROUND(SUM(total_amount) / 4, 2)
    END AS avg_monthly_rev

FROM fact_orders
WHERE is_cancelled = 'N' 
GROUP BY 
    CASE 
        WHEN order_timestamp BETWEEN '2025-01-01' AND '2025-05-31' THEN 'Pre-Crisis'
        WHEN order_timestamp BETWEEN '2025-06-01' AND '2025-10-30' THEN 'Crisis'
    END;
-- question 9
-- 9. Loyalty Impact: Among customers who placed five or more orders before the
-- crisis, determine how many stopped ordering during the crisis, and out of those,
-- how many had an average rating above 4.5?
with order_placed as(
select 
-- CASE 
       
       -- WHEN order_timestamp BETWEEN '2025-06-01' AND '2025-10-30' THEN 'Crisis'
   -- END AS period,
    customer_id,
    count(*)as total_orders from fact_orders where order_timestamp BETWEEN '2025-01-01' AND '2025-05-31' group by customer_id having count(*)>=5),
    No_of_customers as (
    select
    count(*)as no_of_customer from order_placed
    ),
    avg_rating as(
    select customer_id,
    avg(rating)as ratings from fact_ratings group by customer_id
    ),
    crisis_orders AS (
    -- Step 2: Find all unique customers who ordered during the Crisis
    SELECT DISTINCT customer_id 
    FROM fact_orders 
    WHERE order_timestamp BETWEEN '2025-06-01' AND '2025-10-30'),
    
    stopped_ordering as(
    select
    order_placed.customer_id ,avg_rating.ratings from order_placed 
    left join crisis_orders on order_placed.customer_id = crisis_orders.customer_id 
    left join avg_rating on order_placed.customer_id= avg_rating.customer_id
    where crisis_orders.customer_id is null 
    )
  
 SELECT 
    COUNT(*) AS total_loyalists_stopped,
    COUNT(CASE WHEN ratings > 4.5 THEN 1 END) AS high_rating_loyalists_lost
FROM stopped_ordering;
   
    
    -- end of question 9
    -- question 10 Customer Lifetime Decline: Which high-value customers (top 5% by total
-- spend before the crisis) showed the largest drop in order frequency and ratings
-- during the crisis? What common patterns (e.g., location, cuisine preference,
-- delivery delays) do they share?
with customer_spending as (
select 
customer_id,
sum(total_amount) as total_spend
from fact_orders
where
 order_timestamp  BETWEEN '2025-01-01' AND '2025-05-31' and is_cancelled = 'N' group by customer_id
),
top_customers AS (

    SELECT customer_id, SUM(total_amount) AS total_spend
    FROM fact_orders
    GROUP BY customer_id
    ORDER BY total_spend DESC
    LIMIT 5259 

),
drop_frequency as(
select 
top_customers.customer_id,
round(AVG(fact_ratings.rating),2) as avg_rating,
COUNT(distinct CASE WHEN fact_orders.order_timestamp BETWEEN '2025-06-01' AND '2025-10-30' THEN fact_orders.order_id END) AS crisis_orders
from top_customers
join fact_orders on top_customers.customer_id = fact_orders.customer_id
join fact_ratings on top_customers.customer_id = fact_ratings.customer_id

group by top_customers.customer_id

),
-- question 10 rh rha hai half done, i don't what's the issue


-- 





    
   