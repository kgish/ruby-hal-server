require 'hyperresource'

api = HyperResource.new(
    root: 'http://localhost:8080',
    headers: {'Accept' => 'application/json'}
)

begin
  puts 'root = api.get'
  root = api.get
  puts root.body

  puts 'products = api.products'
  products = api.products
  puts products
rescue HyperResource::ResponseError => e
  puts "HyperResource::ResponseError => #{e.message}"
rescue Exception => e
  puts "Exception => #{e.message}"
end
