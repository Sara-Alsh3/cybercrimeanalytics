#!/bin/bash
# Task 5: Arrest Analysis
# Run this script from the project root on the cluster

source /etc/profile.d/hadoop.sh

# Delete output directory if it exists
hdfs dfs -rm -r /user/$USER/project/m1/task5 2>/dev/null

mapred streaming \
  -files src/mapper_arrest.py,src/reducer_sum.py \
  -mapper "python3 mapper_arrest.py" \
  -reducer "python3 reducer_sum.py" \
  -input /data/chicago_crimes.csv \
  -output /user/$USER/project/m1/task5

echo "=== Task 5 Results ==="
hdfs dfs -cat /user/$USER/project/m1/task5/part-00000
