module Cassie::Statements::Statement
  module Mapping
    extend ActiveSupport::Concern

    included do
      # We are mapping term values from a client provided resource.
      # store this object in `_resource` attribte
      # as they could reasonably want to name it `resource`
      attr_accessor :_resource
    end

    module ClassMethods
      def map_from(resource_name)
        define_method resource_name do
          _resource
        end

        define_method "#{resource_name}=" do |val|
          self._resource = val
        end
      end

      protected

      # define getter and setter
      # methods that look up term values
      # from resource object
      def define_term_methods(field)
        getter = field
        setter = "#{field}="

        if method_defined?(getter) || method_defined?(setter)
          raise "accessor or getter already defined for #{field}. Fix the collisions by using the `:value` option."
        else
          # Order of prefrence for finding term value
          #  1. overwritten getter instance method
          #    def id
          #      "some constant"
          #    end
          #  2. value set by setter instance method
          #    def ensure_special_is_special
          #      @id = "one off value" if special?
          #    end
          #  3. getter instance method on resource object
          #    query.user = User.new(id: 105)
          #    query.id
          #    => 105
          define_method getter do
            # 1 is handled by overwritten definition

            # 2: prefer instance value
            if instance_variable_defined?("@#{field}")
              return instance_variable_get("@#{field}")
            end

            # 3: fetch from resource
            if _resource && _resource.respond_to?(field)
              _resource.send(field)
            end
          end

          # query.id = 'some val'
          # initialize underlying instance var
          # which is preferred over resource object attribute
          #
          # Issue: if client defines value for attribute
          # they might assume later setting to nil would
          # revert to behavior of fetching from resource object attribute
          # but that is not the case since the variable is defined
          # and we can't know they didn't want the value of 'nil' to be used
          attr_writer field
        end
      end
    end
  end
end