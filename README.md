# Chicago Crime Analytics - SE446 Milestone 1

## Team Members

| Name | Student ID | Role |
|------|------------|------|
| Sara Alshathri | 231207 | Group Leader |
| Sarah Althukair | 231300 | Member |

---

## Executive Summary

This project implements a MapReduce pipeline to analyze the Chicago Police Department crime dataset (793,073 records, 173.5 MB). Using Hadoop Streaming on the department's cluster, we built four MapReduce jobs that answer critical questions about crime type distribution, location hotspots, yearly trends, and arrest efficiency. Each mapper reads CSV data from stdin, extracts the relevant field at the correct column index, and emits key-value pairs. A single shared reducer (reducer_sum.py) aggregates counts for all tasks without modification.

---

## Dataset

- **Full Dataset**: `/data/chicago_crimes.csv` — 173.5 MB, 793,073 records
- **Sample Dataset**: `/data/chicago_crimes_sample.csv` — 2.3 MB, 10,001 records

| Index | Column | Task |
|:-----:|:-------|:----:|
| 2 | Date | 4 |
| 5 | Primary Type | 2 |
| 7 | Location Description | 3 |
| 8 | Arrest | 5 |

---

## Task 2: Crime Type Distribution

**Assigned to**: Sara Alshathri

**Question:** What are the most common types of crimes in Chicago?

**Mapper:** `src/mapper_crime_type.py` — Extracts Primary Type (column index 5) and emits (crime_type, 1).

**Command:**
```bash
mapred streaming \
  -files mapper_crime_type.py,reducer_sum.py \
  -mapper "python3 mapper_crime_type.py" \
  -reducer "python3 reducer_sum.py" \
  -input /data/chicago_crimes.csv \
  -output /user/sakalshathri/project/m1/task2
```

**Results (Top 5):**

| Crime Type | Count |
|-----------|-------|
| THEFT | 162,688 |
| BATTERY | 151,930 |
| CRIMINAL DAMAGE | 91,241 |
| NARCOTICS | 74,127 |
| ASSAULT | 54,070 |

**Interpretation:** Theft leads all crime types with 162,688 incidents (20.5%), followed by Battery at 151,930 (19.2%). Together these two categories account for nearly 40% of all reported crimes.

### Execution Log

