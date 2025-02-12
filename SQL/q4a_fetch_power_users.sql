-- Who are Fetch’s power users?
-- Solution #1 (App Engagement): Power users scanned atleast 2x more receipts than the minimum receipts scanned by top 1 percentile of the users

-- CTE to compute number of receipts scanned per user
with cte_receipts_per_user as (
    select
        user_id, 
        count(distinct receipt_id) as n_receipts 
    from `fetch.transactions` 
    where receipt_id is not null
    group by user_id
),
-- CTE to compute number of minimum receipts to be scanned to be in top 1% users
cte_top1_percentile as (
    select percentile_cont(n_receipts, 0.99) over () as top1_n_receipts
    from cte_receipts_per_user
    limit 1
)
-- Final query to fetch the users who scanned at least twice more than the minimum receipts scanned by top 1 percentile users
select 
    rpr.user_id as power_user_id, 
    rpr.n_receipts
from cte_receipts_per_user rpr, cte_top1_percentile t1p
where rpr.n_receipts >= 2*t1p.top1_n_receipts 
order by rpr.n_receipts desc;
