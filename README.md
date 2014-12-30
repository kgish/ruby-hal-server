# Webmachine/ROAR Server Template

This is a basic server template for setting up a simple application to show how 
[webmachine](https://github.com/seancribbs/webmachine-ruby) and [roar](https://github.com/apotonick/roar)
can work together to build real RESTful systems in Ruby.

Roar comes with built-in JSON, JSON-HAL, JSON-API and XML support.

## HAL/JSON Web API

Here is an explanation about the Web API

## Installation

In order to install and run the webmachine, run the following commands.

    $ git clone https://github.com/kgish/ruby-webmachine-roar-template.git webmachine-roar
    $ cd webmachine-roar
    $ bundle install

Run the server using defaults WEBrick and port 8080:

    $ bundle exec ruby server.rb
    INFO  WEBrick 1.3.1
    INFO  ruby 2.1.5 (2014-11-13) [x86_64-linux]
    INFO  Webmachine::Adapters::WEBrick::Server#start: pid=13513 port=8080

Run the monitor:

    $ bundle exec ruby monitor-products.rb

If everything is working according to plan you should see something like this:

    57 | 0.0.0.0 | 8080 | products | Webmachine-Ruby/0.3.0 WEBrick/1.3.1 | 200 | OK

    #	id	name	price	category
    -	--	----	-----	--------
    1	1	pizza	500	food
    2	2	shoes	2000	clothing
    3	3	laptop	500000	computer

    CTRL-C to exit

Create your first product:

    $ bundle exec ruby create-product.rb --name=kiffin --category=person --price=1234

You should then see something like this:

    75 | 0.0.0.0 | 8080 | products | Webmachine-Ruby/0.3.0 WEBrick/1.3.1 | 200 | OK

    #	id	name	price	category
    -	--	----	-----	--------
    1	1	pizza	500	food
    2	2	shoes	2000	clothing
    3	3	laptop	500000	computer
    4	4	kiffin	1234	person

    CTRL-C to exit

## Thanks

A special thanks goes to [Sean Cribs](https://github.com/seancribbs) and the other kind folks at [webmachine-ruby github](https://github.com/seancribbs/webmachine-ruby) who answered my bothersome
questions and helped me out alot.

## References

Here is a list of various references that helped me very much:

* [Webmachine](https://github.com/seancribbs/webmachine-ruby)
* [ROAR](https://github.com/apotonick/roar)
* [Webmachine Loves Roar](https://github.com/apotonick/webmachinelovesroar)
* [Pact Broker](https://github.com/bethesque/pact_broker)
* [HyperResource](https://github.com/gamache/hyperresource)
* [HTTP 1.1 Headers Status](http://upload.wikimedia.org/wikipedia/commons/8/88/Http-headers-status.png)

## Author

Kiffin Gish <kiffin.gish@planet.nl>

