CREATE INDEX idx_player_score_tenant_competition_player_rownum
    ON player_score (tenant_id, competition_id, player_id, row_num DESC);

ANALYZE;
