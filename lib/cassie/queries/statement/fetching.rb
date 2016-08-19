require_relative 'relation'
require_relative 'loading'
require_relative 'batches'

class Cassie::Queries::RecordNotFound < StandardError; end

module Cassie::Queries::Statement
  module Fetching
    extend ActiveSupport::Concern

    included do
      include Loading
      include Batches
    end

    # Returns array of rows or empty array
    #
    #   query.fetch(id: 1)
    #   => [{id: 1, name: 'eprothro'}]
    def fetch(args={})
      args.each do |k, v|
        setter = "#{k}="
        send(setter, v) if respond_to? setter
      end

      execute
      result.rows
    end

    # Returns first result or nil
    #
    #   query.find(id: 1)
    #   => {id: 1, name: 'eprothro'}
    #
    #   query.find(id: 2)
    #   => nil
    def find(args={})
      old_limit = defined?(@limit) ? @limit : nil
      self.limit = 1

      fetch.first
    ensure
      if old_limit
        @limit = old_limit
      else
        remove_instance_variable(:@limit)
      end
    end

    # Returns first result or raises RecordNotFound
    #
    #   query.find!(id: 1)
    #   => {id: 1, name: 'eprothro'}
    #
    #   query.find!(id: 2)
    #   RecordNotFound: RecordNotFound
    def find!(args={})
      find || raise(Cassie::Queries::RecordNotFound)
    end
  end
end