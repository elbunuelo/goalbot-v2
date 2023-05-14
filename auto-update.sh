#! /bin/bash

cd ${0%/*}
pwd
git pull
docker compose --env-file var.env exec bot bin/rails db:migrate
docker compose --env-file var.env restart
