
CREATE TABLE raw_input_data AS
FROM read_csv_auto(
    'input.csv',
    delim='^',
    header=false,
    columns={input_data:VARCHAR}
);

WITH stage1 AS (
    SELECT
        input_data[:2]::INT AS page_num,
        input_data[4:]::INT AS before_page
    FROM raw_input_data
    WHERE '|' IN input_data
)
SELECT
    page_num,
    list_distinct(list(before_page))
FROM stage1
GROUP BY page_num
ORDER BY page_num
LIMIT 10;