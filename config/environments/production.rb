# frozen_string_literal: true
require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.cache_store = :memory_store, { size: 128.megabytes }
  config.action_controller.perform_caching = true
  config.eager_load = true
  config.assets.compile = true
  config.log_level = :info
end
