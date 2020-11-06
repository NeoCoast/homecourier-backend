# frozen_string_literal: true

module GeocoderStub
  def self.stub_with
    Geocoder.configure(lookup: :test, ip_lookup: :test)

    results = [
      {
        'coordinates' => [40.7143528, -74.0059731],
        'address' => 'New York, NY, USA',
        'state' => 'New York',
        'state_code' => 'NY',
        'country' => 'United States',
        'country_code' => 'US'
      }
    ]

    Geocoder::Lookup::Test.set_default_stub(results)
  end
end
