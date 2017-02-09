module Cassie::Statements::Statement
  module Mapping

    def self.included(base)
      base.instance_eval do
        # We are mapping term values from a client provided resource.
        # store this object in `_resource` attribte
        # as they could reasonably want to name it `resource`
        attr_accessor :_resource
      end
      base.extend ClassMethods
    end

    # @!parse extend ClassMethods
    module ClassMethods
      # DSL setting a getter and setter.
      #
      # When use with a relation (+where+) or assignment (+set+),
      # the fetching of column values are
      # delegated to the object in this getter.
      #
      # @note This delegation behavor gets last preference.
      #   * An overwritten +column_name+ getter has first preference
      #   * the +@column_name+ instance variable has next preference
      #   * the mapped resource delegation has last preference
      #
      # @example Simple Mapping delegation
      #   Class Statement
      #     include Cassie::Statements::Statement:Relations
      #     include Cassie::Statements::Statement:Mapping
      #
      #     where :name
      #
      #     map_from :user
      #   end
      #
      #   s = Statement.new
      #   s.user = User.new(id: 1)
      #   s.id
      #   #=> 1
      def map_from(resource_name)
        define_method resource_name do
          _resource
        end

        define_method "#{resource_name}=" do |val|
          self._resource = val
        end
      end

      protected

      # override definition of getter and setter
      # methods to look up argument values
      # from resource object
      def define_argument_accessor(name)
        unless Symbol === name
          raise ArgumentError, "A Symbol is required for the accessor methods for setting/getting a relation's value. #{name.class} (#{name}) given."
        end

        getter = name
        setter = "#{name}="

        if method_defined?(getter) || method_defined?(setter)
          raise "accessor or getter already defined for #{name}. Fix the collisions by using the `:value` option."
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
            if instance_variable_defined?("@#{name}")
              return instance_variable_get("@#{name}")
            end

            # 3: fetch from resource
            if _resource && _resource.respond_to?(name)
              _resource.send(name)
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
          attr_writer name
        end
      end
    end
  end
end