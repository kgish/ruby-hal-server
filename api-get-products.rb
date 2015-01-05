require 'hyperresource'

api = HyperResource.new(
    root: 'http://localhost:8080',
    headers: {'Accept' => 'application/json'}
)

puts 'api.get'
begin
    response = api.get
rescue Exception => e
    puts e.message
    exit
end

puts response
