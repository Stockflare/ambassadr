require 'ambassadr/version'
require 'ambassadr/container'
require 'ambassadr/publisher'
require 'ambassadr/properties'

require 'etcd'
require 'docker'

# Publishes and maintains micro-service endpoints to etcd.
#
# This gem is designed to be used inside a Docker container, running alongside
# Etcd. Typical of a CoreOS environment.
#
# It is capable of "wrapping" any executable within a forked process and publishing
# any described endpoints to Etcd, using the Docker Daemon API. The best use case
# for this is running an API inside the gem, such like
#   `$ docker run -v /var/run/docker.sock:/var/run/docker.sock \
#    -d my-company/api ambassador rackup -etcd localhost:4001 \
#    -docker unix:///var/run/docker.sock`
#
# Ambassador makes use of the LABEL definition within the Dockerfile
module Ambassadr

  # Set the access URL for Ambassadr to create connections to the Docker
  # daemon running on this host.
  #
  # @note Used through the CLI, this option is exposed through
  #   the `-docker` property.
  #
  # @note A client will also be created using `ENV['ETCD_HOST']` and
  #   `ENV['ETCD_PORT']` if they are set.
  #
  # @note The first call to this method will create a client, subsequent calls
  #   will simply return the client.
  #
  # @see https://github.com/swipely/docker-api#host
  #
  # @param [string] url to access the Docker Daemon API through
  #
  # @return [string] the url being used to access the Docker daemon
  def self.docker_url(url = "")
    url = (ENV['DOCKER_URL'] || '') if url.empty?
    Docker.url = url
  end

  # Retrieve an Etcd client connection options for Ambassadr to use to create
  # a connection with Etcd.
  #
  # @note Used through the CLI, this option is exposed through
  #   the `-etcd` property. Expressed as "127.0.0.1:4001"
  #
  # @note A client will also be created using `ENV['ETCD_HOST']` and
  #   `ENV['ETCD_PORT']` if they are set.
  #
  # @note The first call to this method will create a client, subsequent calls
  #   will simply return the client.
  #
  # @see https://github.com/ranjib/etcd-ruby#create-a-client-object
  #
  # @param [hash] options to set for the Etcd client
  #
  # @return An Etcd client to be used to connect to the Etcd API
  def self.etcd(options = {})
    options[:host] ||= ENV['ETCD_HOST']
    options[:port] ||= ENV['ETCD_PORT']
    @etcd ||= Etcd.client options
  end

  # Inject shared Ambassadr properties into the ENV variable.
  #
  # @note A property namespaced as `/properties/shared/mysql/host` inside Etcd,
  #   with a base properties path of `/properties/shared` will be injected into
  #   the environment and accessible as `ENV['MYSQL_HOST']`.
  #
  # @note Setting `ENV['PROPERTIES_PATH']` modifies the base path used to inject
  #   properties into the environment.
  #
  # @return [hash] collection of keys and values injected into the environment.
  def self.env!
    Properties.new(ENV['PROPERTIES_PATH']).inject_into ENV do |obj, key, val|
      obj[key.gsub('/', '_').upcase]
    end
  end

  # Publishes the container that Ambassadr is running inside of to Etcd,
  # maintaining an access point based upon the service it is an ambassador of.
  #
  # @note This method is blocks.
  #
  # @return nil
  def self.publish!
    Publisher.new(Container.new, ENV['PUBLISHER_PATH'])
  end

end
