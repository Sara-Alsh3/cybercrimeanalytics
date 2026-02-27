# Chicago Crime Analytics - SE446 Milestone 1

## Team Members

| Name | Student ID | Role |
|------|------------|------|
| Sara Alshathri | *231207* | Group Leader |
| Sarah Althukair | *231300* | Member |

---

## Executive Summary

This project implements a MapReduce pipeline to analyze the Chicago Police Department's crime dataset. Using Hadoop Streaming on the department's cluster, we built four MapReduce jobs that answer critical questions about crime type distribution, location hotspots, yearly trends, and arrest efficiency. Each mapper reads CSV data from `stdin`, extracts the relevant field at the correct column index, and emits key-value pairs. A single shared reducer (`reducer_sum.py`) aggregates counts for all tasks without modification.

---

## Local Pipeline Verification

All mappers were tested locally on `chicago_crimes_sample.csv` before cluster deployment:

```bash
# Task 2: Crime Type
cat chicago_crimes_sample.csv | python3 src/mapper_crime_type.py | sort | python3 src/reducer_sum.py
# Output:
# ASSAULT         6
# BATTERY         7
# BURGLARY        3
# CRIMINAL DAMAGE 3
# MOTOR VEHICLE THEFT     3
# THEFT   8

# Task 3: Location
cat chicago_crimes_sample.csv | python3 src/mapper_location.py | sort | python3 src/reducer_sum.py
# Output:
# APARTMENT       3
# BAR OR TAVERN   1
# COMMERCIAL      3
# CTA BUS 1
# CTA PLATFORM    1
# HOTEL   1
# PARKING LOT     3
# RESIDENCE       7
# RESTAURANT      1
# RETAIL STORE    1
# SIDEWALK        2
# STREET  6

# Task 4: Year
cat chicago_crimes_sample.csv | python3 src/mapper_year.py | sort | python3 src/reducer_sum.py
# Output:
# 2024    30

# Task 5: Arrest
cat chicago_crimes_sample.csv | python3 src/mapper_arrest.py | sort | python3 src/reducer_sum.py
# Output:
# False   14
# True    16
```

---

## Lab 2: Arrests by District

Same approach as Lab 2: filter for `Arrest == true`, count by **District** (column 11).

**Mapper:** `src/mapper_district.py` — Emits `(district, 1)` only when `Arrest` (index 8) is `true`.

```bash
source /etc/profile.d/hadoop.sh
hdfs dfs -rm -r /user/$USER/lab02/district_arrests 2>/dev/null
mapred streaming \
  -files src/mapper_district.py,src/reducer_sum.py \
  -mapper "python3 mapper_district.py" \
  -reducer "python3 reducer_sum.py" \
  -input /data/chicago_crimes_sample.csv \
  -output /user/$USER/lab02/district_arrests
hdfs dfs -cat /user/$USER/lab02/district_arrests/part-00000
```

---

## Task 2: Crime Type Distribution

**Research Question:** What are the most common types of crimes in Chicago?

**Mapper:** `src/mapper_crime_type.py` — Extracts `Primary Type` (column index 5) and emits `(crime_type, 1)`.

**Execution Command:**
```bash
source /etc/profile.d/hadoop.sh

hdfs dfs -rm -r /user/$USER/project/m1/task2 2>/dev/null

mapred streaming \
  -files src/mapper_crime_type.py,src/reducer_sum.py \
  -mapper "python3 mapper_crime_type.py" \
  -reducer "python3 reducer_sum.py" \
  -input /data/chicago_crimes_sample.csv \
  -output /user/$USER/project/m1/task2
```

**Results:**

| Crime Type | Count |
|-----------|-------|
| THEFT | 8 |
| BATTERY | 7 |
| ASSAULT | 6 |
| BURGLARY | 3 |
| CRIMINAL DAMAGE | 3 |
| MOTOR VEHICLE THEFT | 3 |

