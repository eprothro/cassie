RSpec.describe Cassie::Statements::Statement::Conditions do
  let(:base_class){ Cassie::FakeModification }
  let(:klass) do
    Class.new(base_class) do
    end
  end
  let(:object) { klass.new }

  describe "set"  do
    context "with simple assignment" do
      let(:klass) do
        Class.new(base_class) do
          set :foo

          def foo
            'foo_val'
          end
        end
      end
      it "generates update cql" do
        expect(object.send(:build_update_and_bindings).first).to eq('foo = ?')
      end
      it "generates positional binding from getter method" do
        expect(object.send(:build_update_and_bindings).last).to eq(['foo_val'])
      end
    end

    context "with custom assignment" do
      let(:klass) do
        Class.new(base_class) do
          set :foo, term: 'now()'
        end
      end
      it "generates update cql" do
        expect(object.send(:build_update_and_bindings).first).to eq('foo = now()')
      end
      it "generates no positional binding from getter method" do
        expect(object.send(:build_update_and_bindings).last).to eq([])
      end
    end
  end
end
