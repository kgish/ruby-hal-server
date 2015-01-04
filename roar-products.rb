require 'webmachine'
require 'roar/json/hal'
require 'sequel'


# --- Model --- #

# class Sequel::Model
#   def attributes_equal_to(attrs)
#     attrs.inject(true) do |res, kv|
#       k,v = kv
#       self.class.columns.include?(k) ? res && (send(k) == v) : res
#     end
#   end
# end

# Connect to an in-memory database
DB = Sequel.sqlite

DB.create_table :products do
  primary_key :id
  String      :name
end

# Create a dataset from the Products table
products = DB[:products]

# module ProductRepresenter ????
class Product < Sequel::Model
  include Roar::JSON::HAL

  HASH_ATTRS = [:id, :name]

  property :id
  property :name

  link :self do
    "/products/#{id}"
  end

  def self.find(id)
    self[:id => id]
  end

  def to_hash
    HASH_ATTRS.inject({}){|res, k| res.merge k => send(k)}
  end

end

# Populate the products table with random items
names = %w{henry george happy thomas robert michael chappy}

5.times do
  cnt = 0
  name = nil
  loop do
    cnt += 1
    # name needs to be unique
    name = names.sample
    break unless products.first(:name => name) || cnt > 10
  end
  # products.insert( :name => name )
  Product.create( :name => name )
end

product = Product.create(:name => 'Kiffin')

puts ' '
puts product.to_json

if products.count
  cnt = 0
  puts ' '
  puts 'PRODUCTS'
  puts '#   '.ljust(5)+'id  '.ljust(5)+'name       '
  puts '----'.ljust(5)+'----'.ljust(5)+'-----------'
  # products.each do |p|
  #   cnt += 1
  #   puts cnt.to_s.ljust(5)+p[:id].to_s.ljust(5)+p[:name].ljust(16)
  # end
  while cnt < products.count do
    cnt += 1
    p = products[:id => cnt]
    puts cnt.to_s.ljust(5)+p[:id].to_s.ljust(5)+p[:name].ljust(16)+p.to_json
  end
  puts ' '
end

# --- Resources --- #

class BaseResource < Webmachine::Resource
  class << self
    alias_method :let, :define_method
  end

  let(:trace?) { true }
  let(:content_types_provided) { [['application/json', :to_json], ['text/html', :to_html]] }
  let(:content_types_accepted) { [['application/json', :from_json]] }
  let(:post_is_create?) { true }
  let(:allow_missing_post?) { true }
  let(:from_json) { JSON.parse(request.body.to_s)['data'] }

  def finish_request
    puts "Resources::Base[#{request.method}] finish_request"
    # This method is called just before the final response is
    # constructed and sent. The return value is ignored, so any effect
    # of this method must be by modifying the response.

    # Enable simple cross-origin resource sharing (CORS)
    response.headers['Access-Control-Allow-Origin'] = '*'
    response.headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS'
    response.headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
  end
end

# --- Root Resource --- #

class RootResource < BaseResource
  def to_json
    root_response.to_json
  end

  def to_html
    "<pre>#{root_response}</pre>"
  end

  private

  def root_response
    <<-ROOT_RESPONSE
{
  '_links': {
    'self': {
      'href': '/'
    },
    'curies': [
      {
        'name': 'ht',
        'href': 'http://127.0.0.1:8080/rels/{rel}',
        'templated': true
      }
    ],
    'ht:products': {
      'href': '/products'
    }
  },
  'welcome': 'Welcome to the Demo HAL Server.',
  'hint_1': 'This is the first hint.',
  'hint_2': 'This is the second hint.',
  'hint_3': 'This is the third hint.',
  'hint_4': 'This is the fourth hint.',
  'hint_5': 'This is the last hint.'
}
    ROOT_RESPONSE
  end
end

# --- Product Resource --- #

class ProductResource < BaseResource
  def allowed_methods
    %w{ GET }
  end

  def resource_exists?
    @product = Product.find(id)
    !!@product
  end

  def to_json
    @product.to_json
  end

  def to_html
    @product.to_json
  end

  private

  def product
    #@product ||= Product.new(params)
    @product
  end

  def id
    request.path_info[:id]
  end

end

# --- Logger --- #

require 'time'
require 'logger'

class LogListener
  def call(*args)
    handle_event(Webmachine::Events::InstrumentedEvent.new(*args))
  end

  def handle_event(event)
    request = event.payload[:request]
    resource = event.payload[:resource]
    code = event.payload[:code]

    puts '[%s] method=%s uri=%s code=%d resource=%s time=%.4f' % [
      Time.now.iso8601, request.method, request.uri.to_s, code, resource,
      event.duration
    ]
  end
end

Webmachine::Events.subscribe('wm.dispatch', LogListener.new)

# --- Application --- #

App = Webmachine::Application.new do |app|
  app.configure do |config|
    config.adapter = :WEBrick
    config.ip = '127.0.0.1'
    config.port = 8080
    config.adapter = :WEBrick
  end

  app.routes do
    add [], RootResource
    add ['products'], ProductResource
    add ['products', :id], ProductResource
    add ['trace', :*], Webmachine::Trace::TraceResource
  end

end

App.run
