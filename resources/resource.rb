require 'webmachine'
require 'json'

class Resource < Webmachine::Resource
  class << self
    alias_method :let, :define_method
  end

  let(:trace?) { true }
  let(:content_types_provided) { [["application/json", :to_json]] }
  let(:content_types_accepted) { [["application/json", :from_json]] }
  let(:post_is_create?) { true }
  let(:allow_missing_post?) { true }
  let(:from_json) { JSON.parse(request.body.to_s)['data'] }

  #let(:create_path) { "/evaluations/#{create_resource.id}" }
  #let(:from_json) { request.body.rewind; JSON.parse(request.body.read) }
  #let(:to_json) { resource_or_collection.to_json }

  # protected
  #
  #   def parsed_body
  #     @parsed_body ||= JSON.parse(request.body.to_s)
  #   end
end

#class ProductResource < Webmachine::Resource
#
#  def resource_exists?
#    @product = $products[request.path_info[:id].to_i - 1] if request.path_info[:id]
#    !@product.nil?
#  end
#
#  def from_json
#    $products << @product.from_json(request.body.to_s, :except => [:id])
#  end
#  
#  def to_json
#    @product.to_json
#  end
#end
