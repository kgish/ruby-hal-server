require 'resources/resource'
require 'models/user'
require 'json'

require 'digest/md5'

class SessionResource < Resource

  def allowed_methods
    puts "Resource::Session[#{request.method}]: allowed_methods"
    %w{GET POST DELETE OPTIONS}
  end

  def resource_exists?
    puts "Resource::Session[#{request.method}]: resource_exists?"
    if request.path_info.has_key?(:id)
      user = User.find(:id => id)
      puts "Resource::Session[#{request.method}]: resource_exists? user='#{user.inspect}'"
    else
      username = parsed_body['username_or_email']
      puts "Resource::Session[#{request.method}]: resource_exists? username='#{username}'"
      user = User.find(:username => username) || User.find(:email => username)
    end
    res = !!user
    puts "Resource::Session[#{request.method}]: resource_exists? => #{res}"
    res
  end

  def create_path
    puts "Resource::Session[#{request.method}]: create_path => #{request.disp_path}"
    request.disp_path
  end

  # def from_json
  #   puts "Resource::Session[#{request.method}]: from_json"
  #   return 400 if parsed_body.empty?
  #   user = User.new parsed_body['user']
  #   success = user.save
  #   response.body = JSON.generate :username => 'blah'
  #   success ? 201 : 400
  # end

  def service_available?
    puts "Resource::Session[#{request.method}]: service_available?"
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

  def parsed_body
    if request.body.nil? || request.body.to_s.nil? || request.body.to_s.empty?
      body = {}
      puts "Resource::Session[#{request.method}]: parsed_body => empty"
    else
      body = JSON.parse(request.body.to_s)
      puts "Resource::Session[#{request.method}]: parsed_body => #{body.inspect}"
    end
    body
  end

  def create_session
    puts "Resource::Session[#{request.method}]: create_session"
    pb = parsed_body
    if pb.nil?
      puts "Resource::Session[#{request.method}]: parsed_body = nil"
      res = 401
    elsif pb['username_or_email'].empty?
      puts "Resource::Session[#{request.method}]: username_or_email = empty"
      res = 401
    elsif pb['password'].empty?
      puts "Resource::Session[#{request.method}]: password = empty"
      res = 401
    else
      username = pb['username_or_email']
      password = pb['password']
      puts "Resource::Session[#{request.method}]: username=#{username}, password=#{password}"
      user = User.find(:username => username) || User.find(:email => username)
      if user
        if password == user.password
          # TODO: set login_date, later ensure now - login_date < 30 mins
          user.login_date = Time.now
          user.token =  Digest::MD5.hexdigest("#{username}:#{password}")
          puts "Resource::Session[#{request.method}]: user=#{user.inspect} => password OK"
          # token: response.api_key.access_token
          response.body =  JSON.generate({:api_key => {:user_id => user.id, :token => user.token}})
          res = 201
        else
          puts "Resource::Session[#{request.method}]: user=#{user.inspect} => password NOK"
          res = 401
        end
      else
        puts "Resource::Session[#{request.method}]: user not found"
        res = 401
      end
    end
    puts "Resource::Session[#{request.method}]: create_session => #{res}"
    res
  end

  def id
    puts "Resource::Session[#{request.method}]: id"
    request.path_info[:id]
  end

end