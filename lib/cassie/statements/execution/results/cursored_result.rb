module Cassie::Statements::Results
  require_relative 'querying'
  require_relative 'peeking'

  class CursoredResult < Result
    include  Querying
    include  Peeking

    attr_reader :max_cursor_key

    def after_initialize(opts)
      super
      @max_cursor_key = opts[:max_cursor_key]

      define_singleton_method "next_max_#{max_cursor_key}" do
        next_max_cursor
      end
    end

    def next_max_cursor
      if peeked_row
        peeked_row[max_cursor_key]
      end
    end
  end
end