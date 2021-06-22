SELECT repo, COUNT(*) as count
FROM four_keys.pullrequests
WHERE closed_at IS NOT NULL
  AND repo != 'kubernetes'
  AND TIMESTAMP (DATE_SUB(CURRENT_DATE (), INTERVAL 1 MONTH)) < closed_at
GROUP BY repo