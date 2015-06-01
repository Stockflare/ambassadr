module Ambassadr
  class Publisher

    DEFAULT_PATH = '/services'

    TTL = 30

    attr_reader :properties, :container

    def initialize(container, path = nil)
      raise TypeError unless container.is_a? Container
      @properties = Properties.new(path || DEFAULT_PATH)
      @container = container
    end

    def publish
      loop do
        publish_once
        sleep (TTL / 3) * 2
      end
    end

    def publish_once
      container.services.each { |k, v| publish_service(k, v) }
    end

    private

    def publish_service(name, port)
      properties.set key(name), value(port), ttl: TTL
    end

    def key(name)
      "#{name}/#{container.hostname}"
    end

    def value(port)
      "#{container.host}:#{port}"
    end

  end
end
