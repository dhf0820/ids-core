FROM ruby:alpine

#RUN apt-get update -qq && apt-get install -y build-essential
RUN apk update \
    && apk upgrade \
    && apk add build-base libffi-dev

ENV LANG C.UTF-8
ENV APP_BASE /app
RUN echo $APP_BASE
ENV APP_HOME $APP_BASE/delivery_manager
RUN echo $APP_HOME

ENV APP_NAME='DeliveryManager'
RUN mkdir $APP_BASE
RUN mkdir $APP_BASE/sys_models
RUN mkdir $APP_BASE/sys_lib
RUN mkdir $APP_HOME

WORKDIR $APP_BASE

WORKDIR $APP_BASE
COPY ./sys_lib $APP_BASE/sys_lib
COPY ./sys_models $APP_BASE/sys_models/
WORKDIR $APP_HOME

COPY Gemfile* ./
RUN bundle install

COPY . .



#CMD bundle exec rackup -p 4567
#CMD ["bundle","exec", "rackup", "-o", "0.0.0.0", "-p", "4567"]
CMD  ./app