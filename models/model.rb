#require 'roar/representer/json'
#require 'roar/representer/feature/hypermedia'
#require 'sqlite3'

class Model
  include Roar::Representer::JSON
  include Roar::Representer::Feature::Hypermedia

  property :id

#  link :self do
#    "/#{id}"
#  end
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
