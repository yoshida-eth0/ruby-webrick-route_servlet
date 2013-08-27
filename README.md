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
      s.match "/:controller(/:action(/:id))(.:format)", ActionServlet
      s.match "/*path", NotFoundServlet
    })
    server.start

## Example

https://github.com/yoshida-eth0/ruby-webrick-route_servlet/tree/master/example

## Supported methods

match

    s.match "/:controller(/:action(/:id))(.:format)", ActionServlet
    s.match "/*path", NotFoundServlet

root

    s.root IndexServlet

resources

    s.resources "/photos", PhotoServlet

resource

    s.resource "/profile", ProfileServlet

get / post / patch / put / delete

    s.get "/photos", PhotoServlet
    s.post "/photos", PhotoServlet
    s.patch "/photos", PhotoServlet
    s.put "/photos/123", PhotoServlet
    s.delete "/photos/123", PhotoServlet

## Supported options

via

    s.match "/photos/show", PhotoServlet, :via => :get
    s.match "/photos/show", PhotoServlet, :via => [:get, :post]

constraints

    s.match "/photos/:id", PhotoServlet, :constraints => { :id => /[A-Z]\d{5}/ }
    s.match "/photos/:id", PhotoServlet, :id => /[A-Z]\d{5}/
    s.match "/photos/:id", PhotoServlet, :constraints => PhotoConstraint.new
    
    class PhotoConstraint
      def matches?(req)
        /[A-Z]\d{5}/===req.params[:id]
      end
    end

only / except

    s.resources "/photo", PhotoServlet, :only => [:index]
    s.resources "/photo", PhotoServlet, :except => [:index, :show]

defaults

    s.match "/photos/:id(.:format)", PhotoServlet, :defaults => { :format => "json" }
    s.match "/photos/:id(.:format)", PhotoServlet, :format => "json"

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
