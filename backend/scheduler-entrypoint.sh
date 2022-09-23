#! /bin/bash

cd /opt/app/backend
bundle install

bin/rake resque:scheduler
