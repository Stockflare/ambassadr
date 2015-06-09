require 'docker'

module Ambassadr
  class Container

    attr_reader :ident

    def initialize(ident = nil)
      @ident ||= ident || hostname
    end

    def services
      if (mapped = mapped_services).any?
        Hash[mapped]
      else
        {}
      end
    rescue
      raise "error determining services to ambassador"
    end

    def host
      @host ||= label_for :host
    rescue
      '0.0.0.0'
    end

    def ports
      @ports ||= Hash[json['NetworkSettings']['Ports'].map do |key, val|
        service_port = key.match(/[0-9]{4,}/).to_s
        begin
          [service_port, v[0]['HostPort']]
        rescue
          [service_port, nil]
        end
      end]
      @ports
    end

    def hostname
      `hostname`.strip
    end

    private

    def mapped_services
      services = labels.keep_if { |key| key.to_s.match(/\Aambassadr\.services\..+\Z/i) }
      services.map do |label, val|
        if port = ports[parse_val(val)]
          [label.gsub(/\Aambassadr\.services\./, '').gsub('.','/'), port]
        else
          nil
        end
      end.compact!
    end

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
    end

    def labels
      json['Config']['Labels']
    end

    def envs
      json['Config']['Env']
    end

  end
end
