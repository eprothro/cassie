module Cassie::Queries::Statement
  module Filtering
    extend ActiveSupport::Concern

    included do
      class << self
        def wheres
          @wheres ||= []
        end
        #TODO: if we stick with this, inherit base class wheres
      end
    end

    module ClassMethods
      # Sets up class-based filtering clause
      # that all objects will include in query
      # with the binding value being defined on the object
      #
      #    class MyQuery < Cassie::Base
      #      where :field, :eq
      #    end
      #
      #    q = MyQuery.new
      #    q.field = 'value'
      #    q.execute
      #    => 'SELECT * from resources WHERE field = ?; [["value"]]'
      def where(field, matcher, opts={})
        field_getter_method = opts.fetch(:source, field)
        wheres << [field, matcher, field_getter_method]

        if method_defined?(field_getter_method) || method_defined?("#{field_getter_method}=")
          raise "accessor or getter already defined for #{field_getter_method}. Choose an alternate source with the :source option."
        else
          attr_accessor field_getter_method
        end
        self
      end
    end

    # def after_initialize(*args)
    #   wheres << self.class.wheres
    #   super #TODO: callback chain style hook?
    # end

    # protected

    # def wheres
    #   @wheres ||= []
    # end
  end
end