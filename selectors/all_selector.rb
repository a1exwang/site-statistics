require 'geoip'
require 'time'
require_relative 'geo_ip_selector'

class AllSelector < GeoIPSelector
  def name
    'All PVs and IPs:'
  end
end