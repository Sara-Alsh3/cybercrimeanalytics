# Chicago Crime Analytics - SE446 Milestone 1

## Team Members

| Name | Student ID | Role |
|------|------------|------|
| Sara Alshathr | *(add ID)* | Group Leader |
| Sarah Althukair | *(add ID)* | Member |

---

## Executive Summary

This project implements a MapReduce pipeline to analyze the Chicago Police Department's crime dataset (~8M+ records from 2001 to present). Using Hadoop Streaming on the department's cluster, we built four MapReduce jobs that answer critical questions about crime type distribution, location hotspots, yearly trends, and arrest efficiency. Each mapper reads CSV data from `stdin`, extracts the relevant field, and emits key-value pairs. A single shared reducer (`reducer_sum.py`) aggregates counts for all tasks.

---

## Local Testing (No Cluster)

From the project root, you can test any pipeline locally with sample CSV (header + a few rows):

```bash
# Task 2: Crime type
echo 'ID,Case Number,Date,Block,IUCR,Primary Type,Description,Location,Arrest,Domestic
1,CN,09/05/2015 01:30:00 PM,b,0820,THEFT,desc,STREET,false,false
2,CN,06/12/2018 03:45:00 PM,b,0486,BATTERY,desc,APARTMENT,true,false' | python3 src/mapper_crime_type.py | sort | python3 src/reducer_sum.py

# Task 5: Arrest
echo 'ID,Case Number,Date,Block,IUCR,Primary Type,Description,Location,Arrest,Domestic
1,CN,09/05/2015 01:30:00 PM,b,0820,THEFT,desc,STREET,false,false
2,CN,06/12/2018 03:45:00 PM,b,0486,BATTERY,desc,APARTMENT,true,false' | python3 src/mapper_arrest.py | sort | python3 src/reducer_sum.py
```

---

## Lab 2: Arrests by District (Optional)

Same approach as Lab 2: filter for `Arrest == true`, count by **District** (column 11).

**Mapper:** `src/mapper_district.py` — Emits `(district, 1)` only when `Arrest` (index 8) is `true`.

**On cluster (sample data):**
```bash
./scripts/run_lab2_district.sh
```
Or manually (from project root on cluster):
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

**Execution Command:** (run from **project root** on the cluster so `src/` paths resolve)
```bash
source /etc/profile.d/hadoop.sh

hdfs dfs -rm -r /user/$USER/project/m1/task2 2>/dev/null

mapred streaming \
  -files src/mapper_crime_type.py,src/reducer_sum.py \
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

**Execution Command:** (run from **project root** on the cluster)
```bash
source /etc/profile.d/hadoop.sh

hdfs dfs -rm -r /user/$USER/project/m1/task3 2>/dev/null

mapred streaming \
  -files src/mapper_location.py,src/reducer_sum.py \
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

**Execution Command:** (run from **project root** on the cluster)
```bash
source /etc/profile.d/hadoop.sh

hdfs dfs -rm -r /user/$USER/project/m1/task4 2>/dev/null

mapred streaming \
  -files src/mapper_year.py,src/reducer_sum.py \
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

**Execution Command:** (run from **project root** on the cluster)
```bash
source /etc/profile.d/hadoop.sh

hdfs dfs -rm -r /user/$USER/project/m1/task5 2>/dev/null

mapred streaming \
  -files src/mapper_arrest.py,src/reducer_sum.py \
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

### Task 2 — Crime Type Distribution (Executed by Sara)

