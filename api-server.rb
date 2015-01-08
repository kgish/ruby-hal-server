require 'bundler/setup'
require 'webmachine'
require 'sequel'

#### Models (begin) ####

# --- Model::Base --- #

# Connect to an in-memory database
DB = Sequel.sqlite

# --- Model::Product --- #

DB.create_table :products do
  primary_key :id
  String      :name
  String      :category
  Integer     :price
end

# Create a dataset from the Products table
products = DB[:products]

class Product < Sequel::Model
  HASH_ATTRS = [:id, :name, :category, :price]

  def self.create(attributes)
    Product.insert(attributes)
  end

  def self.exists(id)
    Product[id: id]
  end

  def self.remove(id)
    Product[id: id].delete
  end

  def self.collection
    list = []
    Product.all.each do |item|
      list.push({
        href: "/products/#{item[:id]}",
        id:  item[:id],
        name: item[:name],
        category: item[:category],
        price: item[:price]
      })
    end
    list
  end

  def replace(attributes)
    update(attributes)
  end

  def to_hash
    HASH_ATTRS.inject({}){|res, k| res.merge k => send(k)}
  end
end

# Populate the products table with random names and categories
names = %w{kiffin shovel hammer rabbit shoes george apple suitcase soup audi horse maserati pizza beer soap bathtub jupiter dragon dime}
categories = %w{person mineral sport beauty health home garden animal clothing fruit object car food drink unknown book gem thingie}

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
  puts
  puts 'PRODUCTS'
  puts '#   '.ljust(5)+'id  '.ljust(5)+'name           '.ljust(16)+'category       '.ljust(16)+'price '
  puts '----'.ljust(5)+'----'.ljust(5)+'---------------'.ljust(16)+'---------------'.ljust(16)+'----- '
  products.each do |p|
    cnt += 1
    puts cnt.to_s.ljust(5)+p[:id].to_s.ljust(5)+p[:name].ljust(16)+p[:category].ljust(16)+p[:price].to_s
  end
end

# --- Model::User --- #

# Create a Users table
DB.create_table :users do
  primary_key :id
  String      :name
  String      :username
  String      :email
  String      :password
  String      :access_token
  Boolean     :is_admin
  Date        :login_date
end

# Create a dataset from the Users table
users = DB[:users]

class User < Sequel::Model
  HASH_ATTRS = [:id, :name, :username, :email, :password, :access_token, :is_admin, :login_date]

  def to_hash
    HASH_ATTRS.inject({}){|res, k| res.merge k => send(k)}
  end
end

# Populate the Users table.
# kiffin => admin
users.insert(
    :name         => 'Kiffin Gish',
    :username     => 'kiffin',
    :email        => 'kiffin.gish@planet.nl',
    :password     => 'pindakaas',
    :access_token => 'none',
    :is_admin     => true,
    :login_date   => Time.at(rand * Time.now.to_i)
)

# henri => NOT admin
users.insert(
    :name         => 'Henri Bergson',
    :username     => 'henri',
    :email        => 'henri.bergson@planet.nl',
    :password     => 'escargot',
    :access_token => 'none',
    :is_admin     => false,
    :login_date   => Time.at(rand * Time.now.to_i)
)

if users.count
  cnt = 0
  puts
  puts 'USERS'
  puts '#   '.ljust(5)+'id  '.ljust(5)+'name           '.ljust(16)+'username  '.ljust(11)+'email                   '.ljust(26)+'password '.ljust(16)+'admin'
  puts '----'.ljust(5)+'----'.ljust(5)+'---------------'.ljust(16)+'----------'.ljust(11)+'------------------------'.ljust(26)+'---------'.ljust(16)+'-----'
  users.each do |u|
    cnt += 1
    admin = u[:is_admin] ? 'yes' : 'no'
    puts cnt.to_s.ljust(5)+u[:id].to_s.ljust(5)+u[:name].ljust(16)+u[:username].ljust(11)+u[:email].ljust(26)+u[:password].ljust(16)+admin
  end
  puts
end

#### Models (end) ####

#### Resources (begin) ####

