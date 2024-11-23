DROP INDEX `tenant_id_idx` ON `visit_history`;
CREATE INDEX `visit_history_idx` ON `visit_history` (`tenant_id`, `competition_id`, `player_id`, `created_at`);

-- INDEX `tenant_competition_player_idx` (`tenant_id`, `competition_id`, `player_id`)
