module Cassie::Queries::Statement
  module Mapping
    extend ActiveSupport::Concern

    MAPPED_METHODS = [:insert, :update, :delete].freeze

    included do
      MAPPED_METHODS.each do |method|
        next unless method_defined?(method)

        define_method(method) do |resource=nil, opts={}|
          return super(opts) if _resource.nil? && resource.nil?

          self._resource = resource

          if super(opts)
            _resource
          else
            false
          end
        end
      end
    end

    module ClassMethods
      def map_from(resource_name)
        attr_accessor resource_name

        define_method "_resource" do
          send resource_name
        end

        define_method "_resource=" do |val|
          send("#{resource_name}=", val)
        end
      end

      protected

      def define_term_methods(field)
        getter = field
        setter = "#{field}="

        if method_defined?(getter) || method_defined?(setter)
          raise "accessor or getter already defined for #{field}. Fix the collisions by using the `:value` option."
        else
          # Order of prefrence for finding term value
          # 1. overriden getter instance method
          # 2. value set by setter instance method
          # 3. (Eventually) Mapping getter instance method
          # 4. instance resource getter instance method
          define_method getter do
            if instance_variable_defined?("@#{field}")
              return instance_variable_get("@#{field}")
            end
            _resource.send(field) if(_resource && _resource.respond_to?(field))
          end

          define_method setter do |val|
            instance_variable_set("@#{field}", val)
          end
        end
      end
    end
  end
end