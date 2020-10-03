FROM ruby:2.7

WORKDIR /app

COPY Gemfile /app/
RUN bundle install

COPY . /app