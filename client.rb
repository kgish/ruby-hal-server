require 'bundler/setup'
require 'httparty'
require 'json'

puts 'POST /products Beer'
response = HTTParty.post('http://localhost:8080/products', :body => {:product => {:name => "Beer", :category => "Drink", :price => 125}}.to_json, :headers => {'Content-type' => 'application/json'})
puts response.body, response.code, response.message, response.headers.inspect
puts ' '

puts 'GET /product Beer'
prod = response.headers["location"]
response = HTTParty.get(prod, :headers => {'Content-type' => 'application/json'})
puts response.body, response.code, response.message, response.headers.inspect
puts ' '

puts 'POST /products Cadillac'
response = HTTParty.post('http://localhost:8080/products', :body => {:product => {:name => "Cadillac", :category => "Car", :price => 1_850_000}}.to_json, :headers => {'Content-type' => 'application/json'})
puts response.body, response.code, response.message, response.headers.inspect
puts ' '

puts 'GET /product Cadillac'
prod = response.headers["location"]
response = HTTParty.get(prod, :headers => {'Content-type' => 'application/json'})
puts response.body, response.code, response.message, response.headers.inspect
puts ' '


puts 'GET /products ALL'
response = HTTParty.get('http://localhost:8080/products', :headers => {'Content-type' => 'application/json'})
puts response.body, response.code, response.message, response.headers.inspect
puts ' '

#puts 'DELETE /product'
#response = HTTParty.delete(prod, :headers => {'Content-type' => 'application/json'})
#puts response.body, response.code, response.message, response.headers.inspect
#puts ' '
#
#puts 'GET /products'
#response = HTTParty.get('http://localhost:8080/products', :headers => {'Content-type' => 'application/json'})
#puts response.body, response.code, response.message, response.headers.inspect
#puts ' '
