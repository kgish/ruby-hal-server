require 'sequel'

class Task < Sequel::Model
  HASH_ATTRS = [:id, :name, :user_id]

  many_to_one :user
  one_to_many :notes

  def to_hash
    HASH_ATTRS.inject({}){|res, k| res.merge k => send(k)}
  end


end