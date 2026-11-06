
USE nba;

CREATE TABLE player_season_stats (
    id INT AUTO_INCREMENT PRIMARY KEY,
    rk INT,
    player VARCHAR(100),
    age INT,
    team VARCHAR(10),
    pos VARCHAR(10),
    g INT,
    gs INT,
    mp INT,
    fg INT,
    fga INT,
    fg_pct DECIMAL(5,3),
    three_p INT,
    three_pa INT,
    three_pct DECIMAL(5,3),
    two_p INT,
    two_pa INT,
    two_pct DECIMAL(5,3),
    efg_pct DECIMAL(5,3),
    ft INT,
    fta INT,
    ft_pct DECIMAL(5,3),
    orb INT,
    drb INT,
    trb INT,
    ast INT,
    stl INT,
    blk INT,
    tov INT,
    pf INT,
    pts INT,
    awards VARCHAR(255),
    player_additional VARCHAR(255)
);
CREATE TABLE team_stats (
    id INT AUTO_INCREMENT PRIMARY KEY,
    rk INT,
    team VARCHAR(10),
    g INT,
    mp INT,
    fg INT,
    fga INT,
    fg_pct DECIMAL(5,3),
    three_p INT,
    three_pa INT,
    three_pct DECIMAL(5,3),
    two_p INT,
    two_pa INT,
    two_pct DECIMAL(5,3),
    ft INT,
    fta INT,
    ft_pct DECIMAL(5,3),
    orb INT,
    drb INT,
    trb INT,
    ast INT,
    stl INT,
    blk INT,
    tov INT,
    pf INT,
    pts INT
);

DROP TABLE IF EXISTS team_name_map;

CREATE TABLE team_name_map (
    full_name VARCHAR(50),
    abbrev VARCHAR(5)
);
SHOW tables;
