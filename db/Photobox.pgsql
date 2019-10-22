--ANSWER A 

WITH t1 as (
    SELECT 
        creations.creation_device AS device, 
        COUNT(*)AS total 
    FROM   
        creations 
        GROUP BY device

), t2 as (
    SELECT 
        creations.creation_device AS device, 
        Count(*) AS count
    FROM   creations 
        JOIN orders 
        ON orders.creation_id = creations.id 
        WHERE  creations.created_at + interval '7' day > orders.created_at 
        GROUP  BY device
), t3 as(
    SELECT 
        t1.device,  
        t1.total AS total_creations, 
        t2.count AS count,
        ROUND((Cast(t2.count AS numeric) / Cast(t1.total AS numeric)) ,3)  AS percentage
    FROM t1
        LEFT JOIN t2 ON t1.device = t2.device
)
SELECT 
*
from t3



-- ANSWER B version 1 with Moving AVg 7 days
WITH t1 as (
    SELECT 
        Date_trunc('day', creations.created_at) :: DATE AS cdate, 
        Count(*) AS total
    FROM   
        creations 
        GROUP  BY Date_trunc('day', creations.created_at) :: DATE
        ORDER BY cdate

), t2 as (
    SELECT 
        Date_trunc('day', creations.created_at) :: DATE AS cdate, 
        Count(*)                                        AS count 
    FROM   
        creations 
        JOIN orders 
        ON orders.creation_id = creations.id 
        WHERE  creations.created_at + interval '7' day > orders.created_at 
        GROUP  BY Date_trunc('day', creations.created_at) :: DATE
), t3 as (
    SELECT Date_trunc('day', creations.created_at) :: DATE AS cdate, 
                    Count(*) AS count 
    FROM    
        creations 
        JOIN orders 
        ON orders.creation_id = creations.id 
            
        GROUP  BY Date_trunc('day', creations.created_at) :: DATE
), t4 as (
    SELECT 
        t1.cdate AS date, 
        t1.total AS total, 
        t3.count AS count, 
        ROUND(AVG(t2.count) OVER (ORDER BY t1.cdate ROWS BETWEEN 6 PRECEDING AND 0 FOLLOWING)::NUMERIC, 2) AS MA_7
    --    Cast(t2.count AS FLOAT) / Cast(t1.total AS FLOAT) AS " % of orders purchased with 7 days"
    --    t2.count AS "Numer of purchased Creations within 7 days", 
    FROM t1
       LEFT JOIN t2 
       ON 
       t2.cdate = t1.cdate  
       LEFT JOIN t3
       ON 
       t3.cdate = t1.cdate
     
       
) SELECT
    To_char(t4.date, 'YYYY/MM/DD') AS "Date",
    t4.total,
    t4.count,
    ROUND((CAST(t4.ma_7 as numeric) / CAST(t1.total AS numeric)), 2) AS "MOVING AVERAGE 7 DAYS",
    t4.ma_7


  FROM t4
  JOIN t1 on 
  t4.date = t1.cdate


--   ANSWER B BY Device 

WITH t1 as (
    SELECT 
        Date_trunc('day', creations.created_at) :: DATE AS cdate, 
        Count(*) AS total,
        creations.creation_device AS device
    FROM   
        creations 
        GROUP  BY creations.creation_device, Date_trunc('day', creations.created_at) :: DATE

), t2 as (
    SELECT 
        Date_trunc('day', creations.created_at) :: DATE AS cdate, 
        Count(*)                                        AS count 
    FROM   
        creations 
        JOIN orders 
        ON orders.creation_id = creations.id 
        WHERE  creations.created_at + interval '7' day > orders.created_at 
        GROUP  BY Date_trunc('day', creations.created_at) :: DATE
), t3 as (
    SELECT 
        Date_trunc('day', creations.created_at) :: DATE AS cdate, 
        Count(*) AS count 
    FROM            
        creations 
        JOIN orders 
        ON orders.creation_id = creations.id     
        GROUP  BY Date_trunc('day', creations.created_at) :: DATE
), t4 as (
    SELECT 
        To_char(t1.cdate, 'YYYY/MM/DD') AS "Date", 
        t1.total AS "Number of Creations", 
        t3.count AS "Numer of purchased Creations", 
        ROUND(AVG(t2.count) OVER (ORDER BY t1.cdate ROWS BETWEEN 6 PRECEDING AND 0 FOLLOWING)::NUMERIC, 2) AS "Trailing 7 day average",
        t1.device as device
    --    Cast(t2.count AS FLOAT) / Cast(t1.total AS FLOAT) AS " % of orders purchased with 7 days"
    --    t2.count AS "Numer of purchased Creations within 7 days", 
    FROM t1
       LEFT JOIN t2 
       ON 
       t2.cdate = t1.cdate  
       LEFT JOIN t3
       ON 
       t3.cdate = t1.cdate
       GROUP BY device, t1.total, t3.count, t2.count, t1.cdate
       
) SELECT * FROM t4




