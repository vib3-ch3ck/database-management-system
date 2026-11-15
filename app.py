import sqlite3
import sys

#for image
import tkinter as tk
from PIL import Image, ImageTk
import os

DB_NAME = "dbms.db"

def get_db_connection():
    """Establish a connection to the SQLite database."""
    conn = sqlite3.connect(DB_NAME)
    conn.execute("PRAGMA foreign_keys = ON;") # Ensure FKs are enforced
    return conn

def print_header(title):
    print("\n" + "="*50)
    print(f" {title.center(48)} ")
    print("="*50)

def print_menu():
    print("\n--------------------------------")
    print("    SECOND HORIZON BANK MENU    ")
    print("--------------------------------")
    print("1. Customer Directory (Search/Browse)")
    print("2. View Customer Accounts (Related Data)")
    print("3. Add New Customer (Add Data)")
    print("4. Update Customer Phone Number (Update Data)")
    print("5. Branch Summary Report (Summary Report)")
    print("6. Transfer Funds (Transaction)")
    print("7. Exit")
    print("--------------------------------")


def search_customer():
    print_header("SEARCH CUSTOMER")
    last_name = input("Enter customer last name to search: ").strip()
    
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute("SELECT customer_id, firstname, lastname, email, phone FROM customers WHERE lastname LIKE ?", (f"%{last_name}%",))
        results = cursor.fetchall()
        
        if not results:
            print(f"No customers found.")
        else:
            print(f"\nFound {len(results)} customer(s):")
            print(f"{'ID':<5} | {'Name':<20} | {'Email':<25} | {'Phone':<12}") #show ssn? probably not...
            print("-" * 65)
            for row in results:
                print(f"{row[0]:<5} | {row[1] + ' ' + row[2]:<20} | {row[3]:<25} | {row[4]:<12}")
    finally:
        conn.close()


def view_customer_accounts():
    print_header("VIEW CUSTOMER ACCOUNTS")
    try:
        cust_id = int(input("Enter Customer ID: "))
    except ValueError:
        print("Error: Customer ID must be a number.")
        return

    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        # Multi-table join
        query = """
            SELECT c.firstname, c.lastname, a.account_num, a.acc_type, a.balance, ca.ownership_type
                FROM Customers c
                JOIN Customer_Accounts ca ON c.customer_id = ca.customer_id
                JOIN Accounts a ON ca.account_num = a.account_num
                WHERE c.customer_id = ?
        """
        
        cursor.execute(query, (cust_id,))
        results = cursor.fetchall()
        
        if not results:
            print(f"No accounts found.")
        else:
            print(f"\nAccounts for {results[0][0]} {results[0][1]}:")
            print(f"{'Account #':<12} | {'Type':<10} | {'Balance':<12} | {'Ownership':<15}")
            print("-" * 55)
            for row in results:
                print(f"{row[2]:<12} | {row[3]:<10} | ${row[4]:<11,.2f} | {row[5]:<15}")
    finally:
        conn.close()


def add_customer():
    print_header("ADD NEW CUSTOMER")
    first = input("First Name: ").strip()
    last = input("Last Name: ").strip()
    email = input("Email: ").strip()
    phone = input("Phone (XXX-XXXX): ").strip()
    ssn = input("SSN (XXX-XX-XXXX): ").strip()

    if not all([first, last, email, ssn]):
        print("Error: First name, last name, email, and SSN are required.")
        return

    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute("""
            INSERT INTO Customers (firstname, lastname, email, phone, ssn)
            VALUES (?, ?, ?, ?, ?)
        """, (first, last, email, phone, ssn))
        conn.commit()
        print(f"\nSuccess! Customer '{first} {last}' added with ID: {cursor.lastrowid}")
    except sqlite3.IntegrityError as e:
        print(f"\nDatabase Error: Could not add customer. {e}")
        print("(Hint: Email or SSN might already exist in the system)")
    finally:
        conn.close()


