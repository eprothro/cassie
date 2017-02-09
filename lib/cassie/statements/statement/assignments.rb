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

    # @!visibility private
    # @!parse include Mapping
    # @!parse extend Mapping::ClassMethods
    def self.included(base)
      base.instance_eval do
        include Mapping
      end
      base.extend ClassMethods
    end

    module ClassMethods
      # DSL to set an assigment (+SET+ or +VALUES+ clause) for +UPDATE+ and +INSERT+ statements.
      #
      # Defining an assigment also defines an +attr_accessor+ with the same name as
      # the identifier (or the +:value+ option if a symbol is used). The underlying instance
      # variable value for this accessor will be used when determining the value for the assigment.
      #
      # @param [String, Symbol] identifier The column name to set.
      # @param [Hash] opts options for the assigment
      # @option opts [Symbol, Object] :value The value to use for the assigment (constraint). If a [Symbol], a method with that name will be called when the statement is built. Otherwise, the value itself will be used.
      # @option opts [Symbol, Object] :if Determines if the assigment is applied to the statement or not. If a [Symbol], a method with that name will be called when the statement is built. Otherwise, the value itself will be used.
      # @option opts [String] :term The argument value to use instead of a positional placeholder (?). If a [Symbol], a method with that name will be called when the statement is built. Otherwise, the value itself will be used.
      # @return [Enumerable<Array<Object>>] The enumeration of current assigments' parameters
      # @raise [StandardError] if there is already a getter or setter method defined for the
      #   assigment value's implied accessor (+identifier+ or symbol +:value+ option).
      #
      # @example Assigment with implied accessor
      #   set :username #<= gets assigment value from `:username` method
      # @example Assigment with explicit accessor
      #   set :username, value: :name #<= gets assigment value from `:name` method
      def set(identifier, opts={})
        opts[:value] ||= identifier.to_sym

        define_argument_accessor(opts[:value])

        assignments_args << [identifier, opts.delete(:value), opts]
      end

      # The enumeration of current assignments' parameters that will be
      # used to build Assignment objects when the statement is built
      def assignments_args
        @assignments_args ||= []
      end
    end

    # The enumeration of current assignments' parameters that will be
    # used to build Assignment objects when the statement is built
    def assignments_args
      self.class.assignments_args
    end

    protected

    def build_update_and_params
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
        arguments << a.argument if a.argument?
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