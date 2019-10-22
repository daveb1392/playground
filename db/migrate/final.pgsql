-- Answer a
SELECT t1.device,  
       t1.total AS total_creations, 
       t2.count AS "purchased within 7 days of creation",
       Cast(t2.count AS numeric) / Cast(t1.total AS numeric)  AS percentage 
        
        FROM   
        
        (SELECT creations.creation_device AS device, 
            Count(*)AS total 
        
        FROM   
        creations 
        GROUP  BY device) AS t1 

       join (SELECT creations.creation_device AS device, 
                    Count(*) AS count
             FROM   creations 
                    join orders 
                      ON orders.creation_id = creations.id 
             WHERE  creations.created_at + interval '7' day > orders.created_at 
             GROUP  BY device) AS t2 
        ON t1.device = t2.device; 

% 2599

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











select * from creations;

date 
number_of_creations
number_of_purchased_creations
Trailing_7_day_average

--Answer B


SELECT To_char(t1.cdate, 'YYYY/MM/DD') AS "Date", 
       t1.total AS "Number of Creations", 
       t3.count AS "Numer of purchased Creations", 
       t2.count AS "Numer of purchased Creations within 7 days", 
       Cast(t2.count AS FLOAT) / Cast(t1.total AS FLOAT) AS "Trailing 7 day average" 
FROM   
    (SELECT Date_trunc('day', creations.created_at) :: DATE AS cdate, 
               Count(*) AS total 
        FROM   
        creations 
        GROUP  BY Date_trunc('day', creations.created_at) :: DATE) AS t1 
        JOIN 
        
        (SELECT Date_trunc('day', creations.created_at) :: DATE AS cdate, 
                    Count(*)                                        AS count 
             FROM   creations 
                    join orders 
                      ON orders.creation_id = creations.id 

             WHERE  creations.created_at + interval '7' day > orders.created_at 
             
             GROUP  BY Date_trunc('day', creations.created_at) :: DATE) AS t2 
                    
                    ON t2.cdate = t1.cdate 
            JOIN 
            
            
            (SELECT Date_trunc('day', creations.created_at) :: DATE AS cdate, 
                    Count(*) AS count 
            FROM   
             
             creations 
            JOIN orders 
            ON orders.creation_id = creations.id 
            
            GROUP  BY Date_trunc('day', creations.created_at) :: DATE) AS t3 
         ON t3.cdate = t1.cdate 
ORDER  BY t1.cdate; 







---ANSWER B 


WITH t1 as (
    SELECT Date_trunc('day', creations.created_at) :: DATE AS cdate, 
               Count(*) AS total
        FROM   
        creations 
        GROUP  BY Date_trunc('day', creations.created_at) :: DATE
        ORDER BY cdate

), t2 as (
    SELECT 
    Date_trunc('day', creations.created_at) :: DATE AS cdate, 
    Count(*)                                        AS count 
    FROM   creations 
    join orders 
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




WITH t1 as (
    SELECT Date_trunc('day', creations.created_at) :: DATE AS cdate, 
               Count(*) AS total,
               creations.creation_device AS device
        FROM   
        creations 
        GROUP  BY creations.creation_device, Date_trunc('day', creations.created_at) :: DATE

), t2 as (
    SELECT 
    Date_trunc('day', creations.created_at) :: DATE AS cdate, 
    Count(*)                                        AS count 
    FROM   creations 
    join orders 
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














with t1 as (
    SELECT Date_trunc('day', creations.created_at) :: DATE AS cdate, 
               Count(*) AS total 
        FROM   
        creations 
        GROUP  BY Date_trunc('day', creations.created_at) :: DATE

), t2 as (
    SELECT 
    Date_trunc('day', creations.created_at) :: DATE AS cdate, 
    Count(*)                                        AS count 
    FROM   creations 
    join orders 
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
    To_char(t1.cdate, 'YYYY/MM/DD') AS "Date", 
       t1.total AS "Number of Creations", 
       t3.count AS "Numer of purchased Creations", 
    --    t2.count AS "Numer of purchased Creations within 7 days", 
       AVG(t2.count) OVER (ORDER BY t1.cdate ROWS BETWEEN 6 PRECEDING AND 0 FOLLOWING)::FLOAT AS "7-Day Moving Average" 
    --    Cast(t2.count AS FLOAT) / Cast(t1.total AS FLOAT) AS "Trailing 7 day average"
       FROM t1
       LEFT JOIN t2 
       ON 
       t2.cdate = t1.cdate  
       LEFT JOIN t3
       ON 
       t3.cdate = t1.cdate
       
) SELECT * FROM t4

























select date_trunc('day', creations.created_at)::date, creations.creation_device as device, count(*) as total from creations
group by device, date_trunc('day', creations.created_at)::date;



select * from creations
join orders
on orders.creation_id = creations.id
where date_trunc('day', creations.created_at)::date = '2019/09/20';

join 
(select creations.creation_device as device, count(*) as count from creations
join orders
on orders.creation_id = creations.id
where creations.created_at + interval '7' day > orders.created_at 
group by device, creations.created_at) as t2
on t1.device = t2.device;











with creation_table AS (
    -- Table counting the creations per date
SELECT    
    creations.creation_device AS device,
    count(DISTINCT creations.id) AS total_creations, 
    (date_trunc('day', creations.created_at)::date) AS creation_date

FROM creations
GROUP BY creation_date, device
ORDER BY creation_date
-- this is the purchase table counting the total purchases
), sales_table AS (
SELECT 
    COUNT(orders.id) AS count_orders,
    (date_trunc('day', orders.created_at)::date) AS order_date

    FROM orders
GROUP BY order_date
ORDER BY order_date
), creation_orders_table AS (
    -- this table combines the two and gives us a table by date and category with the daily purchases againts the total creations. 
    SELECT 
    creation_table.creation_date AS date,
    creation_table.total_creations AS total_creations,
    sales_table.count_orders AS count_orders,
    creation_table.device AS device
    FROM 
    creation_table
    LEFT JOIN sales_table  
    ON creation_table.creation_date = sales_table.order_date
    ORDER BY date
) 
SELECT 
    creation_orders_table.date,
    creation_orders_table.total_creations,
    creation_orders_table.count_orders,
    creation_orders_table.device
FROM  
    creation_orders_table

 --Now I need to get the daily percentage of creations purchased within 7 days of being created.




-- --THis table is by day with no segmentation to device 
with creation_table AS (
    -- Table counting the creations per date
SELECT    
    -- creations.creation_device AS device,
    count(DISTINCT creations.id) AS total_creations, 
    (date_trunc('day', creations.created_at)::date) AS creation_date

FROM creations
GROUP BY creation_date
ORDER BY creation_date
-- this is the purchase table counting the total purchases
), sales_table AS (
SELECT 
    COUNT(orders.id) AS count_orders,
    (date_trunc('day', orders.created_at)::date) AS order_date

    FROM orders
GROUP BY order_date
ORDER BY order_date
), creation_orders_table AS (
    -- this table combines the two and gives us a table by date and category with the daily purchases againts the total creations. 
    SELECT 
    creation_table.creation_date AS date,
    creation_table.total_creations AS total_creations,
    sales_table.count_orders AS count_orders
    -- creation_table.device AS device
    FROM 
    creation_table
    LEFT JOIN sales_table  
    ON creation_table.creation_date = sales_table.order_date
    ORDER BY date
)SELECT 
    creation_orders_table.date,
    creation_orders_table.total_creations,
    creation_orders_table.count_orders
    FROM  
    creation_orders_table
--  --Now I need to get the daily percentage of creations purchased within 7 days of being created.
