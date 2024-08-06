# Predicting the outcome of soccer matches based on past performance

The objective of this project is to see if it is possible to predict the outcome of soccer matches (home win, draw or away win) based solely on the team's history

The minimum data would be

1. The match date
2. The home team
3. The away team
4. The competition or league
5. The match outcome

It is important to distinguish the club from the team. Some data sources will have Chelsea, Chelsea Women and Chelsea U21 as a single team, Chelsea, with the competition indicating the difference. For this to work the teams must not be ambiguous

You will also want a lot of data, my database starts at 1998-09-30 and contains 948,386 matches

## Where is the data?

I work for a sports data company and the data I am using I "borrowed" from work. We, the company, bought the data from several sources over the years and the data was supplied under contract. One of the clauses common to all the contracts was "no not redistribute"

I'm sure that with some scraping you could build a usable database and would realistically require only a couple of years worth of data to make predictions. But I am unwilling to jeopardise my livelihood for internet points. Sorry you've got to solve this for yourself

## Build the database

The schema is in `schema.sql` and describes the minimum data required. Note that we only need the date of the match and not the kick off time. The `HH:MM` is superfluous when a team only plays one match a day

The `export_completed_matches.sql` script exports the data from the company database and `import`	will import it. To keep the database size down the teams and competitions are stored in other tables

The one thing of note is that `import` flags what it considers "top tier" competitions. This is an arbitrary definition to signify that the teams within the competition are more "professional" and their performance can be considered more stable and therefore predictable

This is a heuristic that seems to work but don't take my list as definitive

## The workflow

This is embedded in `wf`

```bash
#!/usr/bin/env bash

TS=$1

[ -e historical.txt ] && rm historical.txt
[ -e target.txt ] && rm target.txt
[ -e results.csv ] && rm results.csv

./extract ${TS}
./knn
./check
```

Here is an example run

```bash
$ ./wf 2024-08-03
[EXTRACT] Extracting matches before 2024-08-03 into historical.txt
[EXTRACT] Extracting matches on 2024-08-03 into target.txt
[KNN] Of 112 matches wrote 10 predictions into results.csv
[CHECK] match_id:2217052 home_win Correct!!!
[CHECK] match_id:2216968 away_win Failed, outcome was home_win
[CHECK] match_id:2217254 home_win Correct!!!
[CHECK] match_id:2218444 home_win Failed, outcome was away_win
[CHECK] match_id:2217398 away_win Correct!!!
[CHECK] match_id:2148522 away_win Correct!!!
[CHECK] match_id:2176040 home_win Correct!!!
[CHECK] match_id:2092006 home_win Failed, outcome was draw
[CHECK] match_id:2157120 home_win Correct!!!
[CHECK] match_id:2102292 home_win Correct!!!
[CHECK] Correctly predicted 7 of 10 matches (70.0%)
```

## Walking through the code

First you should note that the priority of the code was to allow experimentation, performance was not an issue and it still contains some residual code

### Extracting the data `extract`

Give a date for which to predict matches for we first get a list of the "top tier" competition to filter our data by. Next we build a tree of the outcome of matches a team has played by which side (home or away) and the outcome

```
11622=>
  {:home=>
    {"2021-08-05"=>"home_win",
     "2021-08-19"=>"home_win",
      ...
     "2024-07-18"=>"away_win",
     "2024-07-25"=>"home_win"},
   :away=>
    {"2021-08-13"=>"away_win",
     "2021-08-28"=>"home_win",
	  ...
     "2024-07-11"=>"home_win",
     "2024-07-30"=>"home_win"}},
```

Then we walk over all the matches prior to the date we are trying to predict and write some historical data into `historical.txt`. The format is understood by the next step but is basically

```
---
0.14285714285714285
0.857142857142857
0.5714285714285714
0.42857142857142855
match_id 1651904
outcome draw
start_time 2021-10-06
home_team Valour FC
away_team Cavalry FC
competition Canadian Premier League
```

The first value is the percentage of home matches the home team has won, the next is the number they have lost. Then the same for the away team's away performance. These value are calculated from the previous 19 (magic number) home matches that the home team played and the previous 19 away team matches that the away team has played

Any team with less that 7 (another magic number) previous matches are rejected as having insufficient data

The process is then repeated for all the matches that we want to predict as `target.txt`

Note that there is a lot of unnecessary work being done here, there are only 112 matches in our example, so only 224 teams yet we build the tree for all 1,960 teams in the historical data. We could cut down the amount of work being done by only processing matches that teams we are trying to predict played in. But it has not been much of an issue so far

Also the tree is static and could probably be added to the database and updated when new data is added there

### Predicting `knn`

The historical data from `historical.txt` get loaded into a dataset to be used by the KNN algorithm. Then for each match in `target.txt` a search is made based on euclidean distance for the three possible outcomes, home win, draw or away win

Taking the nearest 11 (yet another magic number, YAMN) results the three outcomes are weighted by their popularity according to how close they were to the match we are trying to predict. The values are normalised to that magic values can change without breaking the heuristics below

Having made a prediction we apply some human *intuition* to throw out the predictions most likely to fail

|Rule|Outcome|
|---|---|
|Predicted outcome is "draw"|Reject the prediction. Draw predictions are almost never correct|
|All three outcomes are present|Reject the prediction. If all three outcomes are presented then the likelihood is that any of the outcomes could occur. This is soccer not science!|
|There is only one predicted outcome|Accept the prediction|
|There are two outcomes|We will accept the outcome if the most likely outcome has a value 0.2 (YAMN) greater than the other. Otherwise reject|

The result is a very conservative predictor but has a better than 70% success rate

## Afterword

My first attempt at this was barely better than average so I am happy with how this went. The various magic numbers were pulled out of thin air but seem to work. The next step would be to see what changing these values would be achieve

Another project for another day

