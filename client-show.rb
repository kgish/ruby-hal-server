require 'bundler/setup'
require 'httparty'
require 'json'

puts 'GET /products ALL'
response = HTTParty.get('http://localhost:8080/products', :headers => {'Content-type' => 'application/json'})
puts response.code, response.headers.inspect, response.message

h = JSON.parse response.body
#puts h['products']

cnt = 0
h['products'].each do |key|
if cnt == 0
  puts "#\tid\tname\tprice\tcategory"
  puts "-\t--\t----\t-----\t--------"
end
  p = key['product']
  cnt = cnt + 1
  puts "#{cnt}\t#{p['id']}\t#{p['name']}\t#{p['price']}\t#{p['category']}"
end

puts ' '
puts "There are -#{cnt}- products"
