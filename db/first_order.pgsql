 -- Bucketing into a cohort first step cohort items
WITH cohort_item as (
  select
    (date_trunc('week', users.created_at)::date) as cohort_week,
    id as user_id
  from users
  ORDER BY 1, 2
), 
-- building the user activities
first_orders AS (
SELECT
    orders.user_id,
      (date_trunc('week', min(orders.created_at))::date
      - cohort_item.cohort_week)/7
    as week_number
  from orders 
  left join cohort_item  ON orders.user_id = cohort_item.user_id
  group by orders.user_id, cohort_item.cohort_week
), cohort_size as 
  (  SELECT 
    cohort_week, count(1) as num_users
    FROM cohort_item
    group by 1
    -- order by 1
  ), retention_table as 
  (select
    cohort_item.cohort_week,
    first_orders.week_number,
    count(1) as num_users
  from first_orders
  left join cohort_item ON first_orders.user_id = cohort_item.user_id
  group by 1, 2
  ), final_values AS (
-- our final value: (cohort_month, size, month_number, percentage)
select
  retention_table.cohort_week,
  cohort_size.num_users as total_users,
  retention_table.week_number,
  retention_table.num_users::float * 100 / cohort_size.num_users as percentage
from retention_table 
left join cohort_size  ON retention_table.cohort_week = cohort_size.cohort_week
where retention_table.cohort_week IS NOT NULL
order by 1, 3
  )
  SELECT * FROM 
  -- cohort_item
  final_values




;