require 'resources/resource'
require 'models/product'
require 'json'

class ProductResource < Resource

  def allowed_methods
    puts "ProductResource[#{request.method}]: allowed_methods"
    if request.path_info.has_key?(:id)
      %w{GET PUT DELETE OPTIONS}
    else
      %w{GET POST OPTIONS}
    end
  end

  def resource_exists?
    if request.path_info.has_key?(:id)
      @resource = Product.find(id)
      result = !@resource.nil?
    else
      result = true
    end
    puts "ProductResource[#{request.method}]: resource_exists => #{result}"
    result
  end

  def delete_resource
    puts "ProductResource[#{request.method}]: delete_resource"
    Product.delete(id)
  end

  def create_path
    @resource = Product.create
    @resource.to_json
    path = @resource.links[:self]
    puts "ProductResource[#{request.method}]: create_path => ${path}"
    path
  end

  def resource
    puts "ProductResource[#{request.method}]: resource"
    @resource ||= Product.find(id)
  end

  def collection
    puts "ProductResource[#{request.method}]: collection"
    @collection ||= Product.all
  end

  def resource_or_collection
    puts "ProductResource[#{request.method}]: resource_or_collection"
    @resource || {:products => collection.map(&:to_hash)}
  end

  def to_json
    puts "ProductResource[#{request.method}]: to_json"
    resource_or_collection.to_json
  end

  def from_json
    puts "ProductResource[#{request.method}]: from_json"
    if request.method === 'PUT'
      if @resource
        delete_resource
        # TODO response.code = 201
      end
      attributes = params
      attributes['id'] = id
      new_product = Product.from_attributes(attributes)
      $products << new_product
      response.body = new_product.to_json
    else
      $products << @resource.from_json(request.body.to_s, :except => [:id])
    end
  end

  def params
    params = JSON.parse(request.body.to_s).to_hash['product']
    puts "ProductResource[#{request.method}]: params => #{params}"
    params
  end

  def id
    puts "ProductResource[#{request.method}]: id"
    request.path_info[:id]
  end

end
