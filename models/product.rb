#require 'bundler/setup'
require 'roar/representer/json'
require 'roar/representer/feature/hypermedia'

class Product
  include Roar::Representer::JSON
  include Roar::Representer::Feature::Hypermedia

  property :name
  property :id
  property :price

  link :self do
    "/products/#{id}"
  end
end

# We're in-memory ROFLSCALE
$products = [
    Product.from_attributes(:id => 1,
                            :name => "Nick's Awesomesauce",
                            :price => 10_000_000),
    Product.from_attributes(:id => 2,
                            :name => "Kiffin's Fancysalade",
                            :price => 20_000)
]

