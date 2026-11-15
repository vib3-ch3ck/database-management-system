-- I changed my design from the original questions and reports, so none of these really fit my deliverable 1 questions exactly


-- Requirement 1: Filters and Sorting
-- What are the large transactions across the bank?
-- Shows the transaction ID, account number, amount, date, and status of deposits >$500 in descending order
-- banks care about the money they have incoming, and want to see their greatest contributors irregardless of branch
SELECT trans_ID, account_num, type, amount, date, status
    FROM transaction_history
    WHERE amount > 500.00 AND type == 'Deposit'
    ORDER BY amount DESC;

-- Requirement 2: Inner Join
-- How much money does each branch manage?
-- joins the branches with the accounts to show what branches manage which accounts and related account details
SELECT b.name AS branch_name, a.account_num, a.acc_type, a.balance
    FROM accounts a
    INNER JOIN branches b ON a.branch_id = b.branch_id
    ORDER BY b.name, a.balance DESC;

-- Requirement 3: Left Join
-- Which customers are not in debt with the bank?
-- joins customers and loans to show which customers have loans and the details of those loans
-- this also shows NULL values, so we know which customers do NOT have loans
SELECT c.firstname, c.lastname, l.loan_id, l.principal, l.rem_balance
    FROM customers c
    LEFT JOIN loans l ON c.customer_id = l.customer_id;

-- Requirement 4: Three-Table Join
-- What is the comprehensive and detailed transaction history of the entire bank?
-- joins customers, customer-accounts, accounts, and transaction-history to see all recent transactions
-- could be modified with a WHERE acc num = xxx to see one account's transactions if desired
SELECT c.firstname, c.lastname, a.acc_type AS account_type, t.date, t.type AS trans_type, t.amount
    FROM customers c
    JOIN customer_accounts ca ON c.customer_id = ca.customer_id
    JOIN accounts a ON ca.account_num = a.account_num
    JOIN transaction_history t ON a.account_num = t.account_num
    -- WHERE a.account_num == 1001
    ORDER BY t.date;

-- Requirement 5: Aggregate Query
-- sums the total cash value in savings accounts across the bank 
SELECT COUNT(account_num) AS num_savings_accounts, SUM(balance) AS savings_balance
    FROM accounts
    WHERE acc_type = 'Savings';

-- Requirement 6: GROUP BY and HAVING
-- Which branches manage more than $10k?
-- shows the branches that manage more than $10k, grouped by branch, descending
-- shows which branch is the 'biggest' and how many accounts that value is distributed across
SELECT b.name AS branch_name, COUNT(a.account_num) AS total_accounts, SUM(a.balance) AS branch_balance
    FROM branches b
    JOIN accounts a ON b.branch_id = a.branch_id
    GROUP BY b.branch_id, b.name
    HAVING SUM(a.balance) > 10000.00
    ORDER BY branch_balance DESC;

-- Requirement 7: Subquery
-- Which customers have more money than the average?
-- shows customers with a balance bigger than the bank-wide average
SELECT 
    c.firstname, 
    c.lastname, 
    cb.total_balance
FROM customers c
JOIN (
    -- balance
    SELECT ca.customer_id, SUM(a.balance) AS total_balance
    FROM customer_Accounts ca
    JOIN accounts a ON ca.account_num = a.account_num
    GROUP BY ca.customer_id
) cb ON c.customer_id = cb.customer_id
WHERE cb.total_balance > (
    -- bank average
    SELECT AVG(branch_total) 
    FROM (
        SELECT SUM(balance) AS branch_total 
        FROM accounts 
        GROUP BY branch_id
    )
);

-- Requirement 8: Set Operation
-- Creates a directory of everyone in the bank, ordered by role (customers/branch managers)
SELECT firstname || ' ' || lastname AS full_name, 'Customer' AS role, phone AS phone
    FROM customers
    UNION
    SELECT manager AS full_name, 'Branch Manager' AS role, phone AS phone
    FROM branches
    ORDER BY role, full_name;

-- Requirement 9: View 
-- What is the combined account value vs debt per customer? Which ones have more debt than cash?
-- uses the view customer_summary to select customers whos debt is bigger than their total cash balance
SELECT customer_id, firstname, lastname, total_cash_balance, total_loan_debt
    FROM customer_summary
    WHERE total_loan_debt > total_cash_balance;