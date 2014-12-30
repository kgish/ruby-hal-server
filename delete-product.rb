require 'httparty'
require 'json'

# Initialize all of the parameters passed on the command line.
params = get_params(false)
puts params
puts ' '

url = "http://#{params[:url]}/products/#{params[:id]}"
puts "DELETE #{url}"
puts ' '

# Attempt to create new product => POST /products Beer'
begin
  response = HTTParty.delete(url, :headers => {'Content-type' => 'application/json'})
  rescue Exception => e
    puts e.message
    exit
end

puts "#{response.code}/#{response.message} #{response.headers['server']}"
exit

unless response.code.to_i >= 200 && response.code.to_i < 300
  puts 'Oops, looks like something went wrong (abort)'
  exit
end

url = response.headers["location"]
puts ' '
puts "GET #{url}"
puts ' '
begin
  response = HTTParty.get(url, :headers => {'Content-type' => 'application/json'})
rescue Exception => e
  puts e.message
  exit
end

unless response.code.to_i >= 200 && response.code.to_i < 300
  puts 'Oops, looks like something went wrong (abort)'
  exit
end

puts "#{response.code}/#{response.message} #{response.headers['server']}"
puts ' '
puts response.body

# Finally ensure that the properties are identical to what was sent.
h = JSON.parse response.body
p = h['product']

cnt = 0
unless p['name'] === params[:name]
  cnt += 1
  puts "Name mismatch -- #{p['name']} != #{params[:name]}"
end

unless p['price'] === params[:price]
  cnt += 1
  puts "Price mismatch -- #{p['price']} != #{params[:price]}"
end

unless p['category'] === params[:category]
  cnt += 1
  puts "Category mismatch -- #{p['category']} != #{params[:category]}"
end

puts cnt > 0 ? 'Failed' : 'Succeeded'

BEGIN {
  require 'getoptlong'

  def show_usage(message, defaults)
    puts "delete-product.rb: #{message}" if message
    puts <<-EOF

  USAGE:

    delete-product [OPTIONS] --id=n

  DESCRIPTION:

    Deletes a product with the given id by sending the
    following HTTP request to the given server:

      DELETE /products/id

  REQUIRED PARAMETERS:

    --id n
       id of product (number)

  OPTIONAL PARAMETERS:

    --help, -h
       show this help screen

    --auth, -a username:password
       basic authorization string (both username and password required)

    --url, -u hostname[:port]
       destination of request (default #{defaults[:host]}:#{defaults[:port]})

  EXAMPLES:

    delete-product --id=11
    delete-product --id=64 --auth=kiffin:pindakaas
    delete-product --id=3 --url=www.example.com:8080

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
        port: 8080
    }

    params = {
        url: nil,
        host: defaults[:host],
        port: defaults[:port],
        id: nil,
        username: nil,
        password: nil,
        auth: nil,
    }

    opts = GetoptLong.new(
        [ '--help',     '-h', GetoptLong::NO_ARGUMENT       ],
        [ '--id',       '-i', GetoptLong::REQUIRED_ARGUMENT ],
        [ '--auth',     '-a', GetoptLong::REQUIRED_ARGUMENT ],
        [ '--url',      '-u', GetoptLong::REQUIRED_ARGUMENT ]
    )

    begin
      opts.each do |opt, arg|
        case opt
          when '--help'
            show_usage(nil, defaults)
          when '--id'
            unless /^\d+$/ === arg
              show_usage("invalid id -- '#{arg}' (only digits)", defaults)
            end
            params[:id] = arg
          when '--auth'
            (username,password) = arg.split(':')
            unless password
              show_usage("password required for username -- '#{username}'", defaults)
            end
            params[:username] = username
            params[:password] = password
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

    # Check required parameters: name, price and category
    show_usage('id is required', defaults) unless params[:id]

    # Check authorization = "username:password"
    params[:auth] = "#{params[:username]}:#{params[:password]}" if params[:username] && params[:password]

    # Check no extra arguments
    show_usage("no extra arguments allowed -- '#{ARGV}'", defaults) unless ARGV.length == 0

    show_params(params) if show

    return params
  end
}