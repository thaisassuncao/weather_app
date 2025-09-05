# frozen_string_literal: true

require "rails_helper"
require "active_support/testing/time_helpers"

RSpec.describe "Forecasts", type: :request do
  include ActiveSupport::Testing::TimeHelpers

  context "when the request succeeds and caching applies" do
    it "renders results and caches by zip" do
      stub_geo_ok
      stub_weather

      post "/forecast", params: { address: "NYC" }

      expect(response).to have_http_status(:ok)
      expect_temp_c!(response.body, 20)

      post "/forecast", params: { address: "NYC" }

      expect(response.body).to include("from cache")
    end
  end

  context "with lat/lon fallback" do
    it "uses lat/lon cache key when no postal code" do
      stub_geo_custom(lat: 51.5074, lon: -0.1278, name: "London", address: {})
      stub_weather

      post "/forecast", params: { address: "London" }

      expect(response).to have_http_status(:ok)
      expect_temp_c!(response.body, 20)
    end

    it "treats very close lat/lon as same key (%.4f)" do
      stub_weather
      stub_geo_custom(lat: 51.50001, lon: -0.12699, address: {})

      post "/forecast", params: { address: "A" }

      expect(response).to have_http_status(:ok)

      stub_geo_custom(lat: 51.50002, lon: -0.12700, address: {})

      post "/forecast", params: { address: "B" }

      expect(response.body).to include("from cache")
    end
  end

  context "when invalid input or upstream failure occurs" do
    it "returns 404 for invalid address" do
      stub_geo_none

      post "/forecast", params: { address: "xyzxyz" }

      expect(response).to have_http_status(:not_found)
      expect(response.body).to include(I18n.t("alerts.not_found"))
    end

    it "returns 503 when weather API fails" do
      stub_geo_ok
      stub_request(:get, %r{api\.open-meteo\.com/v1/forecast}).to_return(status: 500, body: "oops")

      post "/forecast", params: { address: "NYC" }

      expect(response).to have_http_status(:service_unavailable)
      expect(response.body).to include(I18n.t("alerts.weather_unavailable"))
    end
  end

  context "with time passage and config changes" do
    it "uses cache within 30m and refreshes after" do
      stub_geo_ok
      stub_weather(current_c: 20)

      freeze_time do
        post "/forecast", params: { address: "NYC" }

        expect_temp_c!(response.body, 20)

        stub_weather(current_c: 5)

        travel 29.minutes

        post "/forecast", params: { address: "NYC" }

        expect(response.body).to include("from cache")
        expect_temp_c!(response.body, 20)

        travel 2.minutes

        post "/forecast", params: { address: "NYC" }

        expect(response.body).not_to include("from cache")
        expect_temp_c!(response.body, 5)
      end
    end

    it "changes cache bucket when FORECAST_DAYS changes" do
      stub_geo_ok
      stub_weather

      post "/forecast", params: { address: "NYC" }

      expect(response.body).not_to be_empty

      stub_const("ForecastService::FORECAST_DAYS", 9)
      stub_weather

      post "/forecast", params: { address: "NYC" }

      expect(response.body).not_to include("from cache")
    end
  end

  context "with theme and condition chip states" do
    it "uses sunny theme + ☀️ during day & WMO=0" do
      stub_geo_ok
      stub_weather(code: 0, is_day: 1)

      post "/forecast", params: { address: "NYC" }

      expect(response.body).to include('class="theme-sunny"')
      expect(response.body).to include("☀️")
      expect(response.body).to include("Sunny")
    end

    it "uses clear-night theme + 🌙 during night & WMO=0" do
      stub_geo_ok
      stub_weather(code: 0, is_day: 0)

      post "/forecast", params: { address: "NYC" }

      expect(response.body).to include('class="theme-clear-night"')
      expect(response.body).to include("🌙")
      expect(response.body).to include("Clear night")
    end
  end
end
