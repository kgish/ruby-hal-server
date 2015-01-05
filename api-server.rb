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
  String      :category
  Integer     :price
end

# Create a dataset from the Products table
products = DB[:products]

# module ProductRepresenter ????
class Product < Sequel::Model
  include Roar::JSON::HAL

  HASH_ATTRS = [:id, :name, :category, :price]

  property :id
  property :name
  property :category
  property :price

  link :self do
    "/products/#{id}"
  end

  def to_hash
    HASH_ATTRS.inject({}){|res, k| res.merge k => send(k)}
  end

end
# Populate the products table with random items
names = %w{kiffin rabbit shoes george apple suitcase audi horse maserati pizza beer soap bathtub jupiter dragon dime}
categories = %w{person animal clothing fruit object car food drink unknown book gem thingie}

9.times do
  cnt = 0
  name = nil
  loop do
    cnt += 1
    # name needs to be unique
    name = names.sample
    break unless Product.first(:name => name) || cnt > 10
  end
  products.insert(
    :name     => name,
    :category => categories.sample,
    :price    => rand * 10000
  )
end

if Product.count
  cnt = 0
  puts 'PRODUCTS'
  puts '#   '.ljust(5)+'id  '.ljust(5)+'name           '.ljust(16)+'category       '.ljust(16)+'price '
  puts '----'.ljust(5)+'----'.ljust(5)+'---------------'.ljust(16)+'---------------'.ljust(16)+'----- '
  products.each do |p|
    cnt += 1
    puts cnt.to_s.ljust(5)+p[:id].to_s.ljust(5)+p[:name].ljust(16)+p[:category].ljust(16)+p[:price].to_s
  end
end

# --- Resources --- #
require 'json'
class BaseResource < Webmachine::Resource
  class << self
    alias_method :let, :define_method
  end

  let(:trace?) { true }
  let(:content_types_provided) { [['application/json', :as_json], ['text/html', :as_html]] }
  let(:content_types_accepted) { [['application/json', :from_json]] }
  let(:post_is_create?) { true }
  let(:allow_missing_post?) { true }
  #let(:from_json) { JSON.parse(request.body.to_s)['data'] }

  def finish_request
    puts "Resource::Base[#{request.method}] finish_request"
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
  class << self
    alias_method :let, :define_method
  end

  let(:as_html) { as_json_or_html 'html' }
  let(:as_json) { as_json_or_html 'json' }

  def as_json_or_html(json_or_html)
    puts "Resource::Base[#{request.method}] as_#{json_or_html}"
    result = JSON.generate(response_body)
    puts "Resource::Base[#{request.method}] as_#{json_or_html} => #{result}"
    result
  end

  private

  def response_body
    @rr ||= {
      '_links' => {
        'self' => {
          'href' => '/'
        },
        'curies' => [
          {
            'name' => 'ht',
            'href' => "http://#{request.host}:#{request.port}/rels/{rel}",
            'templated' => true
          }
        ],
        'ht:products' => {
          'href' => '/products'
        }
      },
      'welcome' => 'Welcome to Kiffin\'s Demo HAL Server.',
      'hint_1' => 'This is the first hint.',
      'hint_2' => 'This is the second hint.',
      'hint_3' => 'This is the third hint.',
      'hint_4' => 'This is the fourth hint.',
      'hint_5' => 'This is the last hint.'
    }
   @rr
  end
end

# --- Product Resource --- #
=begin

[:resource] = one of %w{products users sessions}
GET /[:resource]
{
   '_links' => {
    'self' => {
      'href' => '/[:resource]'
    },
    'curies' => [
      {
        'name' => 'ht',
        'href' => "http://[:host]:[:port]/rels/{rel}",
        'templated' => true
      }
    ],
    'ht:[:resource]' => [
      {
        'href' => "/products/[:id]",
        // [:resource].params, e.g. products
        'name' => [:name],
        'category' => [:category],
        'price' => [:price]
      },
      {
        ...
      }
    ]
  }
}

GET /[:resource]/[:id]
{
  '_links' => {
    'self' => {
      'href' => "/[:resource]/[:id]"
    },
    'curies' => [
      {
        'name' => 'ht',
        'href' => "http://[:host]:[:port]/rels/{rel}",
        'templated' => true
      }
    ]
  },
   // [:resource].params, e.g. products
  'name' => [:name],
  'category => [:category],
  'price => [:price]
}
=end

