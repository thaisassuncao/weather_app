# frozen_string_literal: true

require "rails_helper"
require "uri"
require "cgi"

RSpec.describe GeocodingService do
  it "geocodes an address and returns lat/lon/postal" do
    stub_geo_ok(
      name: "New York, United States",
      lat: "40.7127281", lon: "-74.0060152", postcode: "10007", country_code: "us"
    )

    res = described_class.geocode("new york city")

    expect(res[:lat]).to be_within(0.001).of(40.7127)
    expect(res[:lon]).to be_within(0.001).of(-74.0060)
    expect(res[:postal_code]).to eq("10007")
    expect(res[:country_code]).to eq("us")
    expect(res[:display_name]).to eq("New York, United States")
  end

  it "returns nil on not found" do
    stub_geo_none

    expect(described_class.geocode("zzzz")).to be_nil
  end

  it "returns nil on HTTP 500" do
    stub_request(:get, %r{nominatim\.openstreetmap\.org/search})
      .to_return(status: 500, body: "oops")

    expect(described_class.geocode("nyc")).to be_nil
  end

  it "returns nil on invalid JSON" do
    stub_request(:get, %r{nominatim\.openstreetmap\.org/search})
      .to_return(status: 200, body: "not-json", headers: { "Content-Type" => "application/json" })

    expect(described_class.geocode("nyc")).to be_nil
  end

  # rubocop:disable RSpec/ExampleLength
  it "sends the expected params and headers" do
    stub_request(:get, %r{\Ahttps://nominatim\.openstreetmap\.org/search(?:\?.*)?\z})
      .with do |req|
        uri = URI(req.uri)
        q   = CGI.parse(uri.query.to_s)

        q["q"] == ["new york city"] &&
          q["format"] == ["json"] &&
          q["addressdetails"] == ["1"] &&
          q["limit"] == ["1"] &&
          req.headers["Accept"] == "application/json" &&
          req.headers["User-Agent"].to_s.match?(/Forecast/i)
      end
      .to_return(status: 200, body: "[]", headers: { "Content-Type" => "application/json" })

    described_class.geocode("new york city")

    expect(
      a_request(:get, %r{\Ahttps://nominatim\.openstreetmap\.org/search(?:\?.*)?\z})
    ).to have_been_made.once
  end
  # rubocop:enable RSpec/ExampleLength
end
