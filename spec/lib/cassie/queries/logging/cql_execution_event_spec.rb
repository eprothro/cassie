RSpec.describe Cassie::Queries::Logging::CqlExecutionEvent do
  let(:klass) do
    Cassie::Queries::Logging::CqlExecutionEvent
  end
  let(:object) { klass.new(*args) }
  let(:args) do
    [
      'cql.execute',            #name
      finish - duration_sec,    #start
      finish,                   #finish
      'some_event_id',          #id
      payload                   #payload hash
    ]
  end
  let(:finish) { Time.now }
  let(:duration_sec){ duration_ms / 1000.0 }
  let(:duration_ms){ 1.5 }
  let(:payload){ {execution_info: execution_info} }
  let(:execution_info) { double(statement: statement, consistency: consistency, trace: nil) }
  let(:statement){ Cassandra::Statements::Simple.new(cql, cql_args) }
  let(:cql){ 'some CQL' }
  let(:cql_args){ nil }
  let(:consistency){ 'some consistency level' }

  describe "#message" do
    context "when inspected" do
      it "includes the duration" do
        expect(object.message.inspect).to include(duration_ms.to_s)
      end

      describe "statement and arguments" do
        it "includes the cql" do
          expect(object.message.inspect).to include(cql)
        end
        context "when uuid arg included" do
          let(:cql_args){ {id: uuid} }
          let(:uuid){ Cassandra::TimeUuid::Generator.new.now }

          it "includes the hex string of uuid" do
            expect(object.message.inspect).to include(uuid.to_s)
          end
        end
      end

      it "includes the consistency level" do
        expect(object.message.inspect).to include(consistency.upcase)
      end
    end
  end

end
