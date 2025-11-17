# README

## Requirements

- [X] Must be done in Ruby on Rails
- [X] Accept an address as input
- [X] Retrieve forecast data for the given address. This should include, at minimum, the current temperature (Bonus points - Retrieve high/low and/or extended forecast)
- [X] Display the requested forecast details to the user
- [X] Cache the forecast details for 30 minutes for all subsequent requests by zip codes.
  - [X] Display indicator if result is pulled from cache.

## Explanations

### Why OpenStreetMap?

The requirement "Accept an address as input" implies a user may include a street in the address.

Most weather APIs prefer `latitude` and `longitude` parameters. Some can be queried by `city` and `state`. Every API tested failed when a street was included.

Geocoding the address prior to requesting the forecast adds complexity and a peformance hit. However, given the requirement, this seems like a reasonable compromise.

A custom `OpenStreetMapClient` class was necessary to geolocate addresses because:
- Gems specific to `OpenStreetMap` are no longer maintained
- The `geocoder` gem failed with a `certificate verify failed` error
- It was decided that creating a custom client would be faster than troubleshooting certificate issues

### Why Open-Meteo vs OpenWeather?

The current release of the `open-weather-ruby-client` gem only provides current weather data.  It does not support the free forecasts endpoint (https://api.openweathermap.org/data/2.5/forecast?lat={lat}&lon={lon}&appid={API key}).

Interestingly, the main branch on github has does: https://github.com/dblock/open-weather-ruby-client/blob/master/lib/open_weather/endpoints/five_day_forecast.rb.

The `open-meteo` gem worked immediately without needing to sign up for an API key.  I is also able to provide current weather as well as hourly and daily forecasts.

### AI generated code

This project was created with limited use of AI agents since the assumption is to showcase "my" skill level. The prompts below were used - using VSCode Copilot (GPT-5 mini).

- Add a basic application layout using bootstrap.
- I've decided to use the slim-rails gem. Can you convert the erb view files to slim?
- Can you enable hot reloading?
- Can you generate a config/wmo_codes.yml file with the values from this gist: https://gist.github.com/stellasphere/9490c195ed2b53c707087c8c2db4ec0c
- You should use the raw file found at: https://gist.githubusercontent.com/stellasphere/9490c195ed2b53c707087c8c2db4ec0c/raw/76b0cb0ef0bfd8a2ec988aa54e30ecd1b483495d/descriptions.json
