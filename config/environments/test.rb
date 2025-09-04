# frozen_string_literal: true
require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.cache_store = :memory_store, { size: 32.megabytes }
  config.action_controller.perform_caching = true
  config.eager_load = false
  config.consider_all_requests_local = true
  config.action_controller.allow_forgery_protection = false
end
