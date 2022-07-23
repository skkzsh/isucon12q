#!/bin/bash
set -euvx

sudo truncate -s 0 -c /var/log/nginx/access.log
sudo truncate -s 0 -c /var/log/nginx/error.log
sudo truncate -s 0 -c /var/log/mysql/mysql-slow.log
sudo truncate -s 0 -c /var/log/mysql/error.log
# mysqladmin flush-logs

# GOPATH=/home/isucon/tmp/go
# GOCACHE=/home/isucon/tmp/go/.cache
# cd ~/webapp/go
# make

docker compose -f ~/webapp/docker-compose-go.yml build
sudo systemctl restart isuports.service

sudo systemctl restart mysql
sudo systemctl restart nginx

