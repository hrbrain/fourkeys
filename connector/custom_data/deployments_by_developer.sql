SELECT
assignee,
COUNT(*) as count
FROM `hrb-fourkeys.four_keys.pullrequests`
WHERE assignee IS NOT NULL
  AND closed_at IS NOT NULL
  AND TIMESTAMP (DATE_SUB(CURRENT_DATE (), INTERVAL 1 MONTH)) < closed_at
GROUP BY assignee