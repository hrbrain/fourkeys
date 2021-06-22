SELECT
author,
COUNT(*) as count
FROM `hrb-fourkeys.four_keys.pullrequests`
WHERE author IS NOT NULL
  AND author != 'hrb-machine'
  AND closed_at IS NOT NULL
  AND TIMESTAMP (DATE_SUB(CURRENT_DATE (), INTERVAL 1 MONTH)) < closed_at
GROUP BY author