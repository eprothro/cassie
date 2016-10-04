require_relative 'assignment'
require_relative 'mapping'

module Cassie::Statements::Statement
  module Assignments
    extend ActiveSupport::Concern

    included do
      include Mapping
    end

    module ClassMethods
      def set(identifier, opts={})
        opts[:value] ||= identifier.to_sym

        if Symbol === opts[:value]
          define_term_methods(opts[:value])
        end

        assignments << Assignment.new(identifier, opts)
      end

      def assignments
        @assignments ||= []
      end
    end

    def assignments
      self.class.assignments
    end

    def build_update_and_bindings
      cql = ""
      arguments = []
      assignment_strings = []

      assignments.each do |a|
        a.bind(self)
        if a.enabled?
          assignment_strings << "#{a.identifier} = #{a.term}"
          arguments << a.argument if a.positional?
        end
      end

      cql = assignment_strings.join(', ')

      # set identifier = term,
      #     identifier = term;
      # set (update cql);
      [cql , arguments]
    end

    def build_insert_and_bindings
      identifiers = []
      terms = []
      arguments = []

      assignments.each do |a, opts|
        a.bind(self)
        if a.enabled?
          identifiers << a.identifier
          terms << a.term
          arguments << a.argument if a.positional?
        end
      end

      identifiers_cql = identifiers.join(", ")
      terms_cql = terms.join(", ")

      # (indentifier, identifier)
      # VALUES
      # (term, term);
      # (identifiers_cql)
      # VALUEES
      # (terms_cql);
      [identifiers_cql, terms_cql , arguments]
    end
  end
end