RSpec.describe Cassie::Statements::Statement::Relations do
  let(:base_class){ Class.new{ include Cassie::Statements::Statement::Relations } }
  let(:klass) do
    Class.new(base_class) do
    end
  end
  let(:object){ klass.new }
  let(:relation)do
    Cassie::Statements::Statement::Relation.new(object, *object.relations_args.first)
  end

  describe "#where" do
    context "with custom term defintion" do
      let(:klass) do
        Class.new(base_class) do
          where :id, :gteq, term: "minTimeuuid(?)", value: :window_min_timestamp

          def window_min_timestamp
            '2013-02-02 10:00+0000'
          end
        end
      end

      it "uses positional term" do
        expect(relation.term).to eq("minTimeuuid(?)")
      end
      it "is positional" do
        expect(relation.positional?).to be true
      end
      it "has argument" do
        expect(relation.argument).to eq('2013-02-02 10:00+0000')
      end
    end

    context "with simple relation" do
      let(:klass) do
        Class.new(base_class) do
          where :foo, :eq

          def foo
            'foo_val'
          end
        end
      end
      it "generates update cql" do
        expect(object.send(:build_where_and_params).first).to eq('WHERE foo = ?')
      end
      it "generates positional binding from getter method" do
        expect(object.send(:build_where_and_params).last).to eq(['foo_val'])
      end
    end

    context "when value is nil" do
      let(:klass) do
        Class.new(base_class) do
          where :foo, :eq

          def foo
            nil
          end
        end
      end
      it "generates update cql" do
        expect(object.send(:build_where_and_params).first).to eq('WHERE foo = ?')
      end
      it "generates positional binding from getter method" do
        expect(object.send(:build_where_and_params).last).to eq([nil])
      end
    end

    context "with :in operation" do
      let(:klass) do
        Class.new(base_class) do

          where :phone, :in

          def phones
            [1,2]
          end
        end
      end

      it "extracts argument from pluralized getter" do
        expect(relation.argument).to eq([1,2])
      end
    end
    context "when relation sets partition value inline" do
      it "raises exception" do
        expect do
          Class.new(Cassie::FakeQuery) do
            select_from :test
            where :partition, :eq, value: 0

            limit 2
          end
        end.to raise_error(ArgumentError)
      end
    end
  end
end
