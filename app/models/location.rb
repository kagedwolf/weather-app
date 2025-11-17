class Location
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Dirty

  attribute :address, :string
  attribute :longitude, :decimal
  attribute :latitude, :decimal
  attribute :forecast_days, :integer, default: 7
  attribute :temperature_unit, :string, default: "fahrenheit"

  validates :latitude, :longitude, presence: true, numericality: true
  validates :temperature_unit, inclusion: {in: Forecast::TEMPERATURE_UNITS, message: "%{value} is not a valid temperature unit"}

  def geocoded?
    latitude.present? && longitude.present?
  end

  def geocode?
    latitude.blank? || longitude.blank? || address_changed? && address.present?
  end

  # could store data[:address] components if needed
  def geocode
    # find should always return a hash (even if empty)
    # always overwrite lat/lon to clear previous values
    geocode_client.find(address).tap do |data|
      self.latitude, self.longitude = data.values_at("lat", "lon")
    end
  end

  def coordinates
    values_at(:latitude, :longitude).map { |v| v.truncate(3) }.join(", ")
  end

  def forecasted?
    forecast.present?
  end

  def forecast
    @forecast ||= fetch_forecast
  end

  def save
    changes_applied # clears dirty tracking info
  end

  def reload!
    clear_changes_information # clears dirty data
  end

  def rollback!
    restore_attributes # restores all previous values
  end

  private

  def geocode_client
    @geocode_client ||= OpenStreetMapClient.new
  end

  # could accpet variable arguments for more flexibility
  # may be safer to cache parsed forecast data rather than raw API response
  # https://open-meteo.com/en/docs
  def fetch_forecast
    return unless geocoded?

    cache_key = "forecast/#{latitude}/#{longitude}/#{temperature_unit}/#{forecast_days}"
    Rails.cache.fetch(cache_key, expires_in: 30.minutes) do
      Rails.logger.info("-------- CACHE MISS: Fetching forecast for #{address} --------")
      location = OpenMeteo::Entities::Location.new(latitude: latitude, longitude: longitude)
      variables = {
        temperature_unit: temperature_unit, forecast_days: forecast_days,
        current: %i[temperature_2m precipitation weather_code is_day],
        daily: %i[temperature_2m_max temperature_2m_min weather_code]
      }
      OpenMeteo::Forecast.new.get(location: location, variables: variables)
    rescue => e
      Rails.logger.error("Error fetching forecast: #{e.message}")
      nil
    end
  end

  # NOTES:
  # Turns out most weather APIs require lat/lon coordinates rather than
  # address strings.
  #
  # The OpenMeteo API has a geocoding service but appears to be limited
  # to cities only.
  #
  # Tried using the Geocoder gem but got invalid certificate errors and
  # didn't want to waste time troubleshooting.
  #
  # Since I was able to easily curl the nominatim API I decided to write
  # a simple client.
  #
  # Example curl command:
  # curl -s \
  #   'https://nominatim.openstreetmap.org/search?q=1+apple+park+way,cupertino&format=json' \
  #   | jq
  #
  # API docs: https://nominatim.org/release-docs/develop/api/Search

  class OpenStreetMapClient
    # Ensure find and search always return a useful default value
    def find(term, **params)
      search(term, **params.with_defaults(limit: 1))&.first || {}
    end

    def search(term, **params)
      Rails.logger.info("OpenStreetMap search for: #{term}")
      client.get("search", params.merge(q: term)).body.presence || [{}]
      # .map { |data| parse(data) }
    rescue => e
      Rails.logger.error("Error during OpenStreetMap search: #{e.message}")
      [{}] # return empty result to avoid breaking callers
    end

    private

    # def parse(data)
    #   address = parse_address(data)
    #   geocode = parse_location(data)
    #   address.merge(geocode)
    # end
    #
    # def parse_location(data)
    #   data.slice("lat", "lon")
    #     .transform_keys("lat" => "latitude", "lon" => "longitude")
    # end
    #
    # def parse_address(data)
    #   data.fetch("address", {})
    #     .slice("road", "city", "state", "country")
    #     .transform_keys("road" => "street", "state" => "region", "city" => "locality")
    # end

    def client
      @client ||= begin
        params = {
          format: "json",
          countrycodes: "us,ca", # limit search to US and Canada
          addressdetails: 1, # include address details in response
          featuretype: "settlement", # restrict to states, cities, neighborhoods
          layer: "address"
        }

        Faraday.new(url: "https://nominatim.openstreetmap.org", params: params) do |faraday|
          faraday.request :json
          faraday.response :json
        end
      end
    end
  end
end
