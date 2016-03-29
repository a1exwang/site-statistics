#!/usr/bin/env ruby
require 'geoip'

log_dir = '/var/log/nginx/'
all_log = ''
Dir.entries(log_dir).each do |f|
  if f =~ /access\.log.*/
    if f =~ /\.gz$/
      log = `gunzip #{File.join(log_dir, f)} -d --stdout | cut -d " " -f 1`
    else
      log = `cat #{File.join(log_dir, f)} | cut -d " " -f 1`
    end
    all_log += log  + "\n"
  end
end
ips = Hash.new 0

all_log.split("\n").each do |ip|
  ips[ip] += 1
end

geoip = GeoIP.new('GeoIP.dat')
asn = GeoIP.new('GeoIPASNum.dat')

(ips.sort_by { |item| item[1] }).each do |ip, count|
  country = geoip.country(ip)
  as = asn.asn(ip)
  puts "#{count}\t#{ip}\t#{country.country_name}\t\t" + (as ? "#{as[0]}\t#{as[1]}" : '')
end 
