require 'ambassadr/version'

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

  autoload :Container, 'ambassadr/container'
  autoload :Publisher, 'ambassadr/publisher'
  autoload :Properties, 'ambassadr/properties'
  autoload :Services, 'ambassadr/services'

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
  # @param [string] url to access the Etcd API through
  #
  # @return An Etcd client to be used to connect to the Etcd API
  def self.etcd(url = "")
    url = (ENV['ETCD_URL'] || '') if url.empty?
    host, port = url.split(/:/)
    @etcd ||= Etcd.client host: host, port: port
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
  # @note If properties could not be found or injected, this method will puts
  #   to $stderr.
  #
  # @return [hash] collection of keys and values injected into the environment.
  def self.env!
    Properties.new.inject_into ENV do |obj, key, val|
      obj[key.gsub('/', '_').upcase]
    end
  rescue
    $stderr.puts 'Unable to inkect shared properties into environment'
  end

  # Publishes the container that Ambassadr is running inside of to Etcd,
  # maintaining an access point based upon the service it is an ambassador of.
  #
  # @note This method is blocking.
  #
  # @note If the will_retry? method is truthy, this method will attempt to retry
  #   execution up to a maximum of 5 times, failing with a message to stderr
  #   if execution fails after 5 attempts within 300 seconds.
  #
  # @param [boolean] retry the execution of this method if it fails?
  #
  # @return nil
  def self.publish!
    attempts = []
    begin
      Publisher.new(Container.new).publish
    rescue
      if Ambassadr.will_retry?
        if attempts.count < 5
          attempts << Time.now.utc.to_i
          sleep 10
          retry
        else
          if attempts.each_cons(2).map { |a,b| b-a }.inject(:+) > 60 * 5
            attempts = [Time.now.utc.to_i]
            sleep 10
            retry
          end
        end
      end
      $stderr.puts "unable to publish container services to etcd"
    end
  end

  # Configure Ambassadr to retry the publishing of container services
  # upon failure to do so. If retrying is enabled, Ambassadr will attempt
  # to re-publish container services if it cannot do so at a specific iteration
  def self.set_retry(retrying)
    @@retry = retrying
  end

  def self.will_retry?
    @@retry
  end

end
