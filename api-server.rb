$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'bundler/setup'
require 'webmachine'

params = get_params(false)
puts params

auth = params[:host]
port = params[:port]

# Resources
require 'resources/root'
require 'resources/product'
require 'resources/user'
require 'resources/session'

# Logging
require 'helpers/logger'

ENVIRONMENT ||= 'development'

App = Webmachine::Application.new do |app|
  app.configure do |config|
    config.adapter = :WEBrick
    config.ip = '127.0.0.1'
    config.port = port
    config.adapter = :WEBrick
    config.adapter_options = {}
  end

  app.routes do
    add [], RootResource
    add ['products'], ProductResource
    add ['products', :id], ProductResource
    add ['users'], UserResource
    add ['users', :id], UserResource
    add ['session', :*], SessionResource
    add ['trace', :*], Webmachine::Trace::TraceResource
  end

end

begin
  App.run
rescue Exception => e
  puts e.message
end

BEGIN {
  require 'getoptlong'

  def show_usage(message, defaults)
    puts "api-server: #{message}" if message
    puts <<-EOF

  USAGE:

    api-server [OPTIONS]

  DESCRIPTION:

    RESTful web server built with Webmachine which exposes an HAL/JSON
    interface API.

  OPTIONAL PARAMETERS:

    --help, -h
       show this help screen

    --auth, -a
       enable authentication (default #{defaults[:auth]})

    --port, -p n
       listen on this port number (default #{defaults[:port]})

  EXAMPLES:

    api-server
    api-server --ip=4200
    api-server --auth
    api-server --ip=8000 --auth

    EOF
    exit 0
  end

  def show_params(params)
    if params[:auth]
      authorization = 'enabled'
    else
      authorization = 'disabled'
    end
    puts "ip:'#{params[:url]}'authorization:'#{authorization}"
  end

  def get_params(show)
    defaults = {
        auth: false,
        port: 8080
    }

    params = {
        auth: defaults[:auth],
        port: defaults[:port]
    }

    opts = GetoptLong.new(
        [ '--help',     '-h', GetoptLong::NO_ARGUMENT       ],
        [ '--auth',     '-a', GetoptLong::NO_ARGUMENT ],
        [ '--port',     '-u', GetoptLong::REQUIRED_ARGUMENT ]
    )

    begin
      opts.each do |opt, arg|
        case opt
          when '--help'
            show_usage(nil, defaults)
          when '--port'
            unless /^\d+$/ === arg
              show_usage("invalid port -- '#{arg}' (only digits)", defaults)
            end
            params[:port] = arg
          when '--auth'
            params[:auth] = true
        end
      end
    rescue GetoptLong::Error => e
      show_usage(nil, defaults)
    end

    # Check url = "hostname:port"
    params[:auth] ||= defaults[:auth]
    params[:port] ||= defaults[:port]

    # Check no extra arguments
    show_usage("no extra arguments allowed -- '#{ARGV}'", defaults) unless ARGV.length == 0

    show_params(params) if show

    return params
  end
}