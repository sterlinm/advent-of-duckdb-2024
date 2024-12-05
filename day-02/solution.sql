CREATE MACRO get_possible_reports(lst) AS
list_concat(
    [lst],
    list_transform(
        range(1, len(lst) + 1),
        x -> list_filter(lst, (v, i) -> i <> x)
    )
);

CREATE MACRO report_is_monotonic(lst) AS
lst IN (list_sort(lst), list_reverse_sort(lst));

CREATE MACRO report_is_gradual(lst) AS
list_distinct(
    list_transform(
        list_zip(lst[:-2], lst[2:]),
        x -> abs(x[2] - x[1]) between 1 and 3
    )
) = [true];

CREATE MACRO report_is_safe(lst) AS
report_is_monotonic(lst)=true AND report_is_gradual(lst)=true;

WITH reports AS (
    SELECT
        row_number() OVER () AS report_number,
        get_possible_reports(list_transform(string_split(level, ' '), v -> v::int)) AS possible_reports,
        unnest(possible_reports) AS report_values,
        generate_subscripts(possible_reports, 1) AS report_index,
        report_is_safe(report_values) AS is_safe
    FROM read_csv('input.csv', columns={level:varchar}, header=false)
)
SELECT
    count(distinct report_number) filter (report_index = 1 AND is_safe=true) AS 'Star 1',
    count(distinct report_number) filter (is_safe=true) AS 'Star 2',
FROM reports;