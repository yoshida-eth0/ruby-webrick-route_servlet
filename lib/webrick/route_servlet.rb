require 'webrick'
require 'webrick/route_servlet/http_request'
require "webrick/route_servlet/version"

module WEBrick
  module RouteServlet
    def service(req, res)
      e = nil

      servlet, options, status = select_route(req)

      if servlet
        # 200 or 404
        begin
          res.status = status
          servlet.get_instance(@config, *options).service(req, res)
          return
        rescue Exception => e
        end
      end

      # 500
      res.status = 500
      if self.class.route500
        begin
          self.class.route500.get_instance(@config).servlet(req, res)
          return
        rescue Exception => e
        end
      end

      if e
        # default 500
        res.body = "<h2>#{e.class}: #{e.message}</h2>\n<pre>#{e.backtrace.join("\n")}</pre>"
      else
        # routing error
        res.body = "RoutingError: #{req.path_info}"
      end
    end

    def select_route(req)
      self.class.routes.each do |re, servlet, options|
        md = re.match(req.path_info)
        if md
          req.extend WEBrick::RouteServlet::HTTPRequest
          req.params = md
          return [servlet, options, 200]
        end
      end
      nil
    end

    module ClassMethods
      attr_accessor :route500

      def match(re, servlet, *options)
        @routes ||= []
        @routes << [normalize_path_re(re), servlet, options]
      end

      def root(servlet, *options)
        @routes ||= []
        @routes.unshift([normalize_path_re("/"), servlet, *options])
      end

      def normalize_path_re(re)
        unless Regexp===re
          re = re.to_s.gsub(%r#/{2,}#, "/").sub(%r#^/?#, "^/").sub(%r#/?$#, '/?$')
          re = re.gsub(%r#/:([^/]+)#, '/(?<\1>[^/]+)')
          re = re.gsub(%r#/\*([^/]+)#, '/(?<\1>.+?)')
          re = Regexp.new(re)
        end
        re
      end

      def routes
        @routes || []
      end
    end

    class << self
      def servlet
        servlet = Class.new(WEBrick::HTTPServlet::AbstractServlet)
        servlet.send(:include, RouteServlet)
        yield servlet if block_given?
        servlet
      end

      def included(klass)
        klass.extend ClassMethods
      end
    end
  end
end
