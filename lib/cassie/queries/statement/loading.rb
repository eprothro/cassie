module Cassie::Queries::Statement
  module Loading
    extend ActiveSupport::Concern

    def fetch(args={})
      rows = super(args)
      rows.map {|r| build_resource(r) }
    end

    protected

    # When class doesn't override
    # simply return a struct with the row data
    def build_resource(row)
      Struct.new(*row.keys).new(*row.values)
    end
  end
end