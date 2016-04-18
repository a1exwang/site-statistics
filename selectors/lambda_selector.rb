require_relative 'geo_ip_selector'

class LambdaSelector < GeoIPSelector
  def initialize(name, lambda)
    super()
    @name = name
    @lambda = lambda
  end

  def select(ip, time, method, url, status, bytes, referer, ua)
    country = @geoip.country(ip)
    as = @asn.asn(ip)

    super if @lambda.call(ip: ip,
                 time: time,
                 method: method,
                 url: url,
                 status: status,
                 bytes: bytes,
                 referer: referer,
                 ua: ua,
                 country: country.country_name,
                 as: (as ? "#{as[0]}\t#{as[1]}" : 'Unknown'))
  end

  def name
    @name
  end
end