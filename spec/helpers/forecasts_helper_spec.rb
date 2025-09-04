# frozen_string_literal: true

require "rails_helper"

RSpec.describe ForecastsHelper, type: :helper do
  describe "#format_date_ymd / #short_weekday" do
    it "formats valid dates" do
      expect(helper.format_date_ymd("2025-09-04")).to eq("2025/09/04")
      expect(helper.short_weekday("2025-09-04")).to match(/\A[A-Za-z]{3}\z/)
    end

    it "is resilient to invalid inputs" do
      expect(helper.format_date_ymd(nil)).to eq("")
      expect(helper.short_weekday("nope")).to eq("")
    end
  end

  describe "#condition_name / #condition_emoji" do
    it "returns sunny/☀️ during the day for :sunny" do
      expect(helper.condition_name(:sunny, 1)).to eq("Sunny")
      expect(helper.condition_emoji(:sunny, 1)).to eq("☀️")
    end

    it "returns clear night/🌙 at night for :sunny" do
      expect(helper.condition_name(:sunny, 0)).to eq("Clear")
      expect(helper.condition_emoji(:sunny, 0)).to eq("🌙")
    end

    it "returns mapped labels/emojis for other conditions" do
      expect(helper.condition_name(:drizzle, 1)).to eq("Drizzle")
      expect(helper.condition_emoji(:drizzle, 1)).to eq("🌦️")
    end
  end
end
