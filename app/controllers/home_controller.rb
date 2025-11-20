class HomeController < ApplicationController
  before_action :set_location

  def index
  end

  def about
    file = Rails.root.join("README.md")
    @content = file.exist? ? file.read : "README file not found."
  end

  def update_location
    @location.assign_attributes(location_params)
    @location.geocode if @location.geocode?

    if @location.changed?
      session[:location] = @location.attributes
      flash[:notice] = "Location updated."
    end

    redirect_to root_path
  end

  def clear_cache
    Rails.cache.clear
    flash[:notice] = "Cache cleared."

    redirect_to root_path
  end

  def reset_location
    @location.clear_cache!
    session.delete(:location)
    flash[:notice] = "Location has been reset."

    redirect_to root_path
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
