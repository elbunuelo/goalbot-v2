FROM ruby:3.1.2

RUN apt-get update -qq && apt-get install -y build-essential

ENV APP_HOME /opt/app
RUN mkdir -p $APP_HOME
WORKDIR $APP_HOME

RUN mkdir -p /opt/redd
ADD ./redd /opt/redd

ADD backend/Gemfile $APP_HOME/Gemfile
ADD backend/Gemfile.lock $APP_HOME/Gemfile.lock

RUN bundle install

ADD . $APP_HOME
