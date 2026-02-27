#!/usr/bin/env python3
"""
Mapper: Crime Trends by Year (Task 4)
Extracts the Year from the Date column (index 2).
Date format: MM/DD/YYYY HH:MM:SS AM/PM
Emits (year, 1) for counting.
"""
import sys
import csv

reader = csv.reader(sys.stdin)

for row in reader:
    try:
        if len(row) < 3:
            continue
        # Skip header row
        if row[0].strip() == 'ID':
            continue
        date_str = row[2].strip()
        # Split by space to get date part, then by / to get year
        date_part = date_str.split(' ')[0]
        year = date_part.split('/')[2]
        if year:
            print(f"{year}\t1")
    except Exception:
        continue
