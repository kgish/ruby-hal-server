params = get_options(false)

puts params

BEGIN {
  require 'getoptlong'

  def show_usage(message, defaults)
    puts "create-product.rb: #{message}" if message
    puts <<-EOF

  USAGE:

    create-product [OPTIONS] --name s --price n --cat s

  DESCRIPTION:

    Creates a product with given attributes by sending the
    following HTTP request to the given server:

      POST /products

  REQUIRED PARAMETERS:

    --name, -n s
       name of product (string)

    --price, -p n
       price of product (number)

    --cat, -c s
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
    puts "url:'#{params[:url]}' name:'#{params[:name]}' price:'#{params[:price]}' cat:'#{params[:cat]}' #{authorization}"
  end

  def get_options(show)
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
        cat: nil,
        username: nil,
        password: nil,
        auth: nil,
    }

    opts = GetoptLong.new(
        [ '--help',  '-h', GetoptLong::NO_ARGUMENT       ],
        [ '--name',  '-n', GetoptLong::REQUIRED_ARGUMENT ],
        [ '--price', '-p', GetoptLong::REQUIRED_ARGUMENT ],
        [ '--cat',   '-c', GetoptLong::REQUIRED_ARGUMENT ],
        [ '--auth',  '-a', GetoptLong::REQUIRED_ARGUMENT ],
        [ '--url',   '-u', GetoptLong::REQUIRED_ARGUMENT ]
    )

    begin
      opts.each do |opt, arg|
        case opt
          when '--help'
            show_usage(nil, defaults)
          when '--name'
            params[:name] = arg
          when '--cat'
            params[:cat] = arg
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
    show_usage('category is required', defaults) unless params[:cat]

    # Check authorization = "username:password"
    params[:auth] = "#{params[:username]}:#{params[:password]}" if params[:username] && params[:password]

    # Check no extra arguments
    show_usage("no extra arguments allowed -- '#{ARGV}'", defaults) unless ARGV.length == 0

    show_params(params) if show

    return params
  end
}
