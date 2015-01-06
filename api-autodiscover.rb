require 'hyperresource'

host = '127.0.0.1'
port = 8080
root = "http://#{host}:#{port}"
headers = { :accept => 'application/json' }

api = HyperResource.new( root: root, headers: headers )

begin

  puts "Host: #{host}"
  puts "Port: #{port}"
  puts "Root: #{root}"
  puts "Headers: #{headers}"

  puts
  puts 'root = api.get'
  root = api.get

  puts
  puts 'root.body'
  puts root.body

  puts
  puts 'Attributes:'
  attributes = root.attributes
  if attributes.nil?
    puts 'None'
  else
    cnt = 0
    attributes.each do |k,v|
      cnt += 1
      puts "#{cnt} '#{k}' = '#{v}'"
    end
  end

  puts
  puts 'Links'
  links = root.links
  if links.nil?
    puts 'None'
  else
    cnt = 0
    links.each do |k,v|
      cnt += 1
      puts "#{cnt} '#{k}' #{v.inspect}"
    end
  end

  unless links.nil?
    puts
    puts 'Links::curies'
    curies = links.curies
    if curies.nil?
      puts 'None'
    else
      cnt = 0
      curies.each do |curie|
        cnt += 1
        puts "#{cnt} #{curie.inspect}"
      end
    end
  end

rescue HyperResource::ResponseError => e
  puts
  puts "HyperResource::ResponseError => #{e.message}"
rescue Exception => e
  puts
  puts "Exception => #{e.message}"
end
