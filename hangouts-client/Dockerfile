FROM python:3.7
LABEL description="Google Hangouts Bot"
LABEL maintainer="http://github.com/hangoutsbot/hangoutsbot"
WORKDIR /app
ADD requirements.txt .
RUN pip install --upgrade pip
RUN pip install -r requirements.txt
RUN mkdir -p /root/.local/share/hangupsbot
ARG PORTS="9001 9002 9003"
EXPOSE $PORTS
