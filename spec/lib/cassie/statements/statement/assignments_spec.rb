RSpec.describe Cassie::Statements::Statement::Assignments do
  let(:base_class){ Cassie::FakeModification }
  let(:klass) do
    Class.new(base_class) do
      set :foo
    end
  end
  let(:object) { klass.new }

  describe "set"  do
    it "provides a getter" do
      expect(object.foo).to be_nil
    end
    it "provides a setter" do
      expect{object.foo = 2}.to change{object.foo}.to 2
    end

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
