require_relative 'assignment'

module Cassie::Queries::Statement
  module Conditions
    extend ActiveSupport::Concern

    module ClassMethods
      def if_not_exists(opts={})
        condition = "NOT EXISTS"
        opts.delete(:value)

        conditions[condition] = opts
      end

      def if_exists(opts={})
        condition = "EXISTS"
        opts.delete(:value)

        conditions[condition] = opts
      end

      def conditions
        @conditions ||= {}
      end
    end

    def conditions
      self.class.conditions
    end

    def build_condition_and_bindings
      condition_strings = []
      bindings = []

      conditions.each do |condition, opts|
        if eval_if_opt?(opts[:if])
          condition_strings << condition.to_s
          bindings << eval_value_opt(opts[:value]) if opts.has_key?(:value)
        end
      end

      cql = "IF #{condition_strings.join(' AND ')}" unless condition_strings.empty?

      [cql , bindings]
    end
  end
end