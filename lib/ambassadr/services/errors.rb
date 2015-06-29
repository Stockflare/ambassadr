module Ambassadr
  class Services
    module Errors

      # Autoload errors that are related to the Ambassadr system, including
      # errors that arise through determining and communicating with other
      # micro-services.

      autoload :NoHostsAvailableError, 'ambassadr/services/errors/no_hosts_available'

      autoload :HostsUnreachableError, 'ambassadr/services/errors/hosts_unreachable'

      autoload :TimeoutError, 'ambassadr/services/errors/timeout'

      # Autoload errors that are related to failing HTTP requests. Most errors
      # can be subsumed by the singular {CodeError} that makes it easy to react
      # to different HTTP Status Code responses.

      autoload :HttpError, 'ambassadr/services/errors/http_error'

    end
  end
end
