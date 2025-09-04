# frozen_string_literal: true
class ForecastsController < ApplicationController
  def new
    # renders the search page
  end

  def create
    @address = params[:address].to_s.strip
    if @address.blank?
      flash.now[:alert] = "Please enter an address."
      return render :new, status: :unprocessable_entity
    end

    geo = GeocodingService.geocode(@address)
    if geo.nil?
      flash.now[:alert] = "Could not find that address."
      return render :new, status: :not_found
    end

    @location_name = geo[:display_name]
    @postal_code   = geo[:postal_code]
    @country_code  = geo[:country_code]
    lat, lon       = geo.values_at(:lat, :lon)

    key =
      if @postal_code.present? && @country_code.present?
        "forecast:zip:#{@country_code.downcase}-#{@postal_code.downcase}"
      else
        "forecast:latlon:#{format('%.4f', lat)}_#{format('%.4f', lon)}"
      end

    cached = Rails.cache.read(key)
    if cached
      @from_cache = true
      @forecast = cached
    else
      @forecast = ForecastService.fetch(lat:, lon:)
      @from_cache = false
      Rails.cache.write(key, @forecast, expires_in: 30.minutes)
    end

    render :new, status: :ok
  rescue ForecastService::FetchError => e
    Rails.logger.warn("Forecast fetch failed: #{e.message}")
    flash.now[:alert] = "Weather service is unavailable right now."
    render :new, status: :service_unavailable
  end
end
