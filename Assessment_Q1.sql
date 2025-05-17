SELECT  
    pp.owner_id AS user_id,
    ROUND(SUM(ssa.amount), 2) AS contributed_amount,
    ROUND(SUM(pp.amount), 2) AS savings_target
FROM 
    plans_plan pp
JOIN 
    savings_savingsaccount ssa ON ssa.plan_id = pp.id
JOIN 
    users_customuser u ON u.id = pp.owner_id
WHERE 
    pp.status_id = 2
    AND pp.is_deleted = 0
    AND pp.is_archived = 0
    AND pp.is_a_goal = 1
    AND u.is_account_deleted = 0
    AND u.is_account_disabled = 0
    AND u.is_private = 0
GROUP BY 
    pp.owner_id
HAVING 
    contributed_amount > savings_target;
-- This query retrieves the user IDs of users who have contributed more to their savings accounts than their savings target.
-- It joins the plans_plan and savings_savingsaccount tables to get the relevant data, filters out deleted or archived accounts, and groups the results by user ID.