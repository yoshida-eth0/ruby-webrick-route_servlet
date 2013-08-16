#!/usr/bin/ruby

$LOAD_PATH << File.expand_path("../lib", File.dirname(__FILE__))

require 'webrick'
require 'webrick/route_servlet'
require 'json'

class IndexServlet < WEBrick::HTTPServlet::AbstractServlet
  def do_GET(req, res)
    res.content_type = "text/html"
    res.body = "<h2>IndexServlet</h2>"
    res.body += "<h4>XxxApiServlet:</h4>"
    res.body += "<a href='/api/people/@me/@frields'>/api/people/@me/@frields</a><br />"
    res.body += "<a href='/api/no/match/api'>/api/no/match/api</a><br />"
    res.body += "<br />"
    res.body += "<h4>NotFoundServlet:</h4>"
    res.body += "<a href='/no/match/path'>/no/match/path</a><br />"
  end
end

class NotFoundServlet < WEBrick::HTTPServlet::AbstractServlet
  def do_GET(req, res)
    res.content_type = "text/html"
    res.body = "<h2>NotFoundServlet</h2>"
    res.body += "<p>path: #{req.params["path"]}</p>"
    res.body += "<a href='/'>index</a>"
  end
end

class PeopleApiServlet < WEBrick::HTTPServlet::AbstractServlet
  def do_GET(req, res)
    res.content_type = "text/plain"
    res.body = JSON.pretty_generate({
      "servlet" => self.class.name,
      "guid" => req.params["guid"],
      "selector" => req.params["selector"],
    })
  end
end

class NotFoundApiServlet < WEBrick::HTTPServlet::AbstractServlet
  def do_GET(req, res)
    res.content_type = "text/plain"
    res.body = JSON.pretty_generate({
      "servlet" => self.class.name,
      "path" => req.params["path"],
    })
  end
end

server = WEBrick::HTTPServer.new(:Port=>3000)
server.mount("/", WEBrick::RouteServlet.servlet{|s|
  s.root IndexServlet
  s.match "/*path", NotFoundServlet
})
server.mount("/api", WEBrick::RouteServlet.servlet{|s|
  s.match "/people/:guid/:selector", PeopleApiServlet
  s.match "/*path", NotFoundApiServlet
})
server.start
