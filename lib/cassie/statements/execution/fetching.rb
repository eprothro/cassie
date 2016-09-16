class Cassie::Statements::RecordNotFound < StandardError; end

module Cassie::Statements::Execution
  require_relative 'batched_fetching'
  require_relative 'deserialization'

  module Fetching
    extend ActiveSupport::Concern

    included do
      include BatchedFetching
      include Deserialization
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
      result
    end

    # Returns first result or nil
    #
    #   query.fetch_first(id: 1)
    #   => {id: 1, name: 'eprothro'}
    #
    #   query.fetch_first(id: 2)
    #   => nil
    def fetch_first(args={})
      old_limit = defined?(@limit) ? @limit : nil
      self.limit = 1

      fetch(args).first
    ensure
      if old_limit
        @limit = old_limit
      else
        remove_instance_variable(:@limit)
      end
    end

    # Returns first result or raises RecordNotFound
    #
    #   query.fetch_first!(id: 1)
    #   => {id: 1, name: 'eprothro'}
    #
    #   query.fetch_first!(id: 2)
    #   RecordNotFound: RecordNotFound
    def fetch_first!(args={})
      fetch_first || raise(Cassie::Statements::RecordNotFound.new('CQL row does not exist'))
    end
  end
end