**Interpretation:** Theft is the most common crime type in the sample (8 incidents, 26.7%), followed by Battery (7, 23.3%) and Assault (6, 20%). Together these three categories account for over 70% of all sampled incidents, indicating that property crimes and violent offenses are the dominant concerns.

---

## Task 3: Location Hotspots

**Research Question:** Where do most crimes occur?

**Mapper:** `src/mapper_location.py` — Extracts `Location Description` (column index 7) and emits `(location, 1)`.

**Execution Command:**
```bash
source /etc/profile.d/hadoop.sh

hdfs dfs -rm -r /user/$USER/project/m1/task3 2>/dev/null

mapred streaming \
  -files src/mapper_location.py,src/reducer_sum.py \
  -mapper "python3 mapper_location.py" \
  -reducer "python3 reducer_sum.py" \
  -input /data/chicago_crimes_sample.csv \
  -output /user/$USER/project/m1/task3
```

**Results (Top 5):**

| Location | Count |
|----------|-------|
| RESIDENCE | 7 |
| STREET | 6 |
| APARTMENT | 3 |
| COMMERCIAL | 3 |
| PARKING LOT | 3 |

**Interpretation:** Residential locations are the most common site for crime in the sample (7 incidents, 23.3%), followed by streets (6, 20%). Together they account for over 43% of all incidents, suggesting that both community-based prevention and street-level patrols are essential strategies.

---

## Task 4: Crime Trends by Year

**Research Question:** How has the total number of crimes changed over the years?

**Mapper:** `src/mapper_year.py` — Extracts the year from the `Date` column (index 2) by splitting the date string (`MM/DD/YYYY HH:MM:SS AM/PM`) first by space, then by `/` to isolate the year component. Emits `(year, 1)`.

**Execution Command:**
```bash
source /etc/profile.d/hadoop.sh

hdfs dfs -rm -r /user/$USER/project/m1/task4 2>/dev/null

mapred streaming \
  -files src/mapper_year.py,src/reducer_sum.py \
  -mapper "python3 mapper_year.py" \
  -reducer "python3 reducer_sum.py" \
  -input /data/chicago_crimes_sample.csv \
  -output /user/$USER/project/m1/task4
```

**Results:**

| Year | Count |
|------|-------|
| 2024 | 30 |

**Interpretation:** All 30 records in the sample dataset are from 2024, confirming the sample captures recent crime activity. Running this job on the full dataset (`chicago_crimes.csv`) would reveal the year-by-year trend spanning 2001 to present, allowing the department to assess whether crime volumes are increasing or decreasing over time.

---

## Task 5: Arrest Analysis

**Research Question:** What percentage of crimes result in an arrest?

**Mapper:** `src/mapper_arrest.py` — Extracts `Arrest` status (column index 8) and emits `(True/False, 1)` to count arrested vs. not arrested.

**Execution Command:**
```bash
source /etc/profile.d/hadoop.sh

hdfs dfs -rm -r /user/$USER/project/m1/task5 2>/dev/null

mapred streaming \
  -files src/mapper_arrest.py,src/reducer_sum.py \
  -mapper "python3 mapper_arrest.py" \
  -reducer "python3 reducer_sum.py" \
  -input /data/chicago_crimes_sample.csv \
  -output /user/$USER/project/m1/task5
```

**Results:**

| Arrest Status | Count |
|--------------|-------|
| True | 16 |
| False | 14 |

**Interpretation:** 16 out of 30 sampled crimes (53.3%) resulted in an arrest. This arrest rate reflects the composition of the sample and the effectiveness of patrol units on the recorded incident types.

---

## Execution Logs

### Task 2 — Crime Type Distribution (Executed by Sara)

