module Cassie::Statements
  require_relative 'statement/selection'
  require_relative 'execution/fetching'
  module Query
    extend ActiveSupport::Concern

    included do
      include Statement::Selection
      include Execution::Fetching
    end
  end
end