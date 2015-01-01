require 'resources/resource'
require 'models/product'
require 'json'

class ProductResource < Resource

  let(:allowed_methods) { %w{GET POST PUT DELETE OPTIONS} }
  let(:to_json) { resource_or_collection.to_json }

  def resource_exists?
    if (!request.path_info.has_key?(:id))
      res = true
    else
      @resource = Product.find(id)
      res = !@resource.nil?
    end
    puts "ProductResource[#{request.method}]: resource_exists => #{res}"
    res
  end

  def delete_resource
    puts "ProductResource[#{request.method}]: delete_resource"
    Product.delete(id)
  end

  def create_path
    puts "ProductResource[#{request.method}]: create_path id = #{$next_product_id}"
    @resource = Product.from_attributes(:id => $next_product_id); $next_product_id += 1
    @resource.to_json
    @resource.links[:self]
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

  def from_json
    puts "ProductResource[#{request.method}]: from_json"
    if request.method === 'PUT'
      # Replace the entire resource, not merge the attributes! That's what PATCH is for.
      # order.destroy if order
      # new_order = Order.new(params)
      # new_order.save(id)
      # response.body = new_order.to_jsoo
      #response.body = @resource.to_json
      delete_resource if @resource
      attributes = params
      attributes['id'] = id
      new_product = Product.from_attributes(attributes);
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
