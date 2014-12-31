require 'webmachine'
require 'json'

class Resource < Webmachine::Resource
  class << self
    alias_method :let, :define_method
  end

  let(:trace?) { true }
  let(:content_types_provided) { [['application/json', :to_json]] }
  let(:content_types_accepted) { [['application/json', :from_json]] }
  let(:post_is_create?) { true }
  let(:allow_missing_post?) { true }
  let(:from_json) { JSON.parse(request.body.to_s)['data'] }

  def is_authorized?(auth)
    puts "Resource: is_authorized? => cookies:#{request.cookies.inspect}"
    true
  end

end

