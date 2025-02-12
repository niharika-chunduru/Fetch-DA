-- Who are Fetch’s power users?
-- Solution #2 (Purchase Spend): Power Users are in the top 0.1% of users who scanned receipts over $10

-- CTE to filter the valid receipts from transactions
-- A receipt is valid if it was scanned only once. If scanned twice, then the user who scanned it first is treated as valid.
with cte_valid_receipts as (
    select 
    distinct receipt_id, 
    first_value(user_id) over (partition by receipt_id order by scan_date) valid_user_id, 
    safe_cast(final_sale as float64) as final_sale
    from `fetch.transactions`
), 
-- CTE to filter user purchase totals worth above 10USD
cte_user_purchase_totals as (
    select 
        valid_user_id, 
        round(sum(final_sale),2) as total_purchase_value
    from cte_valid_receipts
    group by valid_user_id
    having total_purchase_value > 10.0
),
-- CTE to compute the minimum purchase amount needed to be in the top 0.1% of purchase totals
cte_top01_percentile as (
    select 
        round(percentile_cont(total_purchase_value, 0.999) over (),2) as top01_purchase_value 
    from cte_user_purchase_totals
    limit 1
) 
-- Final query to extract top 0.1% of users who scanned receipts over $10
select 
    upt.valid_user_id as power_user_id, 
    upt.total_purchase_value
from cte_user_purchase_totals upt, cte_top01_percentile t01p
where upt.total_purchase_value >= t01p.top01_purchase_value
order by total_purchase_value desc;
