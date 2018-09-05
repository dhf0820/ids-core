FROM ruby:alpine3.6

#RUN apt-get update -qq && apt-get install -y build-essential
RUN apk update \
    && apk upgrade \
    && apk add build-base postgresql-dev libffi-dev

ENV LANG C.UTF-8
ENV APP_HOME /app
ENV APP_NAME='Reader'
#ENV DATABASE_URL='postgres://thulfegwpuslep:8eb1175ccb0db75947541397a4b42a613aa63a7d9f40fafe43a62cecc01d5667@ec2-54-83-58-222.compute-1.amazonaws.com:5432/deau5hnpvmc842'
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

COPY Gemfile* ./
RUN bundle install

COPY . .



#CMD bundle exec rackup -p 4567
#CMD ["bundle","exec", "rackup", "-o", "0.0.0.0", "-p", "4567"]
CMD  ./app