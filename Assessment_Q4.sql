WITH user_txn_summary AS (
    SELECT 
        u.id AS customer_id,
        u.full_name AS name,
        COUNT(ssa.id) AS total_transactions,
        DATE_PART('month', AGE(CURRENT_DATE, u.date_joined)) AS tenure_months,
        SUM(ssa.amount) AS total_transaction_value
    FROM users_customuser u
    LEFT JOIN savings_savingsaccount ssa ON u.id = ssa.user_id
    WHERE u.is_account_deleted = 0
      AND u.is_account_disabled = 0
    GROUP BY u.id, u.full_name, u.date_joined
),

clv_calc AS (
    SELECT 
        customer_id,
        name,
        tenure_months,
        total_transactions,
        ROUND(
            (CASE 
                WHEN tenure_months > 0 THEN 
                    (total_transactions::numeric / tenure_months) * 12 * (0.001 * (total_transaction_value / NULLIF(total_transactions, 0)))
                ELSE 0
             END), 2
        ) AS estimated_clv
    FROM user_txn_summary
)

SELECT *
FROM clv_calc
ORDER BY estimated_clv DESC;
-- This query calculates the estimated Customer Lifetime Value (CLV) for each customer based on their transaction history.
-- It first summarizes the transaction data for each user, then calculates the CLV based on the average monthly transactions and total transaction value.   