# frozen_string_literal: true

module StubHelpers
  def stub_geo_ok(postcode: "10007", country_code: "us",
                  name: "New York, United States",
                  lat: "40.7127281", lon: "-74.0060152")
    stub_request(:get, %r{nominatim\.openstreetmap\.org/search})
      .to_return(
        status: 200,
        body: [
          { "lat" => lat, "lon" => lon, "display_name" => name,
            "address" => { "postcode" => postcode, "country_code" => country_code }.compact }
        ].to_json,
        headers: { "Content-Type" => "application/json" }
      )
  end

  def stub_geo_none
    stub_request(:get, %r{nominatim\.openstreetmap\.org/search})
      .to_return(status: 200, body: "[]", headers: { "Content-Type" => "application/json" })
  end

  def stub_geo_custom(lat:, lon:, name: "Somewhere", address: {})
    stub_request(:get, %r{nominatim\.openstreetmap\.org/search})
      .to_return(
        status: 200,
        body: [
          { "lat" => lat.to_s, "lon" => lon.to_s, "display_name" => name, "address" => address }
        ].to_json,
        headers: { "Content-Type" => "application/json" }
      )
  end

  def stub_weather(current_c: 20.0, code: 0, is_day: 1, daily: nil)
    daily ||= { days: %w[2025-09-04], highs: [25.0], lows: [15.0] }

    stub_request(:get, %r{api\.open-meteo\.com/v1/forecast})
      .to_return(
        status: 200,
        body: {
          "current" => { "temperature_2m" => current_c, "weather_code" => code, "is_day" => is_day },
          "daily" => {
            "time" => daily[:days],
            "temperature_2m_max" => daily[:highs],
            "temperature_2m_min" => daily[:lows]
          }
        }.to_json,
        headers: { "Content-Type" => "application/json" }
      )
  end

  def expect_temp_c!(body, current)
    expect(body).to match(/\b#{Regexp.escape(current.to_s)}(?:\.0)?°C\b/)
  end
end
