CREATE TABLE matches (
  id             INTEGER NOT NULL,
  home_team_id   INTEGER NOT NULL,
  away_team_id   INTEGER NOT NULL,
  competition_id INTEGER NOT NULL,
  neutral_venue  BOOLEAN NOT NULL,
  home_fulltime  INTEGER NOT NULL,
  away_fulltime  INTEGER NOT NULL,
  outcome        STRING NOT NULL,
  start_time     DATE NOT NULL,
  top_tier       BOOLEAN NULL
);

CREATE UNIQUE INDEX matches_id ON matches (id);
CREATE INDEX matches_start_time ON matches (start_time);

CREATE TABLE teams (
  id   INTEGER NOT NULL,
  name STRING NOT NULL
);

CREATE TABLE competitions (
  id          INTEGER NOT NULL,
  name        STRING NOT NULL,
  top_tier    BOOLEAN NULL
);
