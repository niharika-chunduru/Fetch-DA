-- Q. What are the top 5 brands by sales among users that have had their account for at least six months?

-- CTE to compute age of the account when receipt was scanned
-- Account age is calculated at the time of receipt scan, not current date 
with cte_account_ages as (
  select 
    u.id, 
    t.barcode,
    safe_cast(t.final_sale as float64) as final_sale,
    timestamp_diff(cast(t.scan_date as date), cast(u.created_date as date), MONTH) as account_age_mos
  from `fetch.transactions` t join `fetch.users` u ON t.user_id = u.id
), 
-- CTE to compute brand sales rankings among users who have had their account for at least six months 
cte_brand_sales_6mos_plus as (
  select 
    brand, 
    round(sum(final_sale),2) as total_sales, 
    dense_rank() over (order by round(sum(final_sale),2) desc) as sales_rank 
  from cte_account_ages
  join `fetch.products` using(barcode)
  where brand is not null
  and account_age_mos >= 6
  group by brand
  order by sales_rank
)
-- Final query to fetch top 5 brands by sales
select *
from cte_brand_sales_6mos_plus 
where sales_rank <= 5
