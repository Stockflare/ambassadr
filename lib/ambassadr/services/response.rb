require 'hashie'

module Ambassadr
  class Services
    class Response < Hash

      include Hashie::Extensions::Coercion

      include Hashie::Extensions::MethodAccess

      coerce_value Hash, Response

      coerce_value Array, Array[Response]

      def initialize(hash = {})
        super
        hash.each_pair { |k,v| self[k] = v }
      end

    end
  end
end
