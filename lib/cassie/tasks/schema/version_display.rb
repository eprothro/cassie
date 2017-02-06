require 'terminal-table'

module Cassie::Tasks
  module Schema
    module VersionDisplay
      def print_versions(versions)
        members = [:number, :description, :executor, :executed_at]
        titles  = ['Number', 'Description', 'Migrated by', 'Migrated at']
        table = Terminal::Table.new(headings:  titles)

        versions.each.with_index do |v, i|
          row = v.to_h.values_at(*members)
          row[0] = "* #{row[0]}" if i == 0
          table.add_row(row)
        end

        table.align_column(0, :right)
        puts table
      end
    end
  end
end