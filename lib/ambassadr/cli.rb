require 'ambassadr'

module Ambassadr
  class CLI

    attr_reader :argv

    def initialize(argv = [])
      @argv = argv.dup
    end

    def run

      Ambassadr.env!

      main = fork &method(:main)

      # Process.detach publish = fork(&method(:publish))

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

    # def publish
    #   container = Container.new
    #   Publisher.new({ prefix: ENV['AMBASSADR_PREFIX'] }).publish container
    # end

    private

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
