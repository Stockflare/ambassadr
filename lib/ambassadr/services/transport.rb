module Ambassadr
  class Services
    class Transport

      def initialize(path, body = {}, opts = {}, &block)
        block.call response if block
      end

    end
  end
end
