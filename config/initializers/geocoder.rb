# frozen_string_literal: true

Geocoder.configure(
  # Geocoding options
  # timeout: 3,                 # geocoding service timeout (secs)
  lookup: :google_places_search, # name of geocoding service (symbol)
  ip_lookup: :ipinfo_io, # name of IP address geocoding service (symbol)
  api_key: AIzaSyA2noh_s_i7IxYWQ1vsC0MwYWi1nDWFkDM, # API key for geocoding service

  # Calculation options
  units: :km                 # :km for kilometers or :mi for miles
)
