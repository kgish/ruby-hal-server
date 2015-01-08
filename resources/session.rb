require 'resources/base'
require 'models/user'

class SessionResource < BaseResource

end

# # For the secure authentication token
# require 'securerandom'
#
# class SessionResource < Resource
#
#   def allowed_methods
#     puts "Resource::Session[#{request.method}]: allowed_methods"
#     %w{GET POST DELETE OPTIONS}
#   end
#
#   def resource_exists?
#     puts "Resource::Session[#{request.method}]: resource_exists?"
#     if request.path_info.has_key?(:id)
#       user = User.find(:id => id)
#       puts "Resource::Session[#{request.method}]: resource_exists? user='#{user.inspect}'"
#     else
#       username = parsed_body['username_or_email']
#       puts "Resource::Session[#{request.method}]: resource_exists? username='#{username}'"
#       user = User.find(:username => username) || User.find(:email => username)
#     end
#     result = !!user
#     puts "Resource::Session[#{request.method}]: resource_exists? => #{result}"
#     result
#   end
#
#   def create_path
#     puts "Resource::Session[#{request.method}]: create_path => #{request.disp_path}"
#     request.disp_path
#   end
#
#   # def from_json
#   #   puts "Resource::Session[#{request.method}]: from_json"
#   #   return 400 if parsed_body.empty?
#   #   user = User.new parsed_body['user']
#   #   success = user.save
#   #   response.body = JSON.generate :username => 'blah'
#   #   success ? 201 : 400
#   # end
#
#   def service_available?
#     puts "Resource::Session[#{request.method}]: service_available?"
#     true
#   end
#
#   def content_types_provided
#     puts "Resource::Session[#{request.method}]: content_types_provided"
#     [['application/json', :json]]
#   end
#
#   def content_types_accepted
#     puts "Resource::Session[#{request.method}]: content_types_accepted"
#     [['application/json', :create_session]]
#   end
#
#   def parsed_body
#     if request.body.nil? || request.body.to_s.nil? || request.body.to_s.empty?
#       body = {}
#       puts "Resource::Session[#{request.method}]: parsed_body => empty"
#     else
#       body = JSON.parse(request.body.to_s)
#       puts "Resource::Session[#{request.method}]: parsed_body => #{body.inspect}"
#     end
#     body
#   end
#
#   def create_session
#     puts "Resource::Session[#{request.method}]: create_session"
#     pb = parsed_body
#     if pb.nil?
#       puts "Resource::Session[#{request.method}]: parsed_body = nil"
#       result = 401
#     elsif pb['username_or_email'].nil?
#       puts "Resource::Session[#{request.method}]: username_or_email = nil"
#       result = 401
#     elsif pb['password'].nil?
#       puts "Resource::Session[#{request.method}]: password = nil"
#       result = 401
#     else
#       username = pb['username_or_email']
#       password = pb['password']
#       puts "Resource::Session[#{request.method}]: username=#{username}, password=#{password}"
#       #user = User.find(:username => username) || User.find(:email => username)
#       user = $users.where(:username => username).first || $users.where(:email => username).first
#       if user
#         puts "Resource::Session[#{request.method}]: user=#{user.inspect}"
#         if password == user[:password]
#           # TODO: set login_date, later ensure now - login_date < 30 mins
#           user.update(:login_date => Time.now)
#           user.update(:access_token => SecureRandom.hex(64))
#           puts "Resource::Session[#{request.method}]: => password OK"
#           response.body =  JSON.generate({:api_key => {:user_id => user[:id], :access_token => user[:access_token]}})
#           puts "Resource::Session[#{request.method}]: user=#{user.inspect} => password OK"
#           result = 201
#         else
#           puts "Resource::Session[#{request.method}]: user=#{user.inspect} => password NOK"
#           result = 401
#         end
#       else
#         puts "Resource::Session[#{request.method}]: user not found"
#         result = 401
#       end
#     end
#     puts "Resource::Session[#{request.method}]: create_session => #{result}"
#     result
#   end
#
#   def id
#     puts "Resource::Session[#{request.method}]: id"
#     request.path_info[:id]
#   end
#
# end