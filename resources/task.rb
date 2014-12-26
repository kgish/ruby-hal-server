require 'resources/resource'
require 'models/task'
require 'json'

class TaskResource < Resource


  let(:allowed_methods) { %w{GET POST PUT DELETE} }

  let(:create_path) { "/tasks/#{create_resource.id}" }
  let(:as_json) { resource_or_collection.to_json }
  let(:resource_exists?) { !request.path_info.has_key?(:id) || !!Task[id: request.path_info[:id] ] }

  protected

  def create_resource
    @resource = Task.create(from_json)
    #response.body = as_json
  end

  def resource
    @resource ||= Task[id: request.path_info[:id]]
  end

  def collection
    @collection ||= Task.all
  end

  def resource_or_collection
    resource ? resource.to_hash : {:tasks => collection.map(&:to_hash)}
  end

end