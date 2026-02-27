#!/usr/bin/env python3
"""
Mapper: Location Hotspots (Task 3)
Extracts the Location Description (index 7) from each crime record.
Emits (location, 1) for counting.
"""
import sys
import csv

reader = csv.reader(sys.stdin)

for row in reader:
    try:
        if len(row) < 8:
            continue
        # Skip header row
        if row[0].strip() == 'ID':
            continue
        location = row[7].strip()
        if location:
            print(f"{location}\t1")
    except Exception:
        continue
