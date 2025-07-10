FROM ruby:3

ADD ./ruby-compile.sh /tmp
RUN /tmp/ruby-compile.sh

ENV PKG_CONFIG_PATH /usr/local/include/openssl
ENV DISABLE_SSL true
ENV APP_HOME /opt/app
RUN mkdir -p $APP_HOME

RUN mkdir -p $APP_HOME/redd
ADD ./redd $APP_HOME/redd

WORKDIR $APP_HOME/backend
ADD backend/Gemfile $APP_HOME/backend/Gemfile
ADD backend/Gemfile.lock $APP_HOME/backend/Gemfile.lock

RUN bundle update --bundler
RUN bundle install

ADD . $APP_HOME
