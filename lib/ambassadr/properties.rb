module Ambassadr
  class Properties

    DEFAULT_PATH = '/properties/shared'

    attr_reader :path

    def initialize(path = ENV['PROPERTIES_PATH'])
      @path = path || DEFAULT_PATH
    end

    def inject_into(obj = {}, &block)
      if block
        properties.each { |key, val| block.call(obj, key, val) }
        obj
      else
        obj.merge! properties
      end
    end

    def set(key, value, options = {})
      etcd.set("#{path}/#{key}", options.merge(value: value))
      true
    rescue
      false
    end

    def get(key)
      etcd.get("#{path}/#{key}").value
    end

    def properties
      @properties ||= extract({}, values)
    end

    def values
      @get ||= etcd.get(path, recursive: true)
    rescue Etcd::KeyNotFound
      []
    end

    private

    def parse(key)
      key.gsub("#{path}/", '')
    end

    def extract(memo, child)
      if child.directory?
        child.children.reduce(memo, &method(:extract))
      else
        memo[parse child.key] = child.value
      end
    rescue
      {}
    else
      memo
    end

    def etcd
      Ambassadr.etcd
    end

  end
end
