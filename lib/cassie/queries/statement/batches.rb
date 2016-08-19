require_relative 'relation'
require_relative 'loading'
require_relative 'batches'

module Cassie::Queries::Statement
  module Batches
    extend ActiveSupport::Concern

    # Yields each batch of records that was found by the options as an array.
    #
    # If you do not provide a block to find_in_batches, it will return an Enumerator for chaining with other methods.
    #
    #  query.fetch_in_batches do |records|
    #   puts "max score in group: #{records.max{ |a, b| a.score <=> b.score }}"
    #  end
    #
    #  "max score in group: 26"
    def fetch_in_batches(opts={})
      # set page size
      # fetch with pagination until result.last_page? true
    end
  end
end