#! /bin/bash

git config --global --add safe.directory /opt/app
cd /opt/app/backend
# bundle install

RAILS_ENV=production bin/rake resque:scheduler
