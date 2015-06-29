module Ambassadr
  class Services
    module Errors
      # This class represents an error that is raised when a HTTP request, via
      # the {Transport} class results in a status code outside of the 2xx range.
      #
      # It provides helpful comparators, facilitating easy and intuitive decision
      # path making within the rescue block, for a range of HTTP requests.
      #
      # @example Rescuing a failed user creation
      #
      #   class User
      #     def register(attributes = {})
      #       Services::User.create(attributes)
      #     rescue error => Ambassadr::Services::Errors::HttpError
      #       case error
      #       when 422
      #         # terrible example but you get the picture...
      #         if error.response.error == 'validation'
      #           attributes[:email].downcase!
      #           retry
      #         else
      #           raise "there was a validation error"
      #         end
      #       when 500..503
      #         sleep 10
      #         retry
      #       else
      #         raise "user could not be created"
      #       end
      #     end
      #   end
      class HttpError < StandardError

        include Comparable

        attr_reader :http

        def initialize(http)
          @http = http
        end

        def status
          http.status
        end

        alias_method :code, :status

        alias_method :to_i, :status

        def body
          http.body
        rescue
          ""
        end

        def response
          if !body.empty?
            Response.new json_body
          else
            {}
          end
        end

        def <=>(other)
          status <=> other
        end

        alias_method :===, :==

        private

        def json_body
          JSON.parse(body)
        rescue
          {}
        end

      end
    end
  end
end
