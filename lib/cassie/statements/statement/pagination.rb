require_relative 'pagination/cursors'

module Cassie::Statements
  module Statement::Pagination
    extend ActiveSupport::Concern

    included do
      include Cursors

      alias :page_size :limit
      alias :page_size= :limit=

      class << self
        alias :page_size :limit
        alias :page_size= :limit=
      end
    end
  end
end