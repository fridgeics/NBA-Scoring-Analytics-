NBA Scoring Analytics — MySQL Project
An independent basketball analytics project using MySQL to explore NBA scoring efficiency, shooting volume, and how players compare with their teammates and the league.
Project overview
This project combines player statistics, team statistics, and a team-name mapping table to calculate conventional shooting measures alongside a custom Adjusted True Shooting Value (Adjusted TSVal). The aim is to compare players who score at different volumes and efficiencies, not to claim a complete measure of player impact.
Tools and skills
- MySQL and MySQL Workbench
- SQL joins, common table expressions (CTEs), aggregate functions, subqueries, and calculated columns
- Data cleaning and matching team abbreviations to full names
- Basketball statistics and exploratory analysis

True Shooting Attempts (TSA)
TSA = FGA + 0.44 × FTA
True Shooting Percentage (TS%)
TS% = PTS / (2 × TSA)
Team TS% without the player
Team TS% without player = (Team PTS − Player PTS)
    / [2 × (Team TSA − Player TSA)]
TS relative to teammates
TS Relative = Player TS% − Team TS% without player
True Shooting Value (TSVal) — points above the league's overall TS% benchmark, at the same shooting volume:
TSVal = Player PTS − 2 × Player TSA × League TS%
TSVal/G = TSVal / Games Played
Adjusted TSVal per game — a custom scoring-volume adjustment:
Adjusted TSVal/G = TSVal/G
    + 0.05 × (Player TSA/G − League Average Player TSA/G)
The default volume coefficient is 0.05. Players with more TSA/game than the qualifying-player average receive a small bonus; players below that average receive a deduction. This coefficient is an analytical choice, not an official NBA measure. It is mathematically equivalent for ranking purposes to lowering the TS% comparison baseline by 2.5 percentage points.

An additional exploratory column, player_tpts, is defined as PTS − TSA; it is not the player's actual total points or an official NBA statistic.
How the calculations work
1. Load the player, team, and team-name mapping tables into MySQL.
2. Compute overall league TS% using summed team points, FGA, and FTA.
3. Compute the average qualifying player's TSA/game using player rows.
4. Join each player's team abbreviation with its team statistics.
5. Calculate individual efficiency, teammate-relative efficiency, TSVal, and Adjusted TSVal/G.
6. Sort by Adjusted TSVal/G to examine the leaderboard.
Example query
USE nba;

WITH league_stats AS (
    SELECT SUM(pts) / NULLIF(2 * (SUM(fga) + 0.44 * SUM(fta)), 0)
        AS league_ts
    FROM team_stats
),
player_averages AS (
    SELECT AVG((fga + 0.44 * fta) / NULLIF(g, 0)) AS avg_tsa_pg
    FROM nba_import
    WHERE fga > 10 AND team NOT IN ('2TM', '3TM') AND g > 0
)
SELECT
    p.player,
    p.team,
    ROUND(p.pts / NULLIF(p.g, 0), 2) AS ppg,
    ROUND(p.pts / NULLIF(2 * (p.fga + 0.44 * p.fta), 0), 3) AS player_ts,
    ROUND(
        (p.pts - 2 * (p.fga + 0.44 * p.fta) * l.league_ts)
        / NULLIF(p.g, 0)
        + 0.05 * (
            (p.fga + 0.44 * p.fta) / NULLIF(p.g, 0)
            - a.avg_tsa_pg
        ), 3
    ) AS adjusted_tsval_pg
FROM nba_import p
CROSS JOIN league_stats l
CROSS JOIN player_averages a
WHERE p.fga > 10 AND p.team NOT IN ('2TM', '3TM') AND p.g > 0
ORDER BY adjusted_tsval_pg DESC;
Interpretation and limitations
- Adjusted TSVal measures production relative to a chosen scoring benchmark. It does not measure complete offensive value or determine causation.
- It excludes shot creation, assists, turnovers, defense, shot difficulty, and differences in role.
- The 0.44 free-throw coefficient estimates scoring attempts; it is not an exact possession count.
- Very short player samples can produce misleading rankings. A games-played filter (such as 20 or 40 games) helps with season comparisons.
- Traded players may have separate team-specific records; exclude combined 2TM/`3TM` rows to avoid duplication, or aggregate to one full-season record per player for a different analysis.
- League TS% is a ratio of total points to total estimated TSA, whereas league average TSA/game is the arithmetic mean of qualifying player-row TSA/game.
Data source
Player statistics and team statistics are based on Basketball-Reference, including its 2025–26 player totals. Basketball-Reference is credited as the source; the custom formulas and SQL analysis are independent. Check the data provider's reuse conditions before uploading raw datasets to a public repository.
Future improvements
- Consolidate traded players into one record per season.
- Add minimum-games and minimum-attempt filters to leaderboard queries.
- Incorporate turnovers and shot-creation information when available.
- Compare adjusted scoring rankings across seasons.
- Create visualizations to compare scoring volume and efficiency.
Author
Gavin Kerr — independent NBA analytics / SQL portfolio project.
