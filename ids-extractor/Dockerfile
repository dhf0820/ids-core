FROM ruby:alpine

#RUN apt-get update -qq && apt-get install -y build-essential
RUN apk update \
    && apk upgrade \
    && apk add build-base libffi-dev

ENV LANG C.UTF-8
ENV APP_NAME='Demo Reader'
ENV APP_BASE /app
ENV APP_HOME $APP_BASE/ids-extractor

RUN mkdir $APP_BASE
WORKDIR $APP_BASE
RUN echo "PWD: $PWD"


#RUN mkdir /app/sys_models


RUN echo "APP_HOME: $APP_HOME"
RUN echo "APP_BASE: $APP_BASE"

RUN mkdir sys_libs
RUN mkdir sys_models

COPY sys_lib/ sys_lib
COPY ./sys_models/ /app/sys_models/
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

COPY ids-extractor/Gemfile* ./
RUN bundle install

COPY ids-extractor/. .



#CMD bundle exec rackup -p 4567
#CMD ["bundle","exec", "rackup", "-o", "0.0.0.0", "-p", "4567"]
CMD  ./app
