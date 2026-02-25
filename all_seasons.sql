SELECT * FROM nba_player_stats.all_seasons;

ALTER TABLE nba_player_stats.all_seasons RENAME COLUMN `MyUnknownColumn` TO `Player_id`;
-- Data Cleaning Procedure:
-- 1. TRIM all text/VARCHAR columns
-- 2. The draft_year, draft_round and draft_number columns are originally strings because they have a "Undrafted".	Plan is to set all "Undrafted" to NULL and CAST the affected columns as INT
-- 3. The season column came in the format "1996-97" .Plan is to extract the starting seasons "1996" according to NBA conventions and cast as INT
-- Checking for duplicates 
SELECT Player_id ,COUNT(Player_id)
FROM nba_player_stats.all_seasons
GROUP BY Player_id
HAVING COUNT(Player_id)>1;

UPDATE all_seasons
SET 
	player_name = NULLIF(TRIM(player_name), ""),
    team_abbreviation = NULLIF(TRIM(team_abbreviation), ""),
    college = NULLIF(TRIM(college), ""),
    country = TRIM(country),
	draft_year = CAST(NULLIF(TRIM(draft_year), "Undrafted") AS UNSIGNED),
    draft_round = CAST(NULLIF(TRIM(draft_round), "Undrafted") AS UNSIGNED),
    draft_number = CAST(NULLIF(TRIM(draft_number), "Undrafted") AS UNSIGNED),
    season = CAST(LEFT(TRIM(season), 4) AS UNSIGNED);
    
-- Standardize data 
SELECT player_weight
FROM nba_player_stats.all_seasons;

SELECT 
player_name,
ROUND(player_weight,0)
FROM nba_player_stats.all_seasons;

UPDATE nba_player_stats.all_seasons
SET player_weight = ROUND(player_weight,0);

SELECT 
    player_name,
    ROUND(oreb_pct, 2) AS oreb_pct_clean
FROM nba_player_stats.all_seasons;

UPDATE nba_player_stats.all_seasons
SET oreb_pct =ROUND(oreb_pct, 2);

SELECT 
    player_name,
    ROUND(dreb_pct, 2) AS dreb_pct_clean
FROM nba_player_stats.all_seasons;

UPDATE nba_player_stats.all_seasons
SET dreb_pct =  ROUND(dreb_pct, 2);

UPDATE nba_player_stats.all_seasons
SET usg_pct =  ROUND(usg_pct, 2);

UPDATE nba_player_stats.all_seasons
SET ts_pct = ROUND(ts_pct,2);

UPDATE nba_player_stats.all_seasons 
SET 
    ast_pct = ROUND(ast_pct, 2);

-- 1.Which players lead their seasons in scoring, rebounding, and playmaking - and how efficient are they?

--  1. Player Performance Analysis
-- Rank players in each season by points, rebounds, assists per game.
-- Compare efficiency stats (TS% vs usage%) - do volume scorers sacrifice efficiency?
-- Identify most improved players across seasons (biggest jump in points/rebounds/assists).
-- Rank players in each season by points, rebounds, assists per game.

-- Ranking by points 
SELECT season,player_name,pts,
RANK()OVER(PARTITION BY season ORDER BY pts DESC) AS rank_pts
FROM all_seasons;

-- Ranking by rebounds
SELECT season,player_name,reb,RANK()OVER(PARTITION BY season ORDER BY reb DESC) AS rank_reb
FROM all_seasons;

-- Ranking by ast
SELECT season,player_name,ast,RANK()OVER(PARTITION BY season ORDER BY ast DESC) AS rank_ast
FROM all_seasons;

-- Compare efficiency stats (TS% vs usage%) - do volume scorers sacrifice efficiency?
SELECT 
player_name,
AVG(ts_pct) AS AVG_ts_pct,
AVG(usg_pct) AS AVG_usg_pct
FROM all_seasons
GROUP BY player_name
ORDER BY AVG_ts_pct DESC,AVG_usg_pct DESC;

