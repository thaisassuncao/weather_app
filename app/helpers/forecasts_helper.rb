# frozen_string_literal: true

module ForecastsHelper
  CONDITION_LABELS = {
    sunny: "Sunny",
    clear_night: "Clear night",
    cloudy: "Cloudy",
    drizzle: "Drizzle",
    rain: "Rain",
    snow: "Snow",
    fog: "Fog",
    thunder: "Thunderstorms"
  }.freeze

  CONDITION_EMOJIS = {
    sunny: "☀️",
    clear_night: "🌙",
    cloudy: "☁️",
    drizzle: "🌦️",
    rain: "🌧️",
    snow: "🌨️",
    fog: "🌫️",
    thunder: "⛈️"
  }.freeze

  def condition_name(condition, is_day)
    return "Clear" if condition == :sunny && is_day.to_i != 1

    CONDITION_LABELS[condition] || "Weather"
  end

  def condition_emoji(condition, is_day)
    return "🌙" if condition == :sunny && is_day.to_i != 1

    CONDITION_EMOJIS[condition] || "🌤️"
  end

  def short_weekday(date_str)
    Date.parse(date_str).strftime("%a")
  rescue ArgumentError, TypeError
    ""
  end

  def format_date_ymd(date_str)
    Date.parse(date_str).strftime("%Y/%m/%d")
  rescue ArgumentError, TypeError
    date_str.to_s
  end
end