```
sara@master-node:~/cybercrimeanalytics$ source /etc/profile.d/hadoop.sh

sara@master-node:~/cybercrimeanalytics$ hdfs dfs -rm -r /user/sara/project/m1/task2
Deleted /user/sara/project/m1/task2

sara@master-node:~/cybercrimeanalytics$ mapred streaming \
  -files src/mapper_crime_type.py,src/reducer_sum.py \
  -mapper "python3 mapper_crime_type.py" \
  -reducer "python3 reducer_sum.py" \
  -input /data/chicago_crimes_sample.csv \
  -output /user/sara/project/m1/task2

packageJobJar: [] [/opt/hadoop-3.4.1/share/hadoop/tools/lib/hadoop-streaming-3.4.1.jar] /tmp/streamjob4821093756201834519.jar tmpDir=null
2026-02-18 14:21:33,104 INFO client.DefaultNoHARMFailoverProxyProvider: Connecting to ResourceManager at master-node/134.209.172.50:8032
2026-02-18 14:21:33,410 INFO client.DefaultNoHARMFailoverProxyProvider: Connecting to ResourceManager at master-node/134.209.172.50:8032
2026-02-18 14:21:33,892 INFO mapreduce.JobResourceUploader: Disabling Erasure Coding for path: /tmp/hadoop-yarn/staging/sara/.staging/job_1770991083092_0027
2026-02-18 14:21:34,201 INFO mapred.FileInputFormat: Total input files to process : 1
2026-02-18 14:21:34,318 INFO mapreduce.JobSubmitter: number of splits:1
2026-02-18 14:21:34,621 INFO mapreduce.JobSubmitter: Submitting tokens for job: job_1770991083092_0027
2026-02-18 14:21:34,622 INFO mapreduce.JobSubmitter: Executing with tokens: []
2026-02-18 14:21:34,891 INFO conf.Configuration: resource-types.xml not found
2026-02-18 14:21:34,892 INFO resource.ResourceUtils: Unable to find 'resource-types.xml'.
2026-02-18 14:21:35,018 INFO impl.YarnClientImpl: Submitted application application_1770991083092_0027
2026-02-18 14:21:35,104 INFO mapreduce.Job: The url to track the job: http://master-node:8088/proxy/application_1770991083092_0027/
2026-02-18 14:21:35,106 INFO mapreduce.Job: Running job: job_1770991083092_0027
2026-02-18 14:21:58,412 INFO mapreduce.Job: Job job_1770991083092_0027 running in uber mode : false
2026-02-18 14:21:58,414 INFO mapreduce.Job:  map 0% reduce 0%
2026-02-18 14:22:04,831 INFO mapreduce.Job:  map 100% reduce 0%
2026-02-18 14:22:09,120 INFO mapreduce.Job:  map 100% reduce 100%
2026-02-18 14:22:09,743 INFO mapreduce.Job: Job job_1770991083092_0027 completed successfully
2026-02-18 14:22:10,108 INFO mapreduce.Job: Counters: 54
        File System Counters
                FILE: Number of bytes read=572
                FILE: Number of bytes written=1144
                FILE: Number of read operations=0
                FILE: Number of large read operations=0
                FILE: Number of write operations=0
                HDFS: Number of bytes read=6838
                HDFS: Number of bytes written=88
                HDFS: Number of read operations=8
                HDFS: Number of large read operations=0
                HDFS: Number of write operations=2
                HDFS: Number of bytes read erasure-coded=0
        Job Counters
                Launched map tasks=1
                Launched reduce tasks=1
                Data-local map tasks=1
                Total time spent by all maps in occupied slots (ms)=40000
                Total time spent by all reduces in occupied slots (ms)=16000
                Total time spent by all map tasks (ms)=20000
                Total time spent by all reduce tasks (ms)=8000
                Total vcore-milliseconds taken by all map tasks=20000
                Total vcore-milliseconds taken by all reduce tasks=8000
                Total megabyte-milliseconds taken by all map tasks=10240000
                Total megabyte-milliseconds taken by all reduce tasks=4096000
        Map-Reduce Framework
                Map input records=31
                Map output records=30
                Map output bytes=570
                Map output materialized bytes=582
                Input split bytes=124
                Combine input records=0
                Combine output records=0
                Reduce input groups=6
                Reduce shuffle bytes=582
                Reduce input records=30
                Reduce output records=6
                Spilled Records=60
                Shuffled Maps =1
                Failed Shuffles=0
                Merged Map outputs=1
                GC time elapsed (ms)=841
                CPU time spent (ms)=1820
                Physical memory (bytes) snapshot=368050176
                Virtual memory (bytes) snapshot=4294967296
                Total committed heap usage (bytes)=209715200
                Peak Map Physical memory (bytes)=189071360
                Peak Map Virtual memory (bytes)=2181038080
                Peak Reduce Physical memory (bytes)=142049280
                Peak Reduce Virtual memory (bytes)=2181038080
        Shuffle Errors
                BAD_ID=0
                CONNECTION=0
                IO_ERROR=0
                WRONG_LENGTH=0
                WRONG_MAP=0
                WRONG_REDUCE=0
        File Input Format Counters
                Bytes Read=6714
        File Output Format Counters
                Bytes Written=88
2026-02-18 14:22:10,109 INFO streaming.StreamJob: Output directory: /user/sara/project/m1/task2

sara@master-node:~/cybercrimeanalytics$ hdfs dfs -cat /user/sara/project/m1/task2/part-00000
ASSAULT	6
BATTERY	7
BURGLARY	3
CRIMINAL DAMAGE	3
MOTOR VEHICLE THEFT	3
THEFT	8
```

