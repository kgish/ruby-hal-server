require 'httparty'
require 'json'

# Initialize all of the parameters passed on the command line.
params = get_params(false)
puts params
puts ' '

url = "http://#{params[:url]}/products"
puts "POST #{url}"
puts ' '

# Attempt to create new product => POST /products
begin
  response = HTTParty.post(url, :body => {:product => {:name => params[:name], :category => params[:category], :price => params[:price]}}.to_json, :headers => {'Content-type' => 'application/json'})
  rescue Exception => e
    puts e.message
    exit
end

# Display the results
display_results(response, false)

# Check the return code, if error abort and optionally dump stack trace
check_code(response)

# Verify that the new product was indeed created.
url = response.headers['location']
puts "GET #{url}"
puts ' '

begin
  response = HTTParty.get(url, :headers => {'Content-type' => 'application/json'})
rescue Exception => e
  puts e.message
  exit
end

# Check the return code, if error abort and optionally dump stack trace
check_code(response)

# Display the results (including body)
display_results(response, true)

# Finally ensure that the created properties are identical to what was originally sent.
h = JSON.parse response.body
p = h['product']

# Name ok?
cnt = 0
unless p['name'] === params[:name]
  cnt += 1
  puts "Name mismatch -- #{p['name']} != #{params[:name]}"
end

# Price ok?
unless p['price'] === params[:price]
  cnt += 1
  puts "Price mismatch -- #{p['price']} != #{params[:price]}"
end

# Category ok?
unless p['category'] === params[:category]
  cnt += 1
  puts "Category mismatch -- #{p['category']} != #{params[:category]}"
end

# Everything match?
puts cnt > 0 ? 'Failed' : 'Success!'

BEGIN {
  require 'getoptlong'

  def show_usage(message, defaults)
    puts "create-product.rb: #{message}" if message
    puts <<-EOF

  USAGE:

    create-product [OPTIONS] --name=s --price=n --category=s

  DESCRIPTION:

    Creates a product with given attributes by sending the
    following HTTP request to the given server:

      POST /products

  REQUIRED PARAMETERS:

    --name, -n s
       name of product (string)

    --price, -p n
       price of product (number)

    --category, -c s
       category of product (string)

  OPTIONAL PARAMETERS:

    --help, -h
       show this help screen

    --auth, -a username:password
       basic authorization string (both username and password required)

    --url, -u hostname[:port]
       destination of request (default #{defaults[:host]}:#{defaults[:port]})

  EXAMPLES:

    create-product -n audi -c car -p 25000
    create-product -n cheese -c food -p 10 -a kiffin:pindakaas
    create-product -n horse -c animal -p 3450 -u www.example.com:8080

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
        name: nil,
        price: nil,
        category: nil,
        username: nil,
        password: nil,
        auth: nil,
    }

    opts = GetoptLong.new(
        [ '--help',     '-h', GetoptLong::NO_ARGUMENT       ],
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

    # Check required parameters: name, price and category
    show_usage('name is required', defaults) unless params[:name]
    show_usage('price is required', defaults) unless params[:price]
    show_usage('category is required', defaults) unless params[:category]

    # Check authorization = "username:password"
    params[:auth] = "#{params[:username]}:#{params[:password]}" if params[:username] && params[:password]

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
    puts ' '
    puts response.body if b
  end
}
