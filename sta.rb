#!/usr/bin/env ruby
require 'geoip'
require 'time'

require './selectors/all_selector'
require './selectors/range_selector'
require './selectors/lambda_selector'

# combine nginx log files
log_dir = '/var/log/nginx/'
all_log = ''
Dir.entries(log_dir).each do |f|
  if f =~ /access\.log.*/
    if f =~ /\.gz$/
      log = `gunzip #{File.join(log_dir, f)} -d --stdout`
    else
      log = `cat #{File.join(log_dir, f)}`
    end
    all_log += log  + "\n"
  end
end

# parse log

data_selectors = [
    AllSelector.new,
    RangeSelector.new(Time.now - 86400, Time.now),
    RangeSelector.new(Time.parse('2016-04-10'), Time.now),
    LambdaSelector.new('custom', lambda do |info|
      info[:time].between?(Time.parse('2016-04-10'), Time.now) &&
        info[:country] == 'China'
    end)
]

NGINX_REGEX = /^([^ ]+) [^ ]+ [^ ]+ \[([^:]+):([^ ]+ [^ ]+)\] "(\w+) ([^ ]+) [^"]+" (\d+) (\d+) "([^"]+)" "([^"]+)"$/

all_log.split("\n").each do |line|

  # 115.230.124.164 - - [17/Apr/2016:12:20:03 +0800] "GET http://zc.qq.com/cgi-bin/common/attr?id=260714&r=0.0832784589517522 HTTP/1.1" 404 209 "-" "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0; 360SE)"
  if (m = NGINX_REGEX.match(line))
    ip, d1, d2, method, url, status, bytes, referer, ua = m[1..-1]

    t = Time.parse(d1 + ' ' + d2)
    data_selectors.each do |selector|
      selector.select(ip, t, method, url, status.to_i, bytes.to_i, referer, ua)
    end
  else
    #puts line
  end
end

data_selectors.each do |selector|
  puts selector.name
  puts selector.to_s
  puts
end
