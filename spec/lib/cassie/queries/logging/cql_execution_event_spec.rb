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
  let(:statement){ Cassandra::Statements::Simple.new(cql) }
  let(:cql){ 'some CQL' }
  let(:consistency){ 'some consistency level' }

  describe "#message" do
    it "includes the duration" do
      expect(object.message).to include(duration_ms.to_s)
    end
    it "includes the statement" do
      expect(object.message).to include(cql)
    end
    it "includes the consistency level" do
      expect(object.message).to include(consistency)
    end
  end

end
