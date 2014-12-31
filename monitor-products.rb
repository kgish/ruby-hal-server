require 'bundler/setup'
require 'httparty'
require 'json'

params = get_params(false)

host = params[:host]
port = params[:port]
resource = 'products'
url = "http://#{host}:#{port}/#{resource}"

RETRY_COUNT = 6

trap('SIGINT') { throw :ctrl_c }

catch :ctrl_c do
  total = 0
  countdown = 0
  error_message = ''
  loop do
    system('clear')
    countdown = countdown - 1 if countdown > 0
    if countdown == 0
    begin
      response = HTTParty.get(url, :headers => {'Content-type' => 'application/json'})
    rescue Exception =>e
      error_message = e.message
      countdown = RETRY_COUNT
    end
    end
    if countdown == 0
      total += 1
      server = response.headers['server']
      server = server.sub(/ \(.*\)$/, '')
      puts "#{total} | #{host} | #{port} | #{resource} | #{server} | #{response.code} | #{response.message}"
      puts ' '

      h = JSON.parse response.body

      cnt = 0
      h['products'].each do |key|
        if cnt == 0
          puts "#\tid\tname\tprice\tcategory"
          puts "-\t--\t----\t-----\t--------"
        end
        p = key['product']
        cnt += 1
        puts "#{cnt}\t#{p['id']}\t#{p['name']}\t#{p['price']}\t#{p['category']}"
      end
    else
      puts error_message
      puts countdown == RETRY_COUNT ? 'Oops!' : "Retry (#{countdown})"
    end
    puts ' '
    puts 'CTRL-C to exit'
    sleep(1)
  end
end

BEGIN {
  require 'getoptlong'

  def show_usage(message, defaults)
    puts "monitor-product.rb: #{message}" if message
    puts <<-EOF

  USAGE:

    monitor-products [OPTIONS]

  DESCRIPTION:

    Monitors the list or products for the given server by looping through
    the following HTTP request:

      GET /products

    Once started hit CTRL-C to exit from the loop.

  OPTIONAL PARAMETERS:

    --help, -h
       show this help screen

    --auth, -a username:password
       basic authorization string (both username and password required)

    --url, -u hostname[:port]
       destination of request (default #{defaults[:host]}:#{defaults[:port]})

  EXAMPLES:

    monitor-products
    monitor-products --url=localhost:8080
    monitor-products --auth=kiffin:pindakaas

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
        username: nil,
        password: nil,
        auth: nil,
    }

    opts = GetoptLong.new(
        [ '--help',     '-h', GetoptLong::NO_ARGUMENT       ],
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
