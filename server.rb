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

# Connect to an in-memory database
DB = Sequel.sqlite

# Create a Users table
DB.create_table :users do
  primary_key :id
  String      :name
  String      :username
  String      :email
  String      :password
  String      :token
  Boolean     :is_admin
  Date        :login_date
end

# Create a dataset from the Users table
users = DB[:users]

# Populate the Users table.

# kiffin => admin
users.insert(
  :name       => 'Kiffin Gish',
  :username   => 'kiffin',
  :email      => 'kiffin.gish@planet.nl',
  :password   => 'pindakaas',
  :is_admin   => true,
  :login_date => nil
)

# henri => NOT admin
users.insert(
  :name       => 'Henri Bergson',
  :username   => 'henri',
  :email      => 'henri.bergson@planet.nl',
  :password   => 'escargot',
  :is_admin   => false,
  :login_date => nil)

if users.count
  cnt = 0
  puts ' '
  puts 'USERS'
  puts '#   '.ljust(5)+'id  '.ljust(5)+'name           '.ljust(16)+'username  '.ljust(11)+'email                   '.ljust(26)+'password '.ljust(16)+'admin'
  puts '----'.ljust(5)+'----'.ljust(5)+'---------------'.ljust(16)+'----------'.ljust(11)+'------------------------'.ljust(26)+'---------'.ljust(16)+'-----'
  users.each do |u|
    cnt += 1
    admin = u[:is_admin] ? 'yes' : 'no'
    puts cnt.to_s.ljust(5)+u[:id].to_s.ljust(5)+u[:name].ljust(16)+u[:username].ljust(11)+u[:email].ljust(26)+u[:password].ljust(16)+admin
  end
end

require 'bundler/setup'
require 'roar/representer/json'
require 'roar/representer/feature/hypermedia'
require 'webmachine'

require 'resources/product'
require 'resources/session'
require 'resources/user'

# require 'time'
# require 'logger'
#
# class LogListener
#   def call(*args)
#     handle_event(Webmachine::Events::InstrumentedEvent.new(*args))
#   end
#
#   def handle_event(event)
#     request = event.payload[:request]
#     resource = event.payload[:resource]
#     code = event.payload[:code]
#
#     puts '[%s] method=%s uri=%s code=%d resource=%s time=%.4f' % [
#       Time.now.iso8601, request.method, request.uri.to_s, code, resource,
#       event.duration
#     ]
#   end
# end

# Webmachine::Events.subscribe('wm.dispatch', LogListener.new)

begin
  Webmachine.routes do
    add ['products'], ProductResource
    add ['products', :id], ProductResource
    add ['session', '*'], SessionResource
    add ['users'], UserResource
#    add ['trace', '*'], Webmachine::Trace::TraceResource
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