# --- Resource::Base --- #

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

  let(:as_html) { as_json_or_html 'html' }
  let(:as_json) { as_json_or_html 'json' }

  # A method called response_body MUST be defined in all subclasses
  def as_json_or_html(json_or_html)
    puts "Resource::Base[#{request.method}] as_#{json_or_html}"
    result = JSON.generate(response_body)
    puts "Resource::Base[#{request.method}] as_#{json_or_html} => #{result}"
    result
  end

  def finish_request
    puts "Resource::Base[#{request.method}] finish_request"
    # This method is called just before the final response is
    # constructed and sent. The return value is ignored, so any effect
    # of this method must be by modifying the response.

    # Enable simple cross-origin resource sharing (CORS)
    response.headers['Access-Control-Allow-Origin']   = '*'
    response.headers['Access-Control-Allow-Methods']  = 'GET, POST, PUT, DELETE, HEAD, OPTIONS'
    response.headers['Access-Control-Allow-Headers']  = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
    response.headers['Access-Control-Expose-Headers'] = 'connect-src self'
  end

  protected

  def allowed_methods
    puts "Resource::Base[#{request.method}] allowed_methods"
    if request.path_info.has_key?(:id)
      %w{GET PUT DELETE OPTIONS}
    else
      %w{GET POST OPTIONS}
    end
  end

  def response_body
    puts "Resource::Base[#{request.method}] response_body"
    id ? response_body_resource : response_body_collection
  end

  def result_resource(resource_name, resource)
    result = {
      _links: {
        self: {
          href: "/#{resource_name}s/#{id}"
        },
        curies: [
          {
            name: "#{curie_name}",
            href: "http://#{request.host}:#{request.port}/rels/{rel}",
            templated: true
          }
        ]
      }
    }
    result.merge!(resource)
  end

  def result_collection(resource_name, collection)
    puts "Resource::Base[#{request.method}] build_result_collection"
    result = {
        _links: {
            self:  {
                href: "/#{resource_name}s"
            },
            curies: [
                {
                    name: curie_name,
                    href: "http://#{request.host}:#{request.port}/rels/{rel}",
                    templated: true
                }
            ],
        }
        #     'curie_name:resource_name' => []
    }
    result[:_links]["#{curie_name}:#{resource_name}"] = collection
    result
  end

  def params(resource_name)
    puts "Resource::Base[#{request.method}] params(#{resource_name})"
    result = JSON.parse(request.body.to_s)[resource_name]
    puts "Resource::Base[#{request.method}] params(#{resource_name}) => #{result.inspect}"
    result
  end

  def id
    puts "Resource::Base[#{request.method}] id"
    result = request.path_info[:id]
    puts "Resource::Base[#{request.method}] id => #{result}"
    result
  end

  def curie_name
    'ht'
  end

end

# --- Resource::Root --- #

class RootResource < BaseResource

  let(:allowed_methods) { %w{GET} }

  resources = %w{ product user session }

  def response_body
    result = {
      _links: {
        self: {
          href: '/'
        },
        curies: [
          {
            name: curie_name,
            href: "http://#{request.host}:#{request.port}/rels/{rel}",
            templated: true
          }
        ],
        "#{curie_name}:products" =>  {
          href: '/products'
        },
        "#{curie_name}:users" =>  {
          href: '/users'
        },
        "#{curie_name}:sessions" =>  {
        href: '/sessions'
    }
      },
      welcome: 'Welcome to Kiffin\'s Demo HAL Server.',
      hint_1:  'This is the first hint.',
      hint_2:  'This is the second hint.',
      hint_3:  'This is the third hint.',
      hint_4:  'This is the fourth hint.',
      hint_5:  'This is the last hint.'
    }
    puts "Resource::Root[#{request.method}] response_body_resource => #{result.inspect}"
    result
  end
end

# --- Resource::Product --- #

class ProductResource < BaseResource

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
    result = !request.path_info.has_key?(:id) || !!Product.exists(id)
    puts "Resource::Product[#{request.method}] resource_exists? => #{result}"
    result
  end

  def delete_resource
    puts "Resource::Product[#{request.method}] delete_resource"
    Product.remove(id)
  end

  def from_json
    puts "Resource::Product[#{request.method}] from_json"
    if request.method == 'PUT'
      # Remember PUT should replace the entire resource, not merge the attributes,
      # that's what PATCH is for. It's also why you should not expose your database
      # IDs as your API IDs.
      product = Product.exists(id)
      response_code = 200
      if product
        puts "Resource::Product[#{request.method}] from_json, product exists"
        product.replace(params('product'))
      else
        puts "Resource::Product[#{request.method}] from_json, product does not exist"
        new_params = params('product')
        new_params[:id] = id
        product = Product.create(new_params)
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
    result = Product.create(params('product'))
    puts "Resource::Product[#{request.method}] create_resource, @resource=#{result.inspect}"
    result
  end

  def response_body_resource
    # GET /products/[:id]
    puts "Resource::Product[#{request.method}] response_body_resource"
    result = result_resource('product', Product.exists(id))
    puts "Resource::Product[#{request.method}] response_body_resource => #{result.inspect}"
    result
  end

  def response_body_collection
    # GET /products
    puts "Resource::Product[#{request.method}] response_body_collection"
    result = result_collection('product', Product.collection)
    puts "Resource::Product[#{request.method}] response_body_collection => #{result.inspect}"
    result
  end

end

# --- Resource::User --- #

class UserResource < BaseResource

end

# --- Resource::Session --- #

class SessionResource < BaseResource

end

#### Resources (end) ####

#### Logger (begin) ####

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

#### Logger (end) ####

#### Application (begin) ####

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

#### Application (end) ####
