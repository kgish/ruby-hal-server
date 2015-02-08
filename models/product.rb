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
    where(id: id).first
  end

  def self.remove(id)
    Product[id: id].delete
  end

  def self.resource(id)
    p = Product[id: id]
    {
        # id:      p[:id],
        name:     p[:name],
        category: p[:category],
        price:    p[:price]
    }
  end

  def self.collection
    list = []
    Product.all.each do |p|
      list.push({
        href:    "/products/#{p[:id]}",
        # id:      p[:id],
        name:     p[:name],
        category: p[:category],
        price:    p[:price]
      })
    end
    list
  end

  def replace(attributes)
    # Strip out unwanted and/or malicious attributes just in case.
    safe_attributes = attributes.select{|k| %w{name category price}.include?(k.to_s)}
    update(safe_attributes)
  end

  def to_hash
    HASH_ATTRS.inject({}){|res, k| res.merge k => send(k)}
  end
end

# Populate the products table with random names and categories
names = %w{kiffin shovel hammer rabbit shoes george apple suitcase soup audi horse maserati magazine pencil pizza beer soap bathtub jupiter dragon dime}
categories = %w{person mineral sport beauty health home garden animal mineral clothing money fruit object car food drink unknown book gem thingie}

10.times do
  cnt = 0
  name = nil
  loop do
    cnt += 1
    # name needs to be unique
    name = names.sample
    break unless Product.first(:name => name) || cnt > 10
  end
  Product.create(
      :name     => name,
      :category => categories.sample,
      :price    => rand * 10000
  )
end

if Product.count
  cnt = 0
  puts
  puts 'PRODUCTS'
  puts '#  '.ljust(4)+'id '.ljust(4)+'name      '.ljust(11)+'category  '.ljust(11)+'price '
  puts '---'.ljust(4)+'---'.ljust(4)+'----------'.ljust(11)+'----------'.ljust(11)+'----- '
  products.each do |p|
    cnt += 1
    puts cnt.to_s.ljust(4)+p[:id].to_s.ljust(4)+p[:name].ljust(11)+p[:category].ljust(11)+p[:price].to_s
  end
  puts
end

