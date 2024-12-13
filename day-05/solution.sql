
CREATE TABLE raw_input_data AS
FROM read_csv_auto(
    'input.csv',
    delim='^',
    header=false,
    columns={input_data:VARCHAR}
);

CREATE TABLE page_ordering_rules AS
WITH stage1 AS (
    SELECT
        input_data[:2]::INT AS page_num,
        input_data[4:]::INT AS before_page
    FROM raw_input_data
    WHERE '|' IN input_data
)
SELECT
    page_num,
    list_distinct(list(before_page)) AS later_pages
FROM stage1
GROUP BY page_num
ORDER BY page_num;

FROM page_ordering_rules
LIMIT 1;

CREATE TABLE manual_updates AS
WITH stage1 AS (
    SELECT
        row_number() OVER () AS update_number,
        list_transform(string_split(input_data, ','), x -> x::int) AS update_pages,
        update_pages[CEIL(len(update_pages) / 2)::int] AS middle_page
    FROM raw_input_data
    WHERE ',' IN input_data
)
SELECT
    update_number,
    middle_page,
    unnest(update_pages) AS update_page_number,
    generate_subscripts(update_pages, 1) AS update_page_index,
FROM stage1;

WITH stage1 AS (
    SELECT
        u1.update_number,
        u1.update_page_number,
        u1.update_page_index,
        u2.update_page_number AS preceding_page
    FROM manual_updates u1
    JOIN manual_updates u2 ON u1.update_number=u2.update_number AND u1.update_page_index >= u2.update_page_index
    ORDER BY u1.update_number, u1.update_page_index, u2.update_page_index
), stage2 AS (
    SELECT
        update_number,
        update_page_number,
        update_page_index,
        list(preceding_page)[:-2] AS preceding_pages
    FROM stage1
    GROUP BY update_number, update_page_number, update_page_index
    ORDER BY update_number, update_page_index
),
stage3 AS (
    SELECT
        s.*,
        r.later_pages,
        list_has_any(s.preceding_pages, r.later_pages) AS is_rule_violation
    FROM stage2 s
    LEFT JOIN page_ordering_rules r ON s.update_page_number=r.page_num
),
stage4 AS (
SELECT
    s.update_number,
    MAX(s.is_rule_violation) AS has_rule_violation,
    ANY_VALUE(u.middle_page) AS middle_page
FROM stage3 s
JOIN manual_updates u ON s.update_number = u.update_number
GROUP BY s.update_number
HAVING has_rule_violation = false
)
SELECT SUM(middle_page)
FROM stage4;