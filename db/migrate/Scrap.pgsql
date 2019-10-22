with creation_table AS (
SELECT    
    creations.creation_device AS device,
    count(DISTINCT creations.id) AS total_creations, 
    (date_trunc('day', creations.created_at)::date) AS creation_date

FROM creations
GROUP BY creation_date, device
ORDER BY creation_date
-- this is the sales table. 
), sales_table AS (
SELECT 
    COUNT(orders.id) AS count_orders,
    (date_trunc('day', orders.created_at)::date) AS order_date

    FROM orders
GROUP BY order_date
ORDER BY order_date
), final_table AS (
    SELECT 
    sales_table.order_date AS date,
    creation_table.total_creations AS total_creations,
    sales_table.count_orders AS count_orders,
    -- count(case when sales_table.order_date =< creation_table.creation_date - interval '7 day' ),
    creation_table.device
    FROM 
    creation_table
    LEFT JOIN sales_table  ON CAST(creation_table.creation_date AS date) = CAST(sales_table.order_date as date)
    -- WHERE CAST(sales_table.order_date as date) = 
    ORDER BY date
)SELECT 
 * FROM final_table 




-- SELECT 
--     date_trunc('day', orders.created_at) AS order_date, 
--     creation_device AS device
    

-- FROM

SELECT 
    
    date_trunc('day', creations.created_at) AS creation_date,
    date_trunc('day', orders.created_at) AS order_date, 
    orders.id,
    creations.id

FROM orders
LEFT JOIN creations
ON orders.creation_id = creations.id
GROUP BY order_date, orders.id, creation_date, creations.id
ORDER BY creation_date


SELECT * from orders
ORDER BY orders.created_at

SELECT * from creations
ORDER BY creations.created_at

SELECT 
     date_trunc('day', creations.created_at) AS creation_date, 
    count(creations.id) 
FROM creations
GROUP BY creation_date
ORDER BY creation_date

SELECT 
     date_trunc('day', creations.created_at) AS creation_date, 
    count(creations.id) AS creation_count
    -- count(orders.id) AS order_count
FROM creations
-- inner JOIN orders ON creations.id = orders.creation_id
GROUP BY creation_date
ORDER BY creation_date


SELECT 
    COUNT(orders.id) AS count orders,
    (date_trunc('day', orders.created_at)::date) AS order_date

    FROM orders
GROUP BY order_date
ORDER BY order_date
