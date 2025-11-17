module ApplicationHelper
  def weather_description(code, is_day = true)
    period = is_day ? "day" : "night"
    weather_codes.dig(code, period, "description") || "Unknown"
  end

  def weather_icon(code, is_day = true)
    period = is_day ? "day" : "night"
    weather_codes.dig(code, period, "image") || "http://openweathermap.org/img/wn/01d@2x.png"
  end

  def weather_codes
    @weather_codes ||= Rails.root.join("config/wmo_codes.yml")
      .read.then { |f| YAML.safe_load(f) }
  end
end
