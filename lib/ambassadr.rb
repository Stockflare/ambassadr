require 'ambassadr/version'
require 'ambassadr/container'
require 'ambassadr/publisher'
require 'ambassadr/properties'

require 'etcd'
require 'docker'

module Ambassadr

  def self.docker_url(url = "")
    Docker.url = url
  end

  def self.etcd(options = {})
    @etcd ||= Etcd.client options
  end

  def self.env!
    Properties.new(ENV['PROPERTIES_PATH']).inject_into ENV do |obj, key, val|
      obj[key.gsub('/', '_').upcase]
    end
  end

  def self.publish!
    Publisher.new(ENV['PUBLISHER_PATH']).publish Container.new
  end

end
