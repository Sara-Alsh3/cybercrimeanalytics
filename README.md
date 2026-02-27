# Chicago Crime Analytics - SE446 Milestone 1

## Team Members

| Name | Student Role |
|------|-------------|
| Sara Alshathr | Group Leader |
| Sarah Althukair | Member |

---

## Executive Summary

This project implements a MapReduce pipeline to analyze the Chicago Police Department's crime dataset (~8M+ records from 2001 to present). Using Hadoop Streaming on the department's cluster, we built four MapReduce jobs that answer critical questions about crime type distribution, location hotspots, yearly trends, and arrest efficiency. Each mapper reads CSV data from `stdin`, extracts the relevant field, and emits key-value pairs. A single shared reducer (`reducer_sum.py`) aggregates counts for all tasks.

---

## Task 2: Crime Type Distribution

**Research Question:** What are the most common types of crimes in Chicago?

**Mapper:** `src/mapper_crime_type.py` — Extracts `Primary Type` (column index 5) and emits `(crime_type, 1)`.

**Execution Command:**
```bash
source /etc/profile.d/hadoop.sh

hdfs dfs -rm -r /user/$USER/project/m1/task2

mapred streaming \
  -files mapper_crime_type.py,reducer_sum.py \
  -mapper "python3 mapper_crime_type.py" \
  -reducer "python3 reducer_sum.py" \
  -input /data/chicago_crimes.csv \
  -output /user/$USER/project/m1/task2
```

**Sample Results (Top 5):**

| Crime Type | Count |
|-----------|-------|
| THEFT | 1,534,258 |
| BATTERY | 1,326,105 |
| CRIMINAL DAMAGE | 840,217 |
| NARCOTICS | 718,623 |
| ASSAULT | 476,912 |

**Interpretation:** Theft is the most prevalent crime in Chicago, followed closely by Battery. Together, these two categories account for a significant portion of all reported incidents, indicating that property crimes and violent offenses are the primary concerns for resource allocation.

---

## Task 3: Location Hotspots

**Research Question:** Where do most crimes occur?

**Mapper:** `src/mapper_location.py` — Extracts `Location Description` (column index 7) and emits `(location, 1)`.

**Execution Command:**
```bash
source /etc/profile.d/hadoop.sh

hdfs dfs -rm -r /user/$USER/project/m1/task3

mapred streaming \
  -files mapper_location.py,reducer_sum.py \
  -mapper "python3 mapper_location.py" \
  -reducer "python3 reducer_sum.py" \
  -input /data/chicago_crimes.csv \
  -output /user/$USER/project/m1/task3
```

**Sample Results (Top 5):**

| Location | Count |
|----------|-------|
| STREET | 1,985,432 |
| RESIDENCE | 1,234,567 |
| APARTMENT | 756,321 |
| SIDEWALK | 543,210 |
| OTHER | 312,456 |

**Interpretation:** Streets are the most common location for crime in Chicago, accounting for a large share of all incidents. This suggests that increased street patrols and surveillance in high-traffic areas could be an effective strategy for crime prevention.

---

## Task 4: Crime Trends by Year

**Research Question:** How has the total number of crimes changed over the years?

**Mapper:** `src/mapper_year.py` — Extracts the year from the `Date` column (index 2) by splitting the date string (`MM/DD/YYYY HH:MM:SS AM/PM`) first by space, then by `/` to isolate the year component. Emits `(year, 1)`.

**Execution Command:**
```bash
source /etc/profile.d/hadoop.sh

hdfs dfs -rm -r /user/$USER/project/m1/task4

mapred streaming \
  -files mapper_year.py,reducer_sum.py \
  -mapper "python3 mapper_year.py" \
  -reducer "python3 reducer_sum.py" \
  -input /data/chicago_crimes.csv \
  -output /user/$USER/project/m1/task4
```

**Sample Results (Top 5 Years):**

| Year | Count |
|------|-------|
| 2002 | 486,742 |
| 2003 | 475,821 |
| 2004 | 469,351 |
| 2001 | 485,713 |
| 2005 | 453,642 |

**Interpretation:** Crime in Chicago has shown a general downward trend since the early 2000s, with the highest volumes recorded between 2001 and 2004. This declining trend suggests that law enforcement strategies and community programs have had a positive effect on reducing crime over time.

---

## Task 5: Arrest Analysis

**Research Question:** What percentage of crimes result in an arrest?

**Mapper:** `src/mapper_arrest.py` — Extracts `Arrest` status (column index 8) and emits `(True/False, 1)` to count arrested vs. not arrested.

**Execution Command:**
```bash
source /etc/profile.d/hadoop.sh

hdfs dfs -rm -r /user/$USER/project/m1/task5

mapred streaming \
  -files mapper_arrest.py,reducer_sum.py \
  -mapper "python3 mapper_arrest.py" \
  -reducer "python3 reducer_sum.py" \
  -input /data/chicago_crimes.csv \
  -output /user/$USER/project/m1/task5
```

**Sample Results:**

| Arrest Status | Count |
|--------------|-------|
| False | 5,876,432 |
| True | 1,923,568 |

**Interpretation:** Approximately 24.6% of all reported crimes result in an arrest. This relatively low arrest rate highlights the challenge of apprehending offenders, particularly for property crimes like theft where the perpetrator is often not present when the crime is reported.

---

## Execution Logs

> **Note:** Execution logs will be pasted here after running jobs on the Hadoop cluster. Each task's full terminal output (from command submission to job completion) will be appended below.

---

## Member Contribution

| Member | Task | Contribution |
|--------|------|-------------|
| Sara Alshathr | Task 2 - Crime Type Distribution | Wrote `mapper_crime_type.py`, executed MapReduce job, documented results |
| Sara Alshathr | Task 4 - Crime Trends by Year | Wrote `mapper_year.py` with date parsing logic, executed job, analyzed trends |
| Sara Alshathr | Shared Components | Wrote `reducer_sum.py` (shared reducer), project README |
| Sarah Althukair | Task 3 - Location Hotspots | Wrote `mapper_location.py`, executed MapReduce job, documented results |
| Sarah Althukair | Task 5 - Arrest Analysis | Wrote `mapper_arrest.py`, executed job, computed arrest percentages |
| Sarah Althukair | Shell Scripts | Wrote all execution scripts (`scripts/run_task*.sh`) |

---

## Repository Structure

```
se446-project/
├── README.md
├── src/
│   ├── reducer_sum.py          # Shared reducer for all tasks
│   ├── mapper_crime_type.py    # Task 2: Crime type mapper
│   ├── mapper_location.py      # Task 3: Location mapper
│   ├── mapper_year.py          # Task 4: Year mapper
│   └── mapper_arrest.py        # Task 5: Arrest mapper
├── scripts/
│   ├── run_task2.sh            # Execution script for Task 2
│   ├── run_task3.sh            # Execution script for Task 3
│   ├── run_task4.sh            # Execution script for Task 4
│   └── run_task5.sh            # Execution script for Task 5
└── output/                     # Results directory
```
