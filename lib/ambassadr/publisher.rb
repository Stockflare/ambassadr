module Ambassadr
  class Publisher

    DEFAULT_PATH = '/services'

    TTL = 30

    attr_reader :properties, :container

    def initialize(container, path = ENV['PUBLISHER_PATH'])
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
      container.services.each { |name, port| publish_service(name, port) }
    end

    private

    def publish_service(name, port)
      properties.set key(name), value(port), ttl: TTL if port
    end

    def key(name)
      "#{name}/#{container.hostname}"
    end

    def value(port)
      "#{container.host}:#{port}"
    end

  end
end
