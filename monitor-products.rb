require 'bundler/setup'
require 'httparty'
require 'json'

trap('SIGINT') { throw :ctrl_c }

catch :ctrl_c do
  total = 0
  loop do
    system('clear')
    ok = true
    begin
      response = HTTParty.get('http://localhost:8080/products', :headers => {'Content-type' => 'application/json'})
    rescue Exception =>e
      puts e.message
      ok = false
    end
    if ok
      total = total + 1
      puts "#{total} | #{response.headers['server']} | #{response.code} | #{response.message}"
      puts ' '

      h = JSON.parse response.body

      cnt = 0
      h['products'].each do |key|
        if cnt == 0
          puts "#\tid\tname\tprice\tcategory"
          puts "-\t--\t----\t-----\t--------"
        end
        p = key['product']
        cnt = cnt + 1
        puts "#{cnt}\t#{p['id']}\t#{p['name']}\t#{p['price']}\t#{p['category']}"
      end
    else
      puts 'Retry...'
    end
    puts ' '
    puts 'CTRL-C to exit'
    sleep(1)
  end
end
