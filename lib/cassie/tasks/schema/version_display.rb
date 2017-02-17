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
        headings  = ['Number', 'Description', 'Migrated by', 'Migrated at']
        title = "Environment: #{Cassie.env}"
        table = Terminal::Table.new(headings:  headings, title: title)
        current_version = Cassie::Schema.version

        versions.each.with_index do |v|
          row = []
          row[0] = v.number
          row[0] = "* #{row[0]}" if v == current_version
          row[1] = v.description
          row[2] = v.executor
          row[3] = v.executed_at
          row[3] ||= "Unknown"
          table.add_row(row)
        end

        table.align_column(0, :right)
        puts table
      end

      def print_statuses(versions)
        # Note: if we end up using this elsewhere, move to Version::VersionList
        # or something simliar, and have version collection methods return that
        headings  = ['Number', 'Description', 'Status', 'Migration File']
        title = "Environment: #{Cassie.env}"
        table = Terminal::Table.new(headings:  headings, title: title)
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