require 'models/base'

# Create a users table
DB.create_table :users do
  primary_key :id
  String      :name
  String      :username
  String      :email
  String      :password
  String      :access_token
  Boolean     :is_admin
  DateTime    :login_date
end

# Create a dataset from the users table
$users = DB[:users]

# Populate the users table.
# Random login date between now and one day ago.

# kiffin => admin
$users.insert(
    :name         => 'Kiffin Gish',
    :username     => 'kiffin',
    :email        => 'kiffin.gish@planet.nl',
    :password     => 'pindakaas',
    :access_token => 'none',
    :is_admin     => true,
    :login_date   => Time.at(Time.now.to_i - rand * 86400)
)

# henri => NOT admin
$users.insert(
    :name         => 'Henri Bergson',
    :username     => 'henri',
    :email        => 'henri.bergson@gmail.com',
    :password     => 'escargot',
    :access_token => 'none',
    :is_admin     => false,
    :login_date   => Time.at(Time.now.to_i - rand * 86400)
)

# bhogan => NOT admin
$users.insert(
    :name         => 'Ben Hogan',
    :username     => 'bhogan',
    :email        => 'ben.hogan@golf.nl',
    :password     => 'holeinone',
    :access_token => 'none',
    :is_admin     => false,
    :login_date   => Time.at(Time.now.to_i - rand * 86400)
)

# admin => admin
$users.insert(
    :name         => 'Admin',
    :username     => 'admin',
    :email        => 'webmaster@halclient.com',
    :password     => 'admin',
    :access_token => 'none',
    :is_admin     => true,
    :login_date   => Time.at(Time.now.to_i - rand * 86400)
)

if $users.count
  cnt = 0
  puts
  puts 'USERS'
  puts '#  '.ljust(4)+'id '.ljust(4)+'name           '.ljust(16)+'username'.ljust(9)+'email                   '.ljust(25)+'password  '.ljust(11)+'admin'
  puts '---'.ljust(4)+'---'.ljust(4)+'---------------'.ljust(16)+'--------'.ljust(9)+'------------------------'.ljust(25)+'----------'.ljust(11)+'-----'
  $users.each do |u|
    cnt += 1
    admin = u[:is_admin] ? 'yes' : 'no'
    puts cnt.to_s.ljust(4)+u[:id].to_s.ljust(4)+u[:name].ljust(16)+u[:username].ljust(9)+u[:email].ljust(25)+u[:password].ljust(11)+admin
  end
end

class User < Sequel::Model
  HASH_ATTRS = [:id, :name, :username, :email, :password, :access_token, :is_admin, :login_date]

  def self.exists(id)
    User[id: id]
  end

  def self.auth(token)
    # TODO: Check that now - login_date > 30 minutes.
    #       Also need to update login_date for every request.
    user = User.first(:access_token => token)
    puts "User.auth(token='#{token}') => #{user.inspect}"
    user
  end

  def self.remove(id)
    User[id: id].delete
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
        login_date:   u[:login_date]
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
        login_date:   u[:login_date]
      })
    end
    list
  end

  def self.verify_username(username)
    User.where(:username => username).first || User.where(:email => username).first
  end

  def replace(attributes)
    update(attributes)
  end

  def to_hash
    HASH_ATTRS.inject({}){|res, k| res.merge k => send(k)}
  end

end