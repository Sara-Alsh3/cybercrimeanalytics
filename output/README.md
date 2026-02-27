# Output (Results)

This folder is for storing **local copies** of MapReduce results (e.g., `part-00000` or summaries) if you download them from the cluster for your report.

On the cluster, results live in HDFS at:
- `/user/$USER/project/m1/task2/`
- `/user/$USER/project/m1/task3/`
- `/user/$USER/project/m1/task4/`
- `/user/$USER/project/m1/task5/`

View with: `hdfs dfs -cat /user/$USER/project/m1/taskX/part-00000`
