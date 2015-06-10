module Ambassadr
  class Services

    autoload :Mapper, 'ambassadr/services/mapper'
    autoload :Transport, 'ambassadr/services/transport'

    include Mapper

  end
end
