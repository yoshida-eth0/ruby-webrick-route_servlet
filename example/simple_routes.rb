#!/usr/bin/ruby

$LOAD_PATH << File.expand_path("../lib", File.dirname(__FILE__))

require 'webrick'
require 'webrick/route_servlet'

class IndexServlet < WEBrick::HTTPServlet::AbstractServlet
  def do_GET(req, res)
    res.content_type = "text/html"
    res.body = "<h2>IndexServlet</h2>"
    res.body += "<h4>ActionServlet:</h4>"
    3.times {
      controller = ["/users", "/posts"].shuffle[0]
      action = rand(3)==0 ? "" : ["/show", "/edit"].shuffle[0]
      id = action.empty? || rand(3)==0 ? "" : "/#{rand(255)+1}"
      format = [".html", ""].shuffle[0]
      path = controller + action + id + format
      res.body += "<a href='#{path}'>#{path}</a><br />"
    }
    res.body += "<br />"
    res.body += "<h4>NotFoundServlet:</h4>"
    res.body += "<a href='/no/match/path/route'>/no/match/path/route</a><br />"
  end
end

class ActionServlet < WEBrick::HTTPServlet::AbstractServlet
  def do_GET(req, res)
    res.content_type = "text/html"
    res.body = "<h2>PageServlet</h2>"
    res.body += "controller: #{req.params["controller"]}<br />"
    res.body += "action: #{req.params["action"]}<br />"
    res.body += "id: #{req.params["id"]}<br />"
    res.body += "format: #{req.params["format"]}<br />"
    res.body += "<p><a href='/'>index</a></p>"
  end
end

class NotFoundServlet < WEBrick::HTTPServlet::AbstractServlet
  def do_GET(req, res)
    res.content_type = "text/html"
    res.body = "<h2>NotFoundServlet</h2>"
    res.body += "path: #{req.params["path"]}"
    res.body += "<p><a href='/'>index</a></p>"
  end
end

server = WEBrick::HTTPServer.new(:Port=>3000)
server.mount("/", WEBrick::RouteServlet.servlet{|s|
  s.root IndexServlet
  s.match "/:controller(/:action(/:id))(.:format)", ActionServlet
  s.match "/*path", NotFoundServlet
})
server.start
