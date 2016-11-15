module Cassie::Statements::Statement
  #    set "username = ?", value: :username
  #    set :favs, term: 'favs + ?', value: "{ 'movie' : 'Cassablanca' }"
  #    set :username
  class Assignment
    # https://cassandra.apache.org/doc/cql3/CQL.html#updateStmt

    attr_reader :source,
                :identifier,
                :value_method,
                :enabled

    def initialize(source, identifier, value_method, opts={})
      @source = source
      @identifier = identifier
      @value_method = value_method
      @enabled = opts.has_key?(:if) ? source_eval(opts[:if]) : true
      @term = opts.has_key?(:term) ? source_eval(opts[:term]) : "?"
    end

    def identifier
      @identifier if enabled?
    end

    def value
      return @value if defined?(@value)
      @value = source.send(value_method)
    end

    def enabled?
      !!enabled
    end

    def argument?
      positional?
    end

    def argument
      value if argument?
    end

    def term
      @term if enabled?
    end

    def positional?
      term.to_s.include?("?")
    end

    def to_update_cql
      "#{identifier} = #{term}" if enabled?
    end

    private

    def source_eval(value, src=source)
      case value
      when Symbol
        src.send(value)
      else
        value
      end
    end
  end
end