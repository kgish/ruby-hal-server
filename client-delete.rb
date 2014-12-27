require 'bundler/setup'
require 'httparty'
require 'json'

puts 'POST /products Red ball'
response = HTTParty.post('http://localhost:8080/products', :body => {:product => {:name => "Red ball", :category => "Toy", :price => 175}}.to_json, :headers => {'Content-type' => 'application/json'})
puts response.body, response.code, response.message, response.headers.inspect
puts ' '

puts 'GET /product Red ball'
prod = response.headers["location"]
response = HTTParty.get(prod, :headers => {'Content-type' => 'application/json'})
puts response.body, response.code, response.message, response.headers.inspect
puts ' '

puts 'GET /products ALL'
response = HTTParty.get('http://localhost:8080/products', :headers => {'Content-type' => 'application/json'})
puts response.body, response.code, response.message, response.headers.inspect
puts ' '

puts 'DELETE /product Red ball'
response = HTTParty.delete(prod, :headers => {'Content-type' => 'application/json'})
puts response.body, response.code, response.message, response.headers.inspect
puts ' '

puts 'GET /products ALL'
response = HTTParty.get('http://localhost:8080/products', :headers => {'Content-type' => 'application/json'})
puts response.body, response.code, response.message, response.headers.inspect
