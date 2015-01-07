require 'roar/json/hal'
require 'sequel'

#### Models (begin) ####

# --- Model::Base --- #

# Connect to an in-memory database
DB = Sequel.sqlite

# --- Model::Product --- #

DB.create_table :products do
  primary_key :id
  String      :name
  String      :category
  Integer     :price
end

# Create a dataset from the Products table
products = DB[:products]

class Product < Sequel::Model
  include Roar::JSON::HAL

  HASH_ATTRS = [:id, :name, :category, :price]

  property :id
  property :name
  property :category
  property :price

  link :self do
    "/products/#{id}"
  end

  def to_hash
    HASH_ATTRS.inject({}){|res, k| res.merge k => send(k)}
  end
end

# Populate the products table with random items
names = %w{kiffin shovel hammer rabbit shoes george apple suitcase soup audi horse maserati pizza beer soap bathtub jupiter dragon dime}
categories = %w{person mineral sport beauty health home garden animal clothing fruit object car food drink unknown book gem thingie}

9.times do
  cnt = 0
  name = nil
  loop do
    cnt += 1
    # name needs to be unique
    name = names.sample
    break unless Product.first(:name => name) || cnt > 10
  end
  products.insert(
    :name     => name,
    :category => categories.sample,
    :price    => rand * 10000
  )
end

if Product.count
  cnt = 0
  puts
  puts 'PRODUCTS'
  puts '#   '.ljust(5)+'id  '.ljust(5)+'name      '.ljust(11)+'category  '.ljust(11)+'price  to_hash'
  puts '----'.ljust(5)+'----'.ljust(5)+'----------'.ljust(11)+'----------'.ljust(11)+'-----  -------'
  products.each do |p|
    cnt += 1
    puts cnt.to_s.ljust(5)+p[:id].to_s.ljust(5)+p[:name].ljust(11)+p[:category].ljust(11)+p[:price].to_s.ljust(7)+p.to_hash.to_s
  end
end

# --- Model::Product --- #