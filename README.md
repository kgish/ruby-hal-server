# Webmachine/ROAR Server Template

This is a basic server template for setting up a simple application to show how 
[webmachine](https://github.com/seancribbs/webmachine-ruby) and [roar](https://github.com/apotonick/roar)
can work together to build real RESTful systems in Ruby.

Roar comes with built-in JSON, JSON-HAL, JSON-API and XML support.

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

### Server

You can now start the webmachine-roar server using defaults WEBrick and port 8080:

    $ bundle exec ruby server.rb
    INFO  WEBrick 1.3.1
    INFO  ruby 2.1.5 (2014-11-13) [x86_64-linux]
    INFO  Webmachine::Adapters::WEBrick::Server#start: pid=13513 port=8080

### Monitor

You can now fire up the monitor by running the following command:

    $ bundle exec ruby monitor-products.rb

If everything is working according to plan you should see something like this:

    57 | 0.0.0.0 | 8080 | products | Webmachine-Ruby/0.3.0 WEBrick/1.3.1 | 200 | OK

    #	id	name	price	category
    -	--	----	-----	--------
    1	1	pizza	500	    food
    2	2	shoes	2000	clothing
    3	3	laptop	500000	computer

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

## Thanks

A special thanks goes to [Sean Cribs](https://github.com/seancribbs), [Asmod4n](https://github.com/Asmod4n),
[Beth](https://github.com/bethesque) and the other kind folks at [webmachine-ruby](https://github.com/seancribbs/webmachine-ruby)
who answered my many questions and helped me out alot.

## References

Here is a list of various references that helped me very much:

* [Webmachine](https://github.com/seancribbs/webmachine-ruby)
* [ROAR](https://github.com/apotonick/roar)
* [Webmachine Loves Roar](https://github.com/apotonick/webmachinelovesroar)
* [Pact Broker](https://github.com/bethesque/pact_broker)
* [HyperResource](https://github.com/gamache/hyperresource)
* [Aptible::Auth](https://github.com/aptible/aptible-auth-ruby)
* [HTTP 1.1 Headers Status](http://upload.wikimedia.org/wikipedia/commons/8/88/Http-headers-status.png)
* [Webmachine: A Practical Executable Model for HTTP](http://www.infoq.com/presentations/Webmachine-A-Practical-Executable-Model-for-HTTP)

## Author

Kiffin Gish <kiffin.gish@planet.nl>

