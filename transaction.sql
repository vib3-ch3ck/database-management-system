BEGIN TRANSACTION;

-- dedut from savings 1002
UPDATE accounts 
SET balance = balance - 200.00 
WHERE account_num = 1002;

-- add to checking 1001
UPDATE accounts 
SET balance = balance + 200.00 
WHERE account_num = 1001;

-- log this in transaction history
-- id 999 to avoid conflicts 
INSERT INTO transaction_history (trans_ID, account_num, type, destination, amount, date, status) 
VALUES (999, 1002, 'Transfer', '1001', 200.00, '2023-10-15', 'Completed');

-- for demonstration purposes
SELECT * FROM Accounts WHERE account_num IN (1001, 1002);
SELECT * FROM transaction_history;

-- commit because sure why not
COMMIT;