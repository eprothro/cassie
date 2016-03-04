require_relative 'session'

module Cassie::Testing::Fake
  module SessionMethods

    def session(_keyspace=self.keyspace)
      @session ||= Cassie::Testing::Fake::Session.new
    end
  end
end