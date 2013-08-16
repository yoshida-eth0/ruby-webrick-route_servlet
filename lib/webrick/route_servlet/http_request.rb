module WEBrick
  module RouteServlet
    module HTTPRequest
      def params
        @params
      end

      def params=(params)
        @params = params
      end
    end
  end
end
