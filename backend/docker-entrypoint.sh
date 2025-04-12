#! /bin/bash

git config --global --add safe.directory /opt/app
cd /opt/app/backend
# bundle install

rm ./tmp/pids/server.pid

if [ "$CREATE_DB" = 'true' ]; then
  echo "Preparing database"
  bundle exec rake db:create
  bundle exec rake db:schema:load
  bundle exec rake db:migrate
fi

bin/rails s -p $1 -b 0.0.0.0