class ProductResource < BaseResource

  # let(:create_path) { "/products/#{create_resource.id}" }
  # let(:as_json) { resource_or_collection.to_json }
  # let(:resource_exists?) { !request.path_info.has_key?(:id) || !!Product[id: id] }

  def allowed_methods
    if request.path_info.has_key?(:id)
      %w{GET PUT DELETE OPTIONS}
    else
      %w{GET POST OPTIONS}
    end
  end

  def create_path
    puts "Resource::Product[#{request.method}] create_path"
    next_id = create_resource[:id]
    puts "Resource::Product[#{request.method}] next_id=#{next_id}"
    result = "/products/#{next_id}"
    puts "Resource::Product[#{request.method}] create_path => #{result}"
    result
  end

  def resource_exists?
    puts "Resource::Product[#{request.method}] resource_exists?"
    result = !request.path_info.has_key?(:id) || !!Product[id: id]
    puts "Resource::Product[#{request.method}] resource_exists? => #{result}"
    result
  end

  def delete_resource
    puts "Resource::Product[#{request.method}] delete_resource"
    Product[id: id].delete
  end


  def as_html
    puts "Resource::Product[#{request.method}] as_html"
    JSON.generate(response_body)
  end

  def as_json
    puts "Resource::Product[#{request.method}] as_json"
    JSON.generate(response_body)
  end

  def from_json
    puts "Resource::Product[#{request.method}] from_json"
    if request.method == 'PUT'
      # Remember PUT should replace the entire resource, not merge the attributes,
      # that's what PATCH is for. It's also why you should not expose your database
      # IDs as your API IDs.
      product = Product[id: id]
      response_code = 200
      if product
        puts "Resource::Product[#{request.method}] from_json, product exists"
        product.update(params)
      else
        puts "Resource::Product[#{request.method}] from_json, product does not exist"
        new_params = params
        new_params[:id] = id
        next_id = Product.insert(new_params)
        product = Product[id: next_id]
        response_code = 201 # Created
      end
      response.body = product.to_json
      response_code
    else
      result = JSON.parse(request.body.to_s)
      puts "Resource::Product[#{request.method}] from_json => #{result.inspect}"
      result
    end
  end

  protected

  def create_resource
    puts "Resource::Product[#{request.method}] create_resource"
    next_id = Product.insert(params)
    @resource = Product[id: next_id]
    puts "Resource::Product[#{request.method}] create_resource, @resource=#{@resource.inspect}"
    @resource
  end

  def resource
    puts "Resource::Product[#{request.method}] resource"
    @resource ||= Product[id: id]
  end

  def collection
    puts "Resource::Product[#{request.method}] collection"
    @collection ||= Product.all
  end

  def params
    puts "Resource::Product[#{request.method}] params"
    result = JSON.parse(request.body.to_s)['product']
    puts "Resource::Product[#{request.method}] params => #{result.inspect}"
    result
  end

  def id
    puts "Resource::Product[#{request.method}] id"
    result = request.path_info[:id]
    puts "Resource::Product[#{request.method}] id => #{result}"
    result
  end

  def response_body
    puts "Resource::Product[#{request.method}] response_body"
    id ? response_body_resource : response_body_collection
  end

  def response_body_collection
    puts "Resource::Product[#{request.method}] response_body_collection"
    # GET /products
    products = Product.all
    result = {
      '_links' => {
        'self' => {
          'href' => '/products'
        },
        'curies' => [
          {
            'name' => 'ht',
            'href' => "http://#{request.host}:#{request.port}/rels/{rel}",
            'templated' => true
          }
        ],
#        'ht:products' => []
      }
    }
    prod_list = []
    products.each do |item|
      prod_list.push({
          'href' => "/products/#{item[:id]}",
          'name' => item[:name],
          'category' => item[:category],
          'price' => item[:price]
      })
    end
    result['ht:products'] = prod_list
    puts "Resource::Product[#{request.method}] response_body_collection => #{result.inspect}"
    result
  end

  def response_body_resource
    puts "Resource::Product[#{request.method}] response_body_resource"
    # GET /products/[:id]
    product = Product[id: id]
    # product.to_hash
    result = {
      '_links' => {
        'self' => {
          'href' => "/products/#{id}"
        },
        'curies' => [
          {
            'name' => 'ht',
            'href' => "http://#{request.host}:#{request.port}/rels/{rel}",
            'templated' => true
          }
        ]
      },
      'name' => product[:name],
      'category' => product[:category],
      'price' => product[:price]
    }
    puts "Resource::Product[#{request.method}] response_body_resource => #{result.inspect}"
    result
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
