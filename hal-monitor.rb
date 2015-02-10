require 'bundler/setup'
require 'httparty'
require 'json'

params = get_params(false)

host = params[:host]
port = params[:port]
show_products = params[:products]
show_users = params[:users]

# --- Authorization (begin) --- #

username = params[:username]
password = params[:password]
auth = (username.nil? or password.nil?) ? false : true
access_token = nil

if auth
  # Using authorization, login and get access token.
  url_session = "http://#{host}:#{port}/session"
  options = {
    :headers => {
      'Content-type' => 'application/json'
    },
    :body => {
      :username_or_email => username,
      :password => password
    }.to_json
  }
  response_session = HTTParty.post(url_session, options)
  if response_session.code == 201
    access_token = JSON.parse(response_session.body)['api_key']['access_token']
    puts "Login okay: access_token=#{access_token}"
  else
    puts "Login failed: username=#{username}, password=#{password}, code=#{response_session.code}, message=#{response_session.message}"
    exit
  end
end
if auth
  options = { :headers => { 'Content-type' => 'application/json', 'Authorization' => "Bearer #{access_token}" } }
else
  options = { :headers => { 'Content-type' => 'application/json' } }
end

# --- Authorization (end) --- #

RETRY_COUNT = 6

trap('SIGINT') { throw :ctrl_c }

