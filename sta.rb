#!/usr/bin/env ruby
require 'geoip'
require 'time'

log_dir = '/var/log/nginx/'
all_log = ''
Dir.entries(log_dir).each do |f|
  if f =~ /access\.log.*/
    if f =~ /\.gz$/
      log = `gunzip #{File.join(log_dir, f)} -d --stdout | cut -d " " -f 1,4,5`
    else
      log = `cat #{File.join(log_dir, f)} | cut -d " " -f 1,4,5`
    end
    all_log += log  + "\n"
  end
end
ips = Hash.new 0
yesterday_ips = 0
yesterday_pvs = 0
all_log.split("\n").each do |line|
  ip, date1, date2 = line.split(' ')
  next unless ip && date1 && date2
  date = (date1+date2)[1...-1]
  day, hh, mm, ss = date.split(':')
  tstr = day+' '+hh+':'+mm+':'+ss
  t = Time.parse(tstr)
  yesterday_pvs += 1 if t.between?(Time.now-86400, Time.now)
  if ips.key?(ip)
    ips[ip][:count] += 1
    ips[ip][:date] << t
  else
    ips[ip] = { count: 1, date: [ t ] }
    yesterday_ips += 1 if t.between?(Time.now-86400, Time.now)
  end
end

geoip = GeoIP.new('GeoIP.dat')
asn = GeoIP.new('GeoIPASNum.dat')

pv = ips.to_a.reduce(0) { |sum, x| sum + x[1][:count] } 
(ips.sort_by { |item| item[1][:count] }).each do |ip, val|
  country = geoip.country(ip)
  as = asn.asn(ip)
  puts "#{val[:count]}\t#{ip}\t#{country.country_name}\t\t" + (as ? "#{as[0]}\t#{as[1]}" : '')
end 

puts "pv: #{pv}"
puts "ips: #{ips.size}"
puts "yesterday pvs: #{yesterday_pvs}"
puts "yesterday ips: #{yesterday_ips}"
