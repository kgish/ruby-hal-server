require 'resources/resource'
require 'models/user'
require 'json'

class SessionResource < Resource

  def allowed_methods
    puts "Resource::Session[#{request.method}]: allowed_methods"
    %w{GET POST DELETE OPTIONS}
  end

  def resource_exists?
    if request.path_info.has_key?(:id)
      self.user = User.find(:id => id)
    else
      self.user = User.find(:username => parsed_body['username_or_email']) || User.find(:email => parsed_body['username_or_email'])
    end
    res = !!user
    puts "Resource::Session[#{request.method}]: resource_exists? => #{res}"
    res
  end

  # def json
  #   puts "Resource::Session[#{request.method}]: json"
  #   response.body = JSON.generate user.to_hash
  #   200
  # end

  def create_path
    puts "Resource::Session[#{request.method}]: create_path => #{request.disp_path}"
    request.disp_path
  end

  # def from_json
  #   puts "Resource::Session[#{request.method}]: from_json"
  #   return 400 if parsed_body.empty?
  #   user = User.new parsed_body['user']
  #   success = user.save
  #   response.body = JSON.generate :user => user.to_hash
  #   success ? 201 : 400
  # end

  def service_available?
    puts "Resource::Session[#{request.method}]: service_available?"
#    User.connected?
    true
  end

  def post_is_create?
    puts "Resource::Session[#{request.method}]: post_is_create?"
    true
  end

  def content_types_provided
    puts "Resource::Session[#{request.method}]: content_types_provided"
    [['application/json', :json]]
  end

  def content_types_accepted
    puts "Resource::Session[#{request.method}]: content_types_accepted"
    [['application/json', :create_session]]
  end

  def create_session
    puts "Resource::Session[#{request.method}]: create_session"
    return 401 if request.body.to_s.empty?
    body = JSON.parse(request.body.to_s)
    puts "Resource::Session[#{request.method}]: create_session, body=#{body.inspect}"
    parsed_body = body['data']
    return 401 if parsed_body.nil? || parsed_body['username_or_email'].empty? || parsed_body['password'].empty?
    user = User.find(:username => parsed_body['username_or_email']) || User.find(:email => parsed_body['username_or_email'])
    if user
      if parsed_body['user']['password'] == user.password
        response.set_cookie 'user_email', user.email
        201
      else
        401
      end
    else
      401
    end
    puts "Resource::Session[#{request.method}]: create_session => #{res}"
    res
  end

  def id
    puts "Resource::Session[#{request.method}]: id"
    request.path_info[:id]
  end

end