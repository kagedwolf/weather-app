class HomeController < ApplicationController
  before_action :set_location

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

  def reset
    @location.clear_cache!
    session.delete(:location)

    redirect_to root_path
  end

  def about
  end

  private

  def location_params
    params.fetch(:location, {}).permit(:address, :latitude, :longitude, :temperature_unit, :forecast_days)
  end

  def set_location
    @location = Location.new(session.fetch(:location, {})).tap(&:reload!)
  rescue => e
    Rails.logger.error("Error loading location from session: #{e.message}")
    session.delete(:location)
    @location = Location.new
  end
end
