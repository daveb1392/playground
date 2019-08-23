
-- https:
-- //www.holistics.io/blog/calculate-cohort-retention-analysis-
-- with-sql/

-- (user_id, cohort_month), each 
with cohort_items as (
  select
    date_trunc('month', U.timestamp)::date as cohort_month,
    id as user_id
  from users U
  order by 1, 2
)


-- (user_id, month_number): user X has activity in month number X
WITH
  user_activities
  as
  (
    select
      A.user_id,
      MONTH_DIFF(
      date_trunc('month', A.timestamp)
  ::date,
      C.cohort_month
    ) as month_number
  from public.activities A
  left join cohort_items C ON A.user_id = C.user_id
  group by 1, 2
)


-- (cohort_month, size)
with
  cohort_size
  as
  (
    select cohort_month, count(1) as num_users
    from cohort_items
    group by 1
    order by 1
  )

  with retention_table
  as
  (
    select
      C.cohort_month,
      A.month_number,
      count(1) as num_users
    from user_activities A
      left join cohort_items C ON A.user_id = C.user_id
    group by 1, 2
  )
-- our final value: (cohort_month, size, month_number, percentage)
select
  B.cohort_month,
  S.num_users as total_users,
  B.month_number,
  B.num_users::float * 100 / S.num_users as percentage
from retention_table B
  left join cohort_size S ON B.cohort_month = S.cohort_month
where B.cohort_month IS NOT NULL
order by 1, 3