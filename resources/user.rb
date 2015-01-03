require 'resources/resource'
require 'models/user'
require 'json'

class UserResource < Resource

  let(:allowed_methods) { %w{GET POST PUT DELETE OPTIONS} }
  let(:create_path) { "/users/#{create_resource.id}" }
  let(:as_json) { resource_or_collection.to_json }
  # let(:resource_exists?) { !request.path_info.has_key?(:id) || !!User[id: request.path_info[:id] ] }

  def is_authorized?(header=nil)
    puts "Resource::User[#{request.method}] is_authorized?(header=#{header.inspect})"
    cookies = request.cookies
    puts "Resource::User[#{request.method}] is_authorized? cookies=#{cookies.inspect}"
    res = true
    # TODO: not secure!
    # res = false
    # username = cookies['username']
    # access_token = cookies['access_token']
    # puts "Resource::User[#{request.method}] is_authorized? username=#{username}, access_token=#{access_token}"
    # if username && access_token
    # end
    puts "Resource::User[#{request.method}] is_authorized? => #{res}"
    res
  end

  def resource_exists?
    puts "Resource::User[#{request.method}] resource_exists?"
    if request.path_info.has_key?(:id)
      user = $users.where(:id => id).first
      result = !user.nil?
    else
      result = true
    end
    puts "Resource::User[#{request.method}] resource_exists? => #{result}"
    result
  end

  protected

  def create_resource
    puts "Resource::User[#{request.method}] create_resource"
    @resource = User.create(from_json)
    #response.body = as_json
  end

  # def from_json
  #   return if request.method == 'GET'
  #   return 400 if parsed_body.empty?
  #   user = User.new parsed_body['user']
  #   success = user.save
  #   response.body = JSON.generate :user => user.to_hash
  #   success ? 201 : 400
  # end

  def collection
    puts "Resource::User[#{request.method}] collection"
    @collection ||= $users.select_all
  end

  def resource_or_collection
    puts "Resource::User[#{request.method}] resource_or_collection"
    @resource || {:users => collection.map(&:to_hash)}
  end

  def to_json
    puts "Resource::User[#{request.method}] to_json"
    resource_or_collection.to_json
  end

  def resource
    puts "Resource::User[#{request.method}] resource"
    @resource ||= $users.where(:id => id).first
  end

  def id
    request.path_info[:id]
  end

end
