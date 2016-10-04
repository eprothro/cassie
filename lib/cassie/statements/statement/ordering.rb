module Cassie::Statements::Statement
  module Ordering
    extend ActiveSupport::Concern

    protected

    def build_order_str
      ""
    end
  end
end