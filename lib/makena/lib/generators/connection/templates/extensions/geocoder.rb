module Extensions
module Geocoder
extend ActiveSupport::Concern
included do
 
  # Testing? Then timeout now
  Geocoder.configure(:timeout => 0) unless Rails.env.test?

  # Geocoder: street address or IP address
  geocoded_by :address, :if => :address_changed?

  # Geocoder: auto-fetch coordinates
  after_validation :geocode, :if => :address_changed?

  # reverse geocode by latitude and longitude attributes
  reverse_geocoded_by :latitude, :longitude, :if => :longitude_changed?

  # Geocoder: auto-fetch address
  after_validation :reverse_geocode, :if => :longitude_changed?

end
end
end
