module Cassie::Queries::Logging
  class CqlExecutionEvent < ActiveSupport::Notifications::Event

    def duration # in milliseconds
      return super unless traced?

      # trace duration is in microseconds
      trace.duration / 1000.0
    end

    def message
      color "(#{duration.round(1)}ms) #{statement} [#{consistency}]"
    end

    protected

    def execution_info
      payload[:execution_info]
    end

    def statement
      if execution_info
        statement = execution_info.statement
        str = statement.cql
        str += " [#{statement.params}]" if statement.respond_to? :params
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

    def color(message)
      "\e[1m\e[37m#{message}\e[0m\e[22m"
    end
  end
end