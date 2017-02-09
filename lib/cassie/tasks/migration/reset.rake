require 'optparse'

namespace :cassie do
  namespace :migrate do
    desc "Drop and reload the schema, then migrate"
    task :reset => ["cassie:schema:reset", "cassie:migrate"]
  end
end

