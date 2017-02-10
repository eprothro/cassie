require_relative 'version_display'

namespace :cassie do
  namespace :schema do
    desc "Print the history of applied schema migrations"
    task :version do
      include Cassie::Tasks::IO
      include Cassie::Tasks::Schema::VersionDisplay

      begin
        print_versions([Cassie::Schema.version])
      rescue Cassie::Schema::UninitializedError => e
        puts red("Error:\n#{e.message}")
        abort
      end
    end
  end
end