```
sakalshathri@master-node:~$ source /etc/profile.d/hadoop.sh
sakalshathri@master-node:~$ mapred streaming -files mapper_crime_type.py,reducer_sum.py -mapper "python3 mapper_crime_type.py" -reducer "python3 reducer_sum.py" -input /data/chicago_crimes.csv -output /user/sakalshathri/project/m1/task2

packageJobJar: [] [/opt/hadoop-3.4.1/share/hadoop/tools/lib/hadoop-streaming-3.4.1.jar] /tmp/streamjob16974849773613781541.jar tmpDir=null
2026-03-24 15:48:05,154 INFO client.DefaultNoHARMFailoverProxyProvider: Connecting to ResourceManager at master-node/134.209.172.50:8032
2026-03-24 15:48:05,551 INFO client.DefaultNoHARMFailoverProxyProvider: Connecting to ResourceManager at master-node/134.209.172.50:8032
2026-03-24 15:48:06,118 INFO mapreduce.JobResourceUploader: Disabling Erasure Coding for path: /tmp/hadoop-yarn/staging/sakalshathri/.staging/job_1771402826595_0170
2026-03-24 15:48:07,925 INFO mapred.FileInputFormat: Total input files to process : 1
2026-03-24 15:48:07,960 INFO net.NetworkTopology: Adding a new node: /default-rack/164.92.103.148:9866
2026-03-24 15:48:07,962 INFO net.NetworkTopology: Adding a new node: /default-rack/146.190.147.119:9866
2026-03-24 15:48:08,590 INFO mapreduce.JobSubmitter: number of splits:2
2026-03-24 15:48:09,574 INFO mapreduce.JobSubmitter: Submitting tokens for job: job_1771402826595_0170
2026-03-24 15:48:09,575 INFO mapreduce.JobSubmitter: Executing with tokens: []
2026-03-24 15:48:09,966 INFO conf.Configuration: resource-types.xml not found
2026-03-24 15:48:09,967 INFO resource.ResourceUtils: Unable to find 'resource-types.xml'.
2026-03-24 15:48:10,120 INFO impl.YarnClientImpl: Submitted application application_1771402826595_0170
2026-03-24 15:48:10,188 INFO mapreduce.Job: The url to track the job: http://master-node:8088/proxy/application_1771402826595_0170/
2026-03-24 15:48:10,191 INFO mapreduce.Job: Running job: job_1771402826595_0170
2026-03-24 15:48:27,719 INFO mapreduce.Job: Job job_1771402826595_0170 running in uber mode : false
2026-03-24 15:48:27,721 INFO mapreduce.Job:  map 0% reduce 0%
2026-03-24 15:49:00,215 INFO mapreduce.Job:  map 100% reduce 0%
2026-03-24 15:49:14,874 INFO mapreduce.Job:  map 100% reduce 100%
2026-03-24 15:49:17,755 INFO mapreduce.Job: Job job_1771402826595_0170 completed successfully
2026-03-24 15:49:17,996 INFO mapreduce.Job: Counters: 54
        File System Counters
                FILE: Number of bytes read=11798790
                FILE: Number of bytes written=24540929
                FILE: Number of read operations=0
                FILE: Number of large read operations=0
                FILE: Number of write operations=0
                HDFS: Number of bytes read=181964998
                HDFS: Number of bytes written=690
                HDFS: Number of read operations=11
                HDFS: Number of large read operations=0
                HDFS: Number of write operations=2
                HDFS: Number of bytes read erasure-coded=0
        Job Counters
                Launched map tasks=2
                Launched reduce tasks=1
                Data-local map tasks=2
                Total time spent by all maps in occupied slots (ms)=116704
                Total time spent by all reduces in occupied slots (ms)=24376
                Total time spent by all map tasks (ms)=58352
                Total time spent by all reduce tasks (ms)=12188
                Total vcore-milliseconds taken by all map tasks=58352
                Total vcore-milliseconds taken by all reduce tasks=12188
                Total megabyte-milliseconds taken by all map tasks=29876224
                Total megabyte-milliseconds taken by all reduce tasks=6240256
        Map-Reduce Framework
                Map input records=793074
                Map output records=793072
                Map output bytes=10212640
                Map output materialized bytes=11798796
                Input split bytes=198
                Combine input records=0
                Combine output records=0
                Reduce input groups=34
                Reduce shuffle bytes=11798796
                Reduce input records=793072
                Reduce output records=34
                Spilled Records=1586144
                Shuffled Maps =2
                Failed Shuffles=0
                Merged Map outputs=2
                GC time elapsed (ms)=803
                CPU time spent (ms)=9410
                Physical memory (bytes) snapshot=659165184
                Virtual memory (bytes) snapshot=6561808384
                Total committed heap usage (bytes)=348024832
                Peak Map Physical memory (bytes)=251838464
                Peak Map Virtual memory (bytes)=2186235904
                Peak Reduce Physical memory (bytes)=157925376
                Peak Reduce Virtual memory (bytes)=2191650816
        Shuffle Errors
                BAD_ID=0
                CONNECTION=0
                IO_ERROR=0
                WRONG_LENGTH=0
                WRONG_MAP=0
                WRONG_REDUCE=0
        File Input Format Counters
                Bytes Read=181964800
        File Output Format Counters
                Bytes Written=690
2026-03-24 15:49:17,997 INFO streaming.StreamJob: Output directory: /user/sakalshathri/project/m1/task2

sakalshathri@master-node:~$ hdfs dfs -cat /user/sakalshathri/project/m1/task2/part-00000
ARSON	1717
ASSAULT	54070
BATTERY	151930
BURGLARY	39872
CONCEALED CARRY LICENSE VIOLATION	77
CRIM SEXUAL ASSAULT	2463
CRIMINAL DAMAGE	91241
CRIMINAL SEXUAL ASSAULT	1372
CRIMINAL TRESPASS	21476
DECEPTIVE PRACTICE	30396
DOMESTIC VIOLENCE	1
GAMBLING	1314
HOMICIDE	13173
HUMAN TRAFFICKING	13
INTERFERENCE WITH PUBLIC OFFICER	803
INTIMIDATION	92
KIDNAPPING	1108
LIQUOR LAW VIOLATION	2349
MOTOR VEHICLE THEFT	48494
NARCOTICS	74127
NON-CRIMINAL	1
OBSCENITY	24
OFFENSE INVOLVING CHILDREN	2065
OTHER NARCOTIC VIOLATION	11
OTHER OFFENSE	36893
PROSTITUTION	9100
PUBLIC INDECENCY	17
PUBLIC PEACE VIOLATION	1827
RITUALISM	8
ROBBERY	30991
SEX OFFENSE	3932
STALKING	534
THEFT	162688
WEAPONS VIOLATION	8893
```

