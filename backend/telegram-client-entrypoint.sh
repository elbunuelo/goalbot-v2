#! /bin/bash

git config --global --add safe.directory /opt/app
cd /opt/app/backend
# bundle install

bin/rake telegram_client
