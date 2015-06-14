require 'faraday'
require 'json'

module Ambassadr
  class Services
    class Transport

      attr_reader :base, :path, :body, :opts

      def initialize(base, path, body = {}, opts = {}, &block)
        @base = base
        @path = path.to_s
        @body = body
        @opts = opts
        block.call response if block
      end

      def response
        unless @response
          resp = Faraday.new(url: "#{protocol}://#{host}").send(method, path) do |req|
            req.params = body if get?
            req.body = body if post? || patch?
          end
          @response = handler resp
        else
          @response
        end
      rescue => e
        retry if hosts.any?
        raise e
      end

      def handler(response)
        Response.new JSON.parse(response.body)
      end

      def host
        if hosts.any?
          hosts.pop
        else
          raise "no contactable hosts left"
        end
      end

      def get?
        method == :get
      end

      def post?
        method == :post
      end

      def delete?
        method == :delete
      end

      def patch?
        method == :put || method == :patch
      end

      alias_method :put?, :patch?

      def method
        (opts[:method] || :get).to_s.downcase.to_sym
      end

      def protocol
        (opts[:protocol] || :http).to_s.downcase.to_sym
      end

      private

      def hosts
        @hosts ||= if (hosts = properties.values.dup).any?
          hosts.shuffle
        else
          raise "no hosts available for service: #{base}"
        end
      end

      def properties
        @properties ||= Properties.new(base).properties.delete_if { |key| key.match /\// }
      end

    end
  end
end
