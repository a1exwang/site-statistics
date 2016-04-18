require_relative 'base'
require 'geoip'
class GeoIPSelector < Selector

  def initialize
    super
    @ips = {}
    @geoip = GeoIP.new('GeoIP.dat')
    @asn = GeoIP.new('GeoIPASNum.dat')
  end

  def select(ip, time, method, url, status, bytes, referer, ua)
    if @ips.key?(ip)
      @ips[ip][:count] += 1
      @ips[ip][:time] << time
    else
      @ips[ip] = { count: 1, time: [ time ] }
    end
  end

  def get_str
    str = ''
    pv = @ips.to_a.reduce(0) { |sum, x| sum + x[1][:count] }
    (@ips.sort_by { |item| item[1][:count] }).each do |ip, val|
      country = @geoip.country(ip)
      as = @asn.asn(ip)
      str += "#{val[:count]}\t#{ip}\t#{country.country_name}\t\t" + (as ? "#{as[0]}\t#{as[1]}" : 'Unknown')
      str += "\n"
    end

    str += "\npv: #{pv}\n"
    str += "ips: #{@ips.size}\n"

    str
  end
end