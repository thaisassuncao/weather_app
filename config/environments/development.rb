# frozen_string_literal: true
require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.cache_store = :memory_store, { size: 64.megabytes }
  config.action_controller.perform_caching = true
  config.consider_all_requests_local = true
  config.assets.debug = true
  config.eager_load = false
end
