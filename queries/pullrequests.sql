CREATE
TEMP FUNCTION json2array(json STRING)
RETURNS ARRAY<STRING>
LANGUAGE js AS """
  return json && JSON.parse(json).map(x=>x.name);
""";

SELECT opened.id                 as id,
       opened.time_created       as opened_at,
       closed.time_created       as closed_at,
       push.author               as author,
       json2array(closed.labels) as labels,
       opened.first_commit       as first_commit_sha,
       push.time_created         as first_commit_at,
       opened.repo               as repo

FROM # opened pull request
     (SELECT DISTINCT time_created,
                      id,
                      JSON_VALUE(metadata, '$.pull_request.head.sha') as first_commit,
                      JSON_VALUE(metadata, '$.repository.name')       as repo
      FROM `four_keys.events_raw`
      WHERE event_type = 'pull_request'
        AND source = 'github'
        AND JSON_VALUE(metadata, '$.action') = 'opened') opened

     # closed pull request
         LEFT JOIN
     (SELECT DISTINCT time_created,
                      id,
                      JSON_QUERY(metadata, '$.pull_request.labels') as labels,
                      JSON_VALUE(metadata, '$.repository.name')     as repo
      FROM `four_keys.events_raw`
      WHERE event_type = 'pull_request'
        AND source = 'github'
        AND (JSON_VALUE(metadata, '$.action') = 'closed'
          AND JSON_VALUE(metadata, '$.pull_request.merged') = 'true')) closed
ON closed.id = opened.id AND opened.repo = closed.repo

    # first commit
    JOIN
    (SELECT DISTINCT time_created,
    id,
    JSON_VALUE(metadata, '$.head_commit.author.username') as author
    FROM `four_keys.events_raw`
    WHERE event_type = 'push'
    AND source = 'github') push
    ON push.id = opened.first_commit