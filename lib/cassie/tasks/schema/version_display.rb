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
        current_version = Cassie::Schema.version

        versions.each.with_index do |v|
          row = v.to_h.values_at(*members)
          row[0] = "* #{row[0]}" if v == current_version
          table.add_row(row)
        end

        table.align_column(0, :right)
        puts table
      end

      def print_statuses(versions)
        # Note: if we end up using this elsewhere, move to Version::VersionList
        # or something simliar, and have version collection methods return that
        members = [:number, :description]
        titles  = ['Number', 'Description', 'Status', 'Migration File']
        table = Terminal::Table.new(headings:  titles)
        current_version = Cassie::Schema.version

        versions.each.with_index do |v|
          row = []
          row << v.number
          row[0] = "* #{row[0]}" if v == current_version
          row << v.description
          row << (v.recorded? ? "UP" : "DOWN")
          row << (v.migration.try(:path) || red("File Not Found")).gsub("#{Dir.pwd}/", "")
          table.add_row(row)
        end

        table.align_column(0, :right)
        table.align_column(2, :center)
        puts table
      end
    end
  end
end