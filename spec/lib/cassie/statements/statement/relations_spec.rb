RSpec.describe Cassie::Statements::Statement::Relations do
  let(:base_class){ Class.new{ include Cassie::Statements::Statement::Relations } }
  let(:klass) do
    Class.new(base_class) do
    end
  end
  let(:object){ klass.new }
  let(:relation)do
    relation = object.relations.first
    relation.bind(object)
    relation
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
  end
end
