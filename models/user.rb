require 'models/base'

# For the secure authentication token
require 'securerandom'

# Create a users table
DB.create_table :users do
  primary_key :id
  String      :name
  String      :username
  String      :email
  String      :password
  String      :access_token, :default => 'none'
  Boolean     :is_admin
  DateTime    :login_date, :default => 0
  DateTime    :last_seen, :default => 0
end

# Create a dataset from the users table
users = DB[:users]

class User < Sequel::Model
  HASH_ATTRS = [:id, :name, :username, :email, :password, :access_token, :is_admin, :login_date, :last_seen]

  def self.create(attributes)
    id = User.insert(User.safe_attributes(attributes))
    User[id: id]
  end

  def self.exists(id)
    where(id: id).first
  end

  def self.remove(id)
    User[id: id].delete
  end

  def self.auth(token, timeout)
    tm = Time.now
    user = User.first(:access_token => token)
    if user
      # Check that user has been seen within timeout period
      diff = tm.to_i - user[:last_seen].to_i
      if diff > timeout
        puts "Model::User timeout: tm=#{tm.to_i} - last_seen=#{user[:last_seen].to_i} > timeout=#{timeout}"
        user = nil
      else
        user.update(:last_seen => tm)
      end
    end
    user
  end

  def self.verify_username(username)
    User.where(:username => username).first || User.where(:email => username).first
  end

  def self.safe_attributes(attributes)
    # Strip out unwanted and/or malicious attributes just in case.
    attributes.select{|k| %w{id name username email password access_token is_admin}.include?(k.to_s)}
  end

  def self.resource(id)
    u = User[id: id]
    {
        # id:          u[:id],
        name:         u[:name],
        username:     u[:username],
        email:        u[:email],
        password:     u[:password],
        access_token: u[:access_token],
        is_admin:     u[:is_admin],
        login_date:   u[:login_date],
        last_seen:    u[:last_seen]
    }
  end

  def self.collection
    list = []
    User.all.each do |u|
      list.push({
                    href:       "/users/#{u[:id]}",
                    # id:          u[:id],
                    name:         u[:name],
                    username:     u[:username],
                    email:        u[:email],
                    password:     u[:password],
                    access_token: u[:access_token],
                    is_admin:     u[:is_admin],
                    login_date:   u[:login_date],
                    last_seen:    u[:last_seen]
                })
    end
    list
  end

  def login
    tm = Time.now
    update({login_date: tm, last_seen: tm, access_token:  SecureRandom.hex(64)})
  end

  def replace(attributes)
    update(User.safe_attributes(attributes))
  end

  def to_hash
    HASH_ATTRS.inject({}){|res, k| res.merge k => send(k)}
  end

end

# Populate the users table.
# Random login date between now and one day ago.

# kiffin => admin
User.create(
    :name         => 'Kiffin Gish',
    :username     => 'kiffin',
    :email        => 'kiffin.gish@planet.nl',
    :password     => 'pindakaas',
    :is_admin     => true,
    :login_date   => Time.at(Time.now.to_i - rand * 86400)
)

# henri => NOT admin
User.create(
    :name         => 'Henri Bergson',
    :username     => 'henri',
    :email        => 'henri.bergson@gmail.com',
    :password     => 'escargot',
    :is_admin     => false,
    :login_date   => Time.at(Time.now.to_i - rand * 86400)
)

# bhogan => NOT admin
User.create(
    :name         => 'Ben Hogan',
    :username     => 'bhogan',
    :email        => 'ben.hogan@golf.nl',
    :password     => 'holeinone',
    :is_admin     => false,
    :login_date   => Time.at(Time.now.to_i - rand * 86400)
)

# admin => admin
User.create(
    :name         => 'Admin',
    :username     => 'admin',
    :email        => 'webmaster@halclient.com',
    :password     => 'admin',
    :is_admin     => true,
    :login_date   => Time.at(Time.now.to_i - rand * 86400)
)

if User.count
  cnt = 0
  puts
  puts 'USERS'
  puts '#  '.ljust(4)+'id '.ljust(4)+'name           '.ljust(16)+'username'.ljust(9)+'email                   '.ljust(25)+'password  '.ljust(11)+'admin'
  puts '---'.ljust(4)+'---'.ljust(4)+'---------------'.ljust(16)+'--------'.ljust(9)+'------------------------'.ljust(25)+'----------'.ljust(11)+'-----'
  users.each do |u|
    cnt += 1
    admin = u[:is_admin] ? 'yes' : 'no'
    puts cnt.to_s.ljust(4)+u[:id].to_s.ljust(4)+u[:name].ljust(16)+u[:username].ljust(9)+u[:email].ljust(25)+u[:password].ljust(11)+admin
  end
end

