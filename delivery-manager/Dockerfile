FROM ruby:alpine

#RUN apt-get update -qq && apt-get install -y build-essential
RUN apk update \
    && apk upgrade \
    && apk add build-base libffi-dev


ENV APP_NAME='DeliveryManager'
ENV LANG C.UTF-8
ENV APP_BASE /app
ENV APP_HOME $APP_BASE/delivery_manager

RUN mkdir $APP_BASE
WORKDIR $APP_BASE
RUN echo "PWD: $PWD"


#RUN mkdir /app/sys_models


RUN echo "APP_HOME: $APP_HOME"
RUN echo "APP_BASE: $APP_BASE"

WORKDIR $APP_BASE
RUN mkdir sys_lib
RUN mkdir sys_models
RUN ls /app 
RUN pwd
COPY sys_lib sys_lib
RUN mkdir $APP_HOME

# WORKDIR /app
# RUN echo pwd
# COPY ./sys_lib ./sys_lib/
# COPY ./sys_models /app/sys_models/
WORKDIR $APP_HOME

COPY Gemfile* ./
RUN bundle install

COPY . .



#CMD bundle exec rackup -p 4567
#CMD ["bundle","exec", "rackup", "-o", "0.0.0.0", "-p", "4567"]
CMD  ./app