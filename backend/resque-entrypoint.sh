#! /bin/bash

cd /opt/app/backend
bundle install

RAILS_ENV=production QUEUE=incidents bin/rake resque:work
