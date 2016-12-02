def fake_migration(version_number)
  version = Cassie::Schema::Version.new(version_number)
  klass = Class.new(Cassie::Schema::Migration) do
    def up
    end

    def down
    end
  end
  class_name = "Migration_#{version.major}_#{version.minor}_#{version.patch}_#{version.build}".to_sym
  Object.send(:remove_const, class_name) if Object.constants.include?(class_name)
  Object.send(:const_set, class_name, klass)
  class_name.to_s.constantize.new(version)
end

RSpec::Matchers.define :a_migration_like do |x|
  match do |actual|
    actual.version == x.version
  end
end

RSpec::Matchers.define :a_number_close_to do |x, percent|
  match do |actual|
    percent ||= 0.20
    ((actual - x).abs / x.to_f) < percent
  end
end