require 'bundler/setup'
require 'httparty'
require 'json'

puts 'POST /products'
response = HTTParty.post('http://localhost:8080/products', :body => {:product => {:name => "Beer"}}.to_json, :headers => {'Content-type' => 'application/json'})
puts response.body, response.code, response.message, response.headers.inspect
puts ' '

puts 'GET /product'
prod = response.headers["location"]
response = HTTParty.get(prod, :headers => {'Content-type' => 'application/json'})
puts response.body, response.code, response.message, response.headers.inspect
puts ' '

puts 'GET /products'
response = HTTParty.get('http://localhost:8080/products', :headers => {'Content-type' => 'application/json'})
puts response.body, response.code, response.message, response.headers.inspect
puts ' '

puts 'DELETE /product'
response = HTTParty.delete(prod, :headers => {'Content-type' => 'application/json'})
puts response.body, response.code, response.message, response.headers.inspect
puts ' '

puts 'GET /products'
response = HTTParty.get('http://localhost:8080/products', :headers => {'Content-type' => 'application/json'})
puts response.body, response.code, response.message, response.headers.inspect
puts ' '
