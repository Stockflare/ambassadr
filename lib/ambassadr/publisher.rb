module Ambassadr
  class Publisher

    attr_reader :path

    def initialize(path = nil)
      @path = path || default_path
    end

    def publish(container)
      raise TypeError unless arg.is_a? Container
    end

    private

    def default_path
      '/services'
    end

  end
end
