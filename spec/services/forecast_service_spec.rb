# frozen_string_literal: true
require "rails_helper"

RSpec.describe ForecastService do
  it "parses current and daily temps" do
    body = {
      "current" => { "temperature_2m" => 21.3 },
      "daily" => {
        "time" => ["2025-09-04", "2025-09-05"],
        "temperature_2m_max" => [27.2, 26.1],
        "temperature_2m_min" => [18.4, 17.9]
      }
    }.to_json

    stub_request(:get, /api\.open-meteo\.com\/v1\/forecast.*/)
      .to_return(status: 200, body: body, headers: { "Content-Type" => "application/json" })

    res = described_class.fetch(lat: 40.7, lon: -74.0)
    expect(res[:current_c]).to eq(21.3.round(1))
    expect(res[:current_f]).to eq(((21.3*9.0/5)+32).round(1))
    expect(res[:today_high_c]).to eq(27.2.round(1))
    expect(res[:daily].size).to eq(2)
  end

  it "raises on non-200" do
    stub_request(:get, /api\.open-meteo\.com\/v1\/forecast.*/)
      .to_return(status: 500, body: "oops")
    expect { described_class.fetch(lat: 0, lon: 0) }.to raise_error(ForecastService::FetchError)
  end
end
