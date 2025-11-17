class HomeController < ApplicationController
  before_action -> {
    @location = Location.new(session.fetch(:location, {})).tap(&:reload!)
  }

  def index
  end

  def update
    @location.assign_attributes(location_params)
    @location.geocode if @location.geocode?

    if @location.changed?
      session[:location] = @location.attributes
      flash[:notice] = "Location updated."
    end

    redirect_to root_path
  end

  def about
  end

  private

  def location_params
    params.fetch(:location, {}).permit(:address, :latitude, :longitude, :temperature_unit, :forecast_days)
  end

  def forecast
    return unless @search.latitude.present? && @search.longitude.present?

    Forecast.search(latitude: @search.latitude, longitude: @search.longitude)
  end
end
