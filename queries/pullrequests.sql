CREATE
TEMP FUNCTION json2array(json STRING)
RETURNS ARRAY<STRING>
LANGUAGE js AS """
  return json && JSON.parse(json).map(x=>x.name);
""";

SELECT opened.id                 as id,
       opened.time_created       as opened_at,
       closed.time_created       as closed_at,
       closed.assignee           as assignee,
       json2array(closed.labels) as labels,
       opened.first_commit       as first_commit_sha,
       push.time_created         as first_commit_at,
       opened.repo               as repo
FROM (SELECT id,
             time_created,
             JSON_VALUE(metadata, '$.pull_request.head.sha') as first_commit,
             JSON_VALUE(metadata, '$.repository.name')       as repo
      FROM `four_keys.events_raw`
      WHERE event_type = 'pull_request'
        AND source = 'github'
        AND JSON_VALUE(metadata, '$.action') = 'opened') opened
         LEFT JOIN
     (SELECT id,
             time_created,
             JSON_VALUE(metadata, '$.pull_request.assignee.login') as assignee,
             JSON_QUERY(metadata, '$.pull_request.labels')         as labels
      FROM `four_keys.events_raw`
      WHERE event_type = 'pull_request'
        AND source = 'github'
        AND (JSON_VALUE(metadata, '$.action') = 'closed' AND
             JSON_VALUE(metadata, '$.pull_request.merged') = 'true')) closed
     on closed.id = opened.id
         JOIN
     (SELECT id,
             time_created
      FROM `four_keys.events_raw`) push on push.id = opened.first_commit