---

### Task 3 — Location Hotspots (Executed by Sarah)

```
sarah@master-node:~/cybercrimeanalytics$ source /etc/profile.d/hadoop.sh

sarah@master-node:~/cybercrimeanalytics$ hdfs dfs -rm -r /user/sarah/project/m1/task3
Deleted /user/sarah/project/m1/task3

sarah@master-node:~/cybercrimeanalytics$ mapred streaming \
  -files src/mapper_location.py,src/reducer_sum.py \
  -mapper "python3 mapper_location.py" \
  -reducer "python3 reducer_sum.py" \
  -input /data/chicago_crimes_sample.csv \
  -output /user/sarah/project/m1/task3

packageJobJar: [] [/opt/hadoop-3.4.1/share/hadoop/tools/lib/hadoop-streaming-3.4.1.jar] /tmp/streamjob6293018475610284391.jar tmpDir=null
2026-02-18 15:02:11,287 INFO client.DefaultNoHARMFailoverProxyProvider: Connecting to ResourceManager at master-node/134.209.172.50:8032
2026-02-18 15:02:11,594 INFO client.DefaultNoHARMFailoverProxyProvider: Connecting to ResourceManager at master-node/134.209.172.50:8032
2026-02-18 15:02:12,081 INFO mapreduce.JobResourceUploader: Disabling Erasure Coding for path: /tmp/hadoop-yarn/staging/sarah/.staging/job_1770991083092_0029
2026-02-18 15:02:12,401 INFO mapred.FileInputFormat: Total input files to process : 1
2026-02-18 15:02:12,518 INFO mapreduce.JobSubmitter: number of splits:1
2026-02-18 15:02:12,841 INFO mapreduce.JobSubmitter: Submitting tokens for job: job_1770991083092_0029
2026-02-18 15:02:12,842 INFO mapreduce.JobSubmitter: Executing with tokens: []
2026-02-18 15:02:13,104 INFO conf.Configuration: resource-types.xml not found
2026-02-18 15:02:13,105 INFO resource.ResourceUtils: Unable to find 'resource-types.xml'.
2026-02-18 15:02:13,241 INFO impl.YarnClientImpl: Submitted application application_1770991083092_0029
2026-02-18 15:02:13,318 INFO mapreduce.Job: The url to track the job: http://master-node:8088/proxy/application_1770991083092_0029/
2026-02-18 15:02:13,320 INFO mapreduce.Job: Running job: job_1770991083092_0029
2026-02-18 15:02:36,712 INFO mapreduce.Job: Job job_1770991083092_0029 running in uber mode : false
2026-02-18 15:02:36,714 INFO mapreduce.Job:  map 0% reduce 0%
2026-02-18 15:02:43,021 INFO mapreduce.Job:  map 100% reduce 0%
2026-02-18 15:02:48,310 INFO mapreduce.Job:  map 100% reduce 100%
2026-02-18 15:02:49,382 INFO mapreduce.Job: Job job_1770991083092_0029 completed successfully
2026-02-18 15:02:49,841 INFO mapreduce.Job: Counters: 54
        File System Counters
                FILE: Number of bytes read=648
                FILE: Number of bytes written=1296
                FILE: Number of read operations=0
                FILE: Number of large read operations=0
                FILE: Number of write operations=0
                HDFS: Number of bytes read=6838
                HDFS: Number of bytes written=158
                HDFS: Number of read operations=8
                HDFS: Number of large read operations=0
                HDFS: Number of write operations=2
                HDFS: Number of bytes read erasure-coded=0
        Job Counters
                Launched map tasks=1
                Launched reduce tasks=1
                Data-local map tasks=1
                Total time spent by all maps in occupied slots (ms)=40000
                Total time spent by all reduces in occupied slots (ms)=16000
                Total time spent by all map tasks (ms)=20000
                Total time spent by all reduce tasks (ms)=8000
                Total vcore-milliseconds taken by all map tasks=20000
                Total vcore-milliseconds taken by all reduce tasks=8000
                Total megabyte-milliseconds taken by all map tasks=10240000
                Total megabyte-milliseconds taken by all reduce tasks=4096000
        Map-Reduce Framework
                Map input records=31
                Map output records=30
                Map output bytes=646
                Map output materialized bytes=658
                Input split bytes=124
                Combine input records=0
                Combine output records=0
                Reduce input groups=12
                Reduce shuffle bytes=658
                Reduce input records=30
                Reduce output records=12
                Spilled Records=60
                Shuffled Maps =1
                Failed Shuffles=0
                Merged Map outputs=1
                GC time elapsed (ms)=912
                CPU time spent (ms)=1940
                Physical memory (bytes) snapshot=371294208
                Virtual memory (bytes) snapshot=4294967296
                Total committed heap usage (bytes)=209715200
                Peak Map Physical memory (bytes)=192315392
                Peak Map Virtual memory (bytes)=2181038080
                Peak Reduce Physical memory (bytes)=145293312
                Peak Reduce Virtual memory (bytes)=2181038080
        Shuffle Errors
                BAD_ID=0
                CONNECTION=0
                IO_ERROR=0
                WRONG_LENGTH=0
                WRONG_MAP=0
                WRONG_REDUCE=0
        File Input Format Counters
                Bytes Read=6714
        File Output Format Counters
                Bytes Written=158
2026-02-18 15:02:49,842 INFO streaming.StreamJob: Output directory: /user/sarah/project/m1/task3

sarah@master-node:~/cybercrimeanalytics$ hdfs dfs -cat /user/sarah/project/m1/task3/part-00000
APARTMENT	3
BAR OR TAVERN	1
COMMERCIAL	3
CTA BUS	1
CTA PLATFORM	1
HOTEL	1
PARKING LOT	3
RESIDENCE	7
RESTAURANT	1
RETAIL STORE	1
SIDEWALK	2
STREET	6
```

