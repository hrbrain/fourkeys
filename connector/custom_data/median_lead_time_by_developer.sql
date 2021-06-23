SELECT author,
       IFNULL(ANY_VALUE(med_time_to_change) / 60, 0) AS median_time_to_change
FROM (
         SELECT PERCENTILE_CONT(
                        IF(TIMESTAMP_DIFF(closed_at, first_commit_at, MINUTE) > 0,
                           TIMESTAMP_DIFF(closed_at, first_commit_at, MINUTE),
                           NULL), 0.5)
                    OVER (PARTITION BY author) AS med_time_to_change,
                author,
                first_commit_at,
                closed_at,
         FROM `hrb-fourkeys.four_keys.pullrequests`
         WHERE closed_at IS NOT NULL
           AND author IS NOT NULL
           AND author != 'hrb-machine'
           AND TIMESTAMP (DATE_SUB(CURRENT_DATE (), INTERVAL 1 MONTH)) < closed_at
     )
GROUP BY author