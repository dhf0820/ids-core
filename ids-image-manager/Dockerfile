FROM ruby:alpine

#RUN apt-get update -qq && apt-get install -y build-essential
RUN apk update \
    && apk upgrade \
    && apk add build-base libffi-dev

ENV LANG C.UTF-8
ENV APP_HOME /app
ENV APP_NAME='ids-image-manager'

ENV APP_BASE /app
ENV APP_HOME $APP_BASE/
ENV APP_HOME $APP_BASE/ids-image-manager

RUN mkdir $APP_BASE
WORKDIR $APP_BASE

#RUN mkdir /app/sys_models


RUN echo "APP_HOME: $APP_HOME"
RUN echo "APP_BASE: $APP_BASE"

RUN mkdir sys_lib
RUN mkdir sys_models

COPY sys_lib/ sys_lib
COPY ./sys_models/ /app/sys_models/
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

#COPY ./Gemfile ./
COPY ids-image-manager/Gemfile* ./
RUN bundle install

COPY ids-image-manager/. ./
RUN pwd
CMD  ./app


