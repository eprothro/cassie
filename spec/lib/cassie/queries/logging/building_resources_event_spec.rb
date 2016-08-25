RSpec.describe Cassie::Queries::Logging::BuildingResourcesEvent do
  let(:klass) do
    Cassie::Queries::Logging::BuildingResourcesEvent
  end
  let(:object) { klass.new(*args) }
  let(:args) do
    [
      'cassie.building_resources',   #name
      finish - duration_sec,            #start
      finish,                           #finish
      'some_event_id',                  #id
      payload                           #payload hash
    ]
  end
  let(:finish) { Time.now }
  let(:duration_sec){ duration_ms / 1000.0 }
  let(:duration_ms){ 1.5 }
  let(:payload){ {count: count} }
  let(:count) { rand(100) }

  describe "#message" do
    context "when inspected" do
      it "includes the duration" do
        expect(object.message.inspect).to include(duration_ms.to_s)
      end
      it "includes the count" do
        expect(object.message.inspect).to include(count.to_s)
      end
    end
  end

end
