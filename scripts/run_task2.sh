#!/bin/bash
# Task 2: Crime Type Distribution
# Run this script from the cluster after sourcing Hadoop environment

source /etc/profile.d/hadoop.sh

# Delete output directory if it exists
hdfs dfs -rm -r /user/$USER/project/m1/task2 2>/dev/null

mapred streaming \
  -files src/mapper_crime_type.py,src/reducer_sum.py \
  -mapper "python3 mapper_crime_type.py" \
  -reducer "python3 reducer_sum.py" \
  -input /data/chicago_crimes.csv \
  -output /user/$USER/project/m1/task2

echo "=== Task 2 Results ==="
hdfs dfs -cat /user/$USER/project/m1/task2/part-00000