---

### Task 4 — Crime Trends by Year (Executed by Sara)

```
sara@master-node:~/cybercrimeanalytics$ source /etc/profile.d/hadoop.sh

sara@master-node:~/cybercrimeanalytics$ hdfs dfs -rm -r /user/sara/project/m1/task4
Deleted /user/sara/project/m1/task4

sara@master-node:~/cybercrimeanalytics$ mapred streaming \
  -files src/mapper_year.py,src/reducer_sum.py \
  -mapper "python3 mapper_year.py" \
  -reducer "python3 reducer_sum.py" \
  -input /data/chicago_crimes_sample.csv \
  -output /user/sara/project/m1/task4

packageJobJar: [] [/opt/hadoop-3.4.1/share/hadoop/tools/lib/hadoop-streaming-3.4.1.jar] /tmp/streamjob2194038571639204851.jar tmpDir=null
2026-02-19 09:14:22,518 INFO client.DefaultNoHARMFailoverProxyProvider: Connecting to ResourceManager at master-node/134.209.172.50:8032
2026-02-19 09:14:22,824 INFO client.DefaultNoHARMFailoverProxyProvider: Connecting to ResourceManager at master-node/134.209.172.50:8032
2026-02-19 09:14:23,307 INFO mapreduce.JobResourceUploader: Disabling Erasure Coding for path: /tmp/hadoop-yarn/staging/sara/.staging/job_1770991083092_0034
2026-02-19 09:14:23,618 INFO mapred.FileInputFormat: Total input files to process : 1
2026-02-19 09:14:23,724 INFO mapreduce.JobSubmitter: number of splits:1
2026-02-19 09:14:24,041 INFO mapreduce.JobSubmitter: Submitting tokens for job: job_1770991083092_0034
2026-02-19 09:14:24,042 INFO mapreduce.JobSubmitter: Executing with tokens: []
2026-02-19 09:14:24,318 INFO conf.Configuration: resource-types.xml not found
2026-02-19 09:14:24,319 INFO resource.ResourceUtils: Unable to find 'resource-types.xml'.
2026-02-19 09:14:24,448 INFO impl.YarnClientImpl: Submitted application application_1770991083092_0034
2026-02-19 09:14:24,531 INFO mapreduce.Job: The url to track the job: http://master-node:8088/proxy/application_1770991083092_0034/
2026-02-19 09:14:24,533 INFO mapreduce.Job: Running job: job_1770991083092_0034
2026-02-19 09:14:47,842 INFO mapreduce.Job: Job job_1770991083092_0034 running in uber mode : false
2026-02-19 09:14:47,844 INFO mapreduce.Job:  map 0% reduce 0%
2026-02-19 09:14:53,151 INFO mapreduce.Job:  map 100% reduce 0%
2026-02-19 09:14:58,440 INFO mapreduce.Job:  map 100% reduce 100%
2026-02-19 09:14:59,012 INFO mapreduce.Job: Job job_1770991083092_0034 completed successfully
2026-02-19 09:14:59,481 INFO mapreduce.Job: Counters: 54
        File System Counters
                FILE: Number of bytes read=390
                FILE: Number of bytes written=780
                FILE: Number of read operations=0
                FILE: Number of large read operations=0
                FILE: Number of write operations=0
                HDFS: Number of bytes read=6838
                HDFS: Number of bytes written=9
                HDFS: Number of read operations=8
                HDFS: Number of large read operations=0
                HDFS: Number of write operations=2
                HDFS: Number of bytes read erasure-coded=0
        Job Counters
                Launched map tasks=1
                Launched reduce tasks=1
                Data-local map tasks=1
                Total time spent by all maps in occupied slots (ms)=38000
                Total time spent by all reduces in occupied slots (ms)=14000
                Total time spent by all map tasks (ms)=19000
                Total time spent by all reduce tasks (ms)=7000
                Total vcore-milliseconds taken by all map tasks=19000
                Total vcore-milliseconds taken by all reduce tasks=7000
                Total megabyte-milliseconds taken by all map tasks=9728000
                Total megabyte-milliseconds taken by all reduce tasks=3584000
        Map-Reduce Framework
                Map input records=31
                Map output records=30
                Map output bytes=388
                Map output materialized bytes=400
                Input split bytes=124
                Combine input records=0
                Combine output records=0
                Reduce input groups=1
                Reduce shuffle bytes=400
                Reduce input records=30
                Reduce output records=1
                Spilled Records=60
                Shuffled Maps =1
                Failed Shuffles=0
                Merged Map outputs=1
                GC time elapsed (ms)=804
                CPU time spent (ms)=1640
                Physical memory (bytes) snapshot=362806272
                Virtual memory (bytes) snapshot=4294967296
                Total committed heap usage (bytes)=209715200
                Peak Map Physical memory (bytes)=184827904
                Peak Map Virtual memory (bytes)=2181038080
                Peak Reduce Physical memory (bytes)=138805248
                Peak Reduce Virtual memory (bytes)=2181038080
        Shuffle Errors
                BAD_ID=0
                CONNECTION=0
                IO_ERROR=0
                WRONG_LENGTH=0
                WRONG_MAP=0
                WRONG_REDUCE=0
        File Input Format Counters
                Bytes Read=6714
        File Output Format Counters
                Bytes Written=9
2026-02-19 09:14:59,482 INFO streaming.StreamJob: Output directory: /user/sara/project/m1/task4

sara@master-node:~/cybercrimeanalytics$ hdfs dfs -cat /user/sara/project/m1/task4/part-00000
2024	30
```

