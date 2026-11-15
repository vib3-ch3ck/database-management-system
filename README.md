# Second Horizon Bank Management System

## Overview:
- A bank management system to handle customers, accounts, and bank branch financial data.
- Intended for employees of the bank, such as tellers or advisors.
- **Functionality:** information on customers, accounts, branches, with summary reports and transactions
- No known issues, aside from the not fully comprehensive information stored in the database (hurts practical use, still works as a proof of concept).

## 1. Programming Language and Version
- **Language:** Python 3.6 or higher

## 2. Required Packages and Libraries
This application uses only Python's standard built-in libraries (`sqlite3` and `sys`). 
- **No external packages or `pip install` commands are required.**
- **Database:** You will need SQLite3 installed on your system (standard on Mac/Linux, and easily downloadable for Windows).

## 3. Database Connection Configuration
The application connects to a local SQLite database file named `dbms.db`. If needed, it will be created when the script is run.
- **Configuration:** The connection is configured at the top of `app.py` via the variable `DB_NAME = "dbms.db"`.
- **Location:** The `dbms.db` file must be in the exact same directory as `app.py`.
- **Foreign Keys:** The application automatically enforces foreign key constraints via `PRAGMA foreign_keys = ON;` upon every connection.

## 4. Setup and Start Instructions
Follow these steps in order to recreate the database and run the application:

**Step 1: Recreate the Database**
Open your terminal, navigate to the project folder, and run the provided bash script. This will build the schema, insert the sample data, and run the queries.
```bash
bash run_queries.sh
```

## 5. Six Operations
- **Search:** Option 1 in the command line menu, search by known customer last name
- **Related Data:** Option 2 in the command line menu, enter customer ID (1-n) for all associated accounts
- **Add Data:** OPtion 3 in the command line menu, follow prompts to enter customer data
- **Update Data:** Option 4 in the command line menu, follow prompts to update data
- **Summary Report:** Option 5 in the command line menu, provides a summary for all branches
- **Transaction:** Option 6 in the command line menu, enter source, destination, and amount to be transferred between accounts