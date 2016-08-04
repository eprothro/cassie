module Cassie::Queries::Statement
  module Ordering
    extend ActiveSupport::Concern

    included do
      attr_writer :order
    end

    module ClassMethods
      def order=(val)
        @order = val
      end

      def order(val=:get)
        if val == :get
          @order if defined?(@order)
        else
          self.order = val
        end
      end
    end

    def order
      return @order if defined?(@order)
      self.class.order
    end

    protected

    def build_order_str
      return "" unless !order.nil?
      return "" unless !order[:key].nil? && !order[:direction].nil?
      return "" unless eval_if_opt?(order[:if])

      "ORDER BY #{order[:key]} #{order[:direction]}"
    end
  end
end
