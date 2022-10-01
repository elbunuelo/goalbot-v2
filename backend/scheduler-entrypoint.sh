#! /bin/bash

cd /opt/app/backend
bundle install

RAILS_ENV=production bin/rake resque:scheduler