/*ANSWER C 
bucketing our purchases by creation day will help us understand how customer behivior.

*/
-- COHORT TABLE bucketing creations by week
WITH cohort_item AS (
    SELECT
        (date_trunc('week', creations.created_at)::date) AS cohort_week,
        id AS creation_id
    FROM 
        creations
        ORDER BY 1, 2
), first_orders AS (
    SELECT
        orders.creation_id,
        (date_trunc('week', min(orders.created_at))::date - cohort_item.cohort_week)/7 AS week_number
    FROM orders 
        LEFT JOIN cohort_item  ON orders.creation_id = cohort_item.creation_id
        GROUP BY orders.creation_id, cohort_item.cohort_week
), cohort_size AS (  
    SELECT 
        cohort_week, COUNT(1) AS num_creations      
    FROM 
        cohort_item
        GROUP BY 1
), retention_table AS (
    SELECT
        cohort_item.cohort_week,
        first_orders.week_number,
        COUNT(1) AS num_creations
    FROM 
        first_orders
        LEFT JOIN cohort_item ON first_orders.creation_id = cohort_item.creation_id
        GROUP BY 1, 2
  ), final_values AS (
    SELECT
        TO_CHAR(retention_table.cohort_week, 'YYYY/MM/DD')  AS creation_week,
        cohort_size.num_creations AS total_creations,
        retention_table.week_number,
        retention_table.num_creations::FLOAT * 100 / cohort_size.num_creations AS "percentage of orders"
    FROM 
        retention_table 
        LEFT JOIN cohort_size  ON retention_table.cohort_week = cohort_size.cohort_week
        WHERE retention_table.cohort_week IS NOT NULL
        ORDER BY 1, 3
  )
  SELECT * FROM 
  final_values
  ORDER BY creation_week
  


-- User Retention table
WITH cohort_items as (
  select
    date_trunc('week', members.created_at)::date as cohort_week,
    id as member_id
  from members
  order by 1, 2
), orders as (
  select
    orders.member_id,
    TRUNC(DATE_PART('day', orders.created_at::timestamp - cohort_items.cohort_week)/7) as week_number
  from orders
  left join cohort_items ON orders.member_id = cohort_items.member_id
  group by 1, 2

), cohort_size as (
  select cohort_week, count(1) as num_users
  from cohort_items
  group by 1
  order by 1
), retention_table as (
  select
    cohort_items.cohort_week,
    orders.week_number,
    count(1) as num_users
  from orders
  left join cohort_items ON orders.member_id = cohort_items.member_id
  group by 1, 2
) select 
  retention_table.cohort_week,
  cohort_size.num_users as total_users,
  retention_table.week_number,
  retention_table.num_users::float * 100 / cohort_size.num_users as percentage
from retention_table 
left join cohort_size  ON retention_table.cohort_week = cohort_size.cohort_week
where retention_table.cohort_week IS NOT NULL
order by 1, 3



-- --This table show creations and sales by day 

-- WITH creation_table AS (
--     -- Table counting the creations per date
-- SELECT    
--     creations.creation_device AS device,
--     count(DISTINCT creations.id) AS total_creations, 
--     (date_trunc('day', creations.created_at)::date) AS creation_date

-- FROM creations
-- GROUP BY creation_date, device
-- ORDER BY creation_date
-- -- this is the purchase table counting the total purchases
-- ), sales_table AS (
-- SELECT 
--     COUNT(orders.id) AS count_orders,
--     (date_trunc('day', orders.created_at)::date) AS order_date

--     FROM orders
-- GROUP BY order_date
-- ORDER BY order_date
-- ), creation_orders_table AS (
--     -- this table combines the two and gives us a table by date and category with the daily purchases againts the total creations. 
--     SELECT 
--     creation_table.creation_date AS date,
--     creation_table.total_creations AS total_creations,
--     sales_table.count_orders AS count_orders,
--     creation_table.device AS device
--     FROM 
--     creation_table
--     LEFT JOIN sales_table  
--     ON creation_table.creation_date = sales_table.order_date
--     ORDER BY date
-- ) 
-- SELECT 
--     creation_orders_table.date,
--     creation_orders_table.total_creations,
--     creation_orders_table.count_orders,
--     creation_orders_table.device
-- FROM  
--     creation_orders_table





























-- with t1 as (
--     SELECT 
--         creations.id AS creation_id,
--         studio_tech_id,
--         creations.member_id, 
--         orders.id AS order_id,
--         Date_trunc('week', creations.created_at) :: DATE AS creation_ts,
--         Date_trunc('week', orders.created_at) :: DATE AS order_ts,
--         AVG(SUM(t1.days_to_purchase) / (COUNT(*))) AS avg_purchase_days
        
--     FROM
--         (SELECT TRUNC(DATE_PART('day', orders.created_at::timestamp - creations.created_at)) AS days_to_purchase) 
--         From  creations) AS t1

--     JOIN orders 
--     ON creations.id = orders.creation_id 
--     GROUP BY days_to_purchase, creations.id, orders.id
-- )

-- -- ), t2 AS(
-- --     SELECT 
-- --     AVG(SUM(t1.days_to_purchase) / (COUNT(t1.order_id))) AS avg_purchase_days
-- --     FROM t1
-- -- ) SELECT * FROM t2


-- Select 
--      Date_trunc('week', creations.created_at) :: DATE AS creation_ts, 
--     SUM(
--         CASE WHEN creations.creation_device = 'mobile' THEN 1
--         ELSE
--         0 
--         END) AS "mobile",
--         SUM(
--         CASE WHEN creations.creation_device = 'desktop' THEN 1
--         ELSE
--         0 
--         END) AS "desktop",
--         SUM(
--         CASE WHEN creations.creation_device = 'tablet' THEN 1
--         ELSE
--         0 
--         END) AS "tablet",
--         SUM(
--         CASE WHEN creations.creation_device = 'mobile' THEN 1
--         ELSE
--         0 
--         END) AS "mobile",
--         SUM(
--         CASE WHEN creations.creation_device = 'desktop' THEN 1
--         ELSE
--         0 
--         END) AS "desktop",
--         SUM(
--         CASE WHEN creations.creation_device = 'tablet' THEN 1
--         ELSE
--         0 
--         END) AS "tablet",
    
--     FROM creations
--     GROUP by creation_ts