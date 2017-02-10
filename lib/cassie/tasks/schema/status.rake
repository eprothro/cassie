require_relative 'version_display'

namespace :cassie do
  namespace :schema do
    desc "Prints the migration status of all schema migrations, local and applied"
    task :status do
      include Cassie::Tasks::IO
      include Cassie::Tasks::Schema::VersionDisplay

      begin
        all_versions = Cassie::Schema.applied_versions.to_a | Cassie::Schema.local_versions.to_a
        print_statuses(all_versions.sort.reverse)
      rescue Cassie::Schema::UninitializedError => e
        puts red("Error:\n  #{e.message}")
        abort
      end
    end
  end
end