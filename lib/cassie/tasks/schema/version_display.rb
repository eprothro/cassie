require 'terminal-table'

module Cassie::Tasks
  module Schema
    module VersionDisplay
      # Prints an ASCII table represenation of the versions
      # to STDOUT in the order given with column headers.
      def print_versions(versions)
        # Note: if we end up using this elsewhere, move to Version::VersionList
        # or something simliar, and have version collection methods return that
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