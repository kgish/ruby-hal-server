require 'sqlite3'

begin
    
  dbname = "test.db"

  db = SQLite3::Database.open dbname
  db.execute "CREATE TABLE IF NOT EXISTS Products(Id INTEGER PRIMARY KEY, 
      Name TEXT, Category TEXT, Price INT)"
  db.execute "DELETE FROM Products"
  db.execute "INSERT INTO Products VALUES(1,'Audi','Car',52642)"
  db.execute "INSERT INTO Products VALUES(2,'Mercedes','Car',57127)"
  db.execute "INSERT INTO Products VALUES(3,'Skoda','Car',9000)"
  db.execute "INSERT INTO Products VALUES(4,'Volvo','Car',29000)"
  db.execute "INSERT INTO Products VALUES(5,'Bentley','Car',350000)"
  db.execute "INSERT INTO Products VALUES(6,'Citroen','Car',21000)"
  db.execute "INSERT INTO Products VALUES(7,'Hummer','Car',41400)"
  db.execute "INSERT INTO Products VALUES(8,'Volkswagen','Car',21600)"

  count = db.last_insert_row_id

  puts "Inserted #{count} products into database #{dbname}"
    
rescue SQLite3::Exception => e 
    
  puts "Exception occurred"
  puts e
    
ensure
  db.close if db
end
