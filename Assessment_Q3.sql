WITH last_txn AS (
    SELECT 
        plan_id, 
        MAX(created_at) AS last_transaction_date
    FROM savings_savingsaccount
    GROUP BY plan_id
),

filtered_plans AS (
    SELECT 
        pp.id AS plan_id,
        pp.owner_id,
        CASE 
            WHEN pp.is_a_goal = 1 THEN 'Savings'
            ELSE 'Investment'
        END AS type,
        lt.last_transaction_date,
        DATE_PART('day', CURRENT_DATE - lt.last_transaction_date) AS inactivity_days
    FROM plans_plan pp
    LEFT JOIN last_txn lt ON pp.id = lt.plan_id
    WHERE 
        pp.status_id = 2 -- active
        AND pp.is_deleted = 0
        AND pp.is_archived = 0
)

SELECT 
    plan_id,
    owner_id,
    type,
    last_transaction_date,
    inactivity_days
FROM filtered_plans
WHERE 
    last_transaction_date IS NOT NULL
    AND inactivity_days > 365
ORDER BY inactivity_days DESC;
-- This query identifies plans that have been inactive for more than 365 days, categorizing them as either "Savings" or "Investment" based on the `is_a_goal` field.
-- It retrieves the plan ID, owner ID, type, last transaction date, and the number of days since the last transaction.