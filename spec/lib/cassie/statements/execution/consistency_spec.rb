RSpec.describe Cassie::Statements::Execution::Consistency do
  let(:base_class)do
    Class.new do
      include Cassie::Statements::Execution::Consistency
    end
  end
  let(:subclass){ Class.new(base_class) }
  let(:object) { subclass.new }
  let(:consistency){ Cassandra::CONSISTENCIES.sample }
  let(:default_consistency){ nil }

  before(:each){ @original = Cassie::Statements.default_consistency }
  after(:each){ Cassie::Statements.default_consistency = @original }
  describe "BaseClass" do
    describe ".consistency" do
      it "defaults to nil" do
        expect(base_class.consistency).to eq(default_consistency)
      end

      context "when set" do
        it "overrides default" do
          base_class.consistency = consistency
          expect(base_class.consistency).to eq(consistency)
        end
      end
    end
  end

  describe "SubClass" do
    describe ".consistency" do
      it "defaults to base default" do
        expect(subclass.consistency).to eq(default_consistency)
      end

      context "when base class has been set" do
        before(:each) { base_class.consistency = consistency }

        it "inherits base class setting" do
          expect(subclass.consistency).to eq(consistency)
        end
      end

      context "when set with setter" do
        before(:each){ subclass.consistency = consistency }

        it "overrides default" do
          expect(subclass.consistency).to eq(consistency)
        end
        it "doesn't change base class" do
          expect(base_class.consistency).to eq(default_consistency)
        end
      end

      context "when set with getter for DSL feel" do
        before(:each){ subclass.consistency(consistency) }

        it "overrides default" do
          expect(subclass.consistency).to eq(consistency)
        end
        it "doesn't change base class" do
          expect(base_class.consistency).to eq(default_consistency)
        end
      end

      context "when overwritten" do
        let(:consistency){ :three }
        let(:subclass) do
          Class.new(base_class) do
            def self.consistency
              :three
            end
          end
        end

        it "overrides base class setting" do
          expect(subclass.consistency).to eq(consistency)
        end
        it "doesn't change base class" do
          expect(base_class.consistency).to eq(default_consistency)
        end
      end
    end

    describe "#consistency" do
      it "defaults to base_class value" do
        expect(object.consistency).to eq(default_consistency)
      end

      context "when set" do
        before(:each){ object.consistency = consistency }

        it "overrides default" do
          expect(object.consistency).to eq(consistency)
        end
        it "doesn't change subclass" do
          expect(subclass.consistency).to eq(default_consistency)
        end
        it "doesn't change base class" do
          expect(base_class.consistency).to eq(default_consistency)
        end

        context "when .consistency overwritten" do
          let(:consistency){ :three }
          let(:subclass) do
            Class.new(base_class) do
              def self.consistency
                :three
              end
            end
          end

          it "uses object value" do
            expect(object.consistency).to eq(consistency)
          end
        end
      end
    end
  end

  describe "Cassie::Statements::default_consistency" do
    it "is nil" do
      expect(Cassie::Statements.default_consistency).to be_nil
    end
    it "can be set" do
      expect{Cassie::Statements.default_consistency = consistency}.to change{Cassie::Statements.default_consistency}.to(consistency)
    end
    it "is fallback for class including consistency" do
      Cassie::Statements.default_consistency = consistency
      expect(base_class.consistency).to eq(consistency)
    end
  end
end
