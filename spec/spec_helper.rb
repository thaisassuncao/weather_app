# frozen_string_literal: true

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
  config.include ActiveSupport::Testing::TimeHelpers
end
