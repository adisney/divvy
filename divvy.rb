require 'net/http'
require 'json'

uri = URI('https://feeds.divvybikes.com/stations/stations.json')
response = Net::HTTP.get(uri)
stations = JSON.parse(response, {:symbolize_names => true})

# 17 - Division & Wood
#123 - California & Milwaukee
#260 - Kedzie & Milwaukee
#506 - Spauling and Armitage
departure_ids = eval ARGV[0]
arrival_ids = eval ARGV[1]

departure_stations = stations[:stationBeanList].select { |s| departure_ids.include? s[:id] }
arrival_stations = stations[:stationBeanList].select { |s| arrival_ids.include? s[:id] }

message = ""

departure_stations.each do | departure_station |
  if departure_station[:availableBikes] < 3 
    if not message.empty?
      message += " and "
    end
    message += "#{departure_station[:availableBikes]} bike(s) left at #{departure_station[:stationName]}"
  end
end

arrival_stations.each do | arrival_station |
  if arrival_station[:availableDocks] < 4
    if not message.empty?
      message += " and "
    end
    message += "#{arrival_station[:availableDocks]} docks(s) left at #{arrival_station[:stationName]}"
  end
end

def send_message(message)
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

if not message.empty?
  #send_message(message)
  puts message
end
