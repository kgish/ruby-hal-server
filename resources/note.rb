require 'resources/resource'
require 'models/note'
require 'json'

class NoteResource < Resource

  let(:allowed_methods) { %w{GET POST PUT DELETE} }

  let(:create_path) { "/notes/#{create_resource.id}" }
  let(:from_json) { process_create_data }
  let(:as_json) { resource_or_collection.to_json }
  let(:resource_exists?) { !request.path_info.has_key?(:id) || !!Note[id: request.path_info[:id] ] }

  protected

  def process_create_data
    data = JSON.parse(request.body.to_s)['data']
    data['task_id'] ||= request.path_info[:task_id]
    data
  end

  def create_resource
    @resource = Note.create(from_json)
    #response.body = as_json
  end

  def resource
    @resource ||= Note[id: request.path_info[:id]]
  end

  def collection
    @collection ||= Note.filter(:task_id => request.path_info[:task_id]).all
  end

  def resource_or_collection
    raise request.path_tokens.inspect
    resource ? resource.to_hash : {:notes => collection.map(&:to_hash)}
  end

end