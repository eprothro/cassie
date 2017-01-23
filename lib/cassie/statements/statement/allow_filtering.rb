module Cassie::Statements::Statement
  module AllowFiltering
    extend ActiveSupport::Concern

    module ClassMethods
      def inherited(subclass)
        subclass.allow_filtering(allow_filtering?) if defined?(@allow_filtering)
        super
      end

      def allow_filtering(val=:allow)
        @allow_filtering = !!val
      end

      def allow_filtering?
        return !!@allow_filtering if defined?(@allow_filtering)
        false
      end
    end

    def allow_filtering?
      self.class.allow_filtering?
    end

    protected

    def build_allow_filtering_str
      if allow_filtering?
        "ALLOW FILTERING"
      else
        ""
      end
    end
  end
end