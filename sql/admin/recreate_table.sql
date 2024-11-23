-- 最古データしか参照していないので, 初期データを最古データのみにすることにより, データ量を削減する
-- 元データ: /home/isucon/webapp/sql/admin/

ALTER TABLE visit_history RENAME TO visit_history_old;

CREATE TABLE `visit_history` AS
SELECT `tenant_id`, `competition_id`, `player_id`, MIN(`created_at`) AS `created_at`, MIN(`created_at`) AS `updated_at`
FROM `visit_history_old` GROUP BY `tenant_id`, `competition_id`, `player_id`;

CREATE INDEX `visit_history_idx` ON `visit_history` (`tenant_id`, `competition_id`, `player_id`, `created_at`);
