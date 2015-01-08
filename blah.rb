require 'bundler/setup'
require 'sequel'

DB = Sequel.sqlite

DB.create_table :products do
  primary_key :id
  String      :name
  String      :category
  Integer     :price
end

products = DB[:products]

class Product < Sequel::Model
  HASH_ATTRS = [:name, :category, :price]

  def to_hash
    HASH_ATTRS.inject({}){|res, k| res.merge k => send(k)}
  end
end

Product.insert(
  :name     => 'kiffin',
  :category => 'person',
  :price    => 10000
)

product = Product[id: 1]

puts product.to_hash

result = {
  _links: {
    self: {
      href: "/products/#{product[:id]}"
    },
    curies: [
      {
        name: 'ht',
        href: "http://0.0.0.0:8080/rels/{rel}",
        templated: true
      }
    ]
  },
  name: product[:name],
  category: product[:category],
  price: product[:price]
}

puts result.inspect

result2 = {
    _links: {
        self: {
            href: "/products/#{product[:id]}"
        },
        curies: [
            {
                name: 'ht',
                href: "http://0.0.0.0:8080/rels/{rel}",
                templated: true
            }
        ]
    }
}

result2.merge!(product.to_hash)

puts result2.inspect
