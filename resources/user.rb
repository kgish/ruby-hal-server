require 'resources/base'
require 'models/user'

class UserResource < BaseResource

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
      # Remember PUT should replace the entire resource, not merge the attributes,
      # that's what PATCH is for. It's also why you should not expose your database
      # IDs as your API IDs.
      user = User.exists(id)
      response_code = 200
      if user
        puts "Resource::User[#{request.method}] from_json, user exists"
        user.replace(params('user'))
      else
        puts "Resource::User[#{request.method}] from_json, user does not exist"
        new_params = params('user')
        new_params[:id] = id
        user = User.create(new_params)
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
    result = User.create(params('user'))
    puts "Resource::User[#{request.method}] create_resource, @resource=#{result.inspect}"
    result
  end

  # TODO: do not return the id, password or token

  def response_body_resource
    # GET /users/[:id]
    puts "Resource::User[#{request.method}] response_body_resource"
    result = result_resource('user', User.result(id))
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