---

## Task 3: Location Hotspots

**Assigned to**: Sarah Althukair

**Question:** Where do most crimes occur?

**Mapper:** `src/mapper_location.py` — Extracts Location Description (column index 7) and emits (location, 1).

**Command:**
```bash
mapred streaming \
  -files mapper_location.py,reducer_sum.py \
  -mapper "python3 mapper_location.py" \
  -reducer "python3 reducer_sum.py" \
  -input /data/chicago_crimes.csv \
  -output /user/salthukair/project/m1/task3
```

**Results (Top 5):**

| Location | Count |
|----------|-------|
| STREET | 248,326 |
| RESIDENCE | 136,393 |
| APARTMENT | 61,235 |
| SIDEWALK | 47,506 |
| OTHER | 29,671 |

**Interpretation:** Streets are the most common crime location with 248,326 incidents (about 31%), followed by Residence at 136,393. Together they account for nearly half of all crimes. Patrol units should prioritize street-level presence and community outreach in residential areas.

### Execution Log

```
salthukair@master-node:~$ source /etc/profile.d/hadoop.sh
salthukair@master-node:~$ mapred streaming -files mapper_location.py,reducer_sum.py -mapper "python3 mapper_location.py" -reducer "python3 reducer_sum.py" -input /data/chicago_crimes.csv -output /user/salthukair/project/m1/task3

packageJobJar: [] [/opt/hadoop-3.4.1/share/hadoop/tools/lib/hadoop-streaming-3.4.1.jar] /tmp/streamjob2897964957400814118.jar tmpDir=null
2026-03-24 15:54:04,448 INFO client.DefaultNoHARMFailoverProxyProvider: Connecting to ResourceManager at master-node/134.209.172.50:8032
2026-03-24 15:54:04,800 INFO client.DefaultNoHARMFailoverProxyProvider: Connecting to ResourceManager at master-node/134.209.172.50:8032
2026-03-24 15:54:05,275 INFO mapreduce.JobResourceUploader: Disabling Erasure Coding for path: /tmp/hadoop-yarn/staging/salthukair/.staging/job_1771402826595_0172
2026-03-24 15:54:07,485 INFO mapred.FileInputFormat: Total input files to process : 1
2026-03-24 15:54:07,512 INFO net.NetworkTopology: Adding a new node: /default-rack/146.190.147.119:9866
2026-03-24 15:54:07,513 INFO net.NetworkTopology: Adding a new node: /default-rack/164.92.103.148:9866
2026-03-24 15:54:08,115 INFO mapreduce.JobSubmitter: number of splits:2
2026-03-24 15:54:09,024 INFO mapreduce.JobSubmitter: Submitting tokens for job: job_1771402826595_0172
2026-03-24 15:54:09,024 INFO mapreduce.JobSubmitter: Executing with tokens: []
2026-03-24 15:54:09,408 INFO conf.Configuration: resource-types.xml not found
2026-03-24 15:54:09,409 INFO resource.ResourceUtils: Unable to find 'resource-types.xml'.
2026-03-24 15:54:09,522 INFO impl.YarnClientImpl: Submitted application application_1771402826595_0172
2026-03-24 15:54:09,575 INFO mapreduce.Job: The url to track the job: http://master-node:8088/proxy/application_1771402826595_0172/
2026-03-24 15:54:09,579 INFO mapreduce.Job: Running job: job_1771402826595_0172
2026-03-24 15:54:29,324 INFO mapreduce.Job: Job job_1771402826595_0172 running in uber mode : false
2026-03-24 15:54:29,326 INFO mapreduce.Job:  map 0% reduce 0%
2026-03-24 15:54:55,944 INFO mapreduce.Job:  map 50% reduce 0%
2026-03-24 15:54:57,201 INFO mapreduce.Job:  map 100% reduce 0%
2026-03-24 15:55:10,766 INFO mapreduce.Job:  map 100% reduce 100%
2026-03-24 15:55:14,936 INFO mapreduce.Job: Job job_1771402826595_0172 completed successfully
2026-03-24 15:55:15,203 INFO mapreduce.Job: Counters: 54
        File System Counters
                FILE: Number of bytes read=12719805
                FILE: Number of bytes written=26382854
                FILE: Number of read operations=0
                FILE: Number of large read operations=0
                FILE: Number of write operations=0
                HDFS: Number of bytes read=181964998
                HDFS: Number of bytes written=4761
                HDFS: Number of read operations=11
                HDFS: Number of large read operations=0
                HDFS: Number of write operations=2
                HDFS: Number of bytes read erasure-coded=0
        Job Counters
                Launched map tasks=2
                Launched reduce tasks=1
                Data-local map tasks=2
                Total time spent by all maps in occupied slots (ms)=98136
                Total time spent by all reduces in occupied slots (ms)=24800
                Total time spent by all map tasks (ms)=49068
                Total time spent by all reduce tasks (ms)=12400
                Total vcore-milliseconds taken by all map tasks=49068
                Total vcore-milliseconds taken by all reduce tasks=12400
                Total megabyte-milliseconds taken by all map tasks=25122816
                Total megabyte-milliseconds taken by all reduce tasks=6348800
        Map-Reduce Framework
                Map input records=793074
                Map output records=791479
                Map output bytes=11136841
                Map output materialized bytes=12719811
                Input split bytes=198
                Combine input records=0
                Combine output records=0
                Reduce input groups=212
                Reduce shuffle bytes=12719811
                Reduce input records=791479
                Reduce output records=212
                Spilled Records=1582958
                Shuffled Maps =2
                Failed Shuffles=0
                Merged Map outputs=2
                GC time elapsed (ms)=864
                CPU time spent (ms)=9200
                Physical memory (bytes) snapshot=659492864
                Virtual memory (bytes) snapshot=6560309248
                Total committed heap usage (bytes)=347983872
                Peak Map Physical memory (bytes)=254234624
                Peak Map Virtual memory (bytes)=2185224192
                Peak Reduce Physical memory (bytes)=151355392
                Peak Reduce Virtual memory (bytes)=2191044608
        Shuffle Errors
                BAD_ID=0
                CONNECTION=0
                IO_ERROR=0
                WRONG_LENGTH=0
                WRONG_MAP=0
                WRONG_REDUCE=0
        File Input Format Counters
                Bytes Read=181964800
        File Output Format Counters
                Bytes Written=4761
2026-03-24 15:55:15,207 INFO streaming.StreamJob: Output directory: /user/salthukair/project/m1/task3
```

