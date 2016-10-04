module Cassie::Statements
  require_relative 'statement/inserting'
  require_relative 'statement/updating'
  require_relative 'statement/deleting'
  module Modification
    extend ActiveSupport::Concern

    included do
      include Statement::Inserting
      include Statement::Updating
      include Statement::Deleting
    end
  end
end