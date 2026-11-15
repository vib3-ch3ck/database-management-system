.mode box
.nullvalue NULL

PRAGMA foreign_keys = ON;

--cleanup
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS accounts;
DROP TABLE IF EXISTS customer_accounts;
DROP TABLE IF EXISTS transaction_history;
DROP TABLE IF EXISTS loans;
DROP TABLE IF EXISTS branches;

DROP VIEW IF EXISTS customer_summary;

-- tables
CREATE TABLE branches (
    branch_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    phone TEXT,
    address TEXT,
    manager TEXT
);

CREATE TABLE customers (
    customer_id INTEGER PRIMARY KEY,
    firstname TEXT NOT NULL,
    lastname TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL, -- NK 1
    phone TEXT,
    ssn TEXT UNIQUE NOT NULL -- NK 2 / i hope your ssn is unique
);

CREATE TABLE accounts (
    account_num INTEGER PRIMARY KEY,
    branch_id INTEGER NOT NULL,
    acc_type TEXT NOT NULL CHECK (acc_type IN ('Checking', 'Savings')), -- NK 3 / must be one of the two
    balance REAL NOT NULL DEFAULT 0.00 CHECK (balance >= 0), -- no negative balances, overdraft :(
    open_date TEXT NOT NULL,
    FOREIGN KEY (branch_id) REFERENCES branches(branch_id)
);

-- junction table
CREATE TABLE customer_accounts (
    customer_id INTEGER NOT NULL,
    account_num INTEGER NOT NULL,
    ownership_type TEXT NOT NULL,
    PRIMARY KEY (customer_id, account_num),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (account_num) REFERENCES accounts(account_num)
);

CREATE TABLE transaction_history (
    trans_ID INTEGER PRIMARY KEY,
    account_num INTEGER NOT NULL,
    type TEXT NOT NULL,
    destination TEXT,
    amount REAL NOT NULL CHECK (amount > 0), -- no negative payments 
    date TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'Completed',
    FOREIGN KEY (account_num) REFERENCES accounts(account_num)
);


CREATE TABLE loans (
    loan_id INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    branch_id INTEGER NOT NULL,
    principal REAL NOT NULL CHECK (principal > 0), -- no negative loans (?)
    interest_rate REAL NOT NULL,
    term_mos INTEGER NOT NULL,
    start_date TEXT NOT NULL,
    rem_balance REAL NOT NULL CHECK (rem_balance >= 0), -- no owing negative amounts
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (branch_id) REFERENCES branches(branch_id)
);



-- view: total cash & debt
CREATE VIEW customer_summary AS
SELECT 
    c.customer_id, 
    c.firstname, 
    c.lastname,
    COALESCE(SUM(DISTINCT a.balance), 0) AS total_cash_balance,
    COALESCE((SELECT SUM(rem_balance) FROM loans l WHERE l.customer_id = c.customer_id), 0) AS total_loan_debt
FROM customers c
LEFT JOIN customer_accounts ca ON c.customer_id = ca.customer_id
LEFT JOIN accounts a ON ca.account_num = a.account_num
GROUP BY c.customer_id, c.firstname, c.lastname;

-- index: search acc & date for easier monthly statement
CREATE INDEX idx_trans_account_date ON transaction_history(account_num, date);