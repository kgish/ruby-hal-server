require 'models/base'

DB.create_table :products do
  primary_key :id
  String      :name
  String      :category
  Integer     :price
end

# Create a dataset from the Products table
products = DB[:products]

class Product < Sequel::Model
  HASH_ATTRS = [:id, :name, :category, :price]

  def self.create(attributes)
    id = Product.insert(attributes)
    Product[id: id]
  end

  def self.exists(id)
    Product[id: id]
  end

  def self.remove(id)
    Product[id: id].delete
  end

  def self.collection
    list = []
    Product.all.each do |item|
      list.push({
        href: "/products/#{item[:id]}",
        id:  item[:id],
        name: item[:name],
        category: item[:category],
        price: item[:price]
      })
    end
    list
  end

  def replace(attributes)
    update(attributes)
  end

  def to_hash
    HASH_ATTRS.inject({}){|res, k| res.merge k => send(k)}
  end
end

# Populate the products table with random names and categories
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
  puts '#   '.ljust(5)+'id  '.ljust(5)+'name           '.ljust(16)+'category       '.ljust(16)+'price '
  puts '----'.ljust(5)+'----'.ljust(5)+'---------------'.ljust(16)+'---------------'.ljust(16)+'----- '
  products.each do |p|
    cnt += 1
    puts cnt.to_s.ljust(5)+p[:id].to_s.ljust(5)+p[:name].ljust(16)+p[:category].ljust(16)+p[:price].to_s
  end
end

