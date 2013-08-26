module WEBrick
  module RouteServlet
    class ActionServlet < WEBrick::HTTPServlet::AbstractServlet
      def service(req, res)
        action = req.params[:action] rescue ""
        action ||= ""

        if respond_to?(action)
          send(action, req, res)
        else
          raise RuntimeError, "action is not implemented: #{self.class}##{action}"
        end
      end
    end
  end
end
