module Cassie::Statements::Execution
  module Deserialization

    protected

    def build_result(row)
      # Default implementation builds
      # a struct with the row data for
      # more convenient data access
      Struct.new(*row.keys.map(&:to_sym)).new(*row.values)
    end
  end
end