# frozen_string_literal: true

require "net/http"
require "json"
require "uri"

class GeocodingService
  class << self
    def geocode(query)
      url = build_url(query)
      res = http_get(url, headers: nominatim_headers)

      return nil unless res.is_a?(Net::HTTPSuccess)

      json = JSON.parse(res.body)
      parse_result(json.first)
    rescue JSON::ParserError
      nil
    end

    private

    def build_url(query)
      url = URI("https://nominatim.openstreetmap.org/search")
      url.query = URI.encode_www_form(q: query, format: "json", addressdetails: 1, limit: 1)
      url
    end

    def parse_result(first)
      return nil unless first

      addr = first["address"] || {}
      {
        lat: first["lat"].to_f,
        lon: first["lon"].to_f,
        display_name: first["display_name"],
        postal_code: addr["postcode"],
        country_code: addr["country_code"]
      }
    end

    def http_get(uri, headers: {})
      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") do |http|
        req = Net::HTTP::Get.new(uri)
        headers.each { |k, v| req[k] = v }
        http.request(req)
      end
    end

    def nominatim_headers
      {
        "User-Agent" => "WeatherForecast/1.0 (contact: assuncaothais99@gmail.com)",
        "Accept" => "application/json"
      }
    end
  end
end
