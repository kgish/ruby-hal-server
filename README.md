# Ruby-HAL-Server

Example HAL Server based on Webmachine and ROAR, inspired by my visit to [Blendle](http://www.blendle.nl) one day.

Provides a basic template for setting up a simple application combining  [webmachine](https://github.com/seancribbs/webmachine-ruby)
and the Hypertext Application Language (HAL) for building real RESTful systems in Ruby.

ROAR (Resource-Oriented Architectures in Ruby) is a framework for parsing and rendering REST documents. Roar comes with
built-in JSON, JSON-HAL, JSON-API and XML support.

Have a look at my [Ember HAL Client](https://github.com/kgish/ember-hal-client) to see a working example of a web
application specifically built to communicate with this server.

I've tested and verified the server with the [HAL-browser](https://github.com/mikekelly/hal-browser), see below.

![](images/screenshot-monitor.png?raw=true)

## HAL/JSON Web API

Here is an overview of the Web API functionalities that the hal server exposes.

    [:host]      = hostname of hal server, default `127.0.0.1`
    [:port]      = port used by hal server, default `8080`
    [:resource]  = one of `%w{products users sessions}`
    [:id]        = resource id
    [:templated] = true or false, default true

### GET /[:resource]
e.g. /products
```javascript
{
   '_links' => {
    'self' => {
      'href' => '/[:resource]'
    },
    'curies' => [
      {
        'name' => 'ht',
        'href' => "http://[:host]:[:port]/rels/{rel}",
        'templated' => [:templated]
      }
    ],
    'ht:[:resource]' => [
      {
        'href' => "/products/[:id]",
        // [:resource].params, e.g. products
        'name' => [:name],
        'category' => [:category],
        'price' => [:price]
      },
      {
        ...
      }
    ]
  }
}
```

### GET /[:resource]/[:id]
e.g. /products/12

```javascript
{
  '_links' => {
    'self' => {
      'href' => "/[:resource]/[:id]"
    },
    'curies' => [
      {
        'name' => 'ht',
        'href' => "http://[:host]:[:port]/rels/{rel}",
        'templated' => [:templated]
      }
    ]
  },
   // [:resource].params, e.g. products
  'name' => [:name],
  'category => [:category],
  'price => [:price]
}
```
### GET / (Root)

The zero-configuration starts with the root resource where all relevant information
about the hal api service can be obtained.

![](images/screenshot-postman-root.png?raw=true)

## Installation

In order to install and run the webmachine, run the following commands.

    $ git clone https://github.com/kgish/ruby-hal-server.git \
        hal-server
    $ cd hal-server
    $ bundle install

### HAL Server

You can now start the webmachine hal server using defaults WEBrick and port 8080:

    $ bundle exec ruby hal-server.rb
    INFO  WEBrick 1.3.1
    INFO  ruby 2.1.5 (2014-11-13) [x86_64-linux]
    INFO  Webmachine::Adapters::WEBrick::Server#start: pid=13513 port=8080

#### Usage

    USAGE:

      hal-server [OPTIONS]

    DESCRIPTION:

      RESTful web server built with Webmachine which exposes an HAL/JSON
      interface API.

    OPTIONAL PARAMETERS:

      --help, -h
         show this help screen

    --auth, -a [secs]
       enable authentication (default false)
       optional timeout in seconds (default 1800)

      --auth, -a
         enable authentication (default false)

      --port, -p n
         listen on this port number (default 8080)

    EXAMPLES:

      hal-server
      hal-server --ip=4200
      hal-server --auth
      hal-server --ip=8000 --auth
      hal-server --auth=600 (timeout 10 minutes)

### Monitor

You can now fire up the monitor by running the following command:

    $ bundle exec ruby hal-monitor-products.rb

If everything is working according to plan you should see something like this:

    57 | 0.0.0.0 | 8080 | products | Webmachine-Ruby/0.3.0 WEBrick/1.3.1 | 200 | OK

    #	id	name	price	category
    -	--	----	-----	--------
    1	1	pizza	500	    food
    2	2	shoes	2000	clothing
    3	3	laptop	500000	computer

#### Usage

    USAGE:

        hal-monitor [OPTIONS]

    DESCRIPTION:

        Monitors the list of users and products for the given server by
        looping through the following HTTP request:

        GET /products
        GET /users

        Once started hit CTRL-C to exit from the loop.

    OPTIONAL PARAMETERS:

        --help, -h
          show this help screen

        --mon, -m products|users
          only monitor given resource, default show both

        --auth, -a username:password
          authorization string (both username and password required)

        --url, -u hostname[:port]
          destination of request (default 0.0.0.0:8080)

    EXAMPLES:

        hal-monitor
        hal-monitor --mon=users
        hal-monitor --url=localhost:8080
        hal-monitor --auth=kiffin:pindakaas

## Users and roles

Depending on whether you are an admin or regular user you will be given access accordingly, which is
given in the following table.

| Username | Password  | Role  |
| -------- | --------- | ----- |
| kiffin   | pindakaas | admin |
| henri    | escargot  | user  |
| bhogan   | holeinone | user  |
| admin    | admin     | admin |

The role provides the person with certain access privileges illustrated in the following table.

| Role  | Products |  |  |  | Users |  |  |  | Profile |  |
| ---- | ---- | --- | ---- | ------ | ---- | --- | ---- | ------ | ---- | ---- |
|      | view | new | edit | delete | view | new | edit | delete | view | edit |
| admin | x | x | x | x | x | x | x | x | x | x |
| user  | x |   |   |   |   |   |   |   | x | x |

## Tooling

A number of useful tools have also been provided to play around with and gain some
insight into this mysterious world of the future.

### Create a product (POST)

Create your first product by running the following command:

    $ bundle exec ruby create-product.rb --name=kiffin --category=person --price=1234

You should then see something like this:

    75 | 0.0.0.0 | 8080 | products | Webmachine-Ruby/0.3.0 WEBrick/1.3.1 | 200 | OK

    #	id	name	price	category
    -	--	----	-----	--------
    1	1	pizza	500	    food
    2	2	shoes	2000	clothing
    3	3	laptop	500000	computer
    4	4	kiffin	1234	person

Note: when a product is created, this will be verified by making a GET request to check
that indeed the product has been created and the parameters match.

#### Usage

      USAGE:

        create-product [OPTIONS] --name=s --price=n --category=s

      DESCRIPTION:

        Creates a product with given attributes by sending the
        following HTTP request to the given hal server:

          POST /products

      REQUIRED PARAMETERS:

        --name, -n s
          name of product (string)

        --price, -p n
          price of product (number)

        --category, -c s
          category of product (string)

      OPTIONAL PARAMETERS:

        --help, -h
          show this help screen

        --auth, -a username:password
          authorization string (both username and password required)

        --url, -u hostname[:port]
          destination of request (default 0.0.0.0:8080)

      EXAMPLES:

        create-product -n audi -c car -p 25000
        create-product -n cheese -c food -p 10 -a kiffin:pindakaas
        create-product -n horse -c animal -p 3450 -u www.example.com:8080

### Retrieve a product (GET)

You can retrieve a given product (apple) by running the following command:

    $ bundle exec ruby get-product.rb --id=9

You should get results similar to the following:

    {:url=>"0.0.0.0:8080", :host=>"0.0.0.0", :port=>8080, :id=>"9", \
        :username=>nil, :password=>nil, :auth=>nil}

    GET http://0.0.0.0:8080/products/9

    200/OK  Webmachine-Ruby/1.3.0 WEBrick/1.3.1 (Ruby/2.1.5/2014-11-13)

    {"_links":{"self":{"href":"/products/9"},"curies":[{"name":"ht", \
        "href":"http://0.0.0.0:8080:/rels/{rel}","templated":true}]}, \
        "name":"apple","category":"object","price":2628}
    Success!

#### Usage

      USAGE:

        get-product [OPTIONS] --id=n

      DESCRIPTION:

        Find a product with the given id by sending the
        following HTTP request to the given hal server:

          GET /products/id

      REQUIRED PARAMETERS:

        --id n
          product id (number)

      OPTIONAL PARAMETERS:

        --help, -h
          show this help screen

        --auth, -a username:password
          authorization string (both username and password required)

        --url, -u hostname[:port]
          destination of request (default 0.0.0.0:8080)

      EXAMPLES:

        get-product --id=11
        get-product --id=64 --auth=kiffin:pindakaas
        get-product --id=3 --url=www.example.com:8080

### Delete a product (DELETE)

Delete a given product (shoes) by running the following command:

    $ bundle exec ruby delete-product.rb --id=2

You should then see something like this:

    98 | 0.0.0.0 | 8080 | products | Webmachine-Ruby/0.3.0 WEBrick/1.3.1 | 200 | OK

    #	id	name	price	category
    -	--	----	-----	--------
    1	1	pizza	500	    food
    2	3	laptop	500000	computer
    3	4	kiffin	1234	person

#### Usage

      USAGE:

        delete-product [OPTIONS] --id=n

      DESCRIPTION:

        Deletes a product with the given id by sending the
        following HTTP request to the given hal server:

          DELETE /products/id

      REQUIRED PARAMETERS:

        --id n
          product id (number)

      OPTIONAL PARAMETERS:

        --help, -h
          show this help screen

        --auth, -a username:password
          authorization string (both username and password required)

        --url, -u hostname[:port]
          destination of request (default 0.0.0.0:8080)

      EXAMPLES:

        delete-product --id=11
        delete-product --id=64 --auth=kiffin:pindakaas
        delete-product --id=3 --url=www.example.com:8080

### Update a product (PUT)

Update a given product (shoes) by running the following command:

    $ bundle exec ruby update-product.rb --id=1 --name=pizza --price=495 \
        --category=discount

You should then see something like this:

    123 | 0.0.0.0 | 8080 | products | Webmachine-Ruby/0.3.0 WEBrick/1.3.1 | 200 | OK

    #	id	name	price	category
    -	--	----	-----	--------
    1	1	pizza	495	    discount
    2	3	laptop	500000	computer
    3	4	kiffin	1234	person

Ff you pass an `id` of which no product exists, one will be created and you will be returned
a response code `201 Created` according to the specifications for PUT.

Note: when a product is updated, this will be verified by making a GET request to check
that indeed the product has been updated/created and the parameters match.

#### Usage

      USAGE:

        update-product [OPTIONS] --id=n

      DESCRIPTION:

        Updates a product with given attribute(s) by sending the
        following HTTP request to the given hal server:

          PUT /products

      REQUIRED PARAMETERS:

        --id, -i n
          product id (number)

      OPTIONAL PARAMETERS:

        --help, -h
          show this help screen

        --name, -n s
          name of product (string)

        --price, -p n
          price of product (number)

        --category, -c s
          category of product (string)

        --auth, -a username:password
          authorization string (both username and password required)

        --url, -u hostname[:port]
          destination of request (default 0.0.0.0:8080)

      EXAMPLES:

        update-product --id=3 --name=audi --price=25000
        update-product --id=5 --category=food --auth=kiffin:pindakaas
        update-product --id=21 -name=horse --url=www.example.com:8080

### Autodiscover (zero configuration)

A powerful concept behind the Hypertext Application Language (HAL) is that your server can easily expose a
discoverable API for use across various programming domains.

This is where [HyperResource](https://github.com/gamache/hyperresource) can be used to make a `GET /` call to
gather the necessary information to use the service.

To see how this works you can run the following command:

    $ bundle exec ruby hal-autodiscover.rb

You should see something like the following:

    Host: 127.0.0.1
    Port: 8080
    Root: http://127.0.0.1:8080
    Headers: {:accept=>"application/json"}

    root = api.get

    root.body
    {"_links"=>{"self"=>{"href"=>"/"}, "curies"=>[{"name"=>"ht", \
        "href"=>"http://127.0.0.1:8080:/rels/{rel}", "templated"=>true}], \
        "ht:products"=>{"href"=>"/products"}, "ht:users"=>{"href"=>"/u...

    Attributes:
    1 'welcome' = 'Welcome to Kiffin's Demo HAL Server.'
    2 'hint_1' = 'This is the first hint.'
    3 'hint_2' = 'This is the second hint.'
    4 'hint_3' = 'This is the third hint.'
    5 'hint_4' = 'This is the fourth hint.'
    6 'hint_5' = 'This is the last hint.'

    Links
    1 'self' #<HyperResource::Link:0x00000001760e48 @resource=#<HyperR...
    2 'curies' [#<HyperResource::Link:0x000000017605d8 @resource=#<Hyp...
    3 'ht:products' #<HyperResource::Link:0x00000001763828 @resource=#...
    4 'products' #<HyperResource::Link:0x00000001763828 @resource=#<Hy...
    5 'ht_products' #<HyperResource::Link:0x00000001763828 @resource=#...
    6 'ht:users' #<HyperResource::Link:0x00000001753810 @resource=#<Hy...
    7 'users' #<HyperResource::Link:0x00000001753810 @resource=#<Hyper...
    8 'ht_users' #<HyperResource::Link:0x00000001753810 @resource=#<Hy...

    Links::curies
    1 href='http://127.0.0.1:8080:/rels/' base_href='http://127.0.0.1:...

    Links::products
    #<HyperResource::Link:0x000000018e4990 @resource=#<HyperResource:0...

## Authorization

So how does this thing called authorization work? The server endpoint for
acquiring authorization is `/session` and the client requests login:

```
=> POST /session
{ "username_or_email" : USER, "password": PASSWD }
```

where on success the server will generate the token by `SecureRandom.hex(64)`
and replies with:

```
<= 201 Created
{ "api_key" : { "user_id" : ID, "access_token" : ACCESS_TOKEN }}
```

or on failure the greatly feared `401 Unauthorized` error.

From then on the client passes back the token in the authentication
header with all following requests:

```
{ "headers" : { "Authentication" : "Bearer ACCESS_TOKEN" } }
```

Here's a small code snippet which I hope gives you a better idea how to
implement things.

```ruby
# Using authorization, login and get access token.
options = {
  :headers => {
    'Content-type' => 'application/json'
  },
  :body => {
    :username_or_email => username,
    :password => password
  }.to_json
}

# Create session and get token back
response = HTTParty.post('http://127.0.0.1:8080/session', options)

if response.code == 201 # Created
  access_token = JSON.parse(response.body)['api_key']['access_token']
else
  puts 'Login failed'
  exit
end

# Now you can use the token in all following requests
options = { 
  :headers => { 
    'Content-type' => 'application/json', 
    'Authorization' => "Bearer #{access_token}" 
  } 
}

response = HTTParty.get(, options)
```

### User registration

It is also possible for a given person to signup by going to the registration page, filling in the requested
data, and sending the request to the server.

The request is the usual `POST /users` for creating a new user, but in order to succeed the normal
authorization flow has to be bypassed.

This is accomplished by including the header `X-Secret-Key-Signup: SECRET_KEY_SIGNUP` as part of the
request.

The server validates this and ensures that the referer ends with `signup` and if both are true the request will
succeed. The user can then login with the username and password.

Of course, the client also needs to be configured to use the same secret key in order for this to work.

For the time being, this secret key is defined by a constant in the `resources/user.rb` file:

```ruby
SECRET_KEY_SIGNUP = '2d5b0672-b207-11e4-94cd-3c970ead4d26'

class UserResource < BaseResource

  def is_authorized?(auth_header = nil)
    ...
    if @@authorization_enabled
      if request.method == 'OPTIONS'
        result = true
      else
        if auth_header.nil?
          puts "Resource::User[#{request.method}] is_authorized? auth_header=nil!"
          puts "referer=#{request.referer}, headers=#{request.headers.inspect}"
          if request.referer.end_with?('signup') and
                request.headers['x-secret-key-signup'] == SECRET_KEY_SIGNUP
            result = true
          end
        else
          ...
        end
      end
    else
      result = true
    end
    puts "Resource::User[#{request.method}] is_authorized? => #{result}"
    result
  end

  ...
end
```

I realize that this is a bit of a cludge and perhaps not the most secure way to handle signups, but if
anyone else has a better idea please tell me.

### Timeout

Note that a timeout defines the maximum idle time between requests. The default value is 30 minutes. See the
usage above to see how to change this value.

## HAL Compatibility

This has been tested and verified with the [HAL-browser](https://github.com/mikekelly/hal-browser). It should also
work seamlessly with the [HyperResource gem](https://github.com/gamache/hyperresource).

Here are the screenshots as proof.

* [Root](images/hal-browser-root.png?raw=true)
* [Products](images/hal-browser-products.png?raw=true)
* [Product](images/hal-browser-product.png?raw=true)
* [Users](images/hal-browser-users.png?raw=true)
* [User](images/hal-browser-user.png?raw=true)

## Todo list

There are still a number of minor issues which should be looked into, namely
the following:

* Authentication flag `--auth` for the other tools, currently only implemented for `hal-monitor`.
* Should return a 408 Request Time-out HTTP response instead of 401 when idle time > timeout.
* Complete `hal-autodiscover` to scan all features, e.g. products, users, etc.
* The username has to be unique.
* Refactor to use the ROAR gem.
* Use of class variables `@@authentication_enabled` and `@@timeout` is considered bad style.

## Thanks

A special thanks goes to [Sean Cribs](https://github.com/seancribbs), [Asmod4n](https://github.com/Asmod4n),
[Beth](https://github.com/bethesque) and the other kind folks at [webmachine-ruby](https://github.com/seancribbs/webmachine-ruby)
who answered my many questions and helped me out alot. All in all this has been great fun.

## References

Here is a list of various references that helped me very much:

* [Aptible::Auth](https://github.com/aptible/aptible-auth-ruby)
* [HAL-browser](https://github.com/mikekelly/hal-browser)
* [HTTP 1.1 Headers Status](http://upload.wikimedia.org/wikipedia/commons/8/88/Http-headers-status.png)
* [HyperResource](https://github.com/gamache/hyperresource)
* [Pact Broker](https://github.com/bethesque/pact_broker)
* [ROAR](https://github.com/apotonick/roar)
* [Webmachine Loves Roar](https://github.com/apotonick/webmachinelovesroar)
* [Webmachine: A Practical Executable Model for HTTP](http://www.infoq.com/presentations/Webmachine-A-Practical-Executable-Model-for-HTTP)
* [Webmachine](https://github.com/seancribbs/webmachine-ruby)

## Author

Kiffin Gish <kiffin.gish@planet.nl>
Gouda, The Netherlands
