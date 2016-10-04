require_relative 'execution_info'

module Cassie::Testing::Fake
  class Result
    include Enumerable
    attr_reader :rows, :statement, :opts

    def initialize(statement, execution_opts={})
      @statement = statement
      @opts = execution_opts
      @rows = @data = opts[:rows] || []
    end

    def execution_info
      ExecutionInfo.new(statement)
    end

    def each
      if paging_enabled?
        index = current_page - 1
        offset = index * page_size
        @data.slice(offset, page_size) || []
      else
        @data
      end
    end
    alias rows each
    alias each_row each

    def empty?
      rows.empty?
    end

    def paging_enabled?
      !!page_size
    end

    def page_size
      return nil unless opts[:page_size]
      opts[:page_size].to_i
    end

    def pages
      return nil unless paging_enabled?
      (@data.count / page_size.to_f).ceil
    end

    def previous_page
      return nil unless previous_paging_state
      previous_paging_state.bytes[-1]
    end

    def current_page
      return 1 unless paging_enabled? && previous_page
      previous_page + 1
    end

    def last_page?
      return nil unless paging_enabled?
      current_page == pages
    end

    def previous_paging_state
      return nil unless paging_enabled?
      @opts[:paging_state]
    end

    def paging_state
      return nil unless paging_enabled?
      if previous_paging_state
        bytes = previous_paging_state.bytes
        raise 'Too many pages for Cassie testing harness!' if bytes[-1] >= 256
        bytes[-1] = bytes[-1] + 1
        bytes.pack('c*')
      else
        # use last byte of state string to store pages
        # presume 255 pages is enough for any testing
        "paging #{SecureRandom.hex(6)}:" + [1].pack('c*')
      end
    end
  end
end