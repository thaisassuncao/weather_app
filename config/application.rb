# frozen_string_literal: true
require_relative "boot"

require "rails"
require "action_controller/railtie"
require "action_view/railtie"
require "sprockets/railtie"

Bundler.require(*Rails.groups)

module WeatherForecast
  class Application < Rails::Application
    config.load_defaults 7.2

    config.generators do |g|
      g.orm nil
      g.assets false
      g.helper false
      g.test_framework :rspec
    end

    config.cache_store = :memory_store, { size: 64.megabytes }
    config.action_controller.perform_caching = true

    # Timezone / i18n sane defaults
    config.time_zone = "UTC"
    config.eager_load_paths << Rails.root.join("app/services")
  end
end
