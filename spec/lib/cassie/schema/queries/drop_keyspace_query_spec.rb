RSpec.describe Cassie::Schema::DropKeyspaceQuery do
  let(:klass){ Cassie::Schema::DropKeyspaceQuery }
  let(:object) do
    klass.new(keyspace: keyspace).extend(Cassie::Testing::Fake::SessionMethods)
  end
  let(:keyspace){ 'some_keyspace' }

  describe "#execute" do
    it "defaults timeout to 10 sec" do
      expect(object.session).to receive(:execute).with(object.statement, hash_including({timeout: 10})){[]}
      object.execute
    end

  end
end
