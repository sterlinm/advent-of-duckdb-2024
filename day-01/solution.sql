-- To execute run "duckdb < solution.sql"
WITH input_data AS (SELECT * FROM read_csv_auto('input.csv')),
list1 AS (
    SELECT row_number() OVER (ORDER BY list1) AS idx, list1
    FROM input_data
    ORDER BY list1
),
list2 AS (
    SELECT row_number() OVER (ORDER BY list2) AS idx, list2
    FROM input_data
    ORDER BY list2
),
distances AS (
    SELECT l1.idx, l1.list1, l2.list2, ABS(l1.list1 - l2.list2) AS distance
    FROM list1 l1
    LEFT JOIN list2 l2 ON l1.idx=l2.idx
)
SELECT SUM(distance) FROM distances;

WITH input_data AS (SELECT * FROM read_csv_auto('input.csv')),
l1 AS (SELECT list1 FROM input_data),
l2 AS (SELECT list2 FROM input_data),
merged AS (
    SELECT list1, list2
    FROM l1
    LEFT JOIN l2 ON l1.list1=l2.list2
    WHERE list2 IS NOT NULL
),
obs_count AS (
    SELECT list1, COUNT(list2) AS n
    FROM merged
    GROUP BY list1
)
SELECT SUM(list1 * n)
FROM obs_count;