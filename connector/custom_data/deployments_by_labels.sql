SELECT labels, COUNT(*) as count
FROM (SELECT labels FROM four_keys.pullrequests WHERE closed_at IS NOT NULL) l, l.labels
GROUP BY labels