def update_phone():
    print_header("UPDATE CUSTOMER PHONE")
    
    while True:
        contact = input("Updating phone or email? (p/e): ").strip().lower()
        
        if contact == 'p':
            column_name = "phone"
            prompt_text = "new phone number"
        elif contact == 'e':
            column_name = "email"
            prompt_text = "new email address"
        else:
            print("Please choose 'p' or 'e'.")
            continue 
            
        break 

    
    try:
        cust_id = int(input("Enter Customer ID to update: "))
    except ValueError:
        print("Error: Customer ID must be a number.")
        return

    new_value = input(f"Enter {prompt_text}: ").strip()
    if not new_value:
        print(f"Error: {prompt_text} cannot be empty.")
        return

    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute("SELECT firstname, lastname FROM Customers WHERE customer_id = ?", (cust_id,))
        cust = cursor.fetchone()
        
        if not cust:
            print("Error: Customer ID not found.")
            return

        
        cursor.execute(f"UPDATE Customers SET {column_name} = ? WHERE customer_id = ?", (new_value, cust_id))
        conn.commit()
        print(f"{prompt_text.capitalize()} updated successfully.")
    finally:
        conn.close()



def branch_report():
    print_header("BRANCH FINANCIAL REPORT")
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        
        query = """
            SELECT b.name AS branch_name, 
                   COUNT(a.account_num) AS total_accounts, 
                   COALESCE(SUM(a.balance), 0) AS total_deposits
                FROM branches b
                LEFT JOIN accounts a ON b.branch_id = a.branch_id
                GROUP BY b.branch_id
                ORDER BY total_deposits DESC
        """
        cursor.execute(query)
        results = cursor.fetchall()
        
        print(f"{'Branch Name':<25} | {'Total Accounts':<15} | {'Total Deposits':<15}")
        print("-" * 60)
        for row in results:
            print(f"{row[0]:<25} | {row[1]:<15} | ${row[2]:<14,.2f}")
    finally:
        conn.close()


def transfer_funds():
    print_header("TRANSFER FUNDS")
    try:
        source_acc = int(input("Enter SOURCE Account Number: "))
        dest_acc = int(input("Enter DESTINATION Account Number: "))
        amount = float(input("Enter Amount to Transfer: $"))
    except ValueError:
        print("Error: Account numbers must be integers, amount must be a number.")
        return

    if amount <= 0:
        print("Error: Transfer amount must be greater than zero.")
        return

    conn = get_db_connection()
    cursor = conn.cursor()
    
    try:
        
        cursor.execute("SELECT balance, status FROM acounts WHERE account_num = ?", (source_acc,))
        source_data = cursor.fetchone()
        if not source_data:
            print("Error: Source account not found.")
            return
        if source_data[1] != 'Active':
             print("Error: Source account is not Active.")
             return
        if source_data[0] < amount:
            print(f"Error: Insufficient funds. Balance is ${source_data[0]:.2f}.")
            return

        
        cursor.execute("SELECT status FROM accounts WHERE account_num = ?", (dest_acc,))
        dest_data = cursor.fetchone()
        if not dest_data:
            print("Error: Destination account not found.")
            return
        if dest_data[0] != 'Active':
             print("Error: Destination account is not Active.")
             return

        
        conn.execute("BEGIN TRANSACTION;")
        
        # withdraw
        cursor.execute("UPDATE accounts SET balance = balance - ? WHERE account_num = ?", (amount, source_acc))
        # deposit
        cursor.execute("UPDATE accounts SET balance = balance + ? WHERE account_num = ?", (amount, dest_acc))
        
        
        cursor.execute("SELECT MAX(trans_ID) FROM transaction_history")
        max_id = cursor.fetchone()[0] or 0
        cursor.execute("""
            INSERT INTO transaction_history (trans_ID, account_num, type, destination, amount, date, status)
            VALUES (?, ?, 'Transfer', ?, ?, DATE('now'), 'Completed')
        """, (max_id + 1, source_acc, str(dest_acc), amount))

        conn.commit()
        print(f"\nTransfer successful.")

    except sqlite3.Error as e:
        conn.rollback()
        print(f"\nTransaction failed, data rolled back. Error: {e}")
    finally:
        conn.close()


def main():
    while True:
        print_menu()
        choice = input("Select an option (1-7): ").strip()
        
        if choice == '1':
            search_customer()
        elif choice == '2':
            view_customer_accounts()
        elif choice == '3':
            add_customer()
        elif choice == '4':
            update_phone()
        elif choice == '5':
            branch_report()
        elif choice == '6':
            transfer_funds()
        elif choice == '7':
            print("\nThank you for using Second Horizon Bank. Goodbye!") 
            sys.exit(0)
        else:
            print("Invalid selection. Please enter a number between 1 and 7.")

if __name__ == "__main__":
    main()