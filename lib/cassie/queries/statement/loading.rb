module Cassie::Queries::Statement
  module Loading
    extend ActiveSupport::Concern

    def fetch(args={})
      build_resources(super(args))
    end

    protected

    # Default implementation assumes
    # 1 row per resource, clients
    # may override if more complex
    def build_resources(rows)
      rows.map {|r| build_resource(r) }
    end

    # When class doesn't override
    # simply return a struct with the row data
    def build_resource(row)
      Struct.new(*row.keys).new(*row.values)
    end
  end
end