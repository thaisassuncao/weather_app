# frozen_string_literal: true
require "rails_helper"

RSpec.describe "Forecasts", type: :request do
  def stub_geo_ok(postcode: "10007", country_code: "us")
    stub_request(:get, /nominatim\.openstreetmap\.org\/search.*/)
      .to_return(
        status: 200,
        body: [
          {
            "lat" => "40.7127281",
            "lon" => "-74.0060152",
            "display_name" => "New York, United States",
            "address" => { "postcode" => postcode, "country_code" => country_code }
          }
        ].to_json,
        headers: { "Content-Type" => "application/json" }
      )
  end

  def stub_weather_ok
    stub_request(:get, /api\.open-meteo\.com\/v1\/forecast.*/)
      .to_return(
        status: 200,
        body: {
          "current" => { "temperature_2m" => 20.0, "weather_code" => 0, "is_day" => 0 },
          "daily" => {
            "time" => ["2025-09-04"],
            "temperature_2m_max" => [25.0],
            "temperature_2m_min" => [15.0]
          }
        }.to_json,
        headers: { "Content-Type" => "application/json" }
      )
  end

  it "renders results and caches by zip" do
    stub_geo_ok
    stub_weather_ok

    post "/forecast", params: { address: "NYC" }
    expect(response).to have_http_status(:ok)

    # allow either 20°C or 20.0°C depending on rounding precision
    expect(response.body).to match(/\b20(?:\.0)?°C\b/)

    # Second request should hit cache and show 'from cache'
    post "/forecast", params: { address: "NYC" }
    expect(response.body).to include("from cache")
  end

  it "falls back to lat/lon cache key when no postal code" do
    stub_request(:get, /nominatim\.openstreetmap\.org\/search.*/)
      .to_return(
        status: 200,
        body: [
          { "lat" => "51.5074", "lon" => "-0.1278", "display_name" => "London", "address" => {} }
        ].to_json,
        headers: { "Content-Type" => "application/json" }
      )
    stub_weather_ok

    post "/forecast", params: { address: "London" }
    expect(response).to have_http_status(:ok)
    expect(response.body).to match(/\b20(?:\.0)?°C\b/)
  end

  it "handles invalid address" do
    stub_request(:get, /nominatim\.openstreetmap\.org\/search.*/)
      .to_return(status: 200, body: "[]", headers: { "Content-Type" => "application/json" })

    post "/forecast", params: { address: "xyzxyz" }
    expect(response).to have_http_status(:not_found)
    expect(response.body).to include("Could not find that address")
  end
end
