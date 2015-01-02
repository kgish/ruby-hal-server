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
    puts "Resources::Resource[#{request.method}] is_authorized? => cookies:#{request.cookies.inspect}"
    # parsed_body = 'EMPTY!'
    # parsed_body = JSON.parse(request.body.to_s) unless request.body.to_s.empty?
    # puts "Resource::[#{request.method}] body => #{parsed_body}"
    true
  end

  def valid_content_headers?(content_headers = nil)
    puts "Resources::Resource[#{request.method}] content_headers?"
    puts content_headers.inspect unless content_headers.nil?
    true
  end

  def finish_request
    puts "Resources::Resource[#{request.method}] finish_request"
    # This method is called just before the final response is
    # constructed and sent. The return value is ignored, so any effect
    # of this method must be by modifying the response.

    # Enable simple cross-origin resource sharing (CORS)
    response.headers['Access-Control-Allow-Origin'] = '*'
    response.headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept'
  end
end

