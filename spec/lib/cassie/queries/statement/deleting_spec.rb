RSpec.describe Cassie::Queries::Statement::Deleting do
  let(:base_class){ Cassie::FakeQuery }
  let(:klass) do
    Class.new(base_class) do
      attr_accessor :foo

      delete :resources_by_tag
    end
  end
  let(:object) do
      o = klass.new
      allow(o).to receive(:execute)
      allow(o).to receive(:result){ double(empty?: true, rows: []) }
      o
  end
  let(:resource){ double }

  describe "#delete" do
    context "when overridden" do
      let(:klass) do
        Class.new(base_class) do
          delete :resources

          def delete(opts={})
            super
            "foo"
          end
        end
      end
      it "can call deleting's defintion with super" do
        expect(object).to receive(:execute)
        object.delete
      end
      it "can return its own value" do
        expect(object.delete).to eq("foo")
      end
    end
  end
end
