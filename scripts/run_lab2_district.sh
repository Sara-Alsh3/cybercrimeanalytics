#!/bin/bash
# Lab 2: Arrests by District (sample data)
# Run this script from the project root on the cluster

source /etc/profile.d/hadoop.sh

hdfs dfs -rm -r /user/$USER/lab02/district_arrests 2>/dev/null

mapred streaming \
  -files src/mapper_district.py,src/reducer_sum.py \
  -mapper "python3 mapper_district.py" \
  -reducer "python3 reducer_sum.py" \
  -input /data/chicago_crimes_sample.csv \
  -output /user/$USER/lab02/district_arrests

echo "=== Lab 2 Results: Arrests by District ==="
hdfs dfs -cat /user/$USER/lab02/district_arrests/part-00000
