# frozen_string_literal: true

class ForecastsController < ApplicationController
  def new; end

  # rubocop:disable Metrics/AbcSize
  def create
    @address = params[:address].to_s.strip
    return render_invalid(:missing_address, :unprocessable_entity) if @address.blank?

    geo = geocode_address(@address)
    return render_invalid(:not_found, :not_found) unless geo

    @location_name = geo[:display_name]
    @postal_code   = geo[:postal_code]
    @country_code  = geo[:country_code]
    lat, lon       = geo.values_at(:lat, :lon)

    key = cache_key_for(@postal_code, @country_code, lat, lon)
    @forecast, @from_cache = read_or_fetch_forecast(key, lat, lon)
    @theme_class = "theme-#{(@forecast[:condition] || :default).to_s.dasherize}"

    render :new, status: :ok
  rescue ForecastService::FetchError
    render_invalid(:weather_unavailable, :service_unavailable)
  end
  # rubocop:enable Metrics/AbcSize

  private

  def render_invalid(i18n_key, status)
    flash.now[:alert] = I18n.t(i18n_key, scope: "alerts")
    render :new, status:
  end

  def geocode_address(addr)
    GeocodingService.geocode(addr)
  end

  def forecast_days
    ForecastService.const_defined?(:FORECAST_DAYS) ? ForecastService::FORECAST_DAYS : 7
  end

  def cache_key_for(postal, country, lat, lon)
    d = forecast_days

    if postal.present? && country.present?
      format("forecast:zip:%<cc>s-%<pc>s:d%<d>d",
             cc: country.downcase, pc: postal.downcase, d:)
    else
      format("forecast:latlon:%<lat>.4f_%<lon>.4f:d%<d>d",
             lat:, lon:, d:)
    end
  end

  def read_or_fetch_forecast(key, lat, lon)
    if (cached = Rails.cache.read(key))
      [cached, true]
    else
      fresh = ForecastService.fetch(lat:, lon:)
      Rails.cache.write(key, fresh, expires_in: 30.minutes)
      [fresh, false]
    end
  end
end
