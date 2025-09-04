# frozen_string_literal: true
require "rails_helper"

RSpec.describe GeocodingService do
  it "geocodes an address and returns lat/lon/postal" do
    stub_request(:get, /nominatim\.openstreetmap\.org\/search.*/)
      .to_return(status: 200, body: [
        {
          "lat" => "40.7127281",
          "lon" => "-74.0060152",
          "display_name" => "New York, United States",
          "address" => { "postcode" => "10007", "country_code" => "us" }
        }
      ].to_json, headers: { "Content-Type" => "application/json" })

    res = described_class.geocode("new york city")
    expect(res[:lat]).to be_within(0.001).of(40.7127)
    expect(res[:lon]).to be_within(0.001).of(-74.0060)
    expect(res[:postal_code]).to eq("10007")
    expect(res[:country_code]).to eq("us")
  end

  it "returns nil on not found" do
    stub_request(:get, /nominatim\.openstreetmap\.org\/search.*/)
      .to_return(status: 200, body: "[]", headers: { "Content-Type" => "application/json" })
    expect(described_class.geocode("zzzz")).to be_nil
  end
end
