require_relative 'session'

module Cassie::Testing::Fake
  module Query
    def self.extended(extender)
      return if extender.class === Class

      # object has been extended (as opposed to class)
      # memoize the fake session in metaclass for this object
      # as we don't want to change behavior of _every_ object
      # instantiated from the class, only _this_ object
      extender.class.define_singleton_method(:session) do
        @session ||= Session.new
      end

      # overwrite definition from extension
      # to delegate to class definition to
      # minimize difference from vanilla Query
      def extender.session
        self.class.session
      end
    end

    def session
      @session ||= Session.new
    end
  end
end