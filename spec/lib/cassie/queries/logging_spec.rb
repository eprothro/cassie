RSpec.describe Cassie::Queries::Logging do
  let(:klass) do
    Class.new(Cassie::Query) do
    end
  end
  let(:object) { klass.new }

  describe "subscription" do
    let(:statement){ "statement" }
    let(:klass) do
      Class.new(Cassie::Query) do
        cql "statement"
      end
    end
    let(:execution_info){ double(trace: nil) }

    it "only subscribes once per application" do
      expect(ActiveSupport::Notifications).to receive(:subscribe).at_most(:once)

      a = object.new.execute rescue nil

      class QueryB < Cassie::Query
      end
      b = QueryB.new.execute rescue nil
    end
    it "logs upon execution" do
      logger = double(:debug)
      allow(Cassie::Query).to receive(:logger){ logger }

      expect(logger).to receive(:debug)
      .with(/#{Regexp.quote(statement)}/)

      statement_obj = double(cql: statement)

      ActiveSupport::Notifications.instrument('cql.execute') do |payload|
        payload[:execution_info] = double(statement: statement_obj, trace: nil)
      end
    end

    context "when an exception occurs" do
      it "does not log" do
        expect(Cassie::Query.logger).not_to receive(:debug)

        ActiveSupport::Notifications.instrument('cql.execute') do
          raise StandardError
        end rescue nil
      end
    end
  end
end