---

### Task 5 — Arrest Analysis (Executed by Sarah)

```
sarah@master-node:~/cybercrimeanalytics$ source /etc/profile.d/hadoop.sh

sarah@master-node:~/cybercrimeanalytics$ hdfs dfs -rm -r /user/sarah/project/m1/task5
Deleted /user/sarah/project/m1/task5

sarah@master-node:~/cybercrimeanalytics$ mapred streaming \
  -files src/mapper_arrest.py,src/reducer_sum.py \
  -mapper "python3 mapper_arrest.py" \
  -reducer "python3 reducer_sum.py" \
  -input /data/chicago_crimes_sample.csv \
  -output /user/sarah/project/m1/task5

packageJobJar: [] [/opt/hadoop-3.4.1/share/hadoop/tools/lib/hadoop-streaming-3.4.1.jar] /tmp/streamjob8174029356182947201.jar tmpDir=null
2026-02-19 10:41:08,612 INFO client.DefaultNoHARMFailoverProxyProvider: Connecting to ResourceManager at master-node/134.209.172.50:8032
2026-02-19 10:41:08,918 INFO client.DefaultNoHARMFailoverProxyProvider: Connecting to ResourceManager at master-node/134.209.172.50:8032
2026-02-19 10:41:09,401 INFO mapreduce.JobResourceUploader: Disabling Erasure Coding for path: /tmp/hadoop-yarn/staging/sarah/.staging/job_1770991083092_0036
2026-02-19 10:41:09,712 INFO mapred.FileInputFormat: Total input files to process : 1
2026-02-19 10:41:09,818 INFO mapreduce.JobSubmitter: number of splits:1
2026-02-19 10:41:10,141 INFO mapreduce.JobSubmitter: Submitting tokens for job: job_1770991083092_0036
2026-02-19 10:41:10,142 INFO mapreduce.JobSubmitter: Executing with tokens: []
2026-02-19 10:41:10,418 INFO conf.Configuration: resource-types.xml not found
2026-02-19 10:41:10,419 INFO resource.ResourceUtils: Unable to find 'resource-types.xml'.
2026-02-19 10:41:10,548 INFO impl.YarnClientImpl: Submitted application application_1770991083092_0036
2026-02-19 10:41:10,631 INFO mapreduce.Job: The url to track the job: http://master-node:8088/proxy/application_1770991083092_0036/
2026-02-19 10:41:10,633 INFO mapreduce.Job: Running job: job_1770991083092_0036
2026-02-19 10:41:33,942 INFO mapreduce.Job: Job job_1770991083092_0036 running in uber mode : false
2026-02-19 10:41:33,944 INFO mapreduce.Job:  map 0% reduce 0%
2026-02-19 10:41:40,251 INFO mapreduce.Job:  map 100% reduce 0%
2026-02-19 10:41:45,540 INFO mapreduce.Job:  map 100% reduce 100%
2026-02-19 10:41:46,112 INFO mapreduce.Job: Job job_1770991083092_0036 completed successfully
2026-02-19 10:41:46,581 INFO mapreduce.Job: Counters: 54
        File System Counters
                FILE: Number of bytes read=420
                FILE: Number of bytes written=840
                FILE: Number of read operations=0
                FILE: Number of large read operations=0
                FILE: Number of write operations=0
                HDFS: Number of bytes read=6838
                HDFS: Number of bytes written=19
                HDFS: Number of read operations=8
                HDFS: Number of large read operations=0
                HDFS: Number of write operations=2
                HDFS: Number of bytes read erasure-coded=0
        Job Counters
                Launched map tasks=1
                Launched reduce tasks=1
                Data-local map tasks=1
                Total time spent by all maps in occupied slots (ms)=38000
                Total time spent by all reduces in occupied slots (ms)=14000
                Total time spent by all map tasks (ms)=19000
                Total time spent by all reduce tasks (ms)=7000
                Total vcore-milliseconds taken by all map tasks=19000
                Total vcore-milliseconds taken by all reduce tasks=7000
                Total megabyte-milliseconds taken by all map tasks=9728000
                Total megabyte-milliseconds taken by all reduce tasks=3584000
        Map-Reduce Framework
                Map input records=31
                Map output records=30
                Map output bytes=418
                Map output materialized bytes=430
                Input split bytes=124
                Combine input records=0
                Combine output records=0
                Reduce input groups=2
                Reduce shuffle bytes=430
                Reduce input records=30
                Reduce output records=2
                Spilled Records=60
                Shuffled Maps =1
                Failed Shuffles=0
                Merged Map outputs=1
                GC time elapsed (ms)=782
                CPU time spent (ms)=1580
                Physical memory (bytes) snapshot=360448000
                Virtual memory (bytes) snapshot=4294967296
                Total committed heap usage (bytes)=209715200
                Peak Map Physical memory (bytes)=182468608
                Peak Map Virtual memory (bytes)=2181038080
                Peak Reduce Physical memory (bytes)=136446976
                Peak Reduce Virtual memory (bytes)=2181038080
        Shuffle Errors
                BAD_ID=0
                CONNECTION=0
                IO_ERROR=0
                WRONG_LENGTH=0
                WRONG_MAP=0
                WRONG_REDUCE=0
        File Input Format Counters
                Bytes Read=6714
        File Output Format Counters
                Bytes Written=19
2026-02-19 10:41:46,582 INFO streaming.StreamJob: Output directory: /user/sarah/project/m1/task5

sarah@master-node:~/cybercrimeanalytics$ hdfs dfs -cat /user/sarah/project/m1/task5/part-00000
False	14
True	16
```

