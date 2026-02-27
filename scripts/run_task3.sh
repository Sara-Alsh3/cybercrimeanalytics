#!/bin/bash
# Task 3: Location Hotspots
# Run this script from the cluster after sourcing Hadoop environment

source /etc/profile.d/hadoop.sh

# Delete output directory if it exists
hdfs dfs -rm -r /user/$USER/project/m1/task3 2>/dev/null

mapred streaming \
  -files src/mapper_location.py,src/reducer_sum.py \
  -mapper "python3 mapper_location.py" \
  -reducer "python3 reducer_sum.py" \
  -input /data/chicago_crimes.csv \
  -output /user/$USER/project/m1/task3

echo "=== Task 3 Results ==="
hdfs dfs -cat /user/$USER/project/m1/task3/part-00000
