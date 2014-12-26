require 'resources/resource'
require 'models/user'
require 'json'

class UserResource < Resource

  # def is_authorized?(header)
  #   request.cookies['user_email']
  # end

  let(:allowed_methods) { %w{GET POST PUT DELETE} }
  let(:create_path) { "/users/#{create_resource.id}" }
  let(:as_json) { resource_or_collection.to_json }
  let(:resource_exists?) { !request.path_info.has_key?(:id) || !!User[id: request.path_info[:id] ] }

  protected

  def create_resource
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

  def resource
    @resource ||= User[id: request.path_info[:id]]
  end

  def collection
    @collection ||= User.all
  end

  def resource_or_collection
    resource ? resource.to_hash : collection.map(&:to_hash)
    # resource || collection
  end

end
