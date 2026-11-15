.mode box
.nullvalue NULL

PRAGMA foreign_keys = ON;


-- data from:
-- "hey chatgpt give me a sample dataset in csv format for financial info given this erd"
-- Note: it did not do the inserts for me, just gave the data in a csv format that i copy/pasted
--      i did include the csv in my submission, i also copy/pasted the data there for clarity

INSERT INTO branches (branch_id, name, phone, address, manager) VALUES
(1, 'Downtown Branch', '555-0101', '100 Main St, Metropolis', 'Sarah Connor'),
(2, 'Northside Branch', '555-0102', '450 North Ave, Metropolis', 'James Smith'),
(3, 'West End Branch', '555-0201', '88 West Blvd, Gotham', 'Linda Wright'),
(4, 'Eastside Branch', '555-0202', '12 East Rd, Gotham', 'Michael Chang');

INSERT INTO customers (customer_id, firstname, lastname, email, phone, ssn) VALUES
(1, 'Alice', 'Smith', 'alice.smith@email.com', '555-1111', '000-11-2222'),
(2, 'Bob', 'Jones', 'bob.jones@email.com', '555-2222', '000-22-3333'),
(3, 'Charlie', 'Brown', 'charlie.b@email.com', '555-3333', '000-33-4444'),
(4, 'Diana', 'Prince', 'diana.prince@email.com', '555-4444', '000-44-5555'),
(5, 'Evan', 'Wright', 'evan.w@email.com', '555-5555', '000-55-6666'),
(6, 'Fiona', 'Gallagher', 'fiona.g@email.com', '555-6666', '000-66-7777');


INSERT INTO accounts (account_num, branch_id, acc_type, balance, open_date) VALUES
(1001, 1, 'Checking', 2500.50, '2022-01-15'),
(1002, 1, 'Savings', 15000.00, '2022-01-15'),
(1003, 2, 'Checking', 850.25, '2022-03-10'),
(1004, 2, 'Savings', 0.00, '2023-05-01'), 
(1005, 3, 'Checking', 4200.00, '2021-11-20'),
(1006, 3, 'Savings', 50000.00, '2021-11-20'),
(1007, 4, 'Checking', 120.75, '2023-08-05'),
(1008, 1, 'Savings', 7500.00, '2020-05-10');


INSERT INTO customer_accounts (customer_id, account_num, ownership_type) VALUES
(1, 1001, 'Primary'),
(2, 1001, 'Joint'),      -- 1 & 2 (alice and bob) have a joint acc, 1001
(1, 1002, 'Primary'),
(3, 1003, 'Primary'),
(4, 1005, 'Primary'),
(4, 1006, 'Primary'),
(5, 1007, 'Primary'),
(6, 1008, 'Primary'),
(3, 1004, 'Authorized'); -- 3 is authorized on 1004


INSERT INTO transaction_history (trans_ID, account_num, type, destination, amount, date, status) VALUES
(1, 1001, 'Deposit', 'Payroll', 1500.00, '2023-09-01', 'Completed'),
(2, 1001, 'Payment', 'Electric Company', 45.50, '2023-09-02', 'Completed'),
(3, 1001, 'Withdrawal', 'ATM', 100.00, '2023-09-05', 'Completed'),
(4, 1002, 'Transfer', '1001', 500.00, '2023-09-06', 'Completed'),
(5, 1003, 'Deposit', 'Payroll', 2000.00, '2023-09-07', 'Completed'),
(6, 1003, 'Payment', 'Rent', 1200.00, '2023-09-08', 'Completed'),
(7, 1005, 'Deposit', 'Freelance', 3000.00, '2023-09-10', 'Completed'),
(8, 1005, 'Transfer', '1006', 1000.00, '2023-09-12', 'Completed'),
(9, 1006, 'Deposit', 'From 1005', 1000.00, '2023-09-12', 'Completed'),
(10, 1007, 'Deposit', 'Payroll', 500.00, '2023-09-15', 'Completed'),
(11, 1007, 'Payment', 'Internet', 60.00, '2023-09-16', 'Completed'),
(12, 1001, 'Payment', 'Online Store', 200.00, '2023-09-18', 'Pending'),
(13, 1004, 'Payment', 'Restaurant', 150.00, '2023-09-20', 'Completed'),
(14, 1003, 'Withdrawal', 'ATM', 50.00, '2023-09-22', 'Completed'),
(15, 1001, 'Deposit', 'Payroll', 1500.00, '2023-09-29', 'Completed'),
(16, 1002, 'Deposit', 'Interest', 200.00, '2023-09-30', 'Completed'),
(17, 1005, 'Payment', 'Car Loan', 450.00, '2023-10-01', 'Completed'),
(18, 1006, 'Transfer', '1005', 500.00, '2023-10-02', 'Completed'),
(19, 1007, 'Payment', 'Grocery Store', 150.25, '2023-10-03', 'Completed'),
(20, 1001, 'Withdrawal', 'ATM', 60.00, '2023-10-05', 'Completed'),
(21, 1003, 'Deposit', 'Refund', 25.50, '2023-10-06', 'Completed'),
(22, 1008, 'Withdrawal', 'ATM', 300.00, '2023-10-07', 'Completed');

INSERT INTO loans (loan_id, customer_id, branch_id, principal, interest_rate, term_mos, start_date, rem_balance) VALUES
(1, 1, 1, 20000.00, 5.5, 60, '2023-01-10', 17500.00),
(2, 3, 2, 150000.00, 6.2, 360, '2021-05-15', 142000.00),
(3, 4, 3, 5000.00, 4.0, 12, '2022-08-01', 0.00), -- paid off
(4, 5, 4, 25000.00, 7.1, 48, '2023-02-20', 21000.00),
(5, 1, 1, 10000.00, 5.0, 36, '2023-06-15', 8500.00),
(6, 6, 2, 3000.00, 8.5, 24, '2023-09-01', 2750.00);

