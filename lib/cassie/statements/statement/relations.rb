require_relative 'relation'

module Cassie::Statements::Statement
  module Relations
    extend ActiveSupport::Concern

    module ClassMethods
      #    where :username, :eq, value: :method
      #    where :phone, :in
      #    relation :user_id, :gteq, term: "minTimeuuid('2013-02-02 10:00+0000')"
      def where(identifier, op, opts={})
        relation = Relation.new(identifier, op, opts)

        #TODO: does this conflict with mapping behavior
        # in certain scenarios? Can we be more specific?
        if Symbol === relation.value_method
          define_term_methods(relation.value_method)
        end

        relations << relation
      end

      # a where clause is built up of multiple 'relations'
      def relations
        @relations ||= []
      end

      protected

      def define_term_methods(name)
        #TODO: this should probably only raise
        #      if value option was nil and we
        #      are implicilty creating getter/setters.
        if method_defined?(name) || method_defined?("#{name}=")
          raise "accessor or getter already defined for #{name}. Fix the collisions by using the `:value` option."
        else
          attr_accessor name
        end
      end
    end

    # a where clause is built up of multiple 'relations'
    def relations
      self.class.relations
    end

    protected

    def build_where_and_bindings
      cql = ""
      relation_strings = []
      arguments = []

      relations.each do |r|
        r.bind(self)
        if r.enabled?
          relation_strings << "#{r.identifier} #{r.operation} #{r.term}"
          arguments << r.argument if r.positional?
        end
      end

      cql = "WHERE #{relation_strings.join(' AND ')}" unless relation_strings.empty?

      # where identifier inequality term AND identifier inequality term;
      [cql , arguments]
    end
  end
end