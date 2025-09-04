# frozen_string_literal: true
module ForecastsHelper
  def condition_name(condition, is_day)
    case condition
    when :sunny        then is_day.to_i == 1 ? "Sunny" : "Clear"
    when :clear_night  then "Clear night"
    when :cloudy       then "Cloudy"
    when :drizzle      then "Drizzle"
    when :rain         then "Rain"
    when :snow         then "Snow"
    when :fog          then "Fog"
    when :thunder      then "Thunderstorms"
    else "Weather"
    end
  end

  def condition_emoji(condition, is_day)
    case condition
    when :sunny        then is_day.to_i == 1 ? "☀️" : "🌙"
    when :clear_night  then "🌙"
    when :cloudy       then "☁️"
    when :drizzle      then "🌦️"
    when :rain         then "🌧️"
    when :snow         then "🌨️"
    when :fog          then "🌫️"
    when :thunder      then "⛈️"
    else "🌤️"
    end
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
