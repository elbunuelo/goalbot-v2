#! /bin/bash

git config --global --add safe.directory /opt/app
cd /opt/app/backend
# bundle install

bin/rake fetch_goal_video_links
