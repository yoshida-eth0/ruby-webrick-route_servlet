#!/usr/bin/ruby

$LOAD_PATH << File.expand_path("../lib", File.dirname(__FILE__))

require 'webrick'
require 'webrick/route_servlet'

class IndexServlet < WEBrick::HTTPServlet::AbstractServlet
  def do_GET(req, res)
    res.content_type = "text/html"
    res.body = "<h2>IndexServlet</h2>"
    res.body += "<h4>PageServlet:</h4>"
    3.times {
      page = ("a".."z").to_a.shuffle[0..7].join
      res.body += "<a href='/#{page}'>/#{page}</a><br />"
    }
    res.body += "<br />"
    res.body += "<h4>NotFoundServlet:</h4>"
    res.body += "<a href='/no/match/path'>/no/match/path</a><br />"
  end
end

class PageServlet < WEBrick::HTTPServlet::AbstractServlet
  def do_GET(req, res)
    res.content_type = "text/html"
    res.body = "<h2>PageServlet</h2>"
    res.body += "<p>page: #{req.params["page"]}</p>"
    res.body += "<a href='/'>index</a>"
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

server = WEBrick::HTTPServer.new(:Port=>3000)
server.mount("/", WEBrick::RouteServlet.servlet{|s|
  s.root IndexServlet
  s.match "/:page", PageServlet
  s.match "/*path", NotFoundServlet
})
server.start
