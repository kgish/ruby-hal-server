require 'hyperresource'

api = HyperResource.new(
    root: 'http://localhost:8080',
    headers: {'Accept' => 'application/json'}
)

puts 'api.get'
response = api.get
puts "#{response.inspect}"
puts ' '
puts 'api.products'
response = api.products
puts "#{response.inspect}"
