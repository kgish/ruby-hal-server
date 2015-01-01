$LOAD_PATH.unshift(File.dirname(__FILE__))

ENVIRONMENT ||= 'development'

require 'sequel'
class Sequel::Model
  def attributes_equal_to(attrs)
    attrs.inject(true) do |res, kv|
      k,v = kv
      self.class.columns.include?(k) ? res && (send(k) == v) : res
    end
  end
end

# connect to an in-memory database
DB = Sequel.sqlite

# create a products table
DB.create_table :products do
  primary_key :id
  String :name
  String :category
  Integer :price
end

# create a dataset from the items table
products = DB[:products]

# populate the table

names = %w{kiffin rabbit shoes george apple suitcase audi horse maserati pizza beer soap bathtub jupiter dragon dime}
categories = %w{person animal clothing fruit object car food drink unknown book gem thingie}

10.times { products.insert(:name => names.sample, :category => categories.sample, :price => rand * 10000) }

puts "Created #{products.count} products"

if products.count
  cnt = 0
  puts '#   '.ljust(5)+'id  '.ljust(5)+'name           '.ljust(16)+'category       '.ljust(16)+'price '
  puts '----'.ljust(5)+'----'.ljust(5)+'---------------'.ljust(16)+'---------------'.ljust(16)+'----- '
  products.each do |p|
    cnt += 1
    puts cnt.to_s.ljust(5)+p[:id].to_s.ljust(5)+p[:name].ljust(16)+p[:category].ljust(16)+p[:price].to_s
  end
end

require 'bundler/setup'
require 'roar/representer/json'
require 'roar/representer/feature/hypermedia'
require 'webmachine'

#require 'resources/session'
#require 'resources/user'
require 'resources/product'

begin
  Webmachine.routes do
    add ['products'], ProductResource
    add ['products', :id], ProductResource
#    add ['sessions', '*'], SessionResource
#    add ['users'], UserResource
  end.run
rescue Exception => e
  puts e.message
  exit
end

#App = Webmachine::Application.new do |app|
#  app.configure do |config|
#    config.adapter = :WEBrick
#  end
#
#  app.routes do
#    add ['trace', '*'], Webmachine::Trace::TraceResource
#    add ['users', :id], UserResource
#    add ['products', :id], ProductResource
#    add ['products'], ProductResource
#    add ['notes', '*'], NoteResource
#    add ['notes', :id], NoteResource
#    add ['tasks', :task_id, 'notes'], NoteResource
#  end
#
#end
#
#App.run
