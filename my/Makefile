SHELL := /bin/bash

NOW := $(shell date +%m%d-%H%M%S)
DATE ?= $(NOW)

ISSUE := 1

GIT_DIR   := ~/webapp
APP_NAME  := isuports
APP_DIR   := $(GIT_DIR)/go
BUILD_CMD := make
BENCH_DIR := ~/bench
BENCH_CMD := ./bench -target-addr 127.0.0.1:443
# TODO: ALP_MATCHはAPIの実装やnginxのlogから決める
# ALP_MATCH := '^/api/player/player/[0-9a-f]+$$','^/api/player/competition/[0-9a-f]+/ranking$$','^/api/player/competition/[0-9a-f]+/ranking\?rank_after=xxx$$','^/api/organizer/player/[0-9a-f]+/disqualified$$','^/api/organizer/competition/[0-9a-f]+/score$$','^/api/organizer/competition/[0-9a-f]+/finish$$'
ALP_OPTS ?= -q # --qs-ignore-values --limit 10000

NGINX_ACCESS_LOG := /var/log/nginx/access
NGINX_ERROR_LOG := /var/log/nginx/error
NGINX_CONF := /etc/nginx/nginx.conf
NGINX_SITES_AVAIL := /etc/nginx/sites-available

DB_MIDDLE ?= mysql
SLOW_QUERY_LOG := /var/log/mysql/$(DB_MIDDLE)-slow
MYSQL_ERROR_LOG := /var/log/mysql/error
MYSQLD_CONF := /etc/mysql/mysql.conf.d/mysqld.cnf

.PHONY: conf/backup conf/nginx/deploy conf/mysql/deploy rotate truncate build restart prepare bench/before bench bench/after alp slp issue

all: bench bench/after
bench/after: issue # TODO: alp, slp
bench/before: prepare truncate restart # build

conf/backup:
	mkdir -p $(GIT_DIR)/etc/{nginx/sites-available,mysql/$(DB_MIDDLE).conf.d}
	cp {,$(GIT_DIR)}$(NGINX_CONF)
	cp $(NGINX_SITES_AVAIL)/*.conf $(GIT_DIR)$(NGINX_SITES_AVAIL)/
	cp {,$(GIT_DIR)}$(MYSQLD_CONF)

conf/nginx/deploy:
	sudo cp $(NGINX_CONF){,.$(DATE)}
	sudo cp {$(GIT_DIR),}$(NGINX_CONF)
	sudo cp $(NGINX_SITES_AVAIL)/$(APP_NAME).conf{,.$(DATE)}
	sudo cp $(GIT_DIR)$(NGINX_SITES_AVAIL)/*.conf $(NGINX_SITES_AVAIL)/

conf/mysql/deploy:
	sudo cp $(MYSQLD_CONF){,.$(DATE)}
	sudo cp {$(GIT_DIR),}$(MYSQLD_CONF)

rotate:
	sudo mv $(NGINX_ACCESS_LOG){,-$(DATE)}.log
	sudo mv $(NGINX_ERROR_LOG){,-$(DATE)}.log
	sudo mv $(SLOW_QUERY_LOG){,-$(DATE)}.log
	sudo mv $(MYSQL_ERROR_LOG){,-$(DATE)}.log

truncate:
	sudo truncate -s0 -c $(NGINX_ACCESS_LOG).log $(NGINX_ERROR_LOG).log $(SLOW_QUERY_LOG).log $(MYSQL_ERROR_LOG).log
    # mysqladmin flush-logs

build:
	cd $(APP_DIR) && $(BUILD_CMD)

restart:
	sudo systemctl restart $(DB_MIDDLE)
	sudo systemctl restart $(APP_NAME)
	docker compose -f $(GIT_DIR)/docker-compose-go.yml up -d --wait # benchが失敗してしまわないようにwait
	sudo systemctl restart nginx
    # sudo systemctl restart redis # TODO
    # sudo systemctl restart datadog-agent

prepare:
	mkdir -p ~/logs

bench: bench/before
	cd $(BENCH_DIR); \
	$(BENCH_CMD) \
	> >(tee ~/logs/bench-$(DATE).log) \
	2> >(tee ~/logs/bench-error-$(DATE).log >&2)

alp: prepare # TODO avg, sum
	sudo alp json --file $(NGINX_ACCESS_LOG).log \
	$(ALP_OPTS) --sort avg -r \
	tee ~/logs/alp-$(DATE).log
    # -m $(ALP_MATCH) | \ # TODO

slp: prepare
	sudo pt-query-digest $(SLOW_QUERY_LOG).log \
	| tee ~/logs/pt-query-digest-$(DATE).log

issue:
	(cd $(APP_DIR); git rev-parse HEAD; \
	echo "\`\`\`"; cat ~/logs/bench-$(DATE).log; echo "\`\`\`"; \
	echo "<details><summary>Bench error</summary>"; echo -e "\n\`\`\`"; cat ~/logs/bench-error-$(DATE).log; echo "\`\`\`"; echo "</details>"; \
	echo "<details><summary>NGINX error</summary>"; echo -e "\n\`\`\`"; sudo cat $(NGINX_ERROR_LOG).log; echo "\`\`\`"; echo "</details>"; \
	echo "<details><summary>MySQL error</summary>"; echo -e "\n\`\`\`"; sudo cat $(MYSQL_ERROR_LOG).log; echo "\`\`\`";  echo "</details>"; \
	echo "<details><summary>App error</summary>"; echo -e "\n\`\`\`"; cd $(GIT_DIR); docker compose -f docker-compose-go.yml logs --no-log-prefix | jq -R 'fromjson? | select(.level == "ERROR")' ; echo "\`\`\`"; echo "</details>"; \
	) | \
	gh issue comment $(ISSUE) -F-
    # TODO: alp
    # echo "<details><summary>alp</summary>"; echo -e "\n\`\`\`"; cat ~/logs/alp-$(DATE).log; echo "\`\`\`";  echo "</details>"; \
    # TODO: slow query
    # echo "<details><summary>Slow query</summary>"; echo -e "\n\`\`\`"; cat ~/logs/pt-query-digest-$(DATE).log; echo "\`\`\`";  echo "</details>"; \
    # echo "<details><summary>App error</summary>"; echo -e "\n\`\`\`"; sudo journalctl -u $(APP_NAME) --since "$$(systemctl show $(APP_NAME) -p ActiveEnterTimestamp | cut -d= -f2)" --no-pager -o json | jq -r .MESSAGE | jq -R 'fromjson? | select(.error != "")'; echo "\`\`\`"; echo "</details>"; \
    # echo "<details><summary>App error</summary>"; echo -e "\n\`\`\`"; sudo journalctl -u $(APP_NAME) --since "$$(systemctl show $(APP_NAME) -p ActiveEnterTimestamp | cut -d= -f2)" --no-pager -p err ; echo "\`\`\`"; echo "</details>"; \
    # TODO: docker compose logs
