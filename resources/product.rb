require 'resources/base'
require 'models/product'

class ProductResource < BaseResource

  def is_authorized?(auth_header = nil)
    puts "Resource::Product[#{request.method}] is_authorized?(#{auth_header.inspect})"
    result = false # Until proven otherwise
    if request.method == 'OPTIONS' or request.method == 'GET'
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
          end
        end
      end
    end
    puts "Resource::Product[#{request.method}] is_authorized? => #{result}"
    result
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
        product.replace(request_payload('product'))
      else
        puts "Resource::Product[#{request.method}] from_json, product does not exist"
        rp = request_payload('product')
        rp[:id] = id
        product = Product.create(rp)
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

  private

  def create_resource
    puts "Resource::Product[#{request.method}] create_resource"
    result = Product.create(request_payload('product'))
    puts "Resource::Product[#{request.method}] create_resource, @resource=#{result.inspect}"
    result
  end

  def response_body_resource
    # GET /products/[:id]
    puts "Resource::Product[#{request.method}] response_body_resource"
    result = result_resource('product', Product.result(id))
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
