# frozen_string_literal: true

module TestHelpers
  def round_like_service(temp)
    return nil if temp.nil?

    nd = ForecastService::TEMP_PRECISION
    nd.zero? ? temp.round : temp.round(nd)
  end
end
