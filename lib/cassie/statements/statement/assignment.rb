module Cassie::Statements::Statement
  #    set "username = ?", value: :username
  #    set :favs, term: 'favs + ?', value: "{ 'movie' : 'Cassablanca' }"
  #    set :username
  class Assignment
    # https://cassandra.apache.org/doc/cql3/CQL.html#updateStmt

    attr_reader :opts
    attr_reader :source
    attr_reader :identifier

    def initialize(identifier, opts={})
      @identifier = identifier
      opts[:if] = opts.fetch(:if, true)
      opts[:term] = opts.fetch(:term, "?")
      @opts = opts
    end

    def bind(source)
      @source = source
    end

    def enabled?
      !!eval_opt(opts[:if])
    end

    def term
      eval_opt(opts[:term])
    end

    def argument
      eval_opt(opts[:value])
    end

    def positional?
      term.to_s.include?("?")
    end

    protected

    def eval_opt(value)
      case value
      when Symbol
        source.send(value)
      else
        value
      end
    end
  end
end