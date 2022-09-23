#! /bin/bash

cd /opt/app/backend
bundle install

bin/rake fetch_goal_video_links
