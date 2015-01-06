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

    puts
    puts 'Links::curies'
    curies = links.curies
    if curies.nil?
      puts 'None'
    else
      cnt = 0
      curies.each do |c|
        cnt += 1
        puts "#{cnt} href='#{c.href}' base_href='#{c.base_href}' name='#{c.name}' templated='#{c.templated}' params='#{c.params.inspect}' default_method='#{c.default_method}"
        #puts "#{cnt} root='#{c.root}' href='#{c.href}' loaded='#{c.loaded}' base_href='#{c.base_href}' name='#{c.name}' templated='#{c.templated}'' params='#{c.params.inspect}' default_method='#{c.default_method}"
        # root='#{c.root}' => exception (URI::InvalidURIError: the scheme http does not accept registry part: :80 (or bad hostname?)
      end
    end
  end

  products = api.get.products
  puts
  puts 'Links::products'
  puts products.inspect
  products.get.each do |product|
    puts product.inspect
  end

rescue HyperResource::ResponseError => e
  puts
  puts "HyperResource::ResponseError => #{e.message}"
rescue Exception => e
  puts
  puts "Exception => #{e.message}"
end
