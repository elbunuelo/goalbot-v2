#! /bin/bash

cd /opt/app/backend
bundle install

if [ "$CREATE_DB" = 'true' ]; then
  echo "Preparing database"
  bundle exec rake db:create RAILS_ENV=production
  bundle exec rake db:schema:load RAILS_ENV=production
  bundle exec rake db:migrate RAILS_ENV=production
fi

bin/rails s  -e production -p $1
