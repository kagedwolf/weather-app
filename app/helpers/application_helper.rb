module ApplicationHelper
  def render_markdown(text)
    Kramdown::Document.new(text).to_html.html_safe
  end

  def weather_icon_tag(code, is_day = true, **options)
    options.with_defaults!(class: "weather-icon", alt: weather_description(code, is_day))
    icon_url = weather_icon(code, is_day)
    image_tag(icon_url, **options)
  end

  def weather_description(code, is_day = true)
    period = is_day.in?([false, 0]) ? "night" : "day"
    weather_codes.dig(code, period, "description") || "Unknown"
  end

  def weather_icon(code, is_day = true)
    period = is_day.in?([false, 0]) ? "night" : "day"
    weather_codes.dig(code, period, "image") || "http://openweathermap.org/img/wn/01d@2x.png"
  end

  def weather_codes
    @weather_codes ||= Rails.root.join("config/wmo_codes.yml")
      .read.then { |f| YAML.safe_load(f) }
  end
end
