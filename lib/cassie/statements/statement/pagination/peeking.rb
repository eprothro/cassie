module Cassie::Statements::Statement::Pagination
  module Peeking

    def limit
      super || page_size
    end

    def execute
      val = peek_at_next_page do
        super
      end

      #TODO: move this into result opts?
      result.extract_peeked_rows_after(page_size)
      val
    end

    protected

    def result_class
      Cassie::Statements::Results::PeekingResult
    end

    private

    # cache query object instance page_size
    # so we can revert _object_ back to
    # same state and preserve value
    # inheritance chain behavior
    def peek_at_next_page(&block)
      old_page_size = nil
      was_defined = false

      if defined?(@page_size)
        old_page_size = @page_size
        was_defined = true
      end

      @page_size = page_size + 1
      yield
    ensure
      if was_defined
        @page_size = old_page_size
      else
        remove_instance_variable(:@page_size)
      end
    end
  end
end