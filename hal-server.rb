$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'bundler/setup'
require 'webmachine'

ENVIRONMENT ||= 'development'

# Get parameters
params = get_params(false)
auth = params[:auth]
port = params[:port]
timeout = params[:timeout]
puts params

# Resources
require 'resources/base'
require 'resources/root'
require 'resources/product'
require 'resources/user'
require 'resources/session'

# Authorization enabled?
BaseResource.configure(auth, timeout)

# Log listener
require 'helpers/logger'

App = Webmachine::Application.new do |app|
  app.configure do |config|
    config.adapter = :WEBrick
    config.ip = '127.0.0.1'
    config.port = port
    config.adapter = :WEBrick
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
    puts "hal-server: #{message}" if message
    puts <<-EOF

  USAGE:

    hal-server [OPTIONS]

  DESCRIPTION:

    RESTful web server built with Webmachine which exposes an HAL/JSON
    interface API.

  OPTIONAL PARAMETERS:

    --help, -h
       show this help screen

    --auth, -a [secs]
       enable authentication (default #{defaults[:auth]})
       optional timeout in seconds (default #{defaults[:timeout]})

    --port, -p n
       listen on this port number (default #{defaults[:port]})

  EXAMPLES:

    hal-server
    hal-server --ip=4200
    hal-server --auth
    hal-server --ip=8000 --auth
    hal-server --auth=600 (timeout 10 minutes)

    EOF
    exit 0
  end

  def show_params(params)
    if params[:auth]
      authorization = "enabled', timeout=#{params[:timeout]}"
    else
      authorization = 'disabled'
    end
    puts "ip='#{params[:url]}', authorization='#{authorization}'"
  end

  def get_params(show)
    defaults = {
        auth: false,
        timeout: 1800,
        port: 8080
    }

    params = {
        auth: defaults[:auth],
        port: defaults[:port],
        timeout: defaults[:timeout]
    }

    opts = GetoptLong.new(
        [ '--help',     '-h', GetoptLong::NO_ARGUMENT       ],
        [ '--auth',     '-a', GetoptLong::OPTIONAL_ARGUMENT ],
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
            if arg.length > 0
              unless /^\d+$/ === arg
                show_usage("invalid timeout -- '#{arg}' (only digits)", defaults)
              end
              params[:timeout] = arg.to_i
            else
              params[:timeout] = nil
            end
        end
      end
    rescue GetoptLong::Error => e
      show_usage(nil, defaults)
    end

    # Check url = "hostname:port"
    params[:auth] ||= defaults[:auth]
    params[:port] ||= defaults[:port]
    params[:timeout] ||= defaults[:timeout]

    # Check no extra arguments
    show_usage("no extra arguments allowed -- '#{ARGV}'", defaults) unless ARGV.length == 0

    show_params(params) if show

    return params
  end
}
