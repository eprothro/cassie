module Cassie::Queries::Statement
  module Loading
    extend ActiveSupport::Concern

    def fetch(args={})
      rows = super(args)
      rows.map {|r| build_resource(row) }
    end
  end
end