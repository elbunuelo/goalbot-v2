FROM ruby:3.3.6

RUN apt-get update -qq && apt-get install -y build-essential

ENV APP_HOME /opt/app
RUN mkdir -p $APP_HOME

RUN mkdir -p $APP_HOME/redd
ADD ./redd $APP_HOME/redd

WORKDIR $APP_HOME/backend
ADD backend/Gemfile $APP_HOME/backend/Gemfile
ADD backend/Gemfile.lock $APP_HOME/backend/Gemfile.lock

RUN bundle install

ADD . $APP_HOME