---

## Task 4: Crime Trends by Year

**Assigned to**: Sara Alshathri

**Question:** How has the total number of crimes changed over the years?

**Mapper:** `src/mapper_year.py` — Extracts the year from the Date column (index 2) by splitting by space then by `/` to isolate the year. Emits (year, 1).

**Command:**
```bash
mapred streaming \
  -files mapper_year.py,reducer_sum.py \
  -mapper "python3 mapper_year.py" \
  -reducer "python3 reducer_sum.py" \
  -input /data/chicago_crimes.csv \
  -output /user/sakalshathri/project/m1/task4
```

**Results:**

| Year | Count |
|------|-------|
| 2001 | 467,301 |
| 2002 | 205,267 |
| 2003 | 985 |
| 2004 | 915 |
| 2005 | 1,031 |
| 2006 | 796 |
| 2007 | 762 |
| 2008 | 1,010 |
| 2009 | 910 |
| 2010 | 695 |
| 2011 | 770 |
| 2012 | 800 |
| 2013 | 714 |
| 2014 | 825 |
| 2015 | 1,105 |
| 2016 | 1,339 |
| 2017 | 1,387 |
| 2018 | 1,327 |
| 2019 | 1,174 |
| 2020 | 1,832 |
| 2021 | 2,399 |
| 2022 | 4,678 |
| 2023 | 81,461 |
| 2024 | 880 |
| 2025 | 12,710 |

**Interpretation:** The years 2001 (467,301) and 2002 (205,267) contain the vast majority of records in the dataset. From 2003 onward the yearly counts drop to around 700-1,400, with a spike in 2023 (81,461) and 2025 (12,710) which may reflect batch data imports or reporting updates.

### Execution Log

