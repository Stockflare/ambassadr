require 'ambassadr'

module Ambassadr
  class CLI

    attr_reader :argv

    def initialize(argv = [])
      @argv = argv.dup
      configure_docker!
      configure_etcd!
    end

    def run

      Ambassadr.env!

      main = fork &method(:main)

      Process.detach publish = fork(&Ambassadr.method(:publish!))

      trap("CLD") { try_sig(:HUP, main) || try_sig(:HUP, publish) }

      trap("INT") { try_sig(:INT, main) && try_sig(:INT, publish) }

      Process.wait main

      try_sig(:HUP, publish)

    rescue Interrupt
    end

    def main
      begin
        exec *argv unless argv.empty?
      rescue Errno::EACCES
        error "not executable: #{argv.first}"
      rescue Errno::ENOENT
        error "command not found: #{argv.first}"
      end
    end

    private

    def configure_docker!
      docker = argv.index("-docker")
      return nil unless docker
      argv.delete_at docker
      Ambassadr.docker_url = argv.delete_at(docker)
    end

    def configure_etcd!
      etcd = argv.index("-etcd")
      return nil unless etcd
      argv.delete_at etcd
      host, port = argv.delete_at(etcd).split(':')
      Ambassadr.etcd host: host, port: port
    end

    def try_sig(sig, pid)
      Process.kill(sig, pid)
    rescue Errno::ESRCH
      false
    end

    def error(message)
      puts "ERROR: #{message}"
      exit 1
    end

  end
end
