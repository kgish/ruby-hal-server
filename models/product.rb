require 'models/model'

# Create a Products table
DB.create_table :products do
  primary_key :id
  String      :name
  String      :category
  Integer     :price
end

# Create a dataset from the Products table
products = DB[:products]

# Populate the products table with random items

names = %w{kiffin rabbit shoes george apple suitcase audi horse maserati pizza beer soap bathtub jupiter dragon dime}
categories = %w{person animal clothing fruit object car food drink unknown book gem thingie}

9.times do
  cnt = 0
  name = nil
  loop do
    cnt += 1
    # name needs to be unique
    name = names.sample
    break unless products.first(:name => name) || cnt > 10
  end
  products.insert(
    :name     => name,
    :category => categories.sample,
    :price    => rand * 10000
  )
end

if products.count
  cnt = 0
  puts ' '
  puts 'PRODUCTS'
  puts '#   '.ljust(5)+'id  '.ljust(5)+'name           '.ljust(16)+'category       '.ljust(16)+'price '
  puts '----'.ljust(5)+'----'.ljust(5)+'---------------'.ljust(16)+'---------------'.ljust(16)+'----- '
  products.each do |p|
    cnt += 1
    puts cnt.to_s.ljust(5)+p[:id].to_s.ljust(5)+p[:name].ljust(16)+p[:category].ljust(16)+p[:price].to_s
  end
  puts ' '
end

class Product < Model

  property :name
  property :category
  property :price

  def self.create
    product = Product.from_attributes(:id => $next_product_id)
    loop do
      $next_product_id += 1
      break unless find($next_product_id)
    end
    product
  end

  def self.find(id)
    $products.find{|a| a.id.to_i === id.to_i}
  end

  def self.delete(id)
    found = false
    product = self.find(id)
    if product
      ind = $products.find_index(product)
      unless ind.nil?
        $products.delete_at(ind)
        found = true
      end
    end
    found
  end

  def self.all
    $products
  end

  link :self do
    "/products/#{id}"
  end

end

# In-memory for the time being.
$products = [
    Product.from_attributes(:id => 1,
                            :name => 'pizza',
                            :category => 'food',
                            :price => 500),
    Product.from_attributes(:id => 2,
                            :name => 'shoes',
                            :category => 'clothing',
                            :price => 2_000),
    Product.from_attributes(:id => 3,
                            :name => 'laptop',
                            :category => 'computer',
                            :price => 500_000)
]

# Product counter, incremented with each new product created.
$next_product_id = 4

#
# begin
#
#   dbname = "test.db"
#
#   db = SQLite3::Database.open dbname
#   db.execute "CREATE TABLE IF NOT EXISTS Products(Id INTEGER PRIMARY KEY, Name TEXT, Category TEXT, Price INT)"
#   db.execute "DELETE FROM Products"
#   db.execute "INSERT INTO Products VALUES(1,'Audi','Car',52642)"
#   db.execute "INSERT INTO Products VALUES(2,'Mercedes','Car',57127)"
#   db.execute "INSERT INTO Products VALUES(3,'Skoda','Car',9000)"
#   db.execute "INSERT INTO Products VALUES(4,'Volvo','Car',29000)"
#   db.execute "INSERT INTO Products VALUES(5,'Bentley','Car',350000)"
#   db.execute "INSERT INTO Products VALUES(6,'Citroen','Car',21000)"
#   db.execute "INSERT INTO Products VALUES(7,'Hummer','Car',41400)"
#   db.execute "INSERT INTO Products VALUES(8,'Volkswagen','Car',21600)"
#
#   count = db.last_insert_row_id
#
#   puts "Inserted #{count} products into database #{dbname}"
#
# rescue SQLite3::Exception => e
#
#   puts "Exception occurred"
#   puts e
#
# ensure
#   db.close if db
# end
