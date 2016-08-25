RSpec.describe Cassie::Queries::Logging::Subscription do
  let(:klass) do
    Class.new(Cassie::FakeQuery) do
      select :users
    end
  end
  let(:object) { klass.new }

  describe "subscription" do
    let(:execution_info){ double(trace: nil) }

    it "only subscribes once per application" do
      expect(ActiveSupport::Notifications).to receive(:subscribe).at_most(:once)

      object.execute rescue nil #TODO: fixup so we're not trapping all

      class QueryB < Cassie::FakeQuery
      end
      QueryB.new.execute rescue nil #TODO: fixup so we're not trapping all
    end
  end

  describe "cassie.cql.execution" do
    it "logs upon instrumentation" do
      expect(klass.logger).to receive(:debug)
      .with(duck_type(:inspect))

      ActiveSupport::Notifications.instrument('cassie.cql.execution'){}
    end

    context "when an exception occurs" do
      it "does not log" do
        expect(klass.logger).not_to receive(:debug)

        ActiveSupport::Notifications.instrument('cassie.cql.execution') do
          raise StandardError
        end rescue nil
      end
    end
  end

  describe "cassie.building_resources" do
    it "logs upon instrumentation" do
      expect(klass.logger).to receive(:debug)
      .with(duck_type(:inspect))

      ActiveSupport::Notifications.instrument('cassie.building_resources'){}
    end

    context "when an exception occurs" do
      it "does not log" do
        expect(klass.logger).not_to receive(:debug)

        ActiveSupport::Notifications.instrument('cassie.building_resources') do
          raise StandardError
        end rescue nil
      end
    end
  end
end
