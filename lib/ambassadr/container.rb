require 'docker'

module Ambassadr
  class Container

    attr_reader :ident

    def initialize(ident = nil)
      @ident ||= ident || hostname
    end

    def service
      label_for :service
    rescue
      "default"
    end

    def host
      label_for :host
    rescue
      "localhost"
    end

    def ports
      @ports ||= port_json.values.collect { |port| port[0]['HostPort'].to_i }
    end

    def hostname
      `hostname`.strip
    end

    private

    def container
      @container ||= Docker::Container.get ident
    end

    def port_json
      json['NetworkSettings']['Ports']
    rescue
      {}
    end

    def json
      container.json
    rescue
      {}
    end

    def labels
      @labels ||= json['Config']['Labels']
    end

    def label_for(key)
      if val = labels["ambassadr.#{key}"]
        send(*val.split(':'))
      else
        raise "missing #{key} label"
      end
    end

    def env(key)
      envs = json['Config']['Env']
      key, val = envs[envs.index { |i| i.match key.upcase }].split('=')
      val
    end

    def val(str)
      str
    end

  end
end
