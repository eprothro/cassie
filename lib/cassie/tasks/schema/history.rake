require_relative 'version_display'

namespace :cassie do
  namespace :schema do
    desc "Print the history of applied schema migrations"
    task :history do
      include Cassie::Tasks::IO
      include Cassie::Tasks::Schema::VersionDisplay

      begin
        print_versions(Cassie::Schema.applied_versions)
      rescue Cassie::Schema::UninitializedError => e
        puts red(e.message)
      end
    end
  end
end