# Webmachine/ROAR Server Template

This is a Simple Server Template for setting up a This is a sample application to show
how [webmachine](https://github.com/seancribbs/webmachine-ruby) and [roar](https://github.com/apotonick/roar)
can work together to build real RESTful systems in Ruby.

Roar comes with built-in JSON, JSON-HAL, JSON-API and XML support.

## HAL/JSON Web API

Here is an explanation about the Web API

## Instructions

Run the server using defaults WEBrick and port 8080:

    $ ruby server.rb
    INFO  WEBrick 1.3.1
    INFO  ruby 2.1.5 (2014-11-13) [x86_64-linux]
    INFO  Webmachine::Adapters::WEBrick::Server#start: pid=13513 port=8080

Run the test client:

    $ ruby client.rb

## References

Here is a list of various references that helped me very much:

* [Webmachine](https://github.com/seancribbs/webmachine-ruby)
* [ROAR](https://github.com/apotonick/roar)
* [Webmachine Loves Roar](https://github.com/apotonick/webmachinelovesroar)
* [HyperResource](https://github.com/gamache/hyperresource).

## Author

Kiffin Gish <kiffin.gish@planet.nl>


