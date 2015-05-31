require 'docker'

module Ambassadr
  class Container

    def initialize
    end

    def service

    end

    def name

    end

    def ports

    end

    private

    def container
      Docker::Container.get hostname
    end

    def hostname
      @hostname ||= `hostname`.strip
    end

  end
end
