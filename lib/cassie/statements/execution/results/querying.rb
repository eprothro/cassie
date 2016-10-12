module Cassie::Statements::Results
  require_relative 'instrumentation'

  module Querying
    extend ActiveSupport::Concern

    included do
      # enumerate on domain specific models
      # not on underlying Cassandra::Result rows
      #
      # e.g. include? should compare against the
      #      deserialized objects, not the underlying
      #      row hashes.
      include Enumerable
      include Instrumentation

      attr_reader :deserializer
      attr_reader :each_deserializer
    end

    def after_initialize(opts)
      super
      @each_deserializer = opts[:each_deserializer]
      @deserializer = opts[:deserializer]
      ensure_deserialization
    end

    # Deserialize each row into domain objects
    #
    # note: __object__.each is aliased
    # as rows and each_row.
    def each(&block)
      if block_given?
        records.each(&block)
        self
      else
        records.each
      end
    end

    def success?
      # an empty query is still successful
      return true if __getobj__.empty?

      super
    end

    protected

    def records
      @records ||= deserializer.call(rows)
    end

    def ensure_deserialization
      @deserializer ||= method(each_deserializer ? :map_deserialize : :pass_through_deserialize)
    end

    def pass_through_deserialize(hashes)
      hashes
    end

    def map_deserialize(hashes)
      hashes.map{|hash| each_deserializer.call(hash) }
    end
  end
end