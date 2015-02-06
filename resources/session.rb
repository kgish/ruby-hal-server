require 'resources/base'
require 'models/user'
require 'json'

# For the secure authentication token
require 'securerandom'

class SessionResource < BaseResource

  let(:allowed_methods) { %w{POST OPTIONS} }
  let(:content_types_accepted) { [['application/json', :create_session]] }

   def resource_exists?
     puts "Resource::Session[#{request.method}] resource_exists?"
     # result = !request.path_info.has_key?(:id) || !!User.exists(id)
     result = true
     puts "Resource::Session[#{request.method}] resource_exists? => #{result}"
     result
   end

  def create_path
    puts "Resource::Session[#{request.method}] create_path"
    result = '/sessions'
    puts "Resource::Session[#{request.method}] create_path => #{result}"
    result
  end

  def from_json
    puts "Resource::Session[#{request.method}]: from_json"
    result = response.body.nil? ? 400 : 201
    puts "Resource::Session[#{request.method}]: from_json => #{result}"
    result
  end

   def service_available?
     result = true
     puts "Resource::Session[#{request.method}]: service_available? => #{result}"
     result
   end

   def create_session
     puts "Resource::Session[#{request.method}]: create_session"
     rp = request_payload
     if rp.nil?
       puts "Resource::Session[#{request.method}]: request_payload = nil"
       result = 401
     elsif rp['username_or_email'].nil?
       puts "Resource::Session[#{request.method}]: username_or_email = nil"
       result = 401
     elsif rp['password'].nil?
       puts "Resource::Session[#{request.method}]: password = nil"
       result = 401
     else
       username = rp['username_or_email']
       password = rp['password']
       puts "Resource::Session[#{request.method}]: username=#{username}, password=#{password}"
       user = User.verify_username(username)
       if user
         puts "Resource::Session[#{request.method}]: user=#{user.inspect}"
         if user[:password] == password
           puts "Resource::Session[#{request.method}]: => password OK"
#           # TODO: set login_date, later ensure now - login_date < 30 mins
           user.replace({login_date: Time.now, access_token: SecureRandom.hex(64)})
           response.body =  JSON.generate({:api_key => {:user_id => user[:id], :access_token => user[:access_token]}})
           puts "Resource::Session[#{request.method}]: user=#{user.inspect} => password OK"
           result = 201
         else
           puts "Resource::Session[#{request.method}]: user=#{user.inspect} => password NOK"
           result = 401
         end
       else
         puts "Resource::Session[#{request.method}]: user not found"
         result = 401
       end
     end
     puts "Resource::Session[#{request.method}]: create_session => #{result}"
     result
   end

end

