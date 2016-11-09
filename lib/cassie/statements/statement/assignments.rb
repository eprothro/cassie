require_relative 'assignment'
require_relative 'mapping'

module Cassie::Statements::Statement
  # Provides support for a set of CQL assignments
  # and building the insert/update clause and argument list
  # for a cql statement
  #
  # CQL Relation terminology:
  #
  #   "INSERT INTO table (id, username) VALUES (?, ?);", [1, 'eprothro']
  #
  # identifiers: ['id', 'username']
  # terms:       ['?', '?']
  # arguments:   [1, 'eprothro']
  #
  #   "UPDATE table SET id = ?, username = ? WHERE...;", [1, 'eprothro']
  #
  # identifiers: ['id', 'username']
  # terms:       ['?', '?']
  # arguments:   [1, 'eprothro']
  module Assignments
    extend ActiveSupport::Concern

    included do
      include Mapping
    end

    module ClassMethods
      def set(identifier, opts={})
        opts[:value] ||= identifier.to_sym

        define_argument_accessor(opts[:value])

        assignments_args << [identifier, opts.delete(:value), opts]
      end

      def assignments_args
        @assignments_args ||= []
      end
    end

    def assignments_args
      self.class.assignments_args
    end

    def build_update_and_params
      cql = ""
      arguments = []
      assignment_strings = []

      assignments_args.each do |args|
        a = Assignment.new(self, *args)
        assignment_strings += Array(a.to_update_cql)
        arguments << a.argument if a.argument?
      end

      cql = assignment_strings.join(', ')

      [cql , arguments]
    end

    def build_insert_and_params
      identifiers = []
      terms = []
      arguments = []

      assignments_args.each do |args|
        a = Assignment.new(self, *args)
        identifiers += Array(a.identifier)
        terms += Array(a.term)
        arguments += Array(a.argument)
      end

      identifiers_cql = identifiers.join(", ")
      terms_cql = terms.join(", ")

      # (indentifier, identifier)
      # VALUES
      # (term, term);
      # (identifiers_cql)
      # VALUES
      # (terms_cql);
      [identifiers_cql, terms_cql , arguments]
    end
  end
end