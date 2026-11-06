USE nba;

WITH league_stats AS (
    SELECT
        SUM(pts) / (2 * (SUM(fga) + 0.44 * SUM(fta))) AS league_ts
    FROM team_stats
),

player_averages AS (
    SELECT
        AVG(fga + 0.44 * fta) AS avg_tsa,
        AVG(pts - (fga + 0.44 * fta)) AS avg_tpts
        
    FROM nba_import
    WHERE fga > 10
      AND team NOT IN ('2TM', '3TM')
)

SELECT
    p.player,
    p.team,

    -- Player TS%
    ROUND(
        p.pts / (2 * (p.fga + 0.44 * p.fta)),
        3
    ) AS player_ts,

    -- Player TSA
    ROUND(
        p.fga + 0.44 * p.fta,
        3
    ) AS player_tsa,

    -- Player TPTS
    ROUND(
        p.pts - (p.fga + 0.44 * p.fta),
        3
    ) AS player_tpts,

    -- Team TS% without player
    ROUND(
        (t.pts - p.pts) /
        (2 * ((t.fga - p.fga) + 0.44 * (t.fta - p.fta))),
        3
    ) AS team_ts_without_player,

    -- Player TS relative to team
    ROUND(
        p.pts / (2 * (p.fga + 0.44 * p.fta)) -
        (t.pts - p.pts) /
        (2 * ((t.fga - p.fga) + 0.44 * (t.fta - p.fta))),
        3
    ) AS ts_relative,

    -- League TS%
    ROUND(l.league_ts, 3) AS league_avg_ts,

    -- Average player TSA in league
    ROUND(a.avg_tsa, 3) AS league_avg_tsa,

    -- Average player TPTS in league
    ROUND(a.avg_tpts, 3) AS league_avg_tpts,
    

    -- Points above/below league-average TS%
    ROUND(
        p.pts -
        (2 * (p.fga + 0.44 * p.fta) * l.league_ts)
        
        +

        0.05 * (
            (p.fga + 0.44 * p.fta) 
            - a.avg_tsa
        ),
        3
    ) AS ts_val
	

FROM nba_import p

JOIN team_name_map m ON p.team = m.abbrev
JOIN team_stats t ON t.team = m.full_name

CROSS JOIN league_stats l
CROSS JOIN player_averages a

WHERE p.fga >10
  AND p.team NOT IN ('2TM', '3TM')

ORDER BY ts_val DESC;