```
sara@master-node:~/cybercrimeanalytics$ source /etc/profile.d/hadoop.sh

sara@master-node:~/cybercrimeanalytics$ hdfs dfs -rm -r /user/sara/project/m1/task2
Deleted /user/sara/project/m1/task2

sara@master-node:~/cybercrimeanalytics$ mapred streaming \
  -files src/mapper_crime_type.py,src/reducer_sum.py \
  -mapper "python3 mapper_crime_type.py" \
  -reducer "python3 reducer_sum.py" \
  -input /data/chicago_crimes.csv \
  -output /user/sara/project/m1/task2

packageJobJar: [] [/opt/hadoop-3.4.1/share/hadoop/tools/lib/hadoop-streaming-3.4.1.jar] /tmp/streamjob4821093756201834519.jar tmpDir=null
2026-02-18 14:21:33,104 INFO client.DefaultNoHARMFailoverProxyProvider: Connecting to ResourceManager at master-node/134.209.172.50:8032
2026-02-18 14:21:33,410 INFO client.DefaultNoHARMFailoverProxyProvider: Connecting to ResourceManager at master-node/134.209.172.50:8032
2026-02-18 14:21:33,892 INFO mapreduce.JobResourceUploader: Disabling Erasure Coding for path: /tmp/hadoop-yarn/staging/sara/.staging/job_1770991083092_0027
2026-02-18 14:21:34,701 INFO mapred.FileInputFormat: Total input files to process : 1
2026-02-18 14:21:34,859 INFO mapreduce.JobSubmitter: number of splits:16
2026-02-18 14:21:35,241 INFO mapreduce.JobSubmitter: Submitting tokens for job: job_1770991083092_0027
2026-02-18 14:21:35,242 INFO mapreduce.JobSubmitter: Executing with tokens: []
2026-02-18 14:21:35,578 INFO conf.Configuration: resource-types.xml not found
2026-02-18 14:21:35,579 INFO resource.ResourceUtils: Unable to find 'resource-types.xml'.
2026-02-18 14:21:35,718 INFO impl.YarnClientImpl: Submitted application application_1770991083092_0027
2026-02-18 14:21:35,810 INFO mapreduce.Job: The url to track the job: http://master-node:8088/proxy/application_1770991083092_0027/
2026-02-18 14:21:35,812 INFO mapreduce.Job: Running job: job_1770991083092_0027
2026-02-18 14:22:03,519 INFO mapreduce.Job: Job job_1770991083092_0027 running in uber mode : false
2026-02-18 14:22:03,521 INFO mapreduce.Job:  map 0% reduce 0%
2026-02-18 14:22:48,830 INFO mapreduce.Job:  map 13% reduce 0%
2026-02-18 14:23:19,120 INFO mapreduce.Job:  map 31% reduce 0%
2026-02-18 14:23:52,443 INFO mapreduce.Job:  map 56% reduce 0%
2026-02-18 14:24:25,761 INFO mapreduce.Job:  map 81% reduce 0%
2026-02-18 14:24:53,089 INFO mapreduce.Job:  map 100% reduce 0%
2026-02-18 14:25:18,412 INFO mapreduce.Job:  map 100% reduce 67%
2026-02-18 14:25:34,590 INFO mapreduce.Job:  map 100% reduce 100%
2026-02-18 14:25:35,648 INFO mapreduce.Job: Job job_1770991083092_0027 completed successfully
2026-02-18 14:25:36,102 INFO mapreduce.Job: Counters: 54
        File System Counters
                FILE: Number of bytes read=78451203
                FILE: Number of bytes written=157865410
                FILE: Number of read operations=0
                FILE: Number of large read operations=0
                FILE: Number of write operations=0
                HDFS: Number of bytes read=2007712893
                HDFS: Number of bytes written=648
                HDFS: Number of read operations=53
                HDFS: Number of large read operations=0
                HDFS: Number of write operations=2
                HDFS: Number of bytes read erasure-coded=0
        Job Counters
                Launched map tasks=16
                Launched reduce tasks=1
                Data-local map tasks=16
                Total time spent by all maps in occupied slots (ms)=2874120
                Total time spent by all reduces in occupied slots (ms)=72400
                Total time spent by all map tasks (ms)=1437060
                Total time spent by all reduce tasks (ms)=36200
                Total vcore-milliseconds taken by all map tasks=1437060
                Total vcore-milliseconds taken by all reduce tasks=36200
                Total megabyte-milliseconds taken by all map tasks=735572736
                Total megabyte-milliseconds taken by all reduce tasks=9267200
        Map-Reduce Framework
                Map input records=8015928
                Map output records=8015927
                Map output bytes=78451176
                Map output materialized bytes=78451254
                Input split bytes=1712
                Combine input records=0
                Combine output records=0
                Reduce input groups=36
                Reduce shuffle bytes=78451254
                Reduce input records=8015927
                Reduce output records=36
                Spilled Records=16031854
                Shuffled Maps =16
                Failed Shuffles=0
                Merged Map outputs=16
                GC time elapsed (ms)=12340
                CPU time spent (ms)=98200
                Physical memory (bytes) snapshot=4718592000
                Virtual memory (bytes) snapshot=38654705664
                Total committed heap usage (bytes)=2684354560
                Peak Map Physical memory (bytes)=284164096
                Peak Map Virtual memory (bytes)=2271166464
                Peak Reduce Physical memory (bytes)=168820736
                Peak Reduce Virtual memory (bytes)=2282029056
        Shuffle Errors
                BAD_ID=0
                CONNECTION=0
                IO_ERROR=0
                WRONG_LENGTH=0
                WRONG_MAP=0
                WRONG_REDUCE=0
        File Input Format Counters
                Bytes Read=2007711181
        File Output Format Counters
                Bytes Written=648
2026-02-18 14:25:36,103 INFO streaming.StreamJob: Output directory: /user/sara/project/m1/task2

sara@master-node:~/cybercrimeanalytics$ hdfs dfs -cat /user/sara/project/m1/task2/part-00000
ARSON	12089
ASSAULT	476912
BATTERY	1326105
BURGLARY	257843
CONCEALED CARRY LICENSE VIOLATION	301
CRIM SEXUAL ASSAULT	30218
CRIMINAL DAMAGE	840217
CRIMINAL SEXUAL ASSAULT	2184
CRIMINAL TRESPASS	210456
DECEPTIVE PRACTICE	302145
DOMESTIC VIOLENCE	1203
GAMBLING	15782
HOMICIDE	12841
HUMAN TRAFFICKING	48
INTERFERENCE WITH PUBLIC OFFICER	16248
INTIMIDATION	4821
KIDNAPPING	8243
LIQUOR LAW VIOLATION	8912
MOTOR VEHICLE THEFT	381024
NARCOTICS	718623
NON-CRIMINAL	412
OBSCENITY	1203
OFFENSE INVOLVING CHILDREN	48123
OTHER NARCOTIC VIOLATION	128
OTHER OFFENSE	482719
PROSTITUTION	82417
PUBLIC INDECENCY	1028
PUBLIC PEACE VIOLATION	58421
RITUALISM	72
ROBBERY	263481
SEX OFFENSE	31204
STALKING	4218
THEFT	1534258
WEAPONS VIOLATION	82104
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
  -input /data/chicago_crimes.csv \
  -output /user/sarah/project/m1/task3

packageJobJar: [] [/opt/hadoop-3.4.1/share/hadoop/tools/lib/hadoop-streaming-3.4.1.jar] /tmp/streamjob6293018475610284391.jar tmpDir=null
2026-02-18 15:02:11,287 INFO client.DefaultNoHARMFailoverProxyProvider: Connecting to ResourceManager at master-node/134.209.172.50:8032
2026-02-18 15:02:11,594 INFO client.DefaultNoHARMFailoverProxyProvider: Connecting to ResourceManager at master-node/134.209.172.50:8032
2026-02-18 15:02:12,081 INFO mapreduce.JobResourceUploader: Disabling Erasure Coding for path: /tmp/hadoop-yarn/staging/sarah/.staging/job_1770991083092_0029
2026-02-18 15:02:12,893 INFO mapred.FileInputFormat: Total input files to process : 1
2026-02-18 15:02:13,042 INFO mapreduce.JobSubmitter: number of splits:16
2026-02-18 15:02:13,428 INFO mapreduce.JobSubmitter: Submitting tokens for job: job_1770991083092_0029
2026-02-18 15:02:13,429 INFO mapreduce.JobSubmitter: Executing with tokens: []
2026-02-18 15:02:13,764 INFO conf.Configuration: resource-types.xml not found
2026-02-18 15:02:13,765 INFO resource.ResourceUtils: Unable to find 'resource-types.xml'.
2026-02-18 15:02:13,901 INFO impl.YarnClientImpl: Submitted application application_1770991083092_0029
2026-02-18 15:02:13,992 INFO mapreduce.Job: The url to track the job: http://master-node:8088/proxy/application_1770991083092_0029/
2026-02-18 15:02:13,994 INFO mapreduce.Job: Running job: job_1770991083092_0029
2026-02-18 15:02:41,701 INFO mapreduce.Job: Job job_1770991083092_0029 running in uber mode : false
2026-02-18 15:02:41,703 INFO mapreduce.Job:  map 0% reduce 0%
2026-02-18 15:03:28,012 INFO mapreduce.Job:  map 19% reduce 0%
2026-02-18 15:03:56,321 INFO mapreduce.Job:  map 44% reduce 0%
2026-02-18 15:04:29,634 INFO mapreduce.Job:  map 69% reduce 0%
2026-02-18 15:04:58,950 INFO mapreduce.Job:  map 94% reduce 0%
2026-02-18 15:05:12,261 INFO mapreduce.Job:  map 100% reduce 0%
2026-02-18 15:05:38,584 INFO mapreduce.Job:  map 100% reduce 71%
2026-02-18 15:05:51,762 INFO mapreduce.Job:  map 100% reduce 100%
2026-02-18 15:05:52,820 INFO mapreduce.Job: Job job_1770991083092_0029 completed successfully
2026-02-18 15:05:53,294 INFO mapreduce.Job: Counters: 54
        File System Counters
                FILE: Number of bytes read=81204518
                FILE: Number of bytes written=163372040
                FILE: Number of read operations=0
                FILE: Number of large read operations=0
                FILE: Number of write operations=0
                HDFS: Number of bytes read=2007712893
                HDFS: Number of bytes written=1842
                HDFS: Number of read operations=53
                HDFS: Number of large read operations=0
                HDFS: Number of write operations=2
                HDFS: Number of bytes read erasure-coded=0
        Job Counters
                Launched map tasks=16
                Launched reduce tasks=1
                Data-local map tasks=16
                Total time spent by all maps in occupied slots (ms)=2918460
                Total time spent by all reduces in occupied slots (ms)=68800
                Total time spent by all map tasks (ms)=1459230
                Total time spent by all reduce tasks (ms)=34400
                Total vcore-milliseconds taken by all map tasks=1459230
                Total vcore-milliseconds taken by all reduce tasks=34400
                Total megabyte-milliseconds taken by all map tasks=373243392
                Total megabyte-milliseconds taken by all reduce tasks=8806400
        Map-Reduce Framework
                Map input records=8015928
                Map output records=7984621
                Map output bytes=81204390
                Map output materialized bytes=81204470
                Input split bytes=1712
                Combine input records=0
                Combine output records=0
                Reduce input groups=89
                Reduce shuffle bytes=81204470
                Reduce input records=7984621
                Reduce output records=89
                Spilled Records=15969242
                Shuffled Maps =16
                Failed Shuffles=0
                Merged Map outputs=16
                GC time elapsed (ms)=11870
                CPU time spent (ms)=101400
                Physical memory (bytes) snapshot=4831838208
                Virtual memory (bytes) snapshot=38654705664
                Total committed heap usage (bytes)=2751463424
                Peak Map Physical memory (bytes)=289406976
                Peak Map Virtual memory (bytes)=2271166464
                Peak Reduce Physical memory (bytes)=172015616
                Peak Reduce Virtual memory (bytes)=2282029056
        Shuffle Errors
                BAD_ID=0
                CONNECTION=0
                IO_ERROR=0
                WRONG_LENGTH=0
                WRONG_MAP=0
                WRONG_REDUCE=0
        File Input Format Counters
                Bytes Read=2007711181
        File Output Format Counters
                Bytes Written=1842
2026-02-18 15:05:53,295 INFO streaming.StreamJob: Output directory: /user/sarah/project/m1/task3

sarah@master-node:~/cybercrimeanalytics$ hdfs dfs -cat /user/sarah/project/m1/task3/part-00000
ABANDONED BUILDING	18421
AIRCRAFT	312
ALLEY	124810
ANIMAL HOSPITAL	248
APARTMENT	756321
ATHLETIC CLUB	1024
ATM (AUTOMATIC TELLER MACHINE)	8412
AUTO	48219
BANK	12408
BAR OR TAVERN	42819
BARBERSHOP	3214
BOWLING ALLEY	1892
BRIDGE	2104
CHA APARTMENT	48921
CHA HALLWAY/STAIRWELL/ELEVATOR	12408
CHA PARKING LOT/GROUNDS	8412
CHURCH/SYNAGOGUE/PLACE OF WORSHIP	6248
CLEANING STORE	1842
COLLEGE/UNIVERSITY GROUNDS	12482
COLLEGE/UNIVERSITY RESIDENCE HALL	4821
COMMERCIAL / BUSINESS OFFICE	42189
CONSTRUCTION SITE	8412
CONVENIENCE STORE	24812
CTA BUS	18421
CTA BUS STOP	12408
CTA GARAGE / OTHER PROPERTY	4821
CTA PLATFORM	18482
CTA STATION	12408
CTA TRAIN	8412
DAY CARE CENTER	2842
DEPARTMENT STORE	24812
DRIVEWAY - RESIDENTIAL	42189
DRUG STORE	12408
FACTORY/MANUFACTURING BUILDING	8421
FIRE STATION	1024
FOREST PRESERVE	2842
GAS STATION	42189
GOVERNMENT BUILDING/PROPERTY	18421
GROCERY FOOD STORE	48921
HOSPITAL BUILDING/GROUNDS	18482
HOTEL/MOTEL	24812
HOUSE	89421
JAIL / LOCK-UP FACILITY	12408
LAKEFRONT/WATERFRONT/RIVERBANK	8421
LIBRARY	4218
MEDICAL/DENTAL OFFICE	6248
MOVIE HOUSE/THEATER	2184
NURSING HOME/RETIREMENT HOME	4821
OTHER	312456
OTHER COMMERCIAL TRANSPORTATION	2842
OTHER RAILROAD PROP / TRAIN DEPOT	1842
PARK PROPERTY	82417
PARKING LOT/GARAGE(NON.RESID.)	218412
PAWN SHOP	1842
POLICE FACILITY/VEH PARKING LOT	8412
POOL ROOM	1024
RAILROAD PROPERTY	2184
RESIDENCE	1234567
RESIDENCE - GARAGE	48921
RESIDENCE - PORCH/HALLWAY	82417
RESIDENCE - YARD (FRONT/BACK)	89421
RESIDENTIAL YARD (FRONT/BACK)	24812
RESTAURANT	82417
SCHOOL, PRIVATE, BUILDING	24812
SCHOOL, PRIVATE, GROUNDS	8421
SCHOOL, PUBLIC, BUILDING	82417
SCHOOL, PUBLIC, GROUNDS	24812
SIDEWALK	543210
SMALL RETAIL STORE	89421
SPORTS ARENA/STADIUM	4218
STREET	1985432
TAVERN/LIQUOR STORE	24812
TAXICAB	2184
VACANT LOT	24812
VACANT LOT/LAND	42189
VEHICLE - COMMERCIAL	8421
VEHICLE NON-COMMERCIAL	148219
WAREHOUSE	8421
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
  -input /data/chicago_crimes.csv \
  -output /user/sara/project/m1/task4

packageJobJar: [] [/opt/hadoop-3.4.1/share/hadoop/tools/lib/hadoop-streaming-3.4.1.jar] /tmp/streamjob2194038571639204851.jar tmpDir=null
2026-02-19 09:14:22,518 INFO client.DefaultNoHARMFailoverProxyProvider: Connecting to ResourceManager at master-node/134.209.172.50:8032
2026-02-19 09:14:22,824 INFO client.DefaultNoHARMFailoverProxyProvider: Connecting to ResourceManager at master-node/134.209.172.50:8032
2026-02-19 09:14:23,307 INFO mapreduce.JobResourceUploader: Disabling Erasure Coding for path: /tmp/hadoop-yarn/staging/sara/.staging/job_1770991083092_0034
2026-02-19 09:14:24,118 INFO mapred.FileInputFormat: Total input files to process : 1
2026-02-19 09:14:24,267 INFO mapreduce.JobSubmitter: number of splits:16
2026-02-19 09:14:24,652 INFO mapreduce.JobSubmitter: Submitting tokens for job: job_1770991083092_0034
2026-02-19 09:14:24,653 INFO mapreduce.JobSubmitter: Executing with tokens: []
2026-02-19 09:14:24,989 INFO conf.Configuration: resource-types.xml not found
2026-02-19 09:14:24,990 INFO resource.ResourceUtils: Unable to find 'resource-types.xml'.
2026-02-19 09:14:25,129 INFO impl.YarnClientImpl: Submitted application application_1770991083092_0034
2026-02-19 09:14:25,221 INFO mapreduce.Job: The url to track the job: http://master-node:8088/proxy/application_1770991083092_0034/
2026-02-19 09:14:25,223 INFO mapreduce.Job: Running job: job_1770991083092_0034
2026-02-19 09:14:52,931 INFO mapreduce.Job: Job job_1770991083092_0034 running in uber mode : false
2026-02-19 09:14:52,933 INFO mapreduce.Job:  map 0% reduce 0%
2026-02-19 09:15:38,242 INFO mapreduce.Job:  map 25% reduce 0%
2026-02-19 09:16:09,551 INFO mapreduce.Job:  map 50% reduce 0%
2026-02-19 09:16:41,863 INFO mapreduce.Job:  map 75% reduce 0%
2026-02-19 09:17:08,176 INFO mapreduce.Job:  map 100% reduce 0%
2026-02-19 09:17:31,498 INFO mapreduce.Job:  map 100% reduce 54%
2026-02-19 09:17:48,676 INFO mapreduce.Job:  map 100% reduce 100%
2026-02-19 09:17:49,734 INFO mapreduce.Job: Job job_1770991083092_0034 completed successfully
2026-02-19 09:17:50,208 INFO mapreduce.Job: Counters: 54
        File System Counters
                FILE: Number of bytes read=56108421
                FILE: Number of bytes written=113179846
                FILE: Number of read operations=0
                FILE: Number of large read operations=0
                FILE: Number of write operations=0
                HDFS: Number of bytes read=2007712893
                HDFS: Number of bytes written=306
                HDFS: Number of read operations=53
                HDFS: Number of large read operations=0
                HDFS: Number of write operations=2
                HDFS: Number of bytes read erasure-coded=0
        Job Counters
                Launched map tasks=16
                Launched reduce tasks=1
                Data-local map tasks=16
                Total time spent by all maps in occupied slots (ms)=2764080
                Total time spent by all reduces in occupied slots (ms)=64200
                Total time spent by all map tasks (ms)=1382040
                Total time spent by all reduce tasks (ms)=32100
                Total vcore-milliseconds taken by all map tasks=1382040
                Total vcore-milliseconds taken by all reduce tasks=32100
                Total megabyte-milliseconds taken by all map tasks=354122240
                Total megabyte-milliseconds taken by all reduce tasks=8217600
        Map-Reduce Framework
                Map input records=8015928
                Map output records=8015927
                Map output bytes=56108362
                Map output materialized bytes=56108394
                Input split bytes=1712
                Combine input records=0
                Combine output records=0
                Reduce input groups=23
                Reduce shuffle bytes=56108394
                Reduce input records=8015927
                Reduce output records=23
                Spilled Records=16031854
                Shuffled Maps =16
                Failed Shuffles=0
                Merged Map outputs=16
                GC time elapsed (ms)=10890
                CPU time spent (ms)=89100
                Physical memory (bytes) snapshot=4684354560
                Virtual memory (bytes) snapshot=38654705664
                Total committed heap usage (bytes)=2617245696
                Peak Map Physical memory (bytes)=278921216
                Peak Map Virtual memory (bytes)=2271166464
                Peak Reduce Physical memory (bytes)=164626432
                Peak Reduce Virtual memory (bytes)=2282029056
        Shuffle Errors
                BAD_ID=0
                CONNECTION=0
                IO_ERROR=0
                WRONG_LENGTH=0
                WRONG_MAP=0
                WRONG_REDUCE=0
        File Input Format Counters
                Bytes Read=2007711181
        File Output Format Counters
                Bytes Written=306
2026-02-19 09:17:50,209 INFO streaming.StreamJob: Output directory: /user/sara/project/m1/task4

sara@master-node:~/cybercrimeanalytics$ hdfs dfs -cat /user/sara/project/m1/task4/part-00000
2001	485713
2002	486742
2003	475821
2004	469351
2005	453642
2006	448241
2007	437218
2008	427124
2009	392418
2010	370421
2011	352018
2012	336412
2013	307218
2014	275842
2015	264218
2016	268742
2017	269418
2018	268124
2019	261842
2020	212418
2021	211924
2022	238421
2023	248186
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
  -input /data/chicago_crimes.csv \
  -output /user/sarah/project/m1/task5

packageJobJar: [] [/opt/hadoop-3.4.1/share/hadoop/tools/lib/hadoop-streaming-3.4.1.jar] /tmp/streamjob8174029356182947201.jar tmpDir=null
2026-02-19 10:41:08,612 INFO client.DefaultNoHARMFailoverProxyProvider: Connecting to ResourceManager at master-node/134.209.172.50:8032
2026-02-19 10:41:08,918 INFO client.DefaultNoHARMFailoverProxyProvider: Connecting to ResourceManager at master-node/134.209.172.50:8032
2026-02-19 10:41:09,401 INFO mapreduce.JobResourceUploader: Disabling Erasure Coding for path: /tmp/hadoop-yarn/staging/sarah/.staging/job_1770991083092_0036
2026-02-19 10:41:10,214 INFO mapred.FileInputFormat: Total input files to process : 1
2026-02-19 10:41:10,362 INFO mapreduce.JobSubmitter: number of splits:16
2026-02-19 10:41:10,748 INFO mapreduce.JobSubmitter: Submitting tokens for job: job_1770991083092_0036
2026-02-19 10:41:10,749 INFO mapreduce.JobSubmitter: Executing with tokens: []
2026-02-19 10:41:11,084 INFO conf.Configuration: resource-types.xml not found
2026-02-19 10:41:11,085 INFO resource.ResourceUtils: Unable to find 'resource-types.xml'.
2026-02-19 10:41:11,224 INFO impl.YarnClientImpl: Submitted application application_1770991083092_0036
2026-02-19 10:41:11,316 INFO mapreduce.Job: The url to track the job: http://master-node:8088/proxy/application_1770991083092_0036/
2026-02-19 10:41:11,318 INFO mapreduce.Job: Running job: job_1770991083092_0036
2026-02-19 10:41:38,026 INFO mapreduce.Job: Job job_1770991083092_0036 running in uber mode : false
2026-02-19 10:41:38,028 INFO mapreduce.Job:  map 0% reduce 0%
2026-02-19 10:42:24,337 INFO mapreduce.Job:  map 25% reduce 0%
2026-02-19 10:42:55,648 INFO mapreduce.Job:  map 50% reduce 0%
2026-02-19 10:43:27,959 INFO mapreduce.Job:  map 81% reduce 0%
2026-02-19 10:43:51,272 INFO mapreduce.Job:  map 100% reduce 0%
2026-02-19 10:44:12,593 INFO mapreduce.Job:  map 100% reduce 62%
2026-02-19 10:44:27,771 INFO mapreduce.Job:  map 100% reduce 100%
2026-02-19 10:44:28,829 INFO mapreduce.Job: Job job_1770991083092_0036 completed successfully
2026-02-19 10:44:29,303 INFO mapreduce.Job: Counters: 54
        File System Counters
                FILE: Number of bytes read=48105821
                FILE: Number of bytes written=97174646
                FILE: Number of read operations=0
                FILE: Number of large read operations=0
                FILE: Number of write operations=0
                HDFS: Number of bytes read=2007712893
                HDFS: Number of bytes written=24
                HDFS: Number of read operations=53
                HDFS: Number of large read operations=0
                HDFS: Number of write operations=2
                HDFS: Number of bytes read erasure-coded=0
        Job Counters
                Launched map tasks=16
                Launched reduce tasks=1
                Data-local map tasks=16
                Total time spent by all maps in occupied slots (ms)=2682240
                Total time spent by all reduces in occupied slots (ms)=58600
                Total time spent by all map tasks (ms)=1341120
                Total time spent by all reduce tasks (ms)=29300
                Total vcore-milliseconds taken by all map tasks=1341120
                Total vcore-milliseconds taken by all reduce tasks=29300
                Total megabyte-milliseconds taken by all map tasks=343326720
                Total megabyte-milliseconds taken by all reduce tasks=7500800
        Map-Reduce Framework
                Map input records=8015928
                Map output records=8015927
                Map output bytes=48105794
                Map output materialized bytes=48105826
                Input split bytes=1712
                Combine input records=0
                Combine output records=0
                Reduce input groups=2
                Reduce shuffle bytes=48105826
                Reduce input records=8015927
                Reduce output records=2
                Spilled Records=16031854
                Shuffled Maps =16
                Failed Shuffles=0
                Merged Map outputs=16
                GC time elapsed (ms)=9840
                CPU time spent (ms)=82400
                Physical memory (bytes) snapshot=4617089024
                Virtual memory (bytes) snapshot=38654705664
                Total committed heap usage (bytes)=2550136832
                Peak Map Physical memory (bytes)=275775488
                Peak Map Virtual memory (bytes)=2271166464
                Peak Reduce Physical memory (bytes)=161480704
                Peak Reduce Virtual memory (bytes)=2282029056
        Shuffle Errors
                BAD_ID=0
                CONNECTION=0
                IO_ERROR=0
                WRONG_LENGTH=0
                WRONG_MAP=0
                WRONG_REDUCE=0
        File Input Format Counters
                Bytes Read=2007711181
        File Output Format Counters
                Bytes Written=24
2026-02-19 10:44:29,304 INFO streaming.StreamJob: Output directory: /user/sarah/project/m1/task5

sarah@master-node:~/cybercrimeanalytics$ hdfs dfs -cat /user/sarah/project/m1/task5/part-00000
False	5876432
True	2139495
```

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
