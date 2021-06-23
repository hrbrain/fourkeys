WITH last_three_months AS (
    SELECT
    TIMESTAMP (day) AS day
FROM
    UNNEST(
    GENERATE_DATE_ARRAY(
    DATE_SUB(CURRENT_DATE (), INTERVAL 3 MONTH),
    CURRENT_DATE (),
    INTERVAL 1 DAY)) AS day
    # FROM the start of the data
WHERE day
    > (SELECT date (min (time_created)) FROM four_keys.events_raw)
    )
SELECT FORMAT_TIMESTAMP('%Y%m%d', day) AS day,
  # Daily metrics
  deployments,
  median_time_to_change,
FROM
    (
    SELECT
    e.day,
    IFNULL(COUNT (DISTINCT id), 0) AS deployments,
    IFNULL(ANY_VALUE(med_time_to_change) / 60, 0) AS median_time_to_change
    FROM last_three_months e
    LEFT JOIN
    (
    SELECT
    p.id,
    TIMESTAMP_TRUNC(p.closed_at, DAY) AS day,
    ##### Median Time to Change
    PERCENTILE_CONT( # Ignore automated pushes
    IF(
    TIMESTAMP_DIFF(p.closed_at, p.first_commit_at, MINUTE) > 0,
    TIMESTAMP_DIFF(p.closed_at, p.first_commit_at, MINUTE),
    NULL),
    0.5)
    OVER (
    PARTITION BY TIMESTAMP_TRUNC(p.closed_at, DAY)
    ) AS med_time_to_change
    FROM four_keys.pullrequests p, p.labels
    ) p
    ON p.day = e.day
    GROUP BY day
    );