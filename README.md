# DataAnalytics-Assessment

This repository contains SQL solutions to a business data analysis assessment using a relational database (`adashi_assessment.sql`) with the following schema:

* `users_customuser`: Customer demographic and contact information
* `savings_savingsaccount`: Records of deposit transactions
* `plans_plan`: Records of plans created by customers
* `withdrawals_withdrawal`: Records of withdrawal transactions

Each SQL file contains a single query that answers a specific business question, with attention to accuracy, efficiency, and clarity.

---

## 📁 Repository Structure

```
DataAnalytics-Assessment/
│
├── adashi_assessment.sql/
│   ├── _MACOSX/
│   │   ├── adashi_assessment.sql
│   ├── adashi_assessment.sql
├── Assessment_Q1.sql
├── Assessment_Q2.sql
├── Assessment_Q3.sql
├── Assessment_Q4.sql
│
└── README.md
```

---

## 🔎 Hints and Schema Notes

* `owner_id` is a foreign key to the `id` primary key in the `users_customuser` table.
* `plan_id` is a foreign key to the `id` primary key in the `plans_plan` table.
* `savings_plan`: identified by `is_regular_savings = 1`
* `investment_plan`: identified by `is_a_fund = 1`
* `confirmed_amount`: field representing the value of inflow transactions (in kobo).
* `amount_withdrawn`: field representing the value of withdrawal transactions (in kobo).
* **All amount fields are denominated in kobo.** Ensure conversion to Naira (₦) where needed by dividing by 100.

---

# Assessment\_Q1

## Savings Goal Exceeded Report Query

### Overview

This SQL query generates a report listing users who have contributed more money to their savings accounts than their targeted savings goal amount.

### Tables Involved

* `plans_plan (pp)`: Contains savings plans information.
* `savings_savingsaccount (ssa)`: Records contributions made to savings accounts.
* `users_customuser (u)`: User account details.

### Query Logic

* Joins savings plans with their related contributions and associated users.
* Filters:

  * Active goals only (`status_id = 2`, `is_a_goal = 1`)
  * Excludes deleted or archived plans
  * Excludes deleted, disabled, or private user accounts
* Calculates total contributions and savings targets per user.
* Returns users whose contributions exceed their goals.

### Output Columns

* `user_id`: The unique identifier for the user (plan owner).
* `contributed_amount`: Total amount contributed.
* `savings_target`: Target amount set by the user.

### Example Query

```sql
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
```

---

# Assessment\_Q2

## Transaction Frequency Analysis

### Overview

This SQL query analyzes how frequently customers transact to support segmentation efforts by the finance team.

### Tables Involved

* `users_customuser`: Customer profiles.
* `savings_savingsaccount`: Transaction records.

### Query Logic

* Counts transactions per user and calculates tenure in months.
* Computes average monthly transaction frequency.
* Categorizes users as:

  * **High Frequency**: ≥10 transactions/month
  * **Medium Frequency**: 3–9 transactions/month
  * **Low Frequency**: ≤2 transactions/month
* Aggregates by frequency category.

### Output Columns

* `frequency_category`: High, Medium, or Low
* `customer_count`: Number of users in the category
* `avg_transactions_per_month`: Average transaction rate per month

### Example Output

| frequency\_category | customer\_count | avg\_transactions\_per\_month |
| ------------------- | --------------- | ----------------------------- |
| High Frequency      | 250             | 15.2                          |
| Medium Frequency    | 1200            | 5.5                           |
| Low Frequency       | 800             | 1.3                           |

---

# Assessment\_Q3

## Account Inactivity Alert

### Overview

This SQL query flags active savings or investment accounts that have not had any inflow transactions for more than one year (365 days).

### Tables Involved

* `plans_plan`: Account plans.
* `savings_savingsaccount`: Inflow transactions.

### Query Logic

* Extracts latest transaction date per plan.
* Filters to only active, undeleted, non-archived plans.
* Calculates inactivity period in days.
* Returns accounts inactive for over 365 days.

### Output Columns

* `plan_id`: Plan identifier.
* `owner_id`: User ID.
* `type`: Savings or Investment.
* `last_transaction_date`: Most recent inflow date.
* `inactivity_days`: Days since last inflow.

### Example Output

| plan\_id | owner\_id | type    | last\_transaction\_date | inactivity\_days |
| -------- | --------- | ------- | ----------------------- | ---------------- |
| 1001     | 305       | Savings | 2023-08-10              | 455              |

---

# Assessment\_Q4

## Customer Lifetime Value (CLV) Estimation

### Overview

This SQL query estimates Customer Lifetime Value (CLV) based on account tenure and transaction volume, using a simplified formula.

### Tables Involved

* `users_customuser`: Account and signup details.
* `savings_savingsaccount`: Transaction history.

### Query Logic

* Calculates account tenure in months.

* Counts total transactions and computes total transaction value.

* Uses the formula:

  $\text{CLV} = \left( \frac{\text{total_transactions}}{\text{tenure}} \right) \times 12 \times 0.001 \times \text{avg transaction value}$

* Orders users by estimated CLV, descending.

### Output Columns

* `customer_id`: User ID.
* `name`: Full name of the user.
* `tenure_months`: Duration of account.
* `total_transactions`: Number of transactions.
* `estimated_clv`: Lifetime value estimate.

### Example Output

| customer\_id | name     | tenure\_months | total\_transactions | estimated\_clv |
| ------------ | -------- | -------------- | ------------------- | -------------- |
| 1001         | John Doe | 24             | 120                 | 600.00         |

---

## Author

Aniedi Bernard Oboho-Etuk