#! /bin/bash 

cd /opt/app
bundle install

bin/rake resque:scheduler
