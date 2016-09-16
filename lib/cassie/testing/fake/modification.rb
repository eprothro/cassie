require_relative 'session_methods'

module Cassie
  module Testing::Fake::Modification
  end

  class FakeModification < Cassie::Modification
    include Cassie::Testing::Fake::SessionMethods

  end
end