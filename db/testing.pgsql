--  -- Bucketing into a cohort first step cohort items
-- WITH cohort_item as (
--   select
--     (date_trunc('week', users.created_at)::date) as cohort_week,
--     id as user_id
--   from users
--   ORDER BY 1, 2
-- ), 
-- -- building the user activities
-- first_orders AS (
-- SELECT
--     orders.user_id,
--       (date_trunc('week', min(orders.created_at))::date
--       - cohort_item.cohort_week)/7
--     as week_number
--   from orders 
--   left join cohort_item  ON orders.user_id = cohort_item.user_id
--   group by orders.user_id, cohort_item.cohort_week
-- ), cohort_size as 
--   (  SELECT 
--     cohort_week, count(1) as num_users
--     FROM cohort_item
--     group by 1
--     -- order by 1
--   ), retention_table as 
--   (select
--     cohort_item.cohort_week,
--     first_orders.week_number,
--     count(1) as num_users
--   from first_orders
--   left join cohort_item ON first_orders.user_id = cohort_item.user_id
--   group by 1, 2
--   ), final_values AS (
-- -- our final value: (cohort_month, size, month_number, percentage)
-- select
--   retention_table.cohort_week,
--   cohort_size.num_users as total_users,
--   retention_table.week_number,
--   retention_table.num_users::float * 100 / cohort_size.num_users as percentage
-- from retention_table 
-- left join cohort_size  ON retention_table.cohort_week = cohort_size.cohort_week
-- where retention_table.cohort_week IS NOT NULL
-- order by 1, 3
--   )
--   SELECT * FROM 
--   -- cohort_item
--   final_values

-- SELECT 
--     COUNT(orders.id) AS count orders,
--     (date_trunc('day', orders.created_at)::date) AS order_date

--     FROM orders
-- GROUP BY order_date
-- ORDER BY order_date
-- )
 


--  -- Answer a
-- select t1.device, CAST(t2.count as float) / CAST(t1.total as float) as Percentage,t1.total, t2.count from (select creations.creation_device as device, count(*) as total from creations
-- group by device) as t1
-- join 
-- (select creations.creation_device as device, count(*) as count from creations
-- join orders
-- on orders.creation_id = creations.id
-- where creations.created_at + interval '7' day > orders.created_at 
-- group by device) as t2
-- on t1.device = t2.device;

-- -- % 2599

-- -- select * from creations;

-- -- date 
-- -- number_of_creations
-- -- number_of_purchased_creations
-- -- Trailing_7_day_average

-- --Answer B


-- select to_char(t1.cdate,'YYYY/MM/DD') as "Date" , t1.total as "Number of Creations", t3.count as "Numer of purchased Creations", t2.count as "Numer of purchased Creations within 7 days", CAST(t2.count as float) / CAST(t1.total as float) as "Trailing_7_day_average" from 
-- (select date_trunc('day', creations.created_at)::date as cdate, count(*) as total from creations
-- group by date_trunc('day', creations.created_at)::date) as t1
-- join (select date_trunc('day', creations.created_at)::date as cdate, count(*) as count from creations
-- join orders
-- on orders.creation_id = creations.id
-- where creations.created_at + interval '7' day > orders.created_at 
-- group by date_trunc('day', creations.created_at)::date) as t2
-- on t2.cdate = t1.cdate
-- join (select date_trunc('day', creations.created_at)::date as cdate, count(*) as count from creations
-- join orders
-- on orders.creation_id = creations.id
-- group by date_trunc('day', creations.created_at)::date) as t3
-- on t3.cdate = t1.cdate
-- ORDER BY t1.cdate;
