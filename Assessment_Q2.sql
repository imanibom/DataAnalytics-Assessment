WITH monthly_tx_counts AS (
    SELECT
        ssa.user_id,
        DATE_TRUNC('month', ssa.created_at) AS txn_month,
        COUNT(*) AS monthly_txn_count
    FROM savings_savingsaccount ssa
    GROUP BY ssa.user_id, DATE_TRUNC('month', ssa.created_at)
),

avg_txn_per_user AS (
    SELECT
        user_id,
        AVG(monthly_txn_count)::NUMERIC(10,2) AS avg_txn_per_month
    FROM monthly_tx_counts
    GROUP BY user_id
),

categorized_users AS (
    SELECT
        CASE
            WHEN avg_txn_per_month >= 10 THEN 'High Frequency'
            WHEN avg_txn_per_month BETWEEN 3 AND 9 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category,
        avg_txn_per_month
    FROM avg_txn_per_user
)

SELECT
    frequency_category,
    COUNT(*) AS customer_count,
    ROUND(AVG(avg_txn_per_month), 2) AS avg_transactions_per_month
FROM categorized_users
GROUP BY frequency_category
ORDER BY 
    CASE 
        WHEN frequency_category = 'High Frequency' THEN 1
        WHEN frequency_category = 'Medium Frequency' THEN 2
        WHEN frequency_category = 'Low Frequency' THEN 3
    END;
-- This query categorizes users based on their average monthly transaction counts into three categories:
-- High Frequency (10 or more transactions), Medium Frequency (3 to 9 transactions), and Low Frequency (less than 3 transactions).