$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'bundler/setup'
require 'webmachine'

# Resources
require 'resources/root'
require 'resources/product'
require 'resources/user'
require 'resources/session'

# Logging
require 'helpers/logger'

ENVIRONMENT ||= 'development'

App = Webmachine::Application.new do |app|
  app.configure do |config|
    config.adapter = :WEBrick
    config.ip = '127.0.0.1'
    config.port = 8080
    config.adapter = :WEBrick
    config.adapter_options = {}
  end

  app.routes do
    add [], RootResource
    add ['products'], ProductResource
    add ['products', :id], ProductResource
    add ['users'], UserResource
    add ['users', :id], UserResource
    add ['session', :*], SessionResource
    add ['trace', :*], Webmachine::Trace::TraceResource
  end

end

begin
  App.run
rescue Exception => e
  puts e.message
end
