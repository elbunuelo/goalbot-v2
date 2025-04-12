#! /bin/bash

git config --global --add safe.directory /opt/app
cd /opt/app/backend
# bundle install

QUEUE=incidents bin/rake resque:work
