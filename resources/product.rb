require './resources/resource'
require './models/product'
require 'json'

class ProductResource < Resource

  let(:allowed_methods) { %w{GET POST PUT DELETE} }
#  let(:create_path) { "/products/#{create_resource.id}" }
  def create_path
    puts 'create_path'
    @product = Product.from_attributes(:id => $products.length+1)
    @product.to_json
    @product.links[:self]
  end
  let(:to_json) { resource_or_collection.to_json }
#  let(:resource_exists?) { !request.path_info.has_key?(:id) || !!Product[id: request.path_info[:id] ] }

  def resource_exists?
    puts 'resource_exists'
    @product = $products[request.path_info[:id].to_i - 1] if request.path_info[:id]
    !@product.nil?
  end

  protected

  def create_resource
    puts 'create_resource'
    @resource = Product.create(from_json)
    #response.body = as_json
  end

  def resource
    puts 'resource'
    @resource ||= Product[id: request.path_info[:id]]
  end

  def collection
    puts 'collection'
    @collection ||= Product.all
  end

  def resource_or_collection
    puts 'resource_or_collection'
    @product.to_json
#    resource ? resource.to_hash : {:products => collection.map(&:to_hash)}
  end

  def from_json
    puts 'from_json'
    $products << @product.from_json(request.body.to_s, :except => [:id])
  end

end

#class ProductResource < Webmachine::Resource
#
#  def to_json
#    @product.to_json
#  end
#end
