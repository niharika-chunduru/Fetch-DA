-- What is the percentage of sales in the Health & Wellness category by generation?

-- CTE to classify scanned users by generation
WITH cte_scanned_users_generations AS (
    SELECT 
        t.user_id, 
        t.barcode, 
        safe_cast(t.final_sale AS FLOAT64) AS final_sale, 
        CASE
            WHEN FORMAT_TIMESTAMP('%Y', birth_date) BETWEEN '1946' AND '1964' THEN 'Baby Boomers'
            WHEN FORMAT_TIMESTAMP('%Y', birth_date) BETWEEN '1965' AND '1980' THEN 'Generation-X'
            WHEN FORMAT_TIMESTAMP('%Y', birth_date) BETWEEN '1981' AND '1996' THEN 'Millennials'
            ELSE 'Other'
        END AS generation 
    FROM `fetch.transactions` t 
    JOIN `fetch.users` u on u.id = t.user_id
    WHERE birth_date IS NOT NULL 
    AND barcode IS NOT NULL 
    AND final_sale IS NOT NULL
), 
-- CTE to calculate sales of products in H&W category in receipts scanned by users - grouped by user generation
cte_hnw_generational_sales AS (
    SELECT 
        sug.generation,
        ROUND(SUM(final_sale),2) AS hnw_generation_sales
    FROM cte_scanned_users_generations sug 
    JOIN `fetch.products` p USING (barcode)
    WHERE p.category_1 = 'Health & Wellness'
    GROUP BY sug.generation
),
-- CTE to calculate sales of products in H&W category in receipts scanned by users - total
cte_hnw_total_sales AS (
    SELECT 
        ROUND(SUM(hnw_generation_sales),2) AS hnw_total_sales 
    FROM cte_hnw_generational_sales  
)
-- Final query to calculate percentage contribution of sales in Health & Wellness category by generatio
SELECT 
    generation, 
    ROUND(hnw_generation_sales * 100.00 / hnw_total_sales, 2) AS percent_sales
FROM cte_hnw_generational_sales, cte_hnw_total_sales
ORDER BY percent_sales DESC