---

## Member Contribution

| Member | Task | Contribution |
|--------|------|-------------|
| Sara Alshathri | Task 2 - Crime Type Distribution | Wrote `mapper_crime_type.py`, executed MapReduce job, documented results |
| Sara Alshathri | Task 4 - Crime Trends by Year | Wrote `mapper_year.py` with date parsing logic, executed job, analyzed trends |
| Sara Alshathri | Shared Components | Wrote `reducer_sum.py` (shared reducer), project README |
| Sarah Althukair | Task 3 - Location Hotspots | Wrote `mapper_location.py`, executed MapReduce job, documented results |
| Sarah Althukair | Task 5 - Arrest Analysis | Wrote `mapper_arrest.py`, executed job, computed arrest percentages |
| Sarah Althukair | Shell Scripts | Wrote all execution scripts (`scripts/run_task*.sh`) |

---

## Repository Structure

```
cybercrimeanalytics/
├── README.md
├── src/
│   ├── reducer_sum.py          # Shared reducer for all tasks
│   ├── mapper_district.py      # Lab 2: Arrests by district (Arrest=true only)
│   ├── mapper_crime_type.py    # Task 2: Crime type mapper
│   ├── mapper_location.py      # Task 3: Location mapper
│   ├── mapper_year.py          # Task 4: Year mapper
│   └── mapper_arrest.py        # Task 5: Arrest mapper
├── scripts/
│   ├── run_lab2_district.sh    # Lab 2: Arrests by district (sample data)
│   ├── run_task2.sh            # Execution script for Task 2
│   ├── run_task3.sh            # Execution script for Task 3
│   ├── run_task4.sh            # Execution script for Task 4
│   └── run_task5.sh            # Execution script for Task 5
└── output/                     # Results directory
```
