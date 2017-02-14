def fake_migration_file
  contents = <<-EOS
class Migration_0_0_0_1_old < Cassie::Schema::Migration
  def up
  end

  def down
  end
end
EOS
  double(description: "old", build_migration_class: contents)
end