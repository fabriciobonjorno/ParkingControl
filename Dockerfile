FROM ruby:3.4.7-slim

RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libpq-dev \
  libyaml-dev \
  pkg-config \
  git \
  curl \
  nodejs \
  && rm -rf /var/lib/apt/lists/*

# Bundler + Rails
RUN gem install bundler && gem install rails -v 8.1.1

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

RUN rm -f tmp/pids/server.pid

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]