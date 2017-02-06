require 'cassie/tasks'

RSpec.describe Cassie::Tasks::TaskRunner do
  let(:klass){ Cassie::Tasks::TaskRunner }
  let(:object){ klass.new }
  let(:args){ Array(command) + params }
  let(:params){ [] }
  let(:command){ nil }

  describe "#run_command" do
    def run
      object.run_command(args)
    end
    context "with schema:drop" do
      let(:command){ "schema:drop" }

      it "calls drop_schema" do
        expect(object).to receive(:drop_schema)
        run
      end
    end
  end

  describe "drop_schema" do
  end
end