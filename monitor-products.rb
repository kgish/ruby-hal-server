require 'bundler/setup'
require 'httparty'
require 'json'

host = '0.0.0.0'
port = 8080
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
