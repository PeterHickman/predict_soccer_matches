--
-- Dump all the completed matches from the database
--

SELECT
  m.id,
  m.home_team_id,
  h.name AS home_team_name,
  m.away_team_id,
  a.name AS away_team_name,
  c.id AS competition_id,
  c.name AS competition_name,
  m.neutral_venue,
  m.home_fulltime,
  m.away_fulltime,
  m.start_time
FROM
  matches AS m, teams AS h, teams AS a, seasons AS s, competitions AS c
WHERE
  m.completed = true
  AND
  m.abandoned = false
  AND
  m.deleted = false
  AND
  m.home_team_id = h.id
  AND
  m.away_team_id = a.id
  AND
  m.season_id = s.id
  AND
  s.competition_id = c.id;
