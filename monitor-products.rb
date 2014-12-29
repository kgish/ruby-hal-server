require 'bundler/setup'
require 'httparty'
require 'json'

trap("SIGINT") { throw :ctrl_c }

catch :ctrl_c do
  loop do
    system('clear')
    puts 'GET /products ALL'
    begin
      response = HTTParty.get('http://localhost:8080/products', :headers => {'Content-type' => 'application/json'})
    rescue Exception =>e
      puts e.message
      exit
    end
    puts response.code, response.headers.inspect, response.message

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

    puts ' '
    puts "There are -#{cnt}- products"
    puts ' '
    puts 'CTRL-C to exit'
    sleep(1)
  end
end
