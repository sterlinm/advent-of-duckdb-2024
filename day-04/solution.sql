
SELECT
    lag(letters[:3], 3) OVER () AS lag3,
    lag(letters[:3], 2) OVER () AS lag2,
    lag(letters[:3], 1) OVER () AS lag1,
    letters[:3],
    lead(letters[:3], 1) OVER () AS lead1,
FROM read_csv_auto(
    'input.csv',
    header=false,
    columns={letters:VARCHAR}
)
LIMIT 4;

SELECT letters
FROM read_csv_auto(
    'input.csv',
    header=false,
    columns={letters:VARCHAR}
)
LIMIT 3;
