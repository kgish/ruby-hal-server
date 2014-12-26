require 'sequel'

class Note < Sequel::Model
  HASH_ATTRS = [:id, :user_id, :task_id, :title, :body]

  many_to_one :user
  many_to_one :task

  def to_hash
    HASH_ATTRS.inject({}){|res, k| res.merge k => send(k)}
  end


end