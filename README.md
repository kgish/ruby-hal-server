# Webmachine/ROAR Server Template

[***Note***: A newer version (which works with the [HAL Browser](http://haltalk.herokuapp.com/explorer/browser.html#/)) can be found [here](https://github.com/kgish/ruby-webmachine-roar-template/tree/webmachine-and-roar-update-attempt),
however for the time being the [demo client](https://github.com/kgish/ember-hal-template) will only work with this version]

This is a basic server template for setting up a simple application to show how 
[webmachine](https://github.com/seancribbs/webmachine-ruby) and [roar](https://github.com/apotonick/roar)
can work together to build real RESTful systems in Ruby.

Roar comes with built-in JSON, JSON-HAL, JSON-API and XML support. This can be demoed as-is with 
the [Ember HAL Template](https://github.com/kgish/ember-hal-template) client.

This has been tested and verified with the [HAL-browser](https://github.com/mikekelly/hal-browser).

This can be demoed as-is with the [Ember HAL Template](https://github.com/kgish/ember-hal-template) client.

![](images/screenshot-monitor.png?raw=true)

## HAL/JSON Web API

Here is an explanation about the Web API.

    [:host] = hostname of api server, default `127.0.0.1`
    [:port] = port used by api server, default `8080`
    [:resource] = one of `%w{products users sessions}`
    [:id] = resource id
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
about the api service can be obtained.

![](images/screenshot-postman-root.png?raw=true)

## Installation

In order to install and run the webmachine, run the following commands.

    $ git clone https://github.com/kgish/ruby-webmachine-roar-template.git \
        webmachine-roar
    $ cd webmachine-roar
    $ bundle install

### API Server

You can now start the webmachine-roar api server using defaults WEBrick and port 8080:

    $ bundle exec ruby api-server.rb
    INFO  WEBrick 1.3.1
    INFO  ruby 2.1.5 (2014-11-13) [x86_64-linux]
    INFO  Webmachine::Adapters::WEBrick::Server#start: pid=13513 port=8080

### Monitor

You can now fire up the monitor by running the following command:

    $ bundle exec ruby api-monitor-products.rb

If everything is working according to plan you should see something like this:

    57 | 0.0.0.0 | 8080 | products | Webmachine-Ruby/0.3.0 WEBrick/1.3.1 | 200 | OK

    #	id	name	price	category
    -	--	----	-----	--------
    1	1	pizza	500	    food
    2	2	shoes	2000	clothing
    3	3	laptop	500000	computer

#### Usage

    USAGE:

        api-monitor [OPTIONS]

    DESCRIPTION:

        Monitors the list or products for the given api server by looping through
        the following HTTP request:

        GET /products

        Once started hit CTRL-C to exit from the loop.

    OPTIONAL PARAMETERS:

        --help, -h
          show this help screen

        --auth, -a username:password
          basic authorization string (both username and password required)

        --url, -u hostname[:port]
          destination of request (default 0.0.0.0:8080)

    EXAMPLES:

        api-monitor
        api-monitor --url=localhost:8080
        api-monitor --auth=kiffin:pindakaas

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
        following HTTP request to the given api server:

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
          basic authorization string (both username and password required)

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
        following HTTP request to the given api server:

          GET /products/id

      REQUIRED PARAMETERS:

        --id n
          product id (number)

      OPTIONAL PARAMETERS:

        --help, -h
          show this help screen

        --auth, -a username:password
          basic authorization string (both username and password required)

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
        following HTTP request to the given api server:

          DELETE /products/id

      REQUIRED PARAMETERS:

        --id n
          product id (number)

      OPTIONAL PARAMETERS:

        --help, -h
          show this help screen

        --auth, -a username:password
          basic authorization string (both username and password required)

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
        following HTTP request to the given api server:

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
          basic authorization string (both username and password required)

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

    $ bundle exec ruby api-autodiscover.rb

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

## HAL Compatibility

This has been tested and verified with the [HAL-browser](https://github.com/mikekelly/hal-browser). It should also
work seamlessly with the [HyperResource gem](https://github.com/gamache/hyperresource).

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

