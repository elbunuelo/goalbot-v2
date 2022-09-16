#! /bin/bash 

cd /opt/app
bundle install

QUEUE=incidents bin/rake resque:work
