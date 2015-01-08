require 'webmachine'
require 'json'

class BaseResource < Webmachine::Resource
  class << self
    alias_method :let, :define_method
  end

  let(:trace?) { true }
  let(:content_types_provided) { [['application/json', :as_json], ['text/html', :as_html]] }
  let(:content_types_accepted) { [['application/json', :from_json]] }
  let(:post_is_create?) { true }
  let(:allow_missing_post?) { true }

  let(:as_html) { as_json_or_html 'html' }
  let(:as_json) { as_json_or_html 'json' }

  # A method called response_body MUST be defined in all subclasses
  def as_json_or_html(json_or_html)
    puts "Resource::Base[#{request.method}] as_#{json_or_html}"
    result = JSON.generate(response_body)
    puts "Resource::Base[#{request.method}] as_#{json_or_html} => #{result}"
    result
  end

  def finish_request
    puts "Resource::Base[#{request.method}] finish_request"
    # This method is called just before the final response is
    # constructed and sent. The return value is ignored, so any effect
    # of this method must be by modifying the response.

    # Enable simple cross-origin resource sharing (CORS)
    response.headers['Access-Control-Allow-Origin']   = '*'
    response.headers['Access-Control-Allow-Methods']  = 'GET, POST, PUT, DELETE, HEAD, OPTIONS'
    response.headers['Access-Control-Allow-Headers']  = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
    response.headers['Access-Control-Expose-Headers'] = 'connect-src self'
  end

  protected

  def allowed_methods
    puts "Resource::Base[#{request.method}] allowed_methods"
    if request.path_info.has_key?(:id)
      %w{GET PUT DELETE OPTIONS}
    else
      %w{GET POST OPTIONS}
    end
  end

  def response_body
    puts "Resource::Base[#{request.method}] response_body"
    id ? response_body_resource : response_body_collection
  end

  def result_resource(resource_name, resource)
    result = {
        _links: {
            self: {
                href: "/#{resource_name}s/#{id}"
            },
            curies: [
                {
                    name: "#{curie_name}",
                    href: "http://#{request.host}:#{request.port}/rels/{rel}",
                    templated: true
                }
            ]
        }
    }
    result.merge!(resource)
  end

  def result_collection(resource_name, collection)
    puts "Resource::Base[#{request.method}] build_result_collection"
    result = {
        _links: {
            self:  {
                href: "/#{resource_name}s"
            },
            curies: [
                {
                    name: curie_name,
                    href: "http://#{request.host}:#{request.port}/rels/{rel}",
                    templated: true
                }
            ],
        }
        #     'curie_name:resource_name' => []
    }
    result[:_links]["#{curie_name}:#{resource_name}"] = collection
    result
  end

  def params(resource_name)
    puts "Resource::Base[#{request.method}] params(#{resource_name})"
    result = JSON.parse(request.body.to_s)[resource_name]
    puts "Resource::Base[#{request.method}] params(#{resource_name}) => #{result.inspect}"
    result
  end

  def id
    puts "Resource::Base[#{request.method}] id"
    result = request.path_info[:id]
    puts "Resource::Base[#{request.method}] id => #{result}"
    result
  end

  def curie_name
    'ht'
  end

end
