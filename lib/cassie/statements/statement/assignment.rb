module Cassie::Statements::Statement
  #    set "username = ?", value: :username
  #    set :favs, term: 'favs + ?', value: "{ 'movie' : 'Cassablanca' }"
  #    set :username
  class Assignment
    # https://cassandra.apache.org/doc/cql3/CQL.html#updateStmt

    attr_reader :source,
                :identifier,
                :value,
                :enabled,
                :term

    def initialize(source, identifier, value_method, opts={})
      @source = source
      @identifier = identifier
      @value = source.send(value_method)
      @enabled = opts.has_key?(:if) ? source_eval(opts[:if]) : true
      @term = opts.has_key?(:term) ? source_eval(opts[:term]) : "?"
    end

    def enabled?
      !!enabled
    end

    def argument?
      enabled? && positional?
    end

    def argument
      value if argument?
    end

    def positional?
      term.to_s.include?("?")
    end

    def to_update_cql
      return nil unless enabled?
      "#{identifier} = #{term}"
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