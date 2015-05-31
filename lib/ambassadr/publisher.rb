module Ambassadr
  class Publisher

    attr_reader :options

    def initialize(options = {})
      @options = options
    end

    def publish(container)
      raise TypeError unless arg.is_a? Container
    end

    private

    def prefix
      '/services'
    end

  end
end
