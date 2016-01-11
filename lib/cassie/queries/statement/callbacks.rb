module Cassie::Queries::Statement
  module Callbacks
    extend ActiveSupport::Concern

    included do
      include ActiveSupport::Callbacks
      define_callbacks :failure
    end

    module ClassMethods
      def after_failure(*args, &block)
        set_callback(:failure, :after, *args, &block)
      end
    end

    def execute
      run_callbacks :failure unless super
    end
  end
end