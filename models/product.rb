require './models/model'

class Product < Model

  property :name
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

