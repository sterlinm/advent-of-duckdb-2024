WITH stage1 AS (
    SELECT
        unnest(regexp_extract_all(instructions, '(mul\([0-9]+,[0-9]+\)|do\(\)|don''t\(\))')) AS op,
    FROM read_csv_auto(
        'input.csv',
        delim='|',
        header=false,
        columns={instructions:VARCHAR}
    )
), stage2 AS (
    SELECT
        op,
        COALESCE(lag(CASE WHEN op IN ('do()', 'don''t()') THEN op ELSE NULL END IGNORE NULLS) OVER (), 'do()') AS mask
    FROM stage1
), stage3 AS (
    SELECT
        op,
        mask,
        list_product(list_transform(regexp_extract_all(op, '[0-9]+'), x -> x::int)) AS prod,
    FROM stage2
    WHERE op NOT IN ('do()', 'don''t()')
)
SELECT
    SUM(prod)::int AS 'Star 1',
    SUM(prod) filter (mask = 'do()')::int AS 'Star 2'
FROM stage3;