#! /bin/bash

cd /opt/app/backend
# bundle install

QUEUE=incidents bin/rake resque:work
