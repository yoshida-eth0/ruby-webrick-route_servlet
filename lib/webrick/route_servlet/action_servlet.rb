module WEBrick
  module RouteServlet
    class ActionServlet < WEBrick::HTTPServlet::AbstractServlet
      def service(req, res)
        if respond_to?(req.action)
          send(req.action, req, res)
        else
          raise RuntimeError, "action is not implemented: #{self.class}##{req.action}"
        end
      end
    end
  end
end
