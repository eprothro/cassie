require_relative 'assignment'
require_relative 'mapping'

module Cassie::Queries::Statement
  module Assignments
    extend ActiveSupport::Concern

    included do
      include Mapping
    end

    module ClassMethods
      def set(identifier, opts={})
        assignment = Assignment.new(identifier, opts)
        opts[:value] ||= identifier.to_sym

        if Symbol === opts[:value]
          define_term_methods(opts[:value])
        end

        assignments[assignment] = opts
      end

      def assignments
        @assignments ||= {}
      end
    end

    def assignments
      self.class.assignments
    end

    def build_update_and_bindings
      cql = ""
      bindings = []
      assignment_strings = []

      assignments.each do |a, opts|
        if eval_if_opt?(opts[:if])
          assignment_strings << a.to_update_cql
          bindings << eval_value_opt(opts[:value])
        end
      end

      cql = "#{assignment_strings.join(', ')}" unless bindings.empty?

      [cql , bindings]
    end

    def build_insert_and_bindings
      identifiers = []
      bindings = []

      assignments.each do |a, opts|
        if eval_if_opt?(opts[:if])
          identifiers << a.to_insert_cql
          bindings << eval_value_opt(opts[:value])
        end
      end

      identifiers_cql = "#{identifiers.join(', ')}"
      terms_cql = Array.new(identifiers.count){"?"}.join(", ")

      [identifiers_cql, terms_cql , bindings]
    end
  end
end