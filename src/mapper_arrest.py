#!/usr/bin/env python3
"""
Mapper: Arrest Analysis (Task 5)
Extracts the Arrest status (index 8) from each crime record.
Emits (arrest_status, 1) for counting True vs False.
"""
import sys
import csv

reader = csv.reader(sys.stdin)

for row in reader:
    try:
        if len(row) < 9:
            continue
        # Skip header row
        if row[0].strip() == 'ID':
            continue
        arrest = row[8].strip().lower()
        if arrest in ('true', 'false'):
            print(f"{arrest.capitalize()}\t1")
    except Exception:
        continue
