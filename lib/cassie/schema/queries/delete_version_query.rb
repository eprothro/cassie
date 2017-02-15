module Cassie::Schema
  class DeleteVersionQuery < Cassie::Modification
    attr
    delete_from Cassie::Schema.versions_table

    where :id, :eq, if: :id?
    where :env, :eq
    where :application, :eq

    def id?
      !!self.id
    end

    def env
      #setting #env should win
      return @env if defined?(@env)
      Cassie.env
    end

    def application
      #setting #env should win
      return @application if defined?(@application)
      Cassie::Schema.application
    end

    def keyspace
      Cassie::Schema.schema_keyspace
    end
  end
end