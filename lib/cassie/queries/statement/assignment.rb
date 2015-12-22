module Cassie::Queries::Statement
  #
  #
  #    set "username = ?", value: :username
  #    set "favs = favs + ?" value: "{ 'movie' : 'Cassablanca' }"
  #    set :username
  class Assignment
    # https://cassandra.apache.org/doc/cql3/CQL.html#updateStmt

    attr_reader :identifier

    def initialize(identifier, opts={})
      if String === identifier
        #  custom assignment is being defined:
        #
        #  `assign "username = ?", value: :username`
        @cql = identifier
        @custom = true
      else
        @identifier = identifier
      end
    end

    def to_insert_cql
      @cql || identifier
    end

    def to_update_cql
      @cql || "#{identifier} = ?"
    end

    def custom?
      !!@custom
    end
  end
end