require 'models/model'

class Product < Model

  property :name
  property :category
  property :price

  link :self do
    "/products/#{id}"
  end
end

# We're in-memory ROFLSCALE
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
