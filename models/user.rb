require 'sequel'

class User < Sequel::Model
  HASH_ATTRS = [:id, :email, :first_name, :last_name]

  one_to_many :tasks

  def to_hash
    HASH_ATTRS.inject({}){|res, k| res.merge k => send(k)}
  end

end
