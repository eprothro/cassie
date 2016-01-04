RSpec.describe "Cassie Queries" do

  it "adds support for inheriting from cassie query" do
    expect(Cassie::Query).to be_a_kind_of(Class)
  end
end
