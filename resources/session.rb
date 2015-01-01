require 'resources/resource'
require 'models/user'
require 'json'

class SessionResource < Resource

  def allowed_methods
    %w{GET POST PUT DELETE}
  end

  def resource_exists?
    if request.path_info.has_key?(:id)
      self.user = User.find(:id => request.path_info[:id]) 
    else
      self.user = User.find(:email => parsed_body['email'])
    end
    !!user
  end
  
  def json
    response.body = JSON.generate user.to_hash
    200
  end
  
  def create_path
    request.disp_path
  end
  
  def from_json
    return 400 if parsed_body.empty?
    user = User.new parsed_body['user']
    success = user.save 
    response.body = JSON.generate :user => user.to_hash
    success ? 201 : 400
  end
  
  
  
  
  
  #msg = JSON.parse env['rack.input'].read 
  
  def service_available?
    User.connected?
  end

  def allowed_methods
    %w{GET POST DELETE}
  end
  
  def post_is_create?
    true
  end
  
  def resource_exist?
    raise 'AHA'
    true
    # @bleargh_post = BlearghPost.find(request.path_info(:post_id))
    # !@bleargh_post.nil?
  end
  
  def content_types_provided
    [
      ['application/json', :json],
      # ['text/html', :to_html],        
    ]
  end
  
  def json
    response.body = JSON.generate :message => 'Hello'
    200
  end
  
  
  
  def create_path
    request.disp_path
  end
  
  def content_types_accepted
    [["application/json", :create_session]]
  end

  def create_session
    parsed_body = JSON.parse(request.body.to_s) unless request.body.to_s.empty?
    return false unless parsed_body['user']
    if user = User.find(parsed_body['user']['email'])
      if parsed_body['user']['password'] == user.password
        response.set_cookie 'user_email', user.email
        201
      else
        401
      end
    else
      404
    end
  end
  
  # def to_html
  #   raise 'text/html is not supported'
  # 
  #   return 'DA!'
  # end
end