```
sakalshathri@master-node:~$ mapred streaming -files mapper_year.py,reducer_sum.py -mapper "python3 mapper_year.py" -reducer "python3 reducer_sum.py" -input /data/chicago_crimes.csv -output /user/sakalshathri/project/m1/task4

packageJobJar: [] [/opt/hadoop-3.4.1/share/hadoop/tools/lib/hadoop-streaming-3.4.1.jar] /tmp/streamjob16918063326598700804.jar tmpDir=null
2026-03-24 15:49:25,670 INFO client.DefaultNoHARMFailoverProxyProvider: Connecting to ResourceManager at master-node/134.209.172.50:8032
2026-03-24 15:49:26,009 INFO client.DefaultNoHARMFailoverProxyProvider: Connecting to ResourceManager at master-node/134.209.172.50:8032
2026-03-24 15:49:26,542 INFO mapreduce.JobResourceUploader: Disabling Erasure Coding for path: /tmp/hadoop-yarn/staging/sakalshathri/.staging/job_1771402826595_0171
2026-03-24 15:49:28,369 INFO mapred.FileInputFormat: Total input files to process : 1
2026-03-24 15:49:28,414 INFO net.NetworkTopology: Adding a new node: /default-rack/146.190.147.119:9866
2026-03-24 15:49:28,415 INFO net.NetworkTopology: Adding a new node: /default-rack/164.92.103.148:9866
2026-03-24 15:49:29,100 INFO mapreduce.JobSubmitter: number of splits:2
2026-03-24 15:49:30,040 INFO mapreduce.JobSubmitter: Submitting tokens for job: job_1771402826595_0171
2026-03-24 15:49:30,041 INFO mapreduce.JobSubmitter: Executing with tokens: []
2026-03-24 15:49:30,461 INFO conf.Configuration: resource-types.xml not found
2026-03-24 15:49:30,461 INFO resource.ResourceUtils: Unable to find 'resource-types.xml'.
2026-03-24 15:49:30,631 INFO impl.YarnClientImpl: Submitted application application_1771402826595_0171
2026-03-24 15:49:30,708 INFO mapreduce.Job: The url to track the job: http://master-node:8088/proxy/application_1771402826595_0171/
2026-03-24 15:49:30,711 INFO mapreduce.Job: Running job: job_1771402826595_0171
2026-03-24 15:49:48,653 INFO mapreduce.Job: Job job_1771402826595_0171 running in uber mode : false
2026-03-24 15:49:48,655 INFO mapreduce.Job:  map 0% reduce 0%
2026-03-24 15:50:21,662 INFO mapreduce.Job:  map 67% reduce 0%
2026-03-24 15:50:22,908 INFO mapreduce.Job:  map 100% reduce 0%
2026-03-24 15:50:37,526 INFO mapreduce.Job:  map 100% reduce 100%
2026-03-24 15:50:40,376 INFO mapreduce.Job: Job job_1771402826595_0171 completed successfully
2026-03-24 15:50:40,655 INFO mapreduce.Job: Counters: 54
        File System Counters
                FILE: Number of bytes read=7137663
                FILE: Number of bytes written=15218603
                FILE: Number of read operations=0
                FILE: Number of large read operations=0
                FILE: Number of write operations=0
                HDFS: Number of bytes read=181964998
                HDFS: Number of bytes written=245
                HDFS: Number of read operations=11
                HDFS: Number of large read operations=0
                HDFS: Number of write operations=2
                HDFS: Number of bytes read erasure-coded=0
        Job Counters
                Launched map tasks=2
                Launched reduce tasks=1
                Data-local map tasks=2
                Total time spent by all maps in occupied slots (ms)=123208
                Total time spent by all reduces in occupied slots (ms)=22940
                Total time spent by all map tasks (ms)=61604
                Total time spent by all reduce tasks (ms)=11470
                Total vcore-milliseconds taken by all map tasks=61604
                Total vcore-milliseconds taken by all reduce tasks=11470
                Total megabyte-milliseconds taken by all map tasks=31541248
                Total megabyte-milliseconds taken by all reduce tasks=5872640
        Map-Reduce Framework
                Map input records=793074
                Map output records=793073
                Map output bytes=5551511
                Map output materialized bytes=7137669
                Input split bytes=198
                Combine input records=0
                Combine output records=0
                Reduce input groups=25
                Reduce shuffle bytes=7137669
                Reduce input records=793073
                Reduce output records=25
                Spilled Records=1586146
                Shuffled Maps =2
                Failed Shuffles=0
                Merged Map outputs=2
                GC time elapsed (ms)=980
                CPU time spent (ms)=10390
                Physical memory (bytes) snapshot=668921856
                Virtual memory (bytes) snapshot=6560874496
                Total committed heap usage (bytes)=348274688
                Peak Map Physical memory (bytes)=269639680
                Peak Map Virtual memory (bytes)=2186727424
                Peak Reduce Physical memory (bytes)=150118400
                Peak Reduce Virtual memory (bytes)=2189729792
        Shuffle Errors
                BAD_ID=0
                CONNECTION=0
                IO_ERROR=0
                WRONG_LENGTH=0
                WRONG_MAP=0
                WRONG_REDUCE=0
        File Input Format Counters
                Bytes Read=181964800
        File Output Format Counters
                Bytes Written=245
2026-03-24 15:50:40,656 INFO streaming.StreamJob: Output directory: /user/sakalshathri/project/m1/task4

sakalshathri@master-node:~$ hdfs dfs -cat /user/sakalshathri/project/m1/task4/part-00000
2001	467301
2002	205267
2003	985
2004	915
2005	1031
2006	796
2007	762
2008	1010
2009	910
2010	695
2011	770
2012	800
2013	714
2014	825
2015	1105
2016	1339
2017	1387
2018	1327
2019	1174
2020	1832
2021	2399
2022	4678
2023	81461
2024	880
2025	12710
```

---

## Task 5: Arrest Analysis

**Assigned to**: Sarah Althukair

**Question:** What percentage of crimes result in an arrest?

**Mapper:** `src/mapper_arrest.py` — Extracts Arrest status (column index 8) and emits (True/False, 1).

**Command:**
```bash
mapred streaming \
  -files mapper_arrest.py,reducer_sum.py \
  -mapper "python3 mapper_arrest.py" \
  -reducer "python3 reducer_sum.py" \
  -input /data/chicago_crimes.csv \
  -output /user/salthukair/project/m1/task5
```

**Results:**

| Arrest Status | Count |
|--------------|-------|
| False | 571,140 |
| True | 221,932 |

**Arrest Rate**: 221,932 / 793,072 = **28.0%**

**Interpretation:** Only 28.0% of crimes resulted in an arrest. The remaining 72% did not lead to one. The Police Chief should investigate which crime types and locations have the lowest arrest rates to improve resource allocation.

### Execution Log

```
salthukair@master-node:~$ mapred streaming -files mapper_arrest.py,reducer_sum.py -mapper "python3 mapper_arrest.py" -reducer "python3 reducer_sum.py" -input /data/chicago_crimes.csv -output /user/salthukair/project/m1/task5

packageJobJar: [] [/opt/hadoop-3.4.1/share/hadoop/tools/lib/hadoop-streaming-3.4.1.jar] /tmp/streamjob17484628466311789117.jar tmpDir=null
2026-03-24 15:55:23,159 INFO client.DefaultNoHARMFailoverProxyProvider: Connecting to ResourceManager at master-node/134.209.172.50:8032
2026-03-24 15:55:23,411 INFO client.DefaultNoHARMFailoverProxyProvider: Connecting to ResourceManager at master-node/134.209.172.50:8032
2026-03-24 15:55:23,914 INFO mapreduce.JobResourceUploader: Disabling Erasure Coding for path: /tmp/hadoop-yarn/staging/salthukair/.staging/job_1771402826595_0173
2026-03-24 15:55:25,673 INFO mapred.FileInputFormat: Total input files to process : 1
2026-03-24 15:55:25,700 INFO net.NetworkTopology: Adding a new node: /default-rack/146.190.147.119:9866
2026-03-24 15:55:25,701 INFO net.NetworkTopology: Adding a new node: /default-rack/164.92.103.148:9866
2026-03-24 15:55:26,302 INFO mapreduce.JobSubmitter: number of splits:2
2026-03-24 15:55:27,226 INFO mapreduce.JobSubmitter: Submitting tokens for job: job_1771402826595_0173
2026-03-24 15:55:27,226 INFO mapreduce.JobSubmitter: Executing with tokens: []
2026-03-24 15:55:27,577 INFO conf.Configuration: resource-types.xml not found
2026-03-24 15:55:27,578 INFO resource.ResourceUtils: Unable to find 'resource-types.xml'.
2026-03-24 15:55:27,719 INFO impl.YarnClientImpl: Submitted application application_1771402826595_0173
2026-03-24 15:55:27,783 INFO mapreduce.Job: The url to track the job: http://master-node:8088/proxy/application_1771402826595_0173/
2026-03-24 15:55:27,786 INFO mapreduce.Job: Running job: job_1771402826595_0173
2026-03-24 15:55:45,611 INFO mapreduce.Job: Job job_1771402826595_0173 running in uber mode : false
2026-03-24 15:55:45,613 INFO mapreduce.Job:  map 0% reduce 0%
2026-03-24 15:56:14,756 INFO mapreduce.Job:  map 100% reduce 0%
2026-03-24 15:56:30,230 INFO mapreduce.Job:  map 100% reduce 100%
2026-03-24 15:56:32,995 INFO mapreduce.Job: Job job_1771402826595_0173 completed successfully
2026-03-24 15:56:33,213 INFO mapreduce.Job: Counters: 54
        File System Counters
                FILE: Number of bytes read=7708794
                FILE: Number of bytes written=16360811
                FILE: Number of read operations=0
                FILE: Number of large read operations=0
                FILE: Number of write operations=0
                HDFS: Number of bytes read=181964998
                HDFS: Number of bytes written=25
                HDFS: Number of read operations=11
                HDFS: Number of large read operations=0
                HDFS: Number of write operations=2
                HDFS: Number of bytes read erasure-coded=0
        Job Counters
                Launched map tasks=2
                Launched reduce tasks=1
                Data-local map tasks=2
                Total time spent by all maps in occupied slots (ms)=102776
                Total time spent by all reduces in occupied slots (ms)=25546
                Total time spent by all map tasks (ms)=51388
                Total time spent by all reduce tasks (ms)=12773
                Total vcore-milliseconds taken by all map tasks=51388
                Total vcore-milliseconds taken by all reduce tasks=12773
                Total megabyte-milliseconds taken by all map tasks=26310656
                Total megabyte-milliseconds taken by all reduce tasks=6539776
        Map-Reduce Framework
                Map input records=793074
                Map output records=793072
                Map output bytes=6122644
                Map output materialized bytes=7708800
                Input split bytes=198
                Combine input records=0
                Combine output records=0
                Reduce input groups=2
                Reduce shuffle bytes=7708800
                Reduce input records=793072
                Reduce output records=2
                Spilled Records=1586144
                Shuffled Maps =2
                Failed Shuffles=0
                Merged Map outputs=2
                GC time elapsed (ms)=831
                CPU time spent (ms)=10130
                Physical memory (bytes) snapshot=671739904
                Virtual memory (bytes) snapshot=6564732928
                Total committed heap usage (bytes)=347774976
                Peak Map Physical memory (bytes)=270118912
                Peak Map Virtual memory (bytes)=2186813440
                Peak Reduce Physical memory (bytes)=151232512
                Peak Reduce Virtual memory (bytes)=2191421440
        Shuffle Errors
                BAD_ID=0
                CONNECTION=0
                IO_ERROR=0
                WRONG_LENGTH=0
                WRONG_MAP=0
                WRONG_REDUCE=0
        File Input Format Counters
                Bytes Read=181964800
        File Output Format Counters
                Bytes Written=25
2026-03-24 15:56:33,214 INFO streaming.StreamJob: Output directory: /user/salthukair/project/m1/task5

salthukair@master-node:~$ hdfs dfs -cat /user/salthukair/project/m1/task5/part-00000
False	571140
True	221932
```

---

## Member Contribution

| Member | Task | Contribution |
|--------|------|-------------|
| Sara Alshathri | Task 2 | Wrote mapper_crime_type.py, ran on cluster, documented results |
| Sara Alshathri | Task 4 | Wrote mapper_year.py with date parsing, ran on cluster |
| Sara Alshathri | Shared | Wrote reducer_sum.py (shared reducer), project README |
| Sarah Althukair | Task 3 | Wrote mapper_location.py, ran on cluster, documented results |
| Sarah Althukair | Task 5 | Wrote mapper_arrest.py, ran on cluster, computed arrest rate |
| Sarah Althukair | Scripts | Wrote all execution scripts (scripts/run_task*.sh) |

---

## Repository Structure

```
se446-project-group-Group-S/
├── README.md
├── src/
│   ├── reducer_sum.py
│   ├── mapper_district.py
│   ├── mapper_crime_type.py
│   ├── mapper_location.py
│   ├── mapper_year.py
│   └── mapper_arrest.py
├── scripts/
│   ├── run_lab2_district.sh
│   ├── run_task2.sh
│   ├── run_task3.sh
│   ├── run_task4.sh
│   └── run_task5.sh
└── output/
```
