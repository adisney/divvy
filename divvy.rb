require 'net/http'
require 'json'

def get_stations()
  uri = URI('https://feeds.divvybikes.com/stations/stations.json')
  response = Net::HTTP.get(uri)
  return JSON.parse(response, {:symbolize_names => true})
end

def station_details(stations, ids)
  stations[:stationBeanList].select { |s| ids.include? s[:id] }
end

def test_threshold(station, object, threshold)
  key = "available#{object.capitalize}s".to_sym
  if station[key] < threshold 
    return "#{station[key]} #{object}(s) left at #{station[:stationName]}"
  else
    return ""
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

# 17 - Division & Wood
#123 - California & Milwaukee
#260 - Kedzie & Milwaukee
#506 - Spauling and Armitage

departure_ids = eval ARGV[0]
arrival_ids = eval ARGV[1]

stations = get_stations()
departure_stations = station_details(stations, departure_ids)
arrival_stations = station_details(stations, arrival_ids)

messages = []

departure_stations.each do | station |
  messages.push test_threshold(station, "bike", 4)
end

arrival_stations.each do | station |
  messages.push test_threshold(station, "dock", 4)
end

messages.reject!(&:empty?)
if not messages.empty?
  send_message(messages.join(" and "))
end
