require 'roar/json/hal'
require 'sequel'

# class Sequel::Model
#   def attributes_equal_to(attrs)
#     attrs.inject(true) do |res, kv|
#       k,v = kv
#       self.class.columns.include?(k) ? res && (send(k) == v) : res
#     end
#   end
# end

# Connect to an in-memory database
DB = Sequel.sqlite

DB.create_table :products do
  primary_key :id
  String      :name
end

# Create a dataset from the Products table
products = DB[:products]

# Populate the products table with random items
names = %w{kiffin henry george thomas robert michael }

5.times do
  cnt = 0
  name = nil
  loop do
    cnt += 1
    # name needs to be unique
    name = names.sample
    break unless products.first(:name => name) || cnt > 10
  end
  products.insert(
      :name => name
  )
end

module ProductRepresenter
  include Roar::JSON::HAL

  HASH_ATTRS = [:id, :name]

  def to_hash
    HASH_ATTRS.inject({}){|res, k| res.merge k => send(k)}
  end

  property :id
  property :name

  link :self do
    "/products/#{id}"
  end
end

class Product < Sequel::Model
  include Roar::JSON::HAL

  property :id
  property :name

  link :self do
    "/products/#{id}"
  end

end

product = Product.create(:name => 'Kiffin')

puts product.to_json

if products.count
  cnt = 0
  puts ' '
  puts 'PRODUCTS'
  puts '#   '.ljust(5)+'id  '.ljust(5)+'name       '
  puts '----'.ljust(5)+'----'.ljust(5)+'-----------'
  # products.each do |p|
  #   cnt += 1
  #   puts cnt.to_s.ljust(5)+p[:id].to_s.ljust(5)+p[:name].ljust(16)
  # end
  while cnt < products.count do
    cnt += 1
    p = products[:id => cnt]
    puts cnt.to_s.ljust(5)+p[:id].to_s.ljust(5)+p[:name].ljust(16)
  end
  puts ' '
end

