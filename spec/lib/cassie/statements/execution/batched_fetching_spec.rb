RSpec.describe Cassie::Statements::Execution::BatchedFetching do
  let(:base_class){ Cassie::FakeQuery }
  let(:klass) do
    Class.new(base_class) do
      attr_accessor :foo

      select_from :resources_by_tag
    end
  end
  let(:object) do
    object = klass.new
    object.session.rows = rows
    object
  end
  let(:rows){ [row] }
  let(:row){ {tag: 'tag'} }

  describe "#fetch_in_batches" do
    it "calls fetch" do
      fetch_data = object.fetch

      expect(object.fetch_in_batches.first.rows).to eq(fetch_data.rows)
    end
    it "isolates usage of object's stateless_page_size" do
      expect{
        enum = object.fetch_in_batches
        enum.next
      }.not_to change{ object.stateless_page_size }
    end
    it "isolates usage of object's paging_state" do
      expect{
        enum = object.fetch_in_batches
        enum.next
      }.not_to change{ object.paging_state }
    end
    it "isolates usage of enumerator's paging_state" do
        pending "having the harnessing to test this well (fake handling internal pages)"
        enum1 = object.fetch_in_batches
        enum2 = object.fetch_in_batches

        enum1.next
        enum1.next
        state1 = object.result.paging_state

        enum2.next
        expect(state1).not_to eq object.result.paging_state
    end

    context "when there are multiple batches" do
      let(:object) do
        object = klass.new
        object.session.rows = rows
        object
      end
      let(:rows){ [row1, row2, row3] }
      let(:row1){ {tag: 'tag1'} }
      let(:row2){ {tag: 'tag2'} }
      let(:row3){ {tag: 'tag3'} }

      it "fetches every batch" do
        enum = object.fetch_in_batches(batch_size: 1)

        expect(enum.next.map{|h| h[:tag]}).to eq([row1[:tag]])
        expect(enum.next.map{|h| h[:tag]}).to eq([row2[:tag]])
        expect(enum.next.map{|h| h[:tag]}).to eq([row3[:tag]])
        expect{enum.next}.to raise_error(StopIteration)
      end
      it "executes only 1 query per batch" do
        object.fetch_in_batches(batch_size: 1){}

        expect(object.session.query_count).to eq(3)
      end
    end
  end

  describe "#fetch_each" do
    it "enumerates fetch_in_batch" do
      tags = object.fetch_each.map{|e| e.tag}
      expect(tags).to eq(rows.map{|h| h[:tag]})
    end

    context "when there are multiple batches" do
      let(:object) do
        object = klass.new
        object.session.rows = rows
        object
      end
      let(:rows){ [row1, row2, row3] }
      let(:row1){ {tag: 'tag1'} }
      let(:row2){ {tag: 'tag2'} }
      let(:row3){ {tag: 'tag3'} }

      it "enumerates every element" do
        tags = object.fetch_each(batch_size: 1).map{|e| e.tag}
        expect(tags).to eq(rows.map{|h| h[:tag]})
      end
    end
  end
end
