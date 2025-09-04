# frozen_string_literal: true
require "net/http"
require "json"
require "uri"

class ForecastService
  class FetchError < StandardError; end

  class << self
    # Returns a Hash:
    # {
    #   current_c: Float, current_f: Float,
    #   today_high_c: Float, today_low_c: Float,
    #   daily: [ { date: "YYYY-MM-DD", min_c: Float, max_c: Float }, ... ]
    # }
    def fetch(lat:, lon:)
      uri = URI("https://api.open-meteo.com/v1/forecast")
      params = {
        latitude: lat,
        longitude: lon,
        current: "temperature_2m",
        daily: "temperature_2m_max,temperature_2m_min",
        timezone: "auto"
      }
      uri.query = URI.encode_www_form(params)

      res = http_get(uri)
      raise FetchError, "HTTP #{res.code}" unless res.is_a?(Net::HTTPSuccess)

      data = JSON.parse(res.body)

      current_c = (data.dig("current", "temperature_2m") || data.dig("current", "temperature")).to_f
      days = (data.dig("daily", "time") || []).map.with_index do |date, i|
        {
          date: date,
          min_c: data.dig("daily", "temperature_2m_min")[i],
          max_c: data.dig("daily", "temperature_2m_max")[i]
        }
      end

      today = days.first || {}
      {
        current_c: current_c.round(1),
        current_f: c_to_f(current_c),
        today_high_c: (today[:max_c]&.round(1)),
        today_low_c:  (today[:min_c]&.round(1)),
        daily: days.map { |d|
          { date: d[:date], min_c: d[:min_c]&.round(1), max_c: d[:max_c]&.round(1) }
        }
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
  end
end
