FROM ruby:3.3.9-slim AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential git curl pkg-config libyaml-dev \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app

ENV BUNDLE_WITHOUT="development:test" \
    BUNDLE_JOBS=4 \
    BUNDLE_RETRY=3

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .
ENV RAILS_ENV=production

RUN SECRET_KEY_BASE=dummy bundle exec rake assets:precompile

FROM ruby:3.3.9-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    tzdata ca-certificates libyaml-0-2 \
 && rm -rf /var/lib/apt/lists/*

ENV RAILS_ENV=production \
    RACK_ENV=production \
    RAILS_LOG_TO_STDOUT=true \
    RAILS_SERVE_STATIC_FILES=true \
    BUNDLE_WITHOUT="development:test"

WORKDIR /app

COPY --from=builder /usr/local/bundle /usr/local/bundle
COPY --from=builder /app /app

RUN chmod +x bin/rails bin/bundle

EXPOSE 3000
CMD ["bin/rails", "server", "-b", "0.0.0.0", "-p", "3000"]
