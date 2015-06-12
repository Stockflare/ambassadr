module Ambassadr
  class Services

    autoload :Mapper, 'ambassadr/services/mapper'
    autoload :Transport, 'ambassadr/services/transport'
    autoload :Response, 'ambassadr/services/response'

    include Mapper

  end
end
