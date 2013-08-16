# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'webrick/route_servlet/version'

Gem::Specification.new do |spec|
  spec.name          = "webrick-route_servlet"
  spec.version       = WEBrick::RouteServlet::VERSION
  spec.authors       = ["Yoshida Tetsuya"]
  spec.email         = ["yoshida.eth0@gmail.com"]
  spec.description   = %q{WEBrick::RouteServlet is like a Rails routes.rb.}
  spec.summary       = %q{WEBrick::RouteServlet is like a Rails routes.rb. This servlet recognizes URLs and dispatches them to another servlet.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
