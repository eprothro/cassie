RSpec.describe Cassie::Queries::Logging do
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
    it "logs upon execution" do
      expect(klass.logger).to receive(:debug)
      .with(/#{Regexp.quote(object.statement.cql)}/)

      object.execute
    end

    context "when an exception occurs" do
      it "does not log" do
        expect(Cassie::FakeQuery.logger).not_to receive(:debug)

        ActiveSupport::Notifications.instrument('cql.execute') do
          raise StandardError
        end rescue nil
      end
    end
  end
end
