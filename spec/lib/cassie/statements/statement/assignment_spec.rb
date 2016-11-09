RSpec.describe Cassie::Statements::Statement::Assignment do
  let(:execution) do
    double(id: argument, if_meth: false, term_meth: "now()")
  end
  let(:argument){ double }
  let(:klass){ Cassie::Statements::Statement::Assignment }
  let(:args){ [identifier, value_method, opts] }
  let(:identifier){ :id }
  let(:operation){ :eq }
  let(:value_method){ :id }
  let(:opts){ {} }
  let(:object){ klass.new(execution, *args) }

  describe "#enabled?" do
    it "is true" do
      expect(object.enabled?).to be true
    end
    context "with if false value" do
      let(:opts){ {if: false} }
      it "is false" do
        expect(object.enabled?).to be false
      end
    end
    context "with if method" do
      let(:opts){ {if: :if_meth} }
      it "is calls method" do
        expect(object.enabled?).to be false
      end
    end
  end

  describe "#to_update_cql" do
    it "is relation syntax with positional placeholder" do
      expect(object.to_update_cql).to eq("id = ?")
    end
    context "when disabled" do
      let(:opts){ {if: false} }
      it "is nil" do
        expect(object.to_update_cql).to be_nil
      end
    end
  end

  describe "#argument" do
    it "is relation syntax with positional placeholder" do
      expect(object.argument).to eq(argument)
    end
    context "when disabled" do
      let(:opts){ {if: false} }
      it "is nil" do
        expect(object.argument).to be_nil
      end
    end
    context "when non positional" do
      before(:each){ allow(object).to receive(:positional?){false} }
      it "is nil" do
        expect(object.argument).to be_nil
      end
    end
  end

  describe "#argument?" do
    context "when disabled" do
      let(:opts){ {if: false} }
      it "is nil" do
        expect(object.argument?).to be_falsy
      end
    end
    context "when non positional" do
      before(:each){ allow(object).to receive(:positional?){false} }
      it "is nil" do
        expect(object.argument?).to be_falsy
      end
    end
  end

  describe "#term" do
    it "is ?" do
      expect(object.term).to eq("?")
    end
    context "with term value" do
      let(:opts){ {term: "test"} }
      it "is value" do
        expect(object.term).to eq("test")
      end
    end
    context "with term method" do
      let(:opts){ {term: :term_meth} }
      it "is calls method" do
        expect(object.term).to eq("now()")
      end
    end
  end

  describe "#positional?" do
    it "is true" do
      expect(object.positional?).to be true
    end
    context "with positional term value" do
      let(:opts){ {term: "minTimeuuid(?)"} }
      it "is true" do
        expect(object.positional?).to be true
      end
    end
    context "with non-positional term value" do
      let(:opts){ {term: "now()"} }
      it "is calls method" do
        expect(object.positional?).to be false
      end
    end
  end
end