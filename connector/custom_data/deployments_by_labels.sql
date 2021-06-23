SELECT labels, COUNT(*) as count
FROM (
    SELECT labels
    FROM four_keys.pullrequests
    WHERE closed_at IS NOT NULL
    AND TIMESTAMP (DATE_SUB(CURRENT_DATE (), INTERVAL 1 MONTH)) < closed_at
    ) l, l.labels
GROUP BY labels