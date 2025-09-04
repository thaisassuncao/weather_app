# frozen_string_literal: true

require "net/http"
require "json"
require "uri"

class ForecastService
  class FetchError < StandardError; end

  TEMP_PRECISION = 0
  FORECAST_DAYS  = 8

  CONDITION_MAP = {
    sunny: [1, 2],
    cloudy: [3],
    fog: [45, 48],
    drizzle: [51, 53, 55, 56, 57],
    rain: [61, 63, 65, 80, 81, 82, 66, 67],
    snow: [71, 73, 75, 77, 85, 86],
    thunder: [95, 96, 99]
  }.freeze

  class << self
    def fetch(lat:, lon:)
      res = http_get(build_uri(lat, lon))
      raise FetchError, "HTTP #{res.code}" unless res.is_a?(Net::HTTPSuccess)

      data      = JSON.parse(res.body)
      current   = parse_current(data)
      days      = parse_daily(data)
      condition = wmo_to_condition(current[:wmo], current[:is_day])

      build_result(current, days, condition)
    rescue JSON::ParserError => e
      raise FetchError, "Invalid JSON: #{e.message}"
    end

    private

    def build_uri(lat, lon)
      uri = URI("https://api.open-meteo.com/v1/forecast")
      uri.query = URI.encode_www_form(forecast_params(lat, lon))
      uri
    end

    def forecast_params(lat, lon)
      {
        latitude: lat,
        longitude: lon,
        current: "temperature_2m,weather_code,is_day",
        daily: "temperature_2m_max,temperature_2m_min",
        timezone: "auto",
        forecast_days: FORECAST_DAYS
      }
    end

    def parse_current(data)
      c = (data.dig("current", "temperature_2m") || data.dig("current", "temperature")).to_f

      {
        c: c,
        wmo: data.dig("current", "weather_code"),
        is_day: normalize_is_day(data.dig("current", "is_day"))
      }
    end

    def parse_daily(data)
      times = data.dig("daily", "time") || []
      mins  = data.dig("daily", "temperature_2m_min") || []
      maxs  = data.dig("daily", "temperature_2m_max") || []

      times.each_with_index.map { |date, i| { date:, min_c: mins[i], max_c: maxs[i] } }
    end

    def normalize_is_day(data)
      return 1 if data == true
      return 0 if data == false

      data.to_i
    end

    def http_get(uri)
      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") do |http|
        req = Net::HTTP::Get.new(uri)
        req["User-Agent"] = "WeatherForecast/1.0 (contact: assuncaothais99@gmail.com)"
        req["Accept"] = "application/json"
        http.request(req)
      end
    end

    def c_to_f(current)
      (current * 9.0 / 5.0) + 32.0
    end

    def round_temperature(temp)
      return nil if temp.nil?

      nd = TEMP_PRECISION
      nd.zero? ? temp.round : temp.round(nd)
    end

    def wmo_to_condition(code, is_day)
      c = code.to_i
      return (is_day == 1 ? :sunny : :clear_night) if c.zero?

      CONDITION_MAP.each { |sym, list| return sym if list.include?(c) }

      is_day == 1 ? :sunny : :clear_night
    end

    def build_result(current, days, condition)
      today = days.first || {}
      {
        current_c: round_temperature(current[:c]),
        current_f: round_temperature(c_to_f(current[:c])),
        today_high_c: round_temperature(today[:max_c]),
        today_low_c: round_temperature(today[:min_c]),
        daily: build_daily(days),
        weather_code: current[:wmo],
        is_day: current[:is_day],
        condition:
      }
    end

    def build_daily(days)
      days.map do |d|
        { date: d[:date], min_c: round_temperature(d[:min_c]), max_c: round_temperature(d[:max_c]) }
      end
    end
  end
end
