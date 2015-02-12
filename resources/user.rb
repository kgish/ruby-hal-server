require 'resources/base'
require 'models/user'

# When registering a new user the request must contain this X-Secret-Key-Signup header.
SECRET_KEY_SIGNUP = '2d5b0672-b207-11e4-94cd-3c970ead4d26'

class UserResource < BaseResource

  def is_authorized?(auth_header = nil)
    puts "Resource::User[#{request.method}] is_authorized?(#{auth_header.inspect}) @@authorization_enabled=#{@@authorization_enabled}"
    result = false # Until proven otherwise
    if @@authorization_enabled
      if request.method == 'OPTIONS'
        result = true
      else
        if auth_header.nil? or auth_header == 'Bearer none'
          puts "Resource::User[#{request.method}] is_authorized? auth_header=nil!"
          puts "headers=#{request.headers.inspect}"
          if request.headers['x-secret-key-signup'] == SECRET_KEY_SIGNUP
            result = true
          end
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
    @id = create_resource[:id]
    puts "Resource::User[#{request.method}] next_id=#{@id}"
    result = "/users/#{@id}"
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
    result = 200
    if request.method == 'PUT'
      # See comments for Resource::Product.from_json for 'PUT' method
      user = User.exists(id)
      if user
        puts "Resource::User[#{request.method}] from_json, user exists"
        user.replace(request_payload('user'))
      else
        puts "Resource::User[#{request.method}] from_json, user does not exist"
        rp = request_payload('user')
        rp[:id] = id
        user = User.create(rp)
        puts "Resource::User[#{request.method}] from_json, created new user=#{user.inspect}"
        result = 201 # Created
      end
    else
      result = 201 # Created
    end
    response.body = JSON.generate(result_resource('user', User.resource(id)))
    puts "Resource::User[#{request.method}] from_json => #{result}"
    result
  end

  private

  def create_resource
    puts "Resource::User[#{request.method}] create_resource"
    @resource = User.create(request_payload('user'))
    puts "Resource::User[#{request.method}] create_resource, @resource=#{@resource.inspect}"
    @resource
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

