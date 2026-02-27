#!/usr/bin/env python3
"""
Mapper: Arrests by District (Lab 2)
Filters for Arrest == true (index 8), then emits (District, 1) using index 11.
"""
import sys
import csv

reader = csv.reader(sys.stdin)

for row in reader:
    try:
        if len(row) < 12:
            continue
        # Skip header row
        if row[0].strip() == 'ID':
            continue
        arrest_status = row[8].strip().lower()
        district = row[11].strip()
        if arrest_status == 'true' and district:
            print(f"{district}\t1")
    except Exception:
        continue
