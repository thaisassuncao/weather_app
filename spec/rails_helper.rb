# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../config/environment", __dir__)
abort("The Rails environment is running in production mode!") if Rails.env.production?
require "rspec/rails"

Rails.root.glob("spec/support/**/*.rb").each { |f| require f }

RSpec.configure do |config|
  config.include StubHelpers
  config.include TestHelpers
  config.before { Rails.cache.clear }
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
end
