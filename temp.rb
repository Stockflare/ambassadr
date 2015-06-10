module Service

  def self.included(klass)
    klass.extend(ClassMethods)
  end

  module Context

    attr_reader :id

    def initialize(id)
      @id = id
    end

    def path
      "#{self.class.path}/#{id}"
    end

  end

  module ClassMethods

    DEFAULT_PATH = '/services'

    def path
      parts = self.name.split(/::/).collect(&:downcase)
      ([@@root] + parts.slice!(1...parts.length)).join('/')
    end

    def root!(path = ENV['PUBLISHER_PATH'])
      @@root = path || DEFAULT_PATH
      self
    end

    def const_missing(name)
      klass = Class.new
      klass.extend ClassMethods
      klass.send :prepend, Context
      set_accessor name
      const_set name, klass
    end

    private

    def set_accessor(name)
      define_singleton_method(name.capitalize) { |id| const_get(name).new(id) }
    end

  end

end

class Intermediate

  include Service

end

class Internal < Intermediate.root!('/services/internal')
end

# puts Internal.root!('/services/internal')

puts Internal::User.path

puts Internal::User.new(12345).path

puts Internal::User::Watchlist::Stocks.path