catch :ctrl_c do
  url_products = "http://#{host}:#{port}/products"
  url_users = "http://#{host}:#{port}/users"
  total = 0
  countdown = 0
  error_message = ''
  loop do
    system('clear')
    countdown = countdown - 1 if countdown > 0
    if countdown == 0
      begin
        response_products = HTTParty.get(url_products, options) if show_products
        response_users = HTTParty.get(url_users, options) if show_users
      rescue Exception =>e
        error_message = e.message
        countdown = RETRY_COUNT
      end
    end
    if countdown == 0
      total += 1

      # PRODUCTS
      if show_products
        server = response_products.headers['server']
        server = server.sub(/ \(.*\)$/, '')
        puts "#{total} | #{host} | #{port} | products | #{server} | #{response_products.code} | #{response_products.message}"
        puts

        # If forbidden then makes no sense to continue any longer.
        exit if response_products.code.to_i == 401

        body = JSON.parse response_products.body
        products = body['_links']['ht:product']

        cnt = 0
        # Sort products by id
        products.each do |p|
          if cnt == 0
            puts '# '.ljust(4)+'id '.ljust(4)+'name           '.ljust(16)+'category       '.ljust(16)+'price'
            puts '--'.ljust(4)+'---'.ljust(4)+'---------------'.ljust(16)+'---------------'.ljust(16)+'-----'
          end
          cnt += 1
          # Replace { href => '/products/id', ...} with { id => 'id', ... }
          id = p['href'].sub(/^\/[^\/]*\//,'')
          name = p['name'] || ''
          category = p['category'] || ''
          price = p['price'] || ''
          puts cnt.to_s.ljust(4)+id.to_s.ljust(4)+name.ljust(16)+category.ljust(16)+price.to_s
        end

        puts 'No products' if cnt == 0
        puts
      end

      # USERS
      if show_users
        server = response_users.headers['server']
        server = server.sub(/ \(.*\)$/, '')
        puts "#{total} | #{host} | #{port} | users | #{server} | #{response_users.code} | #{response_users.message}"
        puts

        # If forbidden then makes no sense to continue any longer.
        exit if response_users.code.to_i == 401


        body = JSON.parse response_users.body
        users = body['_links']['ht:user']

        cnt = 0
        # Sort users by id
        users.each do |u|
          if cnt == 0
            puts '#  '.ljust(4)+'id '.ljust(4)+'username       '.ljust(16)+'name           '.ljust(16)+'admin'.ljust(6)+'email                  '.ljust(25)+'password   '.ljust(12)+'login              '.ljust(21)+'seen               '
            puts '---'.ljust(4)+'---'.ljust(4)+'---------------'.ljust(16)+'---------------'.ljust(16)+'-----'.ljust(6)+'-----------------------'.ljust(25)+'-----------'.ljust(12)+'-------------------'.ljust(21)+'-------------------'
          end
          cnt += 1
          # Replace { href => '/users/id', ...} with { id => 'id', ... }
          id = u['href'].sub(/^\/[^\/]*\//,'')
          username = u['username'] || ''
          name = u['name'] || ''
          email = u['email'] || ''
          password= u['password'] || ''
          admin = u['is_admin'] ? 'yes' : 'no'
          login_date = u['login_date'].sub(/ \+\d+/, '')
          last_seen = u['last_seen'].sub(/ \+\d+/, '')
          last_seen = 'never' if last_seen == '1970-01-01 01:00:00'
          puts cnt.to_s.ljust(4)+id.to_s.ljust(4)+username.ljust(16)+name.ljust(16)+admin.ljust(6)+email.ljust(25)+password.ljust(12)+login_date.ljust(21)+last_seen
        end

        puts 'No users' if cnt == 0
        puts
      end
    else
      puts error_message #  Connection refused - connect(2)
      puts countdown == RETRY_COUNT ? 'Oops!' : "Retry (#{countdown})"
    end

    puts
    puts 'CTRL-C to exit'
    sleep(5)

  end
end

BEGIN {
  require 'getoptlong'

  def show_usage(message, defaults)
    puts "api-monitor: #{message}" if message
    puts <<-EOF

  USAGE:

    hal-monitor [OPTIONS]

  DESCRIPTION:

    Monitors the list of users and products for the given server by
    looping through the following HTTP request:

      GET /products
      GET /users

    Once started hit CTRL-C to exit from the loop.

  OPTIONAL PARAMETERS:

    --help, -h
       show this help screen

    --mon, -m products|users
       only monitor given resource, default show both

    --auth, -a username:password
       authorization string (both username and password required)

    --url, -u hostname[:port]
       destination of request (default #{defaults[:host]}:#{defaults[:port]})

  EXAMPLES:

    hal-monitor
    hal-monitor --mon=users
    hal-monitor --url=localhost:8080
    hal-monitor --auth=kiffin:pindakaas

    EOF
    exit 0
  end

  def show_params(params)
    if params[:auth]
      authorization = "auth:'#{params[:auth]}'"
    else
      authorization = '(no authorization)'
    end
    puts "url:'#{params[:url]}' name:'#{params[:id]}' #{authorization}"
  end

  def get_params(show)
    defaults = {
        host: '0.0.0.0',
        port: 8080,
        products: true,
        users: true
    }

    params = {
        url: nil,
        host: defaults[:host],
        port: defaults[:port],
        products: defaults[:products],
        users: defaults[:users],
        username: nil,
        password: nil,
        auth: nil,
    }

    opts = GetoptLong.new(
        [ '--help',     '-h', GetoptLong::NO_ARGUMENT       ],
        [ '--mon',      '-m', GetoptLong::REQUIRED_ARGUMENT ],
        [ '--auth',     '-a', GetoptLong::REQUIRED_ARGUMENT ],
        [ '--url',      '-u', GetoptLong::REQUIRED_ARGUMENT ]
    )

    begin
      opts.each do |opt, arg|
        case opt
          when '--help'
            show_usage(nil, defaults)
          when '--auth'
            (username,password) = arg.split(':')
            unless password
              show_usage("password required for username -- '#{username}'", defaults)
            end
            params[:username] = username
            params[:password] = password
          when '--mon'
            if arg == 'products'
              params[:products] = true
              params[:users] = false
            elsif arg == 'users'
              params[:products] = false
              params[:users] = true
            else
              show_usage("invalid resource name -- #{arg} (must be either lproducts or 'users')", defaults)
            end
          when '--url'
            (host,port) = arg.split(':')
            if port
              unless /^\d+$/ === port
                show_usage("invalid port -- #{port} (must be a number)", defaults)
              end
            end
            params[:host] = host
            params[:port] = port
        end
      end
    rescue GetoptLong::Error => e
      show_usage(nil, defaults)
    end

    # Check url = "hostname:port"
    params[:host] ||= defaults[:host]
    params[:port] ||= defaults[:port]
    params[:url] = "#{params[:host]}:#{params[:port]}"

    # Check authorization = "username:password"
    params[:auth] = "#{params[:username]}:#{params[:password]}" if params[:username] && params[:password]

    # Check no extra arguments
    show_usage("no extra arguments allowed -- '#{ARGV}'", defaults) unless ARGV.length == 0

    show_params(params) if show

    return params
  end
}
