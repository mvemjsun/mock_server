FROM ruby:2.7.4-buster

RUN apt update -y

RUN apt install -y git vim qt5-default libqt5webkit5 libqtwebkit-dev libqt5webkit5-dev lsof

RUN gem install bundler

COPY . /app

WORKDIR /app

RUN gem install bundler -v 1.13.7

RUN bundle install

CMD rackup
