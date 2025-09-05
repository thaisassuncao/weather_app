# frozen_string_literal: true

require "rails_helper"

RSpec.describe ForecastService do
  describe ".fetch" do
    context "when parsing responses and rounding values" do
      it "parses current and daily temps and rounds like the service" do
        body = {
          "current" => { "temperature_2m" => 21.3, "weather_code" => 0, "is_day" => 0 },
          "daily" => {
            "time" => %w[2025-09-04 2025-09-05],
            "temperature_2m_max" => [27.2, 26.1],
            "temperature_2m_min" => [18.4, 17.9]
          }
        }.to_json

        stub_request(:get, %r{api\.open-meteo\.com/v1/forecast})
          .to_return(status: 200, body:, headers: { "Content-Type" => "application/json" })

        res = described_class.fetch(lat: 40.7, lon: -74.0)

        expect(res[:current_c]).to eq(round_like_service(21.3))
        expect(res[:current_f]).to eq(round_like_service((21.3 * 9.0 / 5.0) + 32.0))
        expect(res[:today_high_c]).to eq(round_like_service(27.2))
        expect(res[:daily].size).to eq(2)
      end
    end

    context "when the API returns errors" do
      it "raises on non-200 responses" do
        stub_request(:get, %r{api\.open-meteo\.com/v1/forecast}).to_return(status: 500, body: "oops")

        expect { described_class.fetch(lat: 0, lon: 0) }.to raise_error(ForecastService::FetchError)
      end

      it "raises on invalid JSON" do
        stub_request(:get, %r{api\.open-meteo\.com/v1/forecast})
          .to_return(status: 200, body: "not-json")

        expect { described_class.fetch(lat: 0, lon: 0) }.to raise_error(ForecastService::FetchError)
      end
    end

    context "with forecast_days parameter" do
      it "sends forecast_days matching the constant" do
        stub_const("ForecastService::FORECAST_DAYS", 9)
        stub_request(:get, %r{api\.open-meteo\.com/v1/forecast})
          .with { |req| CGI.parse(URI(req.uri).query)["forecast_days"] == ["9"] }
          .to_return(status: 200, body: {
            "current" => { "temperature_2m" => 20, "weather_code" => 0, "is_day" => 1 },
            "daily" => { "time" => %w[2025-09-04], "temperature_2m_max" => [25],
                         "temperature_2m_min" => [15] }
          }.to_json, headers: { "Content-Type" => "application/json" })

        expect { described_class.fetch(lat: 10, lon: 10) }.not_to raise_error
      end
    end

    context "with various is_day representations" do
      it "treats true/1/'1' as day for WMO=0" do
        [true, 1, "1"].each do |v|
          stub_request(:get, %r{api\.open-meteo\.com/v1/forecast}).to_return(status: 200, body: {
            "current" => { "temperature_2m" => 20, "weather_code" => 0, "is_day" => v },
            "daily" => { "time" => %w[2025-09-04], "temperature_2m_max" => [25],
                         "temperature_2m_min" => [15] }
          }.to_json)

          res = described_class.fetch(lat: 0, lon: 0)

          expect(res[:condition]).to eq(:sunny)
        end
      end

      it "treats false/0/'0' as night for WMO=0" do
        [false, 0, "0"].each do |v|
          stub_request(:get, %r{api\.open-meteo\.com/v1/forecast}).to_return(status: 200, body: {
            "current" => { "temperature_2m" => 20, "weather_code" => 0, "is_day" => v },
            "daily" => { "time" => %w[2025-09-04], "temperature_2m_max" => [25],
                         "temperature_2m_min" => [15] }
          }.to_json)

          res = described_class.fetch(lat: 0, lon: 0)

          expect(res[:condition]).to eq(:clear_night)
        end
      end
    end

    context "when mapping WMO to conditions" do
      {
        3 => :cloudy, 45 => :fog, 51 => :drizzle, 61 => :rain,
        71 => :snow, 95 => :thunder
      }.each do |wmo, expected|
        it "maps WMO #{wmo} to :#{expected}" do
          stub_request(:get, %r{api\.open-meteo\.com/v1/forecast}).to_return(status: 200, body: {
            "current" => { "temperature_2m" => 20, "weather_code" => wmo, "is_day" => 1 },
            "daily" => { "time" => %w[2025-09-04], "temperature_2m_max" => [25],
                         "temperature_2m_min" => [15] }
          }.to_json)

          res = described_class.fetch(lat: 0, lon: 0)

          expect(res[:condition]).to eq(expected)
        end
      end
    end
  end
end
