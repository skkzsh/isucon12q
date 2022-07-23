#!/bin/bash
set -euvx

mkdir -p ~/logs

sudo cat /var/log/nginx/access.log |
	alp json -q --qs-ignore-values --sort avg -r -m '^/api/player/player/[0-9a-f]+$','^/api/player/competition/[0-9a-f]+/ranking$','^/api/organizer/player/[0-9a-f]+/disqualified$','^/api/organizer/competition/[0-9a-f]+/score$','^/api/organizer/competition/[0-9a-f]+/finish$' |
	tee ~/logs/alp-$(date +%Y%m%d-%H%M%S).log

# sudo mysqldumpslow /var/log/mysql/mysql-slow.log | tee ~/logs/slow-$(date +%Y%m%d-%H%M%S).log
sudo pt-query-digest /var/log/mysql/mysql-slow.log | tee ~/logs/pt-query-digest-$(date +%Y%m%d-%H%M%S).log

# go tool pprof -http=:10060 http://localhost:6060/debug/pprof/profile

