module Cassie::Statements::Logging
  class ExecuteEvent < ActiveSupport::Notifications::Event

    def duration # in milliseconds
      return super unless traced?

      # trace duration is in microseconds
      trace.duration / 1000.0
    end

    def message
      {
        event: "cassie.cql.execution",
        duration: duration.round(1),
        query: statement,
        consistency: consistency.upcase
      }.extend(Inspector)
    end

    protected

    def execution_info
      payload[:execution_info]
    end

    def statement
      if execution_info
        statement = execution_info.statement
        if statement.respond_to? :cql
          str = statement.cql.dup
          str << " #{statement.params.map(&:to_s)}" if statement.respond_to? :params
        else
          str = statement.to_s
        end
        str
      else
        "CQL executed: (`execution_info` was not present?)"
      end
    end

    def consistency
      if execution_info
        execution_info.consistency
      else
        "consistency level unknown"
      end
    end

    def traced?
      execution_info && !!trace
    end

    def trace
      execution_info.trace
    end

    module Inspector
      def inspect
        color "(#{fetch(:duration).round(1)}ms) #{fetch(:query)} [#{fetch(:consistency).upcase}]"
      end

      def to_s
        inspect
      end

      protected

      def color(message)
        "\e[1m\e[37m#{message}\e[0m\e[22m"
      end
    end
  end
end