require 'docker'

module Ambassadr
  class Container

    attr_reader :ident

    def initialize(ident = nil)
      @ident ||= ident || hostname
    end

    def services
      services = labels.keep_if { |key| key.to_s.match(/\Aambassadr\.services\..+\Z/i) }
      Hash[services.map do |k, v|
        [
          k.gsub(/\Aambassadr\.services\./, '').gsub('.','/'),
          ports[parse_val(v)]
        ]
      end]
    rescue
      raise "error determining services to ambassador"
    end

    def host
      @host ||= label_for :host
    rescue
      '0.0.0.0'
    end

    def ports
      @ports ||= Hash[json['NetworkSettings']['Ports'].map { |k, v| [k, v[0]['HostPort']] }]
    end

    def hostname
      `hostname`.strip
    end

    private

    def label_for(key)
      if val = labels["ambassadr.#{key}"]
        parse_val val
      else
        raise "missing #{key} label"
      end
    end

    def parse_val(val)
      send *val.split(':')
    rescue
      val
    end

    def env(key)
      if env = ENV[key]
        env
      else
        noop, val = envs[envs.index { |i| i.match key.upcase }].split('=')
        val
      end
    end

    def container
      @container ||= Docker::Container.get ident
    end

    def json
      container.json.dup
    rescue
      {}
    end

    def labels
      json['Config']['Labels']
    end

    def envs
      json['Config']['Env']
    end

  end
end
