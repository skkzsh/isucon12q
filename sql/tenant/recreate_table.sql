-- 最新データしか参照していないので, 初期データを最新データのみにすることにより, データ量を削減する

CREATE TABLE player_score_new AS
SELECT ps.* FROM player_score ps JOIN (
    SELECT player_id, competition_id, MAX(row_num) AS max_row_num FROM player_score
    GROUP BY player_id, competition_id
) latest
    ON ps.player_id = latest.player_id
        AND ps.competition_id = latest.competition_id
        AND ps.row_num = latest.max_row_num;

DROP TABLE player_score;
ALTER TABLE player_score_new RENAME TO player_score;

VACUUM;
