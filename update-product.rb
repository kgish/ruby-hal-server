require 'bundler/setup'
require 'httparty'
require 'json'

# Initialize all of the parameters passed on the command line.
params = get_params(false)
puts params
puts

url = "http://#{params[:url]}/products/#{params[:id]}"
puts "PUT #{url}"
puts

# Attempt to create new product => POST /products Beer'
begin
  response = HTTParty.put(url, :body => {:product => {:name => params[:name], :category => params[:category], :price => params[:price]}}.to_json, :headers => {'Content-type' => 'application/json'})
  rescue Exception => e
    puts e.message
    exit
end

# Display the results
display_results(response, true)

# Check the return code, if error abort and optionally dump stack trace
check_code(response)

puts
puts "GET #{url}"
puts
begin
  response = HTTParty.get(url, :headers => {'Content-type' => 'application/json'})
rescue Exception => e
  puts e.message
  exit
end

# Display the results
display_results(response, true)

# Check the return code, if error abort and optionally dump stack trace
check_code(response)

# Finally ensure that the properties are identical to what was sent.
body = JSON.parse response.body
p = body

cnt = 0
unless p['name'] === params[:name]
  cnt += 1
  puts "Name mismatch -- #{p['name']} != #{params[:name]}"
end

unless p['price'].to_i === params[:price].to_i
  cnt += 1
  puts "Price mismatch -- #{p['price']} != #{params[:price]}"
end

unless p['category'] === params[:category]
  cnt += 1
  puts "Category mismatch -- #{p['category']} != #{params[:category]}"
end

puts cnt > 0 ? 'Failed' : 'Success!'

BEGIN {
  require 'getoptlong'

  def show_usage(message, defaults)
    puts "update-product: #{message}" if message
    puts <<-EOF

  USAGE:

    update-product [OPTIONS] --id=n

  DESCRIPTION:

    Updates a product with given attribute(s) by sending the
    following HTTP request to the given server:

      PUT /products

  REQUIRED PARAMETERS:

    --id, -i n
      product id (number)

  OPTIONAL PARAMETERS:

    --help, -h
      show this help screen

    --name, -n s
      name of product (string)

    --price, -p n
      price of product (number)

    --category, -c s
      category of product (string)

    --auth, -a username:password
      authorization string (both username and password required)

    --url, -u hostname[:port]
      destination of request (default #{defaults[:host]}:#{defaults[:port]})

  EXAMPLES:

    update-product --id=3 --name=audi --price=25000
    update-product --id=5 --category=food --auth=kiffin:pindakaas
    update-product --id=21 -name=horse --url=www.example.com:8080

    EOF
    exit 0
  end

  def show_params(params)
    if params[:auth]
      authorization = "auth:'#{params[:auth]}'"
    else
      authorization = '(no authorization)'
    end
    puts "url:'#{params[:url]}' name:'#{params[:name]}' price:'#{params[:price]}' category:'#{params[:category]}' #{authorization}"
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
        name: nil,
        price: nil,
        category: nil,
        username: nil,
        password: nil,
        auth: nil,
    }

    opts = GetoptLong.new(
        [ '--help',     '-h', GetoptLong::NO_ARGUMENT       ],
        [ '--id',       '-i', GetoptLong::REQUIRED_ARGUMENT ],
        [ '--name',     '-n', GetoptLong::REQUIRED_ARGUMENT ],
        [ '--price',    '-p', GetoptLong::REQUIRED_ARGUMENT ],
        [ '--category', '-c', GetoptLong::REQUIRED_ARGUMENT ],
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
          when '--name'
            params[:name] = arg
          when '--category'
            params[:category] = arg
          when '--price'
            unless /^\d+$/ === arg
              show_usage("invalid price -- '#{arg}' (only digits)", defaults)
            end
            params[:price] = arg
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

    # strip out any empty parameters
    params.delete_if { |k, v| v.nil? }

    # Check required parameters: id
    show_usage('id is required', defaults) unless params[:id]

    # Check authorization = "username:password"
    params[:auth] = "#{params[:username]}:#{params[:password]}" if params[:username] && params[:password]

    # Check at least one of name, category or price is present
    show_usage('name, category or price is required', defaults) unless params[:name] || params[:category] || params[:price]

    # Check no extra arguments
    show_usage("no extra arguments allowed -- '#{ARGV}'", defaults) unless ARGV.length == 0

    show_params(params) if show

    return params
  end

  def check_code(response)
    code = response.code.to_i
    unless code >= 200 && code < 300
      puts 'Oops, looks like something went wrong (abort)'
      if code >= 500
        puts response.message, response.body
      end
      exit
    end
  end

  def display_results(response, b)
    puts "#{response.code}/#{response.message} #{response.headers['server']}"
    puts
    puts response.body if b
  end
}
