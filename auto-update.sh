#! /bin/bash

cd ${0%/*}
pwd
git pull
docker-compose --env-file var.env restart bot video-finder telegram-client
