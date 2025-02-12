-- Q. What are the top 5 brands by receipts scanned among users 21 and over?

-- CTE to extract receipts of user age when receipt was scanned
-- User age is calculated at the time of receipt scan, not current date
with cte_user_ages as (
  select 
    receipt_id, 
    barcode, 
    timestamp_diff(cast(t.scan_date as date), cast(u.birth_date as date), YEAR) as age, 
    SAFE_CAST(final_sale AS FLOAT64) as final_sale
  from `fetch.transactions` t left join `fetch.users` u on t.user_id = u.id
  where u.birth_date is not null
)
-- Final query to get top 5 brands from receipts of users aged 21 and above
select brand
from cte_user_ages 
left join `fetch.products` using(barcode)
where brand is not null 
and age>=21
group by brand
order by count(distinct receipt_id) desc, sum(final_sale) desc
limit 5;
