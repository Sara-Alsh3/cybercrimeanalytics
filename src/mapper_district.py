#!/usr/bin/env python3
"""
Mapper: Lab 2 - Arrests by District
Extracts District (index 11) only when Arrest (index 8) is true.
Emits (district, 1) for counting arrests per district.
"""
import sys
import csv

ARREST_IDX = 8
DISTRICT_IDX = 11

reader = csv.reader(sys.stdin)

for row in reader:
    try:
        if len(row) <= DISTRICT_IDX:
            continue
        if row[0].strip() == 'ID':
            continue
        arrest_status = row[ARREST_IDX].strip().lower()
        district = row[DISTRICT_IDX].strip()
        if arrest_status == 'true' and district:
            print(f"{district}\t1")
    except Exception:
        continue
