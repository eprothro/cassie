require_relative 'session_methods'

module Cassie
  module Testing::Fake::Query
  end

  class FakeQuery < Cassie::Query
    extend Cassie::Testing::Fake::SessionMethods
  end
end