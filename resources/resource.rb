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
  # # TODO the following is incorrect
  let(:from_json) { JSON.parse(request.body.to_s)['data'] }

  # def content_types_provided
  #   puts "Resources::Resource[#{request.method}] content_types_provided"
  #   [['application/json', :to_json]]
  # end
  #
  # def content_types_accepted
  #   puts "Resources::Resource[#{request.method}] content_types_accepted"
  #   [['application/json', :from_json]]
  # end
  #
  # def from_json
  #   puts "Resources::Resource[#{request.method}] from_json"
  #   res = JSON.parse(request.body.to_s)['data']
  #   puts "Resources::Resource[#{request.method}] from_json => #{res.inspect}"
  #   res
  # end

  # def is_authorized?(auth)
  #   puts "Resources::Resource[#{request.method}] is_authorized? => true"
  #   true
  # end
  #
  # def valid_content_headers?(content_headers = nil)
  #   ch = content_headers || {}
  #   puts "Resources::Resource[#{request.method}] content_headers? #{ch.inspect}"
  #   true
  # end

  def finish_request
    puts "Resources::Resource[#{request.method}] finish_request"
    # This method is called just before the final response is
    # constructed and sent. The return value is ignored, so any effect
    # of this method must be by modifying the response.

    # Enable simple cross-origin resource sharing (CORS)
    response.headers['Access-Control-Allow-Origin'] = '*'
    response.headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS'
    response.headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
  end
end

