#!/usr/bin/env python3
"""
Mapper: Crime Type Distribution (Task 2)
Extracts the Primary Type (index 5) from each crime record.
Emits (crime_type, 1) for counting.
"""
import sys
import csv

reader = csv.reader(sys.stdin)

for row in reader:
    try:
        if len(row) < 6:
            continue
        # Skip header row
        if row[0].strip() == 'ID':
            continue
        crime_type = row[5].strip()
        if crime_type:
            print(f"{crime_type}\t1")
    except Exception:
        continue
