module Ambassadr
  class Services
    module Mapper

      def self.included(klass)
        klass.extend(ClassMethods)
      end

      module ClassMethods

        def root!(path = ENV['PUBLISHER_PATH'])
          @@root = path || "/#{_rel}"
          self
        end

        def _path(*suffixes)
          _rel.empty? ? @@root : ([@@root, _rel] + suffixes).join('/')
        end

        def _rel
          _parts.slice(1..._parts.length).join('/')
        end

        def const_missing(name)
          klass = Class.new
          klass.extend ClassMethods
          klass.send :prepend, ContextMethods
          set_context_accessor name
          const_set name, klass
        end

        def method_missing(name, *args, &block)
          Transport.new "#{_path}/#{name}", *args, &block
        end

        private

        def set_context_accessor(name)
          define_singleton_method(name.capitalize) { |*a| const_get(name).new(*a) }
        end

        def _parts
          self.name.split(/::/).collect(&:downcase)
        end

      end

      module ContextMethods

        attr_reader :context

        def initialize(*context)
          @context = context.collect(&:to_s).join('/')
        end

        def _path
          self.class._path context
        end

        def method_missing(name, *args, &block)
          transport "#{_path}/#{name}", *args, &block
        end

        { update: :patch, delete: :delete }.each do |name, type|
          define_method(name) do |attrs = {}, &block|
            transport _path, attrs, method: type, &block
          end
        end

        private

        def transport(*args, &block)
          Transport.new *args, &block
        end

      end

    end
  end
end
