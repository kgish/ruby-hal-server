class BaseModel
  include Roar::JSON::HAL

  property :id

  # link :self do
  #   "/#{id}"
  # end
end

# begin
#
#   db = SQLite3::Database.new ':memory:'
#   puts "SQLite3::Database.new ':memory:' => Succeeded"
#   version = db.get_first_value 'SELECT SQLITE_VERSION()'
#   puts "SELECT SQLITE_VERSION() => #{version}"
#
# rescue SQLite3::Exception => e
#
#   puts "Exception occurred"
#   puts e
#
# ensure
#   db.close if db
# end
