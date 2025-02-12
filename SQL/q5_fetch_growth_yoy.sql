-- Q. At what percent has Fetch grown year over year?
-- Assuming growth in terms of number of users signup up on the app year-over-year

-- CTE to compute the number of signups per year
with cte_signups_per_yr as (
  select 
    format_timestamp('%Y',created_date) year, 
    count(distinct id)  n_signups
  from `fetch.users`
  group by year
), 
-- CTE to find the number of signups in the previous year for every year
cte_signups_yoy as (
  select 
    *, 
    lag(n_signups) over (order by year) as prev_year_signups
  from cte_signups_per_yr
) 
-- Final query to calculate the growth in number of signups year over year
select 
  *,
  round((n_signups-prev_year_signups)*100/prev_year_signups,2) as percent_growth_yoy
 from cte_signups_yoy 
order by year
