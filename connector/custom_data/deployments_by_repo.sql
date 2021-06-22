SELECT repo, COUNT(*) as count
FROM four_keys.pullrequests
WHERE closed_at IS NOT NULL
GROUP BY repo