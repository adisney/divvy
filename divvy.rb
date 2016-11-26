require 'net/http'
require 'json'

uri = URI('https://feeds.divvybikes.com/stations/stations.json')
response = Net::HTTP.get(uri)
stations = JSON.parse(response, {:symbolize_names => true})

# 17
#123
departure_id = ARGV[0].to_i
#506
arrival_id = ARGV[1].to_i

departure_station = stations[:stationBeanList].select { |s| s[:id] == departure_id }[0]
arrival_station = stations[:stationBeanList].select { |s| s[:id] == arrival_id }[0]

message = ""

if departure_station[:availableBikes] < 3 
  message = "#{departure_station[:availableBikes]} bike(s) left at #{departure_station[:stationName]}"
end

if arrival_station[:availableDocks] < 4
  if not message.empty?
    message += " and "
  end
  message += "#{arrival_station[:availableDocks]} docks(s) left at #{arrival_station[:stationName]}"
end

if not message.empty?
  url = URI.parse("https://api.pushover.net/1/messages.json")
  req = Net::HTTP::Post.new(url.path)
  req.set_form_data({
      :token => "amwgnue5wa7gm3hmi6z97tqjq6quz7",
      :user => "uah7sDAHUfvaju3S4WvALuQK2fq5H5",
      :message => "Only #{message}",
  })
  res = Net::HTTP.new(url.host, url.port)
  res.use_ssl = true
  res.verify_mode = OpenSSL::SSL::VERIFY_PEER
  res.start {|http| http.request(req) }
end
