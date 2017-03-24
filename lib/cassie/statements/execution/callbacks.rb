module Cassie::Statements::Execution
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

    def execute(*args)
      super || run_callbacks(:failure)
    end
  end
end