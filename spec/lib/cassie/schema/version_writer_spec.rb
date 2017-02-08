RSpec.describe Cassie::Schema::VersionWriter do
  let(:klass){ Cassie::Schema::VersionWriter }
  let(:object){ klass.new(version, buffer) }
  let(:buffer){ StringIO.new }
  let(:version){ Cassie::Schema::Version.new('1') }

  describe "class_name" do
    it "always outputs 4 parts" do
      expect(object.version.migration_class_name).to eq("Migration_1_0_0_0")
    end
  end

  describe "write" do
    let(:migration_klass) do
      object.write
      Object.send(:remove_const, version.migration_class_name.to_sym) if Object.constants.include?(version.migration_class_name.to_sym)
      eval(buffer.string)
      eval(version.migration_class_name)
    end
    let(:migration){ migration_klass.new }
    it "defines ruby class in buffer" do
      expect(migration_klass.name).to eq(version.migration_class_name)
    end
    it "defines ruby up method in buffer" do
      expect(migration).to respond_to(:up)
    end
    it "defines ruby up method in buffer" do
      expect(migration).to respond_to(:down)
    end
  end

  describe "directory" do
    it "is config directory for migrations" do
      expect(object.directory).to eq(Cassie::Schema.paths["migrations_directory"])
    end
  end

  describe "with_io" do
    context "without io overridden" do
      let(:buffer){ nil }

      it "writes to config directory" do
        Dir.mktmpdir do |dir|
          allow(object).to receive(:directory){ dir }

          object.with_io do |io|
            expect(File.dirname(io.path)).to eq(dir)
            expect(File.basename(io.path)).to eq(object.basename)
          end
        end
      end

      context "if file already exists" do
        it "raises an exception that the migration already exists" do
          Dir.mktmpdir do |dir|
            allow(object).to receive(:directory){ dir }
            File.new(object.filename, 'w')

            expect{object.with_io{}}.to raise_error(IOError, /already exists/)
          end
        end
      end
    end
  end
end

