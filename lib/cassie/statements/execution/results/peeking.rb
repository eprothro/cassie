module Cassie::Statements::Results
  module Peeking
    extend ActiveSupport::Concern

    included do
      attr_reader :next_row
    end

    def extract_peeked_rows_after(page_size)
      peeked_count = rows.count - page_size
      @next_row = case
      when peeked_count == 1
        rows.delete_at(-1)
      when peeked_count <= 0
        {}
      else
        raise "More than one row was peeked at. Please report this Cassie issue: https://github.com/eprothro/cassie/issues."
      end
    end

  end
end