require 'time'
require_relative 'geo_ip_selector'
require 'geoip'

class RangeSelector < GeoIPSelector
  attr_accessor :str
  def initialize(start_time, end_time)
    super()
    @start_time = start_time
    @end_time = end_time
  end

  def select(ip, time, method, url, status, bytes, referer, ua)
    if time.between?(@start_time, @end_time)
      super
    end
  end

  def name
    "#{@start_time.strftime '%Y-%m-%d %H:%M'} - #{@end_time.strftime '%Y-%m-%d %H:%M'} PVs and IPs:"
  end
end