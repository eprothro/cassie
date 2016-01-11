#TODO: figure out a better way to do a test harness
class FakeSession
  class FakeBoundStatement
    def bind(*args)
    end
  end
  def execute(*args)
  end
  def prepare(*args)
    FakeBoundStatement.new
  end
end
class Cassie::Query
  def self.session
    FakeSession.new
  end
end

RSpec.describe Cassie::Queries::Statement::Callbacks do
  let(:klass) do
    Class.new(Cassie::Query) do
    end
  end
  let(:succeed?) { true }
  let(:object) do
    o = klass.new
    allow(o).to receive(:execution_successful?){ succeed? }
    o
  end

  describe ".after_failure", :only do
    let(:klass) do
      Class.new(Cassie::Query) do
        after_failure :foo
        def foo
        end
      end
    end

    context "when execute succeeds" do
      it "does not call object method" do
        expect(object).not_to receive(:foo)
        object.execute
      end
    end

    context "when execute fails" do
      let(:succeed?){ false }

      it "calls object method" do
        expect(object).to receive(:foo)
        object.execute
      end
    end
  end
end