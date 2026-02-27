#!/bin/bash
# Run Sara's tasks (Task 2 + Task 4) and save full execution logs.
# Run this script ON THE CLUSTER from project root after: source /etc/profile.d/hadoop.sh

set -e
REPO_ROOT="${REPO_ROOT:-.}"
cd "$REPO_ROOT"

source /etc/profile.d/hadoop.sh

echo "========== Task 2: Crime Type Distribution =========="
hdfs dfs -rm -r /user/$USER/project/m1/task2 2>/dev/null || true

mapred streaming \
  -files src/mapper_crime_type.py,src/reducer_sum.py \
  -mapper "python3 mapper_crime_type.py" \
  -reducer "python3 reducer_sum.py" \
  -input /data/chicago_crimes.csv \
  -output /user/$USER/project/m1/task2 2>&1 | tee task2_log.txt

echo ""
echo "========== Task 4: Crime Trends by Year =========="
hdfs dfs -rm -r /user/$USER/project/m1/task4 2>/dev/null || true

mapred streaming \
  -files src/mapper_year.py,src/reducer_sum.py \
  -mapper "python3 mapper_year.py" \
  -reducer "python3 reducer_sum.py" \
  -input /data/chicago_crimes.csv \
  -output /user/$USER/project/m1/task4 2>&1 | tee task4_log.txt

echo ""
echo "Done. Logs saved: task2_log.txt, task4_log.txt"
echo "Download to your laptop: scp $USER@134.209.172.50:~/task2_log.txt ~/task4_log.txt ."
