#! /bin/bash

cd /opt/app
bundle install

bin/rake fetch_goal_video_links
