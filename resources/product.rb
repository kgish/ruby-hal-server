require './resources/resource'
require './models/product'
require 'json'

class ProductResource < Resource

  let(:allowed_methods) { %w{GET POST PUT DELETE} }
#  let(:create_path) { "/products/#{create_resource.id}" }
  let(:to_json) { resource_or_collection.to_json }
#  let(:resource_exists?) { !request.path_info.has_key?(:id) || !!Product[id: request.path_info[:id] ] }

  def resource_exists?
    if (!request.path_info.has_key?(:id))
      res = true
    else
      @resource = $products[request.path_info[:id].to_i - 1]
      res = !@resource.nil?
    end
    puts "ProductResource: resource_exists => #{res}"
    res
  end

  def delete_resource
    puts 'ProductResource: delete_resource'
    $products.delete_at(request.path_info[:id].to_i - 1)
    true
  end

  def create_path
    puts 'ProductResource: create_path'
    @resource = Product.from_attributes(:id => $products.length+1)
    @resource.to_json
    @resource.links[:self]
  end

  protected

  # def create_resource
  #   puts 'ProductResource: create_resource'
  #   @resource = Product.create(from_json)
  #   #response.body = as_json
  # end

  def resource
    puts 'ProductResource: resource'
    #@resource ||= Product[id: request.path_info[:id]]
    @resource ||= $products[request.path_info[:id].to_i - 1]
  end

  def collection
    puts 'ProductResource: collection'
    #@collection ||= Product.all
    @collection ||= $products
  end

  def resource_or_collection
    puts 'ProductResource: resource_or_collection'
    @resource || {:products => collection.map(&:to_hash)}
#    resource ? resource.to_hash : {:products => collection.map(&:to_hash)}
  end

  def from_json
    puts 'ProductResource: from_json'
    $products << @resource.from_json(request.body.to_s, :except => [:id])
  end

end

#class ProductResource < Webmachine::Resource
#
#  def to_json
#    @product.to_json
#  end
#end