module Cassie::Statements::Results
  module Peeking
    extend ActiveSupport::Concern

    included do
      attr_reader :limit
      attr_reader :peeked_row
    end

    def peeked_result
      return @peeked_result if defined?(@peeked_result)

      @peeked_result = if peeked_row
        each_deserializer.call(peeked_row)
      end
    end

    protected

    def after_initialize(opts={})
      super
      @limit = opts[:limit]
      extract_peeked_rows_after(limit)
    end

    def extract_peeked_rows_after(limit)
      peeked_count = rows.count - limit
      @peeked_row = case
      when peeked_count == 1
        raw_rows.delete_at(-1)
      when peeked_count <= 0
        nil
      else
        raise "More than one row was peeked at. Please report this Cassie issue: https://github.com/eprothro/cassie/issues."
      end
    end

    def raw_rows
      __getobj__.instance_variable_get(:@rows)
    end
  end
end