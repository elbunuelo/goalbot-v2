#! /bin/bash

cd ${0%/*}
pwd
git pull
docker-compose restart bot
