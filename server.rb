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
    add ['users', :id], UserResource
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
