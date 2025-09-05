# frozen_string_literal: true

source "https://rubygems.org"
ruby "3.3.9"

gem "puma", ">= 6.4"
gem "rails", "7.2.2.2"
gem "sprockets-rails"

group :development, :test do
  gem "rspec-rails"
  gem "rubocop", require: false
  gem "rubocop-performance", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-rspec", require: false
end

group :test do
  gem "webmock"
end
