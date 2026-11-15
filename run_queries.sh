#!/bin/bash

DB="dbms.db"

echo "Recreating database..."

rm -f "$DB"

sqlite3 "$DB" < schema.sql
if [ $? -ne 0 ]; then
    echo "Error: Failed to create schema."
    exit 1
fi
sqlite3 "$DB" < insert_data.sql
if [ $? -ne 0 ]; then
    echo "Error: Failed to insert data."
    exit 1
fi

echo
echo "Running queries..."

sqlite3 -header -column "$DB" < queries.sql

echo
echo "Running transaction..."

sqlite3 -bail "$DB" < transaction.sql
status=$?

if [ "$status" -eq 0 ]; then
    echo "Transaction completed successfully."
else
    echo "Transaction failed."
    echo "Uncommitted changes were rolled back."
fi

echo
echo "Done."
