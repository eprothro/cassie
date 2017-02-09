# for pluralization
require 'active_support/core_ext/string'
require_relative 'relation'

module Cassie::Statements::Statement
  # Provides support for a set of CQL relations
  # and building the where clause and argument list
  # for a cql statement
  #
  # CQL Relation terminology:
  #
  #   "SELECT * FROM table WHERE id = ?", [1]
  #
  # relation:   'WHERE'
  # identifier: 'id'
  # operation:  '='
  # term:       '?'
  # argument:   '1'
  module Relations
    extend ActiveSupport::Concern

    module ClassMethods
      # DSL to set a ranging relation (+WHERE+ clause) for the statement.
      #
      # Defining a relation also defines an +attr_accessor+ with the same name as
      # the identifier (or the +:value+ option if a symbol is used). The underlying instance
      # variable value for this accessor will be used when determining the value for the relation.
      #
      # @param [String, Symbol] identifier The field name or other CQL identifier to restrict the query.
      # @param [Symbol] operation Which operation to use. See {Cassie::Statements::Statement::Relation::OPERATIONS} for valid symbols and their associated operations.
      # @param [Hash] opts options for the relation
      # @option opts [Symbol, Object] :value The value to use for the ranging relation (constraint). If a [Symbol], a method with that name will be called when the statement is built. Otherwise, the value itself will be used.
      # @option opts [Symbol, Object] :if Determines if the relation is applied to the statement or not. If a [Symbol], a method with that name will be called when the statement is built. Otherwise, the value itself will be used.
      # @option opts [String] :term The argument value to use instead of a positional placeholder (?). If a [Symbol], a method with that name will be called when the statement is built. Otherwise, the value itself will be used.
      # @return [Enumerable<Array<Object>>] The enumeration of current relations' parameters
      # @raise [StandardError] if there is already a getter or setter method defined for the
      #   relation value's implied accessor (+identifier+ or symbol +:value+ option).
      #
      # @example Range relation with implied accessor
      #   where :username, :eq #<= gets relation value from `:username` method
      # @example Range relation with explicit accessor
      #   where :username, :eq, value: :name #<= gets relation value from `:name` method
      # @example Range relation with multi-value, pluarlized accessr
      #   where :phone, :in #<= gets relation value from `:phones` method
      def where(identifier, operation, opts={})
        opts[:value] ||= implied_argument_method(identifier, operation)

        define_argument_accessor(opts[:value])

        relations_args << [identifier, operation, opts.delete(:value), opts]
      end

      # The enumeration of current relations' parameters that will be
      # used to build Relation objects when the statement is built
      def relations_args
        @relations_args ||= []
      end

      protected

      # @todo extract argument accessor creation for
      #      more DRY and clear usage. See mapping module.
      def define_argument_accessor(name)
        unless Symbol === name
          raise ArgumentError, "A Symbol is required for the accessor methods for setting/getting a relation's value. #{name.class} (#{name}) given."
        end
        # @todo this should probably only raise
        #      if value option was nil and we
        #      are implicilty creating getter/setters.
        if method_defined?(name) || method_defined?("#{name}=")
          raise "accessor or getter already defined for #{name}. Fix the collisions by using the `:value` option."
        else
          attr_accessor name
        end
      end

      private

      def implied_argument_method(identifier, op)
        method = if op == :in
          identifier.to_s.pluralize
        else
          identifier
        end

        method.to_sym
      end
    end

    # a where clause is built up of multiple 'relations'
    def relations_args
      self.class.relations_args
    end

    protected

    def build_where_and_params
      cql = ""
      relation_strings = []
      arguments = []

      relations_args.each do |args|
        r = Relation.new(self, *args)
        relation_strings += Array(r.to_cql)
        arguments << r.argument if r.argument?
      end

      cql = "WHERE #{relation_strings.join(' AND ')}" unless relation_strings.empty?

      # where identifier inequality term AND identifier inequality term;
      [cql , arguments]
    end
  end
end