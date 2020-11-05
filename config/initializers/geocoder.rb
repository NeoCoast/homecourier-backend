# frozen_string_literal: true

Geocoder.configure(
  # Geocoding options
  # timeout: 3,                 # geocoding service timeout (secs)
  lookup: :nominatim, # name of geocoding service (symbol)
  ip_lookup: :ipinfo_io, # name of IP address geocoding service (symbol)
  # api_key: nil,               # API key for geocoding service

  # Calculation options
  units: :km                 # :km for kilometers or :mi for miles
)
