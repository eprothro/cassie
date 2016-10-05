require_relative 'session_methods'

module Cassie
  module Testing::Fake::Definition
  end

  class FakeDefinition < Cassie::Definition
    include Cassie::Testing::Fake::SessionMethods

  end
end