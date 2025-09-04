# frozen_string_literal: true
require "net/http"
require "json"
require "uri"

class ForecastService
  class FetchError < StandardError; end

  FORECAST_DAYS = 8
  TEMP_PRECISION = 0

  class << self
    def fetch(lat:, lon:)
      uri = URI("https://api.open-meteo.com/v1/forecast")
      params = {
        latitude: lat,
        longitude: lon,
        current: "temperature_2m,weather_code,is_day",
        daily: "temperature_2m_max,temperature_2m_min",
        timezone: "auto",
        forecast_days: FORECAST_DAYS
      }
      uri.query = URI.encode_www_form(params)

      res = http_get(uri)
      raise FetchError, "HTTP #{res.code}" unless res.is_a?(Net::HTTPSuccess)

      data = JSON.parse(res.body)

      c_raw   = (data.dig("current", "temperature_2m") || data.dig("current", "temperature")).to_f
      wmo     = data.dig("current", "weather_code")
      is_day  = data.dig("current", "is_day")
      is_dayi = (is_day == true || is_day == false) ? (is_day ? 1 : 0) : is_day.to_i

      days = (data.dig("daily", "time") || []).map.with_index do |date, i|
        {
          date: date,
          min_c: data.dig("daily", "temperature_2m_min")[i],
          max_c: data.dig("daily", "temperature_2m_max")[i]
        }
      end

      today = days.first || {}
      condition = wmo_to_condition(wmo, is_dayi)

      {
        current_c: round_temperature(c_raw),
        current_f: round_temperature(c_to_f(c_raw)),
        today_high_c: round_temperature(today[:max_c]),
        today_low_c:  round_temperature(today[:min_c]),
        daily: days.map { |d|
          { date: d[:date], min_c: round_temperature(d[:min_c]), max_c: round_temperature(d[:max_c]) }
        },
        weather_code: wmo,
        is_day: is_dayi,
        condition: condition
      }
    rescue JSON::ParserError => e
      raise FetchError, "Invalid JSON: #{e.message}"
    end

    private

    def http_get(uri)
      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") do |http|
        req = Net::HTTP::Get.new(uri)
        req["User-Agent"] = "WeatherForecast/1.0 (contact: assuncaothais99@gmail.com)"
        req["Accept"] = "application/json"
        http.request(req)
      end
    end

    def c_to_f(c)
      ((c * 9.0 / 5.0) + 32.0).round(1)
    end

    def round_temperature(temp)
      return nil if temp.nil?
      nd = TEMP_PRECISION
      nd == 0 ? temp.round : temp.round(nd)
    end

    def wmo_to_condition(code, is_day)
      c = code.to_i

      case c
      when 0
        is_day == 1 ? :sunny : :clear_night
      when 1, 2
        :sunny
      when 3
        :cloudy
      when 45, 48
        :fog
      when 51, 53, 55, 56, 57
        :drizzle
      when 61, 63, 65, 80, 81, 82, 66, 67
        :rain
      when 71, 73, 75, 77, 85, 86
        :snow
      when 95, 96, 99
        :thunder
      else
        is_day == 1 ? :sunny : :clear_night
      end
    end
  end
end
