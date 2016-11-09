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
      #    where :username, :eq, value: :method
      #    where :phone, :in
      #    relation :user_id, :gteq, term: "minTimeuuid('2013-02-02 10:00+0000')"
      def where(identifier, op, opts={})
        opts[:value] ||= implied_argument_method(identifier, op)

        define_argument_accessor(opts[:value])

        relations_args << [identifier, op, opts.delete(:value), opts]
      end

      def relations_args
        @relations_args ||= []
      end

      protected

      #TODO: extract argument accessor creation for
      #      more DRY and clear usage. See mapping module.
      def define_argument_accessor(name)
        unless Symbol === name
          raise ArgumentError, "A Symbol is required for the accessor methods for setting/getting a relation's value. #{name.class} (#{name}) given."
        end
        #TODO: this should probably only raise
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