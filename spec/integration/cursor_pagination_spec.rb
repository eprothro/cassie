RSpec.describe Cassie::Statements::Statement::Pagination::Cursors do
  let(:klass) do
    class Events < Cassie::Query
      cql %(
        SELECT * from events
        WHERE user_id = ?;
      )

      attr_accessor :user

      def initialize(opts = {})
        @user = opts[:user]
      end

      def bindings
        [user.id]
      end
    end
  end
  let(:object) { klass.new }

  before(:all) do
    setup_events(users: [current_user, other_user],
                 events_per_user: 10 )
  end
  after(:all){ truncate_events }

  describe "getting most recent events" do

    context "when there are no new events" do
    end
  end

  describe "paging through all events" do
  end

end
