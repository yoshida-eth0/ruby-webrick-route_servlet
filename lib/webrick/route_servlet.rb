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
      if e
        # default 500
        res.body = "<h2>#{e.class}: #{e.message}</h2>\n<pre>#{e.backtrace.join("\n")}</pre>"
      else
        # routing error
        res.body = "RoutingError: #{req.request_method} #{req.path_info}"
      end
    end

    def select_route(req)
      req_method = req.request_method.to_sym
      if req.query["_method"]
        req_method = req.query["_method"].upcase.to_sym
      end

      self.class.routes.each do |method, re, servlet, servlet_options, request_options|
        if method==:* || method==req_method
          md = re.match(req.path_info)
          if md
            # path params
            params = Hash[md.names.map(&:to_sym).zip(md.captures)]

            # default params
            defaults = request_options[:defaults] || request_options
            params.each do |k,v|
              if v.nil?
                params[k] = defaults[k]
              end
            end

            # set
            req.action = params[:action] || request_options[:action]
            req.params = params

            # advanced constraints
            constraints = request_options[:constraints]
            if constraints.respond_to?(:matches?)
              next unless constraints.matches?(req)
            end

            return [servlet, servlet_options]
          end
        end
      end
      nil
    end

    module ClassMethods
      def match(re, servlet, *servlet_options, **request_options)
        @routes ||= []
        re = _normalize_path_re(re, request_options)
        _select_via(request_options).each do |via|
          @routes << [via, re, servlet, servlet_options, request_options]
        end
      end

      def root(servlet, *servlet_options, **request_options)
        @routes ||= []
        @routes.unshift([:*, _normalize_path_re("/", request_options), servlet, servlet_options, request_options])
      end

      ["get", "post", "patch", "put", "delete"].each do |method|
        class_eval %{
          def #{method}(re, servlet, *servlet_options, **request_options)
            @routes ||= []
            @routes << [:#{method.upcase}, _normalize_path_re(re, request_options), servlet, servlet_options, request_options]
          end
        }
      end

      def resources(re, servlet, *servlet_options, **request_options)
        re = re.to_s.sub(%r#/$#, "")

        actions = {
          :index   => [:get,    "#{re}(.:format)"],
          :create  => [:post,   "#{re}(.:format)"],
          :new     => [:get,    "#{re}/new(.:format)"],
          :edit    => [:get,    "#{re}/:id/edit(.:format)"],
          :show    => [:get,    "#{re}/:id(.:format)"],
          :update  => [:put,    "#{re}/:id(.:format)"],
          :destroy => [:delete, "#{re}/:id(.:format)"],
        }
        _select_rest_actions(actions, request_options)

        actions.each do |action, (method, re)|
          send(method, re, servlet, *servlet_options, request_options.merge({:action => action}))
        end
      end

      def resource(re, servlet, *servlet_options, **request_options)
        re = re.to_s.sub(%r#/$#, "")

        actions = {
          :create  => [:post,   "#{re}(.:format)"],
          :new     => [:get,    "#{re}/new(.:format)"],
          :edit    => [:get,    "#{re}/edit(.:format)"],
          :show    => [:get,    "#{re}(.:format)"],
          :update  => [:put,    "#{re}(.:format)"],
          :destroy => [:delete, "#{re}(.:format)"],
        }
        _select_rest_actions(actions, request_options)

        actions.each do |action, (method, re)|
          send(method, re, servlet, *servlet_options, request_options.merge({:action => action}))
        end
      end

      def routes
        @routes ||= []
      end

      def _normalize_path_re(re, request_options)
        unless Regexp===re
          # normalize slash
          re = re.to_s.gsub(%r#/{2,}#, "/")

          # escape
          re = re.gsub(/([\.\-?*+\\^$])/, '\\\\\1')

          # start end regexp
          re = re.sub(%r#^/?#, "^/").sub(%r#/?$#, '/?$')

          # normalize parentheses
          re = re.gsub(")", ")?")

          # constrain named capture ':'
          constraints = request_options[:constraints] || request_options
          keys = re.scan(%r#:([^/()\.]+)#).map(&:first).sort{|a,b| b.length <=> a.length}
          keys.each do |key|
            value_re = Regexp.new("(?<#{key}>[^/]+?)")
            if constraints.respond_to?(:[]) && Regexp===constraints[key.to_sym]
              value_re = /(?<#{key}>#{constraints[key.to_sym]})/
            end
            re = re.gsub(":#{key}", value_re.to_s)
          end

          # constrain named capture '*'
          keys = re.scan(%r#\\\*([^/()\.]+)#).map(&:first).sort{|a,b| b.length <=> a.length}
          keys.each do |key|
            value_re = Regexp.new("(?<#{key}>.+?)")
            if constraints.respond_to?(:[]) && Regexp===constraints[key.to_sym]
              value_re = /(?<#{key}>#{constraints[key.to_sym]})/
            end
            re = re.gsub("\\*#{key}", value_re.to_s)
          end

          re = Regexp.new(re)
        end
        re
      end
      private :_normalize_path_re

      def _select_via(request_options)
        via = request_options[:via] || :*
        via = [via].flatten
        via.map(&:to_sym).map(&:upcase)
      end
      private :_select_via

      def _select_rest_actions(actions, request_options)
        # only
        if request_options[:only]
          only = request_options[:only]
          only = [only].flatten
          actions.select!{|k,v| only.include?(k)}
        end

        # except
        if request_options[:except]
          except = request_options[:except]
          except = [except].flatten
          actions.delete_if{|k,v| except.include?(k)}
        end

        actions
      end
      private :_select_rest_actions
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
