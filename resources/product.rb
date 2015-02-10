require 'resources/base'
require 'models/product'

class ProductResource < BaseResource

  def is_authorized?(auth_header = nil)
    puts "Resource::Product[#{request.method}] is_authorized?(#{auth_header.inspect}) @@authorization_enabled=#{@@authorization_enabled}"
    result = false # Until proven otherwise
    if @@authorization_enabled
      if request.method == 'OPTIONS'
        result = true
      else
        if auth_header.nil?
          puts "Resource::Product[#{request.method}] is_authorized? auth_header=nil!"
        else
          user = user_auth(auth_header)
          puts "Resource::Product[#{request.method}] is_authorized? user=#{user.inspect}"
          if user.nil?
            puts "Resource::Product[#{request.method}] is_authorized? user=nil!"
          else
            if user[:is_admin]
              # Admin can do anything!
              puts "Resource::Product[#{request.method}] is_authorized? admin"
              result = true
            else
              # Other non-admin users can only view products (GET)
              puts "Resource::Product[#{request.method}] is_authorized? GET always allowed"
              result = request.method == 'GET'
            end
          end
        end
      end
    else
      result = true
    end
    puts "Resource::Product[#{request.method}] is_authorized? => #{result}"
    result
  end

  def create_path
    puts "Resource::Product[#{request.method}] create_path"
    @id = create_resource[:id]
    puts "Resource::Product[#{request.method}] next_id=#{@id}"
    result = "/products/#{@id}"
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
    result = 200
    if request.method == 'PUT'
      # The PUT method requests that the enclosed entity be stored under the supplied
      # Request-URI. If the Request-URI refers to an already existing resource, the
      # enclosed entity SHOULD be considered as a modified version of the one residing on
      # the origin server. If the Request-URI does not point to an existing resource, and
      # that URI is capable of being defined as a new resource by the requesting user
      # agent, the origin server can create the resource with that URI. If a new resource
      # is created, the origin server MUST inform the user agent via the 201 (Created) response.
      # If an existing resource is modified, either the 200 (OK) or 204 (No Content) response
      # codes SHOULD be sent to indicate successful completion of the request.
      product = Product.exists(id)
      if product
        puts "Resource::Product[#{request.method}] from_json, product exists"
        product.replace(request_payload('product'))
      else
        puts "Resource::Product[#{request.method}] from_json, product does not exist"
        rp = request_payload('product')
        rp[:id] = id
        product = Product.create(rp)
        puts "Resource::Product[#{request.method}] from_json, created new product=#{product.inspect}"
        result = 201 # Created
      end
    else
      result = 201 # Created
    end
    response.body = JSON.generate(result_resource('product', Product.resource(id)))
    puts "Resource::Product[#{request.method}] from_json => #{result}"
    result
  end

  private

  def create_resource
    puts "Resource::Product[#{request.method}] create_resource"
    @resource = Product.create(request_payload('product'))
    puts "Resource::Product[#{request.method}] create_resource, @resource=#{@resource.inspect}"
    @resource
  end

  def response_body_resource
    # GET /products/[:id]
    puts "Resource::Product[#{request.method}] response_body_resource"
    result = result_resource('product', Product.resource(id))
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
