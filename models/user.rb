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
  Date        :login_date
end

# Create a dataset from the users table
$users = DB[:users]

# Populate the users table.

# kiffin => admin
$users.insert(
    :name         => 'Kiffin Gish',
    :username     => 'kiffin',
    :email        => 'kiffin.gish@planet.nl',
    :password     => 'pindakaas',
    :access_token => 'none',
    :is_admin     => true,
    :login_date   => Time.at(rand * Time.now.to_i)
)

# henri => NOT admin
$users.insert(
    :name         => 'Henri Bergson',
    :username     => 'henri',
    :email        => 'henri.bergson@planet.nl',
    :password     => 'escargot',
    :access_token => 'none',
    :is_admin     => false,
    :login_date   => Time.at(rand * Time.now.to_i)
)

if $users.count
  cnt = 0
  puts ' '
  puts 'USERS'
  puts '#   '.ljust(5)+'id  '.ljust(5)+'name           '.ljust(16)+'username  '.ljust(11)+'email                   '.ljust(26)+'password '.ljust(16)+'admin'
  puts '----'.ljust(5)+'----'.ljust(5)+'---------------'.ljust(16)+'----------'.ljust(11)+'------------------------'.ljust(26)+'---------'.ljust(16)+'-----'
  $users.each do |u|
    cnt += 1
    admin = u[:is_admin] ? 'yes' : 'no'
    puts cnt.to_s.ljust(5)+u[:id].to_s.ljust(5)+u[:name].ljust(16)+u[:username].ljust(11)+u[:email].ljust(26)+u[:password].ljust(16)+admin
  end
end

class User < Sequel::Model
  HASH_ATTRS = [:id, :name, :username, :email, :password, :access_token, :is_admin, :login_date]

  def to_hash
    HASH_ATTRS.inject({}){|res, k| res.merge k => send(k)}
  end

end