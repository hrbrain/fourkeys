SELECT
assignee,
COUNT(*) as count
FROM `hrb-fourkeys.four_keys.pullrequests`
WHERE assignee IS NOT NULL
AND closed_at IS NOT NULL
GROUP BY assignee