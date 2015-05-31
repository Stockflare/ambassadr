require 'ambassadr/version'
require 'ambassadr/container'
require 'ambassadr/publisher'

module Ambassadr

  def self.env!

  end

  def publish!
    container = Container.new
    Publisher.new({ prefix: ENV['AMBASSADR_PREFIX'] }).publish container
  end

end
