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
        expect(object.send(:build_update_and_params).first).to eq('foo = ?')
      end
      it "generates positional binding from getter method" do
        expect(object.send(:build_update_and_params).last).to eq(['foo_val'])
      end
    end

    context "when value is nil" do
      let(:klass) do
        Class.new(base_class) do
          set :foo

          def foo
            nil
          end
        end
      end
      it "generates update cql" do
        expect(object.send(:build_update_and_params).first).to eq('foo = ?')
      end
      it "generates update positional binding from getter method" do
        expect(object.send(:build_update_and_params).last).to eq([nil])
      end
      it "generates insert cql" do
        expect(object.send(:build_insert_and_params).first).to eq('foo')
        expect(object.send(:build_insert_and_params)[1]).to eq('?')
      end
      it "generates insert positional binding from getter method" do
        expect(object.send(:build_insert_and_params)[2]).to eq([nil])
      end
    end

    context "with if option" do
      let(:klass) do
        Class.new(base_class) do
          set :foo, if: :check

          def check
            false
          end
        end
        it "doesn't "
        expect(object.send(:build_insert_and_params).first).to eq('foo')
      end
    end

    context "with custom assignment" do
      let(:klass) do
        Class.new(base_class) do
          set :foo, term: 'now()'
        end
      end
      it "generates update cql" do
        expect(object.send(:build_update_and_params).first).to eq('foo = now()')
      end
      it "generates no positional binding from getter method" do
        expect(object.send(:build_update_and_params).last).to eq([])
      end
    end
  end
end
