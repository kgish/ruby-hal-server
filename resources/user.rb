require 'resources/base'
require 'models/user'

class UserResource < BaseResource

  def is_authorized?(auth_header = nil)
    puts "Resource::User[#{request.method}] is_authorized?(#{auth_header.inspect}) @@authorization_enabled=#{@@authorization_enabled}"
    result = false # Until proven otherwise
    if @@authorization_enabled
      if request.method == 'OPTIONS'
        result = true
      else
        if auth_header.nil?
          puts "Resource::User[#{request.method}] is_authorized? auth_header=nil!"
        else
          user = user_auth(auth_header)
          puts "Resource::User[#{request.method}] is_authorized? user=#{user.inspect}"
          if user.nil?
            puts "Resource::User[#{request.method}] is_authorized? user=nil!"
          else
            if user[:is_admin]
              # Admin can do anything!
              puts "Resource::User[#{request.method}] is_authorized? admin"
              result = true
            else
              # User can only view and edit his own information
              if user[:id].to_i === id.to_i
                puts "Resource::User[#{request.method}] is_authorized? user id=#{user[:id]}"
                result = true
              else
                puts "Resource::User[#{request.method}] is_authorized? user id=#{user[:id]} not equal to #{id}!"
              end
            end
          end
        end
      end
    else
      result = true
    end
    puts "Resource::User[#{request.method}] is_authorized? => #{result}"
    result
  end

  def create_path
    puts "Resource::User[#{request.method}] create_path"
    next_id = create_resource[:id]
    puts "Resource::User[#{request.method}] next_id=#{next_id}"
    result = "/users/#{next_id}"
    puts "Resource::User[#{request.method}] create_path => #{result}"
    result
  end

  def resource_exists?
    puts "Resource::User[#{request.method}] resource_exists?"
    result = !request.path_info.has_key?(:id) || !!User.exists(id)
    puts "Resource::User[#{request.method}] resource_exists? => #{result}"
    result
  end

  def delete_resource
    puts "Resource::User[#{request.method}] delete_resource"
    User.remove(id)
  end

  def from_json
    puts "Resource::User[#{request.method}] from_json"
    if request.method == 'PUT'
      # See comments for Resource::Product.from_json for 'PUT' method
      user = User.exists(id)
      response_code = 200
      if user
        puts "Resource::User[#{request.method}] from_json, user exists"
        user.replace(request_payload('user'))
      else
        puts "Resource::User[#{request.method}] from_json, user does not exist"
        rp = request_payload('user')
        rp[:id] = id
        user = User.create(rp)
        response_code = 201 # Created
      end
      response.body = user.to_json
      response_code
    else
      result = JSON.parse(request.body.to_s)
      puts "Resource::User[#{request.method}] from_json => #{result.inspect}"
      result
    end
  end

  private

  def create_resource
    puts "Resource::User[#{request.method}] create_resource"
    result = User.create(request_payload('user'))
    puts "Resource::User[#{request.method}] create_resource, @resource=#{result.inspect}"
    result
  end

  def response_body_resource
    # GET /users/[:id]
    puts "Resource::User[#{request.method}] response_body_resource"
    result = result_resource('user', User.resource(id))
    puts "Resource::User[#{request.method}] response_body_resource => #{result.inspect}"
    result
  end

  def response_body_collection
    # GET /users
    puts "Resource::User[#{request.method}] response_body_collection"
    result = result_collection('user', User.collection)
    puts "Resource::User[#{request.method}] response_body_collection => #{result.inspect}"
    result
  end

end

