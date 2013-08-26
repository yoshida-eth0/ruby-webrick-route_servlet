require 'webrick'
require 'webrick/route_servlet/http_request'
require 'webrick/route_servlet/action_servlet'
require "webrick/route_servlet/version"

module WEBrick
  module RouteServlet
    def service(req, res)
      e = nil

      req.extend WEBrick::RouteServlet::HTTPRequest
      servlet, servlet_options = select_route(req)

      if servlet
        # 200
        begin
          res.status = 200
          servlet.get_instance(@config, *servlet_options).service(req, res)
          return
        rescue Exception => e
        end
      end

      # 500
      res.status = 500
      if self.class.error500
        begin
          self.class.error500.get_instance(@config).servlet(req, res)
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
      self.class.routes.each do |method, re, servlet, servlet_options, request_options|
        if method==:* || method==req.request_method.to_sym
          md = re.match(req.path_info)
          if md
            params = Hash[md.names.map(&:to_sym).zip(md.captures)]
            params.delete_if{|k,v| v.nil?}
            req.params = request_options.merge(params)
            return [servlet, servlet_options]
          end
        end
      end
      nil
    end

    module ClassMethods
      attr_accessor :error500

      def match(re, servlet, *servlet_options, **request_options)
        @routes ||= []
        @routes << [:*, _normalize_path_re(re), servlet, servlet_options, request_options]
      end

      def root(servlet, *servlet_options, **request_options)
        @routes ||= []
        @routes.unshift([:*, _normalize_path_re("/"), servlet, servlet_options, request_options])
      end

      ["get", "post", "put", "delete"].each do |method|
        class_eval %{
          def #{method}(re, servlet, *servlet_options, **request_options)
            @routes ||= []
            @routes << [:#{method.upcase}, _normalize_path_re(re), servlet, servlet_options, request_options]
          end
        }
      end

      def resources(re, servlet, *servlet_options, **request_options)
        re = re.to_s.sub(%r#/$#, "")
        get    "#{re}(.:format)",          servlet, *servlet_options, request_options.merge({:action => :index})
        post   "#{re}(.:format)",          servlet, *servlet_options, request_options.merge({:action => :create})
        get    "#{re}/new(.:format)",      servlet, *servlet_options, request_options.merge({:action => :new})
        get    "#{re}/:id/edit(.:format)", servlet, *servlet_options, request_options.merge({:action => :edit})
        get    "#{re}/:id(.:format)",      servlet, *servlet_options, request_options.merge({:action => :show})
        put    "#{re}/:id(.:format)",      servlet, *servlet_options, request_options.merge({:action => :update})
        delete "#{re}/:id(.:format)",      servlet, *servlet_options, request_options.merge({:action => :destroy})
      end

      def resource(re, servlet, *servlet_options, **request_options)
        re = re.to_s.sub(%r#/$#, "")
        post   "#{re}(.:format)",      servlet, *servlet_options, request_options.merge({:action => :create})
        get    "#{re}/new(.:format)",  servlet, *servlet_options, request_options.merge({:action => :new})
        get    "#{re}/edit(.:format)", servlet, *servlet_options, request_options.merge({:action => :edit})
        get    "#{re}(.:format)",      servlet, *servlet_options, request_options.merge({:action => :show})
        put    "#{re}(.:format)",      servlet, *servlet_options, request_options.merge({:action => :update})
        delete "#{re}(.:format)",      servlet, *servlet_options, request_options.merge({:action => :destroy})
      end

      def routes
        @routes ||= []
      end

      def _normalize_path_re(re)
        unless Regexp===re
          # normalize slash
          re = re.to_s.gsub(%r#/{2,}#, "/")
          # escape
          re = re.gsub(/([\.\-?*+\\^$])/, '\\\\\1')
          # start end regexp
          re = re.sub(%r#^/?#, "^/").sub(%r#/?$#, '/?$')
          # normalize parentheses
          re = re.gsub(")", ")?")
          # named capture
          re = re.gsub(%r#/:([^/()\.]+)#, '/(?<\1>[^/]+?)')
          re = re.gsub(%r#\.:([^/()\.]+)#, '.(?<\1>[^/]+?)')
          re = re.gsub(%r#/\\\*([^/]+)#, '/(?<\1>.+?)')
          re = Regexp.new(re)
        end
        re
      end
      private :_normalize_path_re
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
