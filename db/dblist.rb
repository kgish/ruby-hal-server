require 'sqlite3'

begin
    
  db = SQLite3::Database.open "test.db"
    
  puts"SELECT * FROM Products" 
  stm = db.prepare "SELECT * FROM Products" 
  rs = stm.execute 
    
  rs.each do |row|
    puts row.join "\s"
  end
           
rescue SQLite3::Exception => e 
    
  puts "Exception occurred"
  puts e
    
ensure
  stm.close if stm
  db.close if db
end
