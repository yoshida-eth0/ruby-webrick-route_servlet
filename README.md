# WEBrick::RouteServlet

WEBrick::RouteServlet is like a Rails routes.rb.
This servlet recognizes URLs and dispatches them to another servlet.

## Installation

Add this line to your application's Gemfile:

    gem 'webrick-route_servlet'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install webrick-route_servlet

## Usage

    server = WEBrick::HTTPServer.new(:Port=>3000)
    server.mount("/", WEBrick::RouteServlet.servlet{|s|
      s.root IndexServlet
      s.match "/:page", PageServlet
      s.match "/*path", NotFoundServlet
    })
    server.start

## Example

https://github.com/yoshida-eth0/ruby-webrick-route_servlet/tree/master/example

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
