module Cassie::Statements::Execution
  module BatchedFetching
    extend ::ActiveSupport::Concern

    included do
      attr_accessor :paging_state
      attr_accessor :stateless_page_size
    end

    # Uses #fetch_in_batches with a batch size of 1000 (or as
    # specified by the +:batch_size+ option) to enumerate through all
    # records, while using batches to limit resource consumption.
    #
    # If you do not provide a block to #fetch_each, it will return an Enumerator
    # for chaining with other methods.
    #
    #   UsersByPositionQuery.fetch_each.with_index do |user, index|
    #     user.position = index
    #     UserMapper.update_position(user)
    #   end
    #
    # ==== Options
    # * <tt>:batch_size</tt> - Specifies the size of the batch. Default to 1000.
    #
    # NOTE: Any limit specified on the query will affect the batched set.
    # Cassandra internal paging is used for batching.
    def fetch_each(opts={})
      return to_enum(:fetch_each, opts) unless block_given?

      fetch_in_batches(opts) do |records|
        records.each { |record| yield record }
      end
    end

    # Yields each batch of records that was found by the options as an array.
    #
    # If you do not provide a block to find_in_batches, it will return an Enumerator for chaining with other methods.
    #
    #  query.fetch_in_batches do |records|
    #   puts "max score in group: #{records.max{ |a, b| a.score <=> b.score }}"
    #  end
    #
    #  "max score in group: 26"
    #
    # ==== Options
    # * <tt>:batch_size</tt> - Specifies the size of the batch. Default to 1000.
    #
    # NOTE: Any limit specified on the query will affect the batched set.
    # Cassandra internal paging is used for batching.
    def fetch_in_batches(opts={})
      opts[:batch_size] ||= 1000

      # spawn the new query as soon as the enumerable is created
      # rather than waiting until the firt iteration is executed.
      # The client could mutate the object between these moments,
      # however we don't want to spawn twice if a block isn't passed.
      paged_query = opts.delete(:_paged_query) || self.clone

      return to_enum(:fetch_in_batches, opts.merge(_paged_query: paged_query)) unless block_given?

      # use Cassandra internal paging
      # but clone the query to isolate it
      # and allow all paging queries
      # to execute within a Cassie::Query
      # for use of other features, like logging
      #
      # note: stateless page size is independent from limit
      paged_query.stateless_page_size = opts[:batch_size]
      paged_query.paging_state = nil

      loop do
        # done if the previous result was the last page
        break if paged_query.result && paged_query.result.last_page?
        raise page_size_changed_error(opts[:batch_size]) if opts[:batch_size] != paged_query.stateless_page_size

        batch = paged_query.fetch
        paged_query.paging_state = paged_query.result.paging_state

        yield batch
      end
    end

    private

    def page_size_changed_error(original_size)
      Cassie::Statements::Statement::Invalid.new("Page size is no longer valid. It was #{original_size} when the batch was started, and is now #{self.page_size}. Continuing would cause unexpected results.")
    end
  end
end