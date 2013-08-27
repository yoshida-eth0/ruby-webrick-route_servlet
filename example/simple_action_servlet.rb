#!/usr/bin/ruby

$LOAD_PATH << File.expand_path("../lib", File.dirname(__FILE__))

require 'webrick'
require 'webrick/route_servlet'

class IndexServlet < WEBrick::HTTPServlet::AbstractServlet
  def do_GET(req, res)
    res.content_type = "text/html"
    res.body = "<h2>IndexServlet</h2>\n"
    res.body += "<h4>UserServlet:</h4>\n"
    res.body += create_link("GET", "/users", "index")
    res.body += create_link("POST", "/users", "create")
    res.body += create_link("GET", "/users/new", "new")
    res.body += create_link("GET", "/users/1/edit", "edit")
    res.body += create_link("GET", "/users/1", "show")
    res.body += create_link("PUT", "/users/1", "update")
    res.body += create_link("DELETE", "/users/1", "destroy")
    res.body += "<br />"
    res.body += "<h4>NotFoundServlet:</h4>"
    res.body += "<a href='/no/match/path/route'>/no/match/path/route</a><br />"
  end

  def create_link(method, path, action)
    method2 = method=="GET" ? "GET" : "POST"
    "<form action='#{path}' method='#{method2}'>\n" +
    "<input type='hidden' name='_method' value='#{method}' />\n" +
    "<input type='submit' value='#{method} #{path} => #{action}' />\n" +
    "</form>\n"
  end
end

class UserServlet < WEBrick::RouteServlet::ActionServlet
  def index(req, res)
    res.content_type = "text/html"
    res.body = "<h2>RestServlet#index</h2>\n"
    res.body += "<p>action: #{req.action}</p>\n"
    res.body += "<p>params: #{req.params}</p>\n"
    res.body += "<p><a href='/'>index</a></p>\n"
  end

  def create(req, res)
    res.content_type = "text/html"
    res.body = "<h2>RestServlet#create</h2>\n"
    res.body += "<p>action: #{req.action}</p>\n"
    res.body += "<p>params: #{req.params}</p>\n"
    res.body += "<p><a href='/'>index</a></p>\n"
  end

  def new(req, res)
    res.content_type = "text/html"
    res.body = "<h2>RestServlet#new</h2>\n"
    res.body += "<p>action: #{req.action}</p>\n"
    res.body += "<p>params: #{req.params}</p>\n"
    res.body += "<p><a href='/'>index</a></p>\n"
  end

  def edit(req, res)
    res.content_type = "text/html"
    res.body = "<h2>RestServlet#edit</h2>\n"
    res.body += "<p>action: #{req.action}</p>\n"
    res.body += "<p>params: #{req.params}</p>\n"
    res.body += "<p><a href='/'>index</a></p>\n"
  end

  def show(req, res)
    res.content_type = "text/html"
    res.body = "<h2>RestServlet#show</h2>\n"
    res.body += "<p>action: #{req.action}</p>\n"
    res.body += "<p>params: #{req.params}</p>\n"
    res.body += "<p><a href='/'>index</a></p>\n"
  end

  def update(req, res)
    res.content_type = "text/html"
    res.body = "<h2>RestServlet#update</h2>\n"
    res.body += "<p>action: #{req.action}</p>\n"
    res.body += "<p>params: #{req.params}</p>\n"
    res.body += "<p><a href='/'>index</a></p>\n"
  end

  def destroy(req, res)
    res.content_type = "text/html"
    res.body = "<h2>RestServlet#destroy</h2>\n"
    res.body += "<p>action: #{req.action}</p>\n"
    res.body += "<p>params: #{req.params}</p>\n"
    res.body += "<p><a href='/'>index</a></p>\n"
  end
end

class NotFoundServlet < WEBrick::HTTPServlet::AbstractServlet
  def do_GET(req, res)
    res.content_type = "text/html"
    res.body = "<h2>NotFoundServlet</h2>"
    res.body += "path: #{req.params[:path]}"
    res.body += "<p><a href='/'>index</a></p>"
  end

  def do_POST(req, res)
    do_GET(req, res)
  end
end

server = WEBrick::HTTPServer.new(:Port=>3000)
server.mount("/", WEBrick::RouteServlet.servlet{|s|
  s.root IndexServlet
  s.resources "/users", UserServlet
  s.match "/*path", NotFoundServlet
})
server.start
