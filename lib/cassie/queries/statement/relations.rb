require_relative 'relation'

module Cassie::Queries::Statement
  module Relations
    extend ActiveSupport::Concern

    module ClassMethods
      def relation(identifier, op, opts={})
        relation = Relation.new(identifier, op, opts)
        opts[:value] ||= identifier.to_sym

        if Symbol === opts[:value]
          define_term_methods(opts[:value])
        end

        relations[relation] = opts
      end

      def where(*args)
        relation(*args)
      end

      # a where clause is built up of multiple 'relations'
      def relations
        @relations ||= {}
      end

      private

      def define_term_methods(name)
        #TODO: this should probably only raise
        #      if value option was nil and we
        #      are implicilty creating getter/setters.
        if method_defined?(name) || method_defined?("#{name}=")
          raise "accessor or getter already defined for #{name}. Fix the collions by using the `:value` option."
        else
          attr_accessor name
        end
      end
    end

    # a where clause is built up of multiple 'relations'
    def relations
      self.class.relations
    end

    def build_where_and_bindings
      cql = ""
      bindings = []
      relation_strings = []

      relations.each do |r, opts|
        if eval_if_opt?(opts[:if])
          relation_strings << r.to_cql
          bindings << eval_value_opt(opts[:value])
        end
      end

      cql = "WHERE #{relation_strings.join(' AND ')}" unless bindings.empty?

      [cql , bindings]
    end
  end
end