-- Identify most improved players across seasons (biggest jump in points/rebounds/assists).
WITH season_diff AS (
    SELECT 
        player_name,
        season,
        pts,
        reb,
        ast,
        LAG(pts) OVER (PARTITION BY player_name ORDER BY season) AS prev_pts,
        LAG(reb) OVER (PARTITION BY player_name ORDER BY season) AS prev_reb,
        LAG(ast) OVER (PARTITION BY player_name ORDER BY season) AS prev_ast
    FROM nba_player_stats.all_seasons
)

SELECT
    player_name,
    season,
    ROUND(pts - prev_pts, 2) AS pts_improvement,
    ROUND(reb - prev_reb, 2) AS reb_improvement,
    ROUND(ast - prev_ast, 2) AS ast_improvement,
    ROUND((pts - prev_pts) + (reb - prev_reb) + (ast - prev_ast), 2) AS total_improvement
FROM season_diff
WHERE prev_pts IS NOT NULL     -- removes first season of each player
ORDER BY total_improvement DESC;

-- 2. Era & Team Comparisons
-- Compare average player size (height/weight) between 1990s, 2000s, 2010s, and 2020s.
-- Identify which teams consistently produce top-performing players.
-- Look at rookies vs veterans - how do their contributions differ?

-- Compare average player size (height/weight) between 1990s, 2000s, 2010s, and 2020s.
SELECT 
    CONCAT(FLOOR(season / 10) * 10, 's') AS era,
    ROUND(AVG(player_height), 2) AS avg_height,
    ROUND(AVG(player_weight), 2) AS avg_weight
    FROM all_seasons
    GROUP BY era;

-- Identify which teams consistently produce top-performing players.
    WITH ranked AS (
SELECT season, team_abbreviation AS team,
    player_name,
    RANK()OVER(PARTITION BY season ORDER BY pts DESC) AS rank_pts,
    RANK()OVER(PARTITION BY season ORDER BY reb DESC) AS rank_reb,
    RANK()OVER(PARTITION BY season ORDER BY ast DESC) AS rank_ast,
    RANK()OVER(PARTITION BY season ORDER BY net_rating DESC) AS rank_net_rating,
    RANK()OVER(PARTITION BY season ORDER BY ts_pct DESC) AS rank_ts_pct
FROM all_seasons
)

SELECT 
    team,
    COUNT(*) AS total_top_performer_appearances
FROM ranked
WHERE 
    rank_pts <= 10      -- top scorers
    OR rank_reb <= 10   -- top rebounders
    OR rank_ast <= 10   -- top playmakers
    OR rank_net_rating <= 10  -- top impact players
    OR rank_ts_pct <= 10       -- top efficiency players
GROUP BY team
ORDER BY total_top_performer_appearances DESC;
    
    
-- Look at rookies vs veterans - how do their contributions differ?
-- IDENTIFY ROOKIE SEASON:
SELECT
	player_name,
    MIN(season) AS rookie_season
FROM
	all_seasons
GROUP BY
	player_name;
    
    -- CALCULATE EXPERIENCE
    SELECT
		a.player_name,
        a.season,
        a.season-r.rookie_season AS Experience
        FROM all_seasons a
        JOIN(
        SELECT player_name,MIN(season) AS rookie_season
        FROM all_seasons
        GROUP BY player_name
        )r
        ON a.player_name=r.player_name;
        
       -- CLASSIFY ROOKIE VS VETERAN
       SELECT
    a.player_name,
    a.season,
    a.season - r.rookie_season AS experience,
    CASE
        WHEN a.season - r.rookie_season = 0 THEN 'Rookie'
        WHEN a.season - r.rookie_season >= 4 THEN 'Veteran'
        ELSE 'Mid-Level'
    END AS experience_level
FROM all_seasons a
JOIN (
    SELECT player_name, MIN(season) AS rookie_season
    FROM all_seasons
    GROUP BY player_name
) r
ON a.player_name = r.player_name
ORDER BY a.player_name, a.season;


   